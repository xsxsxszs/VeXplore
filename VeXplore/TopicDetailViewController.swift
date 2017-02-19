//
//  TopicDetailViewController.swift
//  VeXplore
//
//  Copyright © 2016 Jimmy. All rights reserved.
//

import WebKit

protocol TopicDetailViewControllerDelegate: class
{
    func showMoreIcon()
    func isUnfavoriteTopic(_ unfavorite: Bool) // if unfavorite topic
}

class TopicDetailViewController: BaseTableViewController, TopicDetailDelegate, WKNavigationDelegate
{
    var topicId = R.String.Zero
    var topicDetailModel: TopicDetailModel!
    var token: String?
    private var contentView = TopicDetailContentView()
    private var lastContentCellHeight: CGFloat?
    weak var delegate: TopicDetailViewControllerDelegate?
    weak var inputVC: TopicReplyingViewController!
    var webViewReloadCount: UInt8 = 0
    
    override func viewDidLoad()
    {
        contentView.contentWebView.scrollView.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
        super.viewDidLoad()
        tableView.register(TopicDetailHeaderCell.self, forCellReuseIdentifier: String(describing: TopicDetailHeaderCell.self))
        contentView.contentWebView.navigationDelegate = self
        initTopLoading()
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleContentSizeCategoryDidChanged), name: NSNotification.Name.UIContentSizeCategoryDidChange, object: nil)
    }
    
    deinit
    {
        contentView.contentWebView.scrollView.removeObserver(self, forKeyPath: "contentSize")
    }
    
    @objc
    private func handleContentSizeCategoryDidChanged()
    {
        prepareForReuse()
    }
    
    override func prepareForReuse()
    {
        super.prepareForReuse()
        contentView.load(with: topicDetailModel)
    }
    
    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey : Any]?,
                               context: UnsafeMutableRawPointer?)
    {
        if let change = change, let newContentSize = change[.newKey] as? NSValue
        {
            contentView.contentHeight = newContentSize.cgSizeValue.height
            if let lastContentCellHeightUnwrap = lastContentCellHeight, lastContentCellHeightUnwrap == contentView.contentHeight
            {
                return
            }
            lastContentCellHeight = contentView.contentHeight
            contentView.frame = CGRect(origin: .zero, size: CGSize(width: tableView.bounds.width, height: contentView.contentHeight))
            tableView.tableFooterView = contentView
        }
    }
    
    override func topLoadingRequest()
    {
        V2Request.Topic.getDetail(withTopicId: topicId) { [weak self] (response) in
            guard let weakSelf = self else {
                return
            }
            
            weakSelf.stopLoading(withLoadingStyle: .top, success: response.success, completion: { (success) -> Void in
                if success, let topicDetailModel = response.value
                {
                    weakSelf.topicDetailModel = topicDetailModel
                    weakSelf.delegate?.showMoreIcon()
                    weakSelf.tableView.reloadData()
                    
                    UIView.animate(withDuration: R.Constant.InsetAnimationDuration, delay: 0, options: .beginFromCurrentState, animations: {
                        weakSelf.tableView.contentInset = .zero
                        }, completion: { (_) in
                            if User.shared.isLogin
                            {
                                let preferences = UserDefaults.standard
                                if preferences.bool(forKey: R.Key.EnablePullReply)
                                {
                                    weakSelf.topReminderLabel.text = R.String.PullToReplyTopic
                                    weakSelf.topReminderLabel.isHidden = false
                                }
                                else
                                {
                                    let enableShake = preferences.object(forKey: R.Key.EnableShake) as? NSNumber
                                    if enableShake?.boolValue != false
                                    {
                                        weakSelf.topReminderLabel.text = R.String.ShakeToRepleyTopic
                                        weakSelf.topReminderLabel.isHidden = false
                                    }
                                }
                            }
                            weakSelf.tableView.tableHeaderView = nil
                            weakSelf.contentView.load(with: weakSelf.topicDetailModel)
                    })
                    weakSelf.isTopLoadingFail = false
                    weakSelf.enableTopLoading = false
                }
                else
                {
                    if response.message.count > 0, response.message[0] == R.String.NeedLoginError
                    {
                        weakSelf.topMessageLabel.text = R.String.NeedLoginToViewThisTopic
                        weakSelf.topMessageLabel.isHidden = false
                        weakSelf.topLoadingView.isHidden = true
                        weakSelf.tableView.tableFooterView = nil
                        User.shared.logout()
                    }
                    weakSelf.isTopLoadingFail = true
                }
                weakSelf.isTopLoading = false
            })
        }
    }
    
    
    // MARK: - UITableViewDataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return topicDetailModel != nil ? 1 : 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: TopicDetailHeaderCell.self), for: indexPath) as! TopicDetailHeaderCell
        guard let topicDetailModel = topicDetailModel else {
            return cell
        }
        cell.topicDetailModel = topicDetailModel
        if let avatar = topicDetailModel.avatar, let url = URL(string: R.String.Https + avatar)
        {
            cell.avatarImageView.avatarImage(withURL: url)
        }
        cell.topicTitleLabel.text = topicDetailModel.topicTitle
        cell.userNameLabel.text = topicDetailModel.username
        cell.nodeNameBtn.setTitle(topicDetailModel.nodeName, for: .normal)
        cell.dateLabel.text = topicDetailModel.date
        cell.favoriteNumLabel.text = topicDetailModel.favoriteNum ?? R.String.NoFavorite
        if topicDetailModel.topicCommentTotalCount != nil
        {
            cell.repliesNumberLabel.text = topicDetailModel.topicCommentTotalCount
        }
        if let token = topicDetailModel.token, token.isEmpty == false
        {
            cell.favoriteContainerView.isHidden = false
        }
        cell.likeImageView.tintColor = topicDetailModel.isFavorite ? .lightPink : .middleGray
        cell.delegate = self
        return cell
    }
    
    // MARK: - UITableViewDelegate
    lazy private var heightCell: TopicDetailHeaderCell = {
        let cell = TopicDetailHeaderCell()
        cell.bounds = self.tableView.bounds
        cell.autoresizingMask = [.flexibleWidth]
        
        return cell
    }()
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        heightCell.prepareForReuse()
        heightCell.topicTitleLabel.text = topicDetailModel.topicTitle
        heightCell.userNameLabel.text = R.String.Placeholder
        heightCell.dateLabel.text = R.String.Placeholder
        heightCell.setNeedsLayout()
        heightCell.layoutIfNeeded()
        let height = ceil(heightCell.contentView.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height)
        return height
    }

    // MARK: - TopicDetailDelegate
    func favoriteBtnTapped()
    {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        refreshTopicToken(completion: { [weak self] (token) in
            guard let weakSelf = self else {
                return
            }
            
            if let topicId = weakSelf.topicDetailModel.topicId
            {
                V2Request.Topic.favoriteTopic(!weakSelf.topicDetailModel.isFavorite, topicId: topicId, token: token, completionHandler: { (response) in
                    if response.success
                    {
                        weakSelf.refreshPage(completion: { (success) in
                            if success == true
                            {
                                weakSelf.delegate?.isUnfavoriteTopic(!weakSelf.topicDetailModel.isFavorite)
                                dispatch_async_safely_to_main_queue {
                                    weakSelf.tableView.reloadData()
                                }
                            }
                            UIApplication.shared.isNetworkActivityIndicatorVisible = false
                        })
                    }
                    else
                    {
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    }
                })
            }
            else
            {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        })
    }
    
    private func refreshPage(completion: @escaping (Bool) -> Void )
    {
        V2Request.Topic.getDetail(withTopicId: topicId, completionHandler: { [weak self] (response) in
            guard let weakSelf = self else {
                return
            }
            
            if response.success, let topicDetailModel = response.value
            {
                weakSelf.topicDetailModel = topicDetailModel
            }
            completion(response.success)
        })
    }
    
    private func refreshTopicToken(completion: @escaping (String) -> Void )
    {
        V2Request.Topic.getDetail(withTopicId: topicId, completionHandler: { (response) in
            if response.success,
                let topicDetailModel = response.value,
                let topicDetailModelUnwrap = topicDetailModel,
                let token = topicDetailModelUnwrap.token
            {
                completion(token)
            }
            else
            {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        })
    }
    
    // MARK: - WKNavigationDelegate
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void)
    {
        if let list = navigationAction.request.url?.absoluteString.components(separatedBy: "/special_tag_for_image_tap_vexplore/"),
            list.count == 6,
            let offsetX = Float(list[1]),
            let offsetY = Float(list[2]),
            let width = Float(list[3]),
            let height = Float(list[4])
        {
            if let superview = view.superview, superview is UIScrollView
            {
                let superContentScrollView = superview as! UIScrollView
                if superContentScrollView.contentOffset.x <= 0
                {
                    let imageKey = list[5]
                    let frame = CGRect(x: CGFloat(offsetX), y: CGFloat(offsetY), width: CGFloat(width), height: CGFloat(height))
                    var imageInfo = ImageInfo()
                    ImageCache.default.retrieveImage(forKey: imageKey, completionHandler: { image in
                        if image != nil
                        {
                            dispatch_async_safely_to_main_queue {
                                imageInfo.image = image
                                imageInfo.referenceRect = frame
                                imageInfo.referenceView = webView.scrollView
                                let imageVC = ImageViewingController(imageInfo: imageInfo)
                                imageVC.presented(by: self)
                                decisionHandler(.cancel)
                                return
                            }
                        }
                    })
                }
            }
        }
        
        // load from local
        if navigationAction.navigationType == .other
        {
            decisionHandler(.allow)
            return
        }
        else if navigationAction.navigationType == .linkActivated
        {
            if let url = navigationAction.request.url?.absoluteString, URLAnalyzer.Analyze(url: url, handleViewController: self) == true
            {
                decisionHandler(.cancel)
            }
            decisionHandler(.allow)
            return
        }
        decisionHandler(.cancel)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!)
    {
        for urlString in contentView.imgSrcArray
        {
            if let url = URL(string: urlString)
            {
                if ImageCache.default.isImageCachedInDisk(forKey: urlString)
                {
                    self.replaceWebImage(withImageKey: urlString)
                }
                else
                {
                    ImageDownloader.default.downloadImage(with: url, completionHandler: { [weak self] (image, originalData, error) -> () in
                        guard let weakSelf = self else {
                            return
                        }
                        
                        if let image = image
                        {
                            ImageCache.default.cache(image: image, originalData: originalData, forKey: urlString, completionHandler: {
                                weakSelf.replaceWebImage(withImageKey: urlString)
                            })
                        }
                    })
                }
            }
        }
    }
    
    func webViewWebContentProcessDidTerminate(_ webView: WKWebView)
    {
        // Topic detail may be truncated due to WebKit crash.
        // Try to reload webView if crash.
        // If web view load wrong content, it will keep crashing and reloading.
        // Stop reloading web view if the reload count exceeds 32 times.
        guard webViewReloadCount < 0x20  else {
            return
        }
        webViewReloadCount += 1
        contentView.load(with: topicDetailModel)
    }
    
    private func replaceWebImage(withImageKey imageKey: String)
    {
        if ImageCache.default.isImageCachedInDisk(forKey: imageKey)
        {
            let replaceImageScriptTemplate = try! String(contentsOfFile: Bundle.main.path(forResource: "ImageReplace", ofType: "js")!, encoding: .utf8)
            let imageCachedUrl = "file://" + ImageCache.default.cachePath(forKey: imageKey)
            let replaceImageScript = String(format: replaceImageScriptTemplate, imageKey, imageCachedUrl)
            contentView.contentWebView.evaluateJavaScript(replaceImageScript, completionHandler: { (object, error) in
                if error != nil
                {
                    print(error.debugDescription)
                }
            })
        }
    }
    
    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool)
    {
        if enableTopLoading == false, User.shared.isLogin
        {
            let offset = -scrollView.contentOffset.y
            let preferences = UserDefaults.standard
            if offset > R.Constant.LoadingViewHeight, preferences.bool(forKey: R.Key.EnablePullReply)
            {
                inputVC.topicId = topicId
                present(inputVC, animated: true, completion: nil)
                return
            }
        }
        super.scrollViewDidEndDragging(scrollView, willDecelerate: decelerate)
    }
    
}
