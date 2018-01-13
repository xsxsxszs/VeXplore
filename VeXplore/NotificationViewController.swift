//
//  NotificationViewController.swift
//  VeXplore
//
//  Copyright © 2016 Jimmy. All rights reserved.
//


class NotificationViewController: SwipeTableViewController, NotificationCellDelegate, Codable
{
    private var currentPage = 1
    private var totalPageNum = 1
    private var notifications = [NotificationModel]()
    var topicId = R.String.Zero
    var username: String?
    
    private enum CodingKeys: String, CodingKey
    {
        case currentPage
        case totalPageNum
        case notifications
        case username
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        navigationItem.title = R.String.Notification

        if currentPage >= totalPageNum
        {
            enableBottomLoading = false
        }
        else
        {
            tableView.tableFooterView = tableFooterView
            enableBottomLoading = true
            bottomLoadingView.initSquaresNormalPostion()
        }
        tableView.estimatedRowHeight = 0
        tableView.estimatedSectionHeaderHeight = 0
        tableView.estimatedSectionFooterHeight = 0
        tableView.register(NotificationCell.self, forCellReuseIdentifier: String(describing: NotificationCell.self))
        NotificationCenter.default.addObserver(self, selector: #selector(didLogout), name: NSNotification.Name.User.DidLogout, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didLogin), name: NSNotification.Name.User.DidLogin, object: nil)
    }
    
    override init()
    {
        super.init()
        dismissStyle = .none
    }
    
    @objc
    private func didLogin()
    {
        isTopLoading = false
        isTopLoadingFail = false
        topLoadingView.initSquaresPosition()
        topLoadingView.isHidden = false
        topMessageLabel.isHidden = true
        tableView.contentInset = .zero
        centerMessageLabel.isHidden = true
        tableView.tableFooterView = nil
        enableBottomLoading = false
    }
    
    @objc
    private func didLogout()
    {
        centerMessageLabel.isHidden = true
        tableView.tableFooterView = nil
        enableBottomLoading = false
        notifications.removeAll()
        tableView.reloadData()
    }
    
    // MARK: - Loading request
    override func topLoadingRequest()
    {
        if User.shared.isLogin == false
        {
            stopLoading(withLoadingStyle: .top, success: false, completion: { (success) in
                self.topMessageLabel.text = R.String.NeedLoginToViewNotifications
                self.topMessageLabel.isHidden = false
                self.topLoadingView.isHidden = true
                self.isTopLoadingFail = true
                self.isTopLoading = false
            })
            return
        }
        
        V2Request.Notification.getNotifications { [weak self] (response) in
            guard let weakSelf = self else {
                return
            }
            
            weakSelf.stopLoading(withLoadingStyle: .top, success: response.success, completion: { (success) -> Void in
                if success, let value = response.value
                {
                    weakSelf.notifications = value.0
                    weakSelf.totalPageNum = value.1
                    weakSelf.currentPage = 2
                    if weakSelf.currentPage > weakSelf.totalPageNum
                    {
                        weakSelf.enableBottomLoading = false
                        weakSelf.tableView.tableFooterView = nil
                    }
                    else
                    {
                        weakSelf.tableView.tableFooterView = weakSelf.tableFooterView
                        weakSelf.enableBottomLoading = true
                        weakSelf.bottomLoadingView.initSquaresNormalPostion()
                    }
                    if weakSelf.notifications.count > 0
                    {
                        weakSelf.tableView.reloadData()
                        weakSelf.centerMessageLabel.text = nil
                        weakSelf.centerMessageLabel.isHidden = true
                    }
                    else
                    {
                        weakSelf.centerMessageLabel.text = R.String.NoNotificationNow
                        weakSelf.centerMessageLabel.isHidden = false
                    }
                    UIView.animate(withDuration: R.Constant.InsetAnimationDuration, delay: 0, options: .beginFromCurrentState, animations: {
                        weakSelf.tableView.contentInset = .zero
                    }) { (_) in
                        weakSelf.topLoadingView.initSquaresPosition()
                        weakSelf.cacheIfNeed()
                    }
                    weakSelf.isTopLoadingFail = false
                }
                else
                {
                    if response.message.count > 0 && response.message[0] == R.String.NotAuthorizedError
                    {
                        weakSelf.topMessageLabel.isHidden = false
                        weakSelf.topMessageLabel.text = R.String.NeedLoginToViewNotifications
                        User.shared.logout()
                    }
                    weakSelf.isTopLoadingFail = true
                }
                weakSelf.isTopLoading = false
            })
        }
    }
    
