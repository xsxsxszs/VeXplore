//
//  NodeTopicListViewController.swift
//  VeXplore
//
//  Copyright © 2016 Jimmy. All rights reserved.
//


class NodeTopicListViewController: TopicListViewController
{
    var node: NodeModel? {
        didSet
        {
            if let nodeId = node?.nodeId, nodeId.isEmpty == false
            {
                self.nodeId = nodeId
            }
        }
    }
    
    private var currentPage = 1
    private var totalPageNum = 1
    private var isFavorite = false
    private var favoriteActionUrl: String?
    var nodeId: String?
    weak var favoriteNodesVC: FavoriteNodesViewController?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        enableBottomLoading = false
        if User.shared.isLogin
        {
            let favoriteBtn = UIBarButtonItem(image: R.Image.Favorite, style: .plain, target: self, action: #selector(favoriteBtnTapped))
            favoriteBtn.tintColor = .middleGray
            navigationItem.rightBarButtonItem = favoriteBtn
        }
        let closeBtn = UIBarButtonItem(image: R.Image.Close, style: .plain, target: self, action: #selector(closeBtnTapped))
        closeBtn.tintColor = .middleGray
        navigationItem.leftBarButtonItem = closeBtn
    }
    
    @objc
    private func closeBtnTapped()
    {
        dismiss(animated: true, completion: nil)
    }
    
    @objc
    private func favoriteBtnTapped()
    {
        if let url = favoriteActionUrl
        {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            V2Request.Node.favoriteNode(withURL: url, completionHandler: { (response) in
                if response.success
                {
                    self.isFavorite = !self.isFavorite
                    self.navigationItem.rightBarButtonItem?.tintColor = self.isFavorite ? .lightPink : .middleGray
                    if let favoriteNodesVC = self.favoriteNodesVC, self.isFavorite == false
                    {
                        favoriteNodesVC.nodeToDelete = self.nodeId
                    }
                }
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            })
        }
    }
    
    // MARK: - Loading request
    override func topLoadingRequest()
    {
        guard let nodeId = nodeId, nodeId.isEmpty == false else {
            return
        }
        
        V2Request.Node.getTopicList(withNodeId: nodeId, page: 1) { [weak self] (response) in
            guard let weakSelf = self else {
                return
            }
            
            weakSelf.stopLoading(withLoadingStyle: .top, success: response.success, completion: { (success) -> Void in
                if success, let value = response.value
                {
                    weakSelf.topicList = value.0
                    weakSelf.isFavorite = value.1
                    weakSelf.totalPageNum = value.2
                    weakSelf.favoriteActionUrl = value.3
                    // set title
                    if let nodeName = value.4, nodeName.isEmpty == false
                    {
                        weakSelf.title = nodeName
                    }
                    if weakSelf.isFavorite
                    {
                        weakSelf.navigationItem.rightBarButtonItem?.tintColor = .lightPink
                    }
                    weakSelf.currentPage = 2
                    if weakSelf.currentPage > weakSelf.totalPageNum
                    {
                        weakSelf.enableBottomLoading = false
                    }
                    else
                    {
                        weakSelf.tableView.tableFooterView = weakSelf.tableFooterView
                        weakSelf.enableBottomLoading = true
                        weakSelf.bottomLoadingView.initSquaresNormalPostion()
                    }
                    weakSelf.tableView.reloadData()
                    UIView.animate(withDuration: R.Constant.InsetAnimationDuration, delay: 0, options: .beginFromCurrentState, animations: {
                        weakSelf.tableView.contentInset = .zero
                        }, completion: { (_) in
                            weakSelf.tableView.tableHeaderView = nil
                    })
                    weakSelf.isTopLoadingFail = false
                    weakSelf.enableTopLoading = false
                    weakSelf.programaticScrollEnabled = true
                }
                else
                {
                    if response.message.count > 0 && response.message[0] == R.String.NeedLoginError
                    {
                        weakSelf.topMessageLabel.text = R.String.NeedLoginToViewThisNode
                        weakSelf.topMessageLabel.isHidden = false
                        weakSelf.topLoadingView.isHidden = true
                        User.shared.logout()
                    }
                    else
                    {
                        weakSelf.programaticScrollEnabled = false
                    }
                    weakSelf.isTopLoadingFail = true
                }
                weakSelf.isTopLoading = false
            })
        }
    }
    
    override func bottomLoadingRequest()
    {
        guard let nodeId = nodeId, nodeId.isEmpty == false else {
            return
        }
        
        V2Request.Node.getTopicList(withNodeId: nodeId, page: currentPage) { [weak self] (response) in
            guard let weakSelf = self else {
                return
            }
            
            weakSelf.stopLoading(withLoadingStyle: .bottom, success: response.success, completion: { (success) -> Void in
                if success, let value = response.value
                {
                    weakSelf.topicList.append(contentsOf: value.0)
                    weakSelf.currentPage += 1
                    if weakSelf.currentPage > weakSelf.totalPageNum
                    {
                        weakSelf.tableView.tableFooterView = nil
                        weakSelf.enableBottomLoading = false
                    }
                    weakSelf.tableView.reloadData()
                    weakSelf.isBottomLoadingFail = false
                }
                else
                {
                    weakSelf.isBottomLoadingFail = true
                }
                weakSelf.isBottomLoading = false
            })
        }
    }
    
    // MARK: - UITableViewDataSource
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: TopicCell.self), for: indexPath) as! TopicCell
        let topicItem = topicList[indexPath.row]
        cell.topicItemModel = topicItem
        cell.topicTitleLabel.text = topicItem.topicTitle
        cell.userNameLabel.text = topicItem.username
        cell.nodeNameBtn.isHidden = true
        if topicItem.repliesNumber != nil
        {
            cell.repliesNumberLabel.text = topicItem.repliesNumber
        }
        if let avatar = topicItem.avatar, let url = URL(string: R.String.Https + avatar)
        {
            cell.avatarImageView.avatarImage(withURL: url)
        }
        if let lastReplyUserName = topicItem.lastReplyUserName, lastReplyUserName.isEmpty == false
        {
            cell.lastReplayDateAndUserLabel.text = topicItem.lastReplyDate
        }
        else
        {
            cell.lastReplayDateAndUserLabel.text = String(format: R.String.PublicDate, topicItem.lastReplyDate ?? R.String.Empty)
        }
        cell.delegate = self
        return cell
    }
    
    // MARK: - UITableViewDelegate
    lazy private var heightCell: TopicCell = {
        let cell = TopicCell()
        cell.bounds = self.tableView.bounds
        cell.autoresizingMask = [.flexibleWidth]
        
        return cell
    }()
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        heightCell.prepareForReuse()
        let model = topicList[indexPath.row]
        heightCell.topicTitleLabel.text = model.topicTitle
        heightCell.userNameLabel.text = R.String.Placeholder
        heightCell.lastReplayDateAndUserLabel.text = R.String.Placeholder
        heightCell.setNeedsLayout()
        heightCell.layoutIfNeeded()
        let height = ceil(heightCell.contentView.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height)
        return height
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView)
    {
        guard isTopLoadingFail == false else{
            scrollView.bounces = true
            return
        }
        super.scrollViewDidScroll(scrollView)
    }
    
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView)
    {
        guard isTopLoadingFail == false else{
            scrollView.bounces = true
            return
        }
        super.scrollViewDidEndDecelerating(scrollView)
    }
    
}
