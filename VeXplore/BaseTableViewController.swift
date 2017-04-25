//
//  BaseTableViewController.swift
//  SquaresLoading
//
//  Copyright © 2016 Jimmy. All rights reserved.
//

import MessageUI
import SharedKit

class BaseTableViewController: SwipeTransitionViewController, UITableViewDataSource, UITableViewDelegate, SquareLoadingViewDelegate, TopicCellDelegate, MFMailComposeViewControllerDelegate
{
    lazy var tableHeaderView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.width, height: 0))
        view.autoresizingMask = .flexibleWidth
        
        return view
    }()
    
    lazy var tableFooterView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.width, height: 0))
        view.autoresizingMask = .flexibleWidth
        
        return view
    }()
    
    lazy var topLoadingView: SquaresLoadingView = {
        let view = SquaresLoadingView(loadingStyle: LoadingStyle.top)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    lazy var bottomLoadingView: SquaresLoadingView = {
        let view = SquaresLoadingView(loadingStyle: LoadingStyle.bottom)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.delegate = self
        
        return view
    }()
    
    lazy var topReminderLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = R.Font.Small
        label.textColor = .border
        label.isHidden = true
        
        return label
    }()
    
    lazy var topMessageLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = R.Font.Small
        label.textColor = .desc
        label.isHidden = true
        
        return label
    }()
    
    lazy var centerMessageLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = R.Font.Small
        label.textColor = .desc
        label.isHidden = true
        
        return label
    }()
    
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: self.view.bounds, style: .plain)
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = .background

        return tableView
    }()
    
    var topicList = [TopicItemModel]()
    var isTopLoading = false
    var enableBottomLoading = false
    var enableTopLoading = true
    var isBottomLoading = false
    var isTopLoadingFail = false
    var isBottomLoadingFail = false
    var request: Request?
    
    init()
    {
        super.init(nibName: nil, bundle: nil)
    }
    
    override func encode(with aCoder: NSCoder)
    {
        aCoder.encode(topicList, forKey: "topicList")
    }
    
    required convenience init?(coder aDecoder: NSCoder)
    {
        self.init()
        topicList = aDecoder.decodeObject(forKey: "topicList") as! [TopicItemModel]
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        tableHeaderView.addSubview(topLoadingView)
        tableHeaderView.addSubview(topMessageLabel)
        tableFooterView.addSubview(bottomLoadingView)
        let bindings = [
            "topLoadingView": topLoadingView,
            "bottomLoadingView": bottomLoadingView
        ]
        tableHeaderView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[topLoadingView]|", metrics: nil, views: bindings))
        topLoadingView.bottomAnchor.constraint(equalTo: tableHeaderView.bottomAnchor).isActive = true
        topLoadingView.heightAnchor.constraint(equalToConstant: R.Constant.LoadingViewHeight).isActive = true
        
        tableFooterView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[bottomLoadingView]|", metrics: nil, views: bindings))
        bottomLoadingView.topAnchor.constraint(equalTo: tableFooterView.topAnchor).isActive = true
        bottomLoadingView.heightAnchor.constraint(equalToConstant: R.Constant.LoadingViewHeight).isActive = true
        
        tableView.addSubview(centerMessageLabel)
        tableView.addSubview(topReminderLabel)
        view.addSubview(tableView)
        topMessageLabel.centerXAnchor.constraint(equalTo: tableHeaderView.centerXAnchor).isActive = true
        topMessageLabel.centerYAnchor.constraint(equalTo: tableHeaderView.centerYAnchor).isActive = true
        centerMessageLabel.centerXAnchor.constraint(equalTo: tableView.centerXAnchor).isActive = true
        centerMessageLabel.centerYAnchor.constraint(equalTo: tableView.centerYAnchor).isActive = true
        topReminderLabel.centerXAnchor.constraint(equalTo: tableView.centerXAnchor).isActive = true
        topReminderLabel.bottomAnchor.constraint(equalTo: tableView.topAnchor, constant: -32.0).isActive = true
        
        tableView.tableHeaderView = tableHeaderView
        topLoadingView.initSquaresPosition()
        bottomLoadingView.initSquaresPosition()
        
        refreshColorScheme()
        
        NotificationCenter.default.addObserver(self, selector: #selector(refreshColorScheme), name: NSNotification.Name.Setting.NightModeDidChange, object: nil)
    }
    
    @objc
    private func refreshColorScheme()
    {
        navigationController?.navigationBar.setupNavigationbar()
        topReminderLabel.textColor = .border
        topMessageLabel.textColor = .desc
        centerMessageLabel.textColor = .desc
        tableView.backgroundColor = .background
    }
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        // override this method in subclass
        return topicList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        // override this method in subclass
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: TopicCell.self), for: indexPath) as! TopicCell
        return cell
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        // override this method in subclass
    }
    
    // MARK: - UIScrollViewDelegate
    override func scrollViewDidScroll(_ scrollView: UIScrollView)
    {
        super.scrollViewDidScroll(scrollView)
        
        if !isTopLoading && !isTopLoadingFail && scrollView.contentOffset.y < 0 && enableTopLoading
        {
            let offset = -scrollView.contentOffset.y
            topLoadingView.showLoadingView(withOffset: offset)
        }
        // loading if content is not enough to fill tableview frame
        if enableBottomLoading && scrollView.contentSize.height < scrollView.frame.height && !isBottomLoading && !isBottomLoadingFail
        {
            beginBottomLoading()
        }
        // Bottom loading if enabled
        if enableBottomLoading && scrollView.contentSize.height > scrollView.frame.height && !isBottomLoading && !isBottomLoadingFail
        {
            tableFooterView.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: R.Constant.LoadingViewHeight)
            tableView.tableFooterView = tableFooterView
            if scrollView.contentOffset.y + scrollView.frame.height > scrollView.contentSize.height - (tableView.tableFooterView?.bounds.height ?? 0)
            {
                beginBottomLoading()
            }
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool)
    {
        guard enableTopLoading == true else{
            return
        }
        
        // Top loading
        let offset = -scrollView.contentOffset.y
        if offset > R.Constant.LoadingViewHeight && !isTopLoading
        {
            if isTopLoadingFail
            {
                topLoadingFromFailState()
            }
            else
            {
                beginTopLoading()
            }
        }
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView)
    {
        guard enableTopLoading == true && (scrollView.contentOffset.y < 0 || scrollView.contentSize.height == 0) else{
            return
        }
        
        var contentInsetTop = tableView.contentInset
        contentInsetTop.top = R.Constant.LoadingViewHeight
        tableView.contentInset = contentInsetTop
        isTopLoading = true
        topLoadingView.beginLoading()
        topLoadingRequest()
    }
    
    // MARK: - Top Loading
    func initTopLoading(shouldResetContent reset: Bool = false)
    {
        if reset
        {
            resetContent()
        }
        topLoadingView.initSquaresPosition()
        let offsetY = tableView.contentOffset.y - R.Constant.LoadingViewHeight
        tableView.setContentOffset(CGPoint(x: tableView.contentOffset.x, y: offsetY), animated: true)
    }

    func startLoading()
    {
        resetContent()
        topLoadingView.initSquaresNormalPostion()
        isTopLoading = true
        UIView.animate(withDuration: R.Constant.InsetAnimationDuration, delay: 0, options: .beginFromCurrentState, animations: {
            var contentInsetTop = self.tableView.contentInset
            contentInsetTop.top = R.Constant.LoadingViewHeight
            self.tableView.contentInset = contentInsetTop
        }) { (_) in
            self.topLoadingRequest()
        }
        topLoadingView.beginLoading()
    }
    
    private func resetContent()
    {
        topicList.removeAll()
        tableView.reloadData()
        isTopLoading = false
        tableView.setContentOffset(.zero, animated: false)
    }
    
    private func beginTopLoading()
    {
        isTopLoading = true
        topLoadingView.beginLoading()
        topLoadingRequest()
        DispatchQueue.main.async { () -> Void in
            UIView.animate(withDuration: R.Constant.InsetAnimationDuration, delay: 0, options: .beginFromCurrentState, animations: {
                var contentInsetTop = self.tableView.contentInset
                contentInsetTop.top = R.Constant.LoadingViewHeight
                self.tableView.contentInset = contentInsetTop
                }, completion: nil)
        }
    }
    
    func topLoadingFromFailState()
    {
        isTopLoading = false
        topLoadingView.initSquaresNormalPostion()
        beginTopLoading()
    }
    
    // MARK: - Bottom Loading
    private func beginBottomLoading()
    {
        bottomLoadingView.isHidden = false
        bottomLoadingView.initSquaresNormalPostion()
        bottomLoadingView.beginLoading()
        isBottomLoading = true
        bottomLoadingRequest()
    }
    
    // MARK: - Stop Loading
    func stopLoading(withLoadingStyle style: LoadingStyle, success: Bool, completion: CompletionTask?)
    {
        switch style
        {
        case .top:
            topLoadingView.stopLoading(withSuccess: success, completion: completion)
        case .bottom:
            bottomLoadingView.stopLoading(withSuccess: success, completion: completion)
        }
    }
    
    // MARK: - SquareLoadingViewDelegate
    func didTriggeredReloading()
    {
        beginBottomLoading()
    }
    
    // MARK: - TopicDetailDelegate
    func avatarTapped(withUsername username: String)
    {
        let profileVC = OtherProfileViewController()
        profileVC.username = username
        self.bouncePresent(viewController: profileVC, completion: nil)
    }
    
    func nodeTapped(withNodeId nodeId: String, nodeName: String?)
    {
        let nodeTopicListVC = NodeTopicListViewController()
        nodeTopicListVC.nodeId = nodeId
        nodeTopicListVC.title = nodeName
        self.bouncePresent(navigationVCWith: nodeTopicListVC, completion: {
            nodeTopicListVC.startLoading()
        })
    }
    
    // MARK: - Public
    func removeTopic(withId topicId: String)
    {
        if let index = topicList.index(where: {$0.topicId == topicId})
        {
            topicList.remove(at: index)
            tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
        }
    }
    
    func prepareForReuse()
    {
        topReminderLabel.font = R.Font.Small
        topMessageLabel.font = R.Font.Small
        centerMessageLabel.font = R.Font.Small
    }
    
    func topLoadingRequest()
    {
        // override this method in subclass
    }
    
    func bottomLoadingRequest()
    {
        // override this method in subclass
    }
    
    // MARK: - MFMailComposeViewControllerDelegate
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?)
    {
        dismiss(animated: true, completion: nil)
    }
}