    override func bottomLoadingRequest()
    {
        V2Request.Notification.getNotifications(withPage: currentPage) { [weak self] (response) in
            guard let weakSelf = self else {
                return
            }
            
            weakSelf.stopLoading(withLoadingStyle: .bottom, success: response.success, completion: { (success) -> Void in
                if success, let value = response.value
                {
                    weakSelf.totalPageNum = value.1
                    weakSelf.bottomLoadingView.isHidden = true
                    var shouldAddNotifications = false
                    var insertIndexPaths = [IndexPath]()
                    if let lastNotification = weakSelf.notifications.last, let lastNotificationId = lastNotification.notificationId
                    {
                        for newNotification in value.0
                        {
                            if newNotification.notificationId == lastNotificationId
                            {
                                shouldAddNotifications = true
                                continue
                            }
                            if shouldAddNotifications
                            {
                                let indexPath = IndexPath(row: weakSelf.notifications.count, section: 0)
                                insertIndexPaths.append(indexPath)
                                weakSelf.notifications.append(newNotification)
                            }
                        }
                    }
                    if shouldAddNotifications == false
                    {
                        for newNotification in value.0
                        {
                            let indexPath = IndexPath(row: weakSelf.notifications.count, section: 0)
                            insertIndexPaths.append(indexPath)
                            weakSelf.notifications.append(newNotification)
                        }
                    }
                    weakSelf.tableView.insertRows(at: insertIndexPaths, with: .none)
                    weakSelf.currentPage += 1
                    if weakSelf.currentPage > weakSelf.totalPageNum
                    {
                        weakSelf.tableView.tableFooterView = nil
                        weakSelf.enableBottomLoading = false
                    }
                    weakSelf.cacheIfNeed()
                }
                else
                {
                    weakSelf.isBottomLoadingFail = true
                }
                weakSelf.isBottomLoading = false
            })
        }
    }
    
    private func cacheIfNeed()
    {
        if User.shared.isLogin
        {
            username = User.shared.username
            if let diskCachePath = cachePathString(withFilename: classForCoder.description()),
                let jsonData = try? JSONEncoder().encode(self)
            {
                NSKeyedArchiver.archiveRootObject(jsonData, toFile: diskCachePath)
            }
        }
    }
    
    // MARK: - UITableViewDataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return notifications.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: NotificationCell.self), for: indexPath) as! NotificationCell
        let notification: NotificationModel = notifications[indexPath.row]
        if let avatar = notification.avatar, let url = URL(string: R.String.Https + avatar)
        {
            cell.avatarImageView.avatarImage(withURL: url)
        }
        cell.notificationModel = notification
        cell.delegate = self
        return cell
    }

    // MARK: - UITableViewDelegate
    lazy private var heightCell: NotificationCell = {
        let cell = NotificationCell()
        cell.bounds = self.tableView.bounds
        cell.autoresizingMask = [.flexibleWidth]
        
        return cell
    }()
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        heightCell.prepareForReuse()
        let model = notifications[indexPath.row]
        heightCell.notificationModel = model
        heightCell.setNeedsLayout()
        heightCell.layoutIfNeeded()
        let height = ceil(heightCell.contentView.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height)
        return height
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        for cell in tableView.visibleCells as! [NotificationCell]
        {
            if cell.isDirty
            {
                cell.reset()
            }
        }
        if let topicId = notifications[indexPath.row].topicId
        {
            let topicVC = TopicViewController(topicId: topicId)
            DispatchQueue.main.async(execute: {
                self.bouncePresent(navigationVCWith: topicVC, completion: nil)
            })
        }
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView)
    {
        super.scrollViewDidScroll(scrollView)
        for cell in tableView.visibleCells as! [NotificationCell]
        {
            if cell.isDirty
            {
                cell.reset()
            }
        }
    }
    
    // MARK: - NotificationCellDelegate
    func cellWillBeginSwipe(at indexPath: IndexPath)
    {
        for cell in tableView.visibleCells as! [NotificationCell]
        {
            if cell.isDirty && tableView.indexPath(for: cell)?.compare(indexPath) != .orderedSame
            {
                cell.reset()
            }
        }
    }
    
    func deleteNotification(withId notificationId: String)
    {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        V2Request.Notification.deleteNotification(withId: notificationId, completionHandler: { [weak self] (response) in
            guard let weakSelf = self else {
                return
            }
            
            if response.success
            {
                for (index, notification) in weakSelf.notifications.enumerated()
                {
                    if notification.notificationId == notificationId
                    {
                        weakSelf.notifications.remove(at: index)
                        weakSelf.tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
                        weakSelf.cacheIfNeed()
                    }
                }
            }
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        })
    }
    
    // MARK: - Double tap tabar item
    func doubleTapTabarItem()
    {
        if topMessageLabel.isHidden == true
        {
            if tableView.contentOffset.y > 0
            {
                tableView.setContentOffset(.zero, animated: true)
            }
            else if tableView.contentOffset.y == 0, isTopLoadingFail == false
            {
                topLoadingView.initSquaresPosition()
                let offsetY = tableView.contentOffset.y - R.Constant.LoadingViewHeight
                tableView.setContentOffset(CGPoint(x: tableView.contentOffset.x, y: offsetY), animated: true)
            }
        }
    }
    
}
