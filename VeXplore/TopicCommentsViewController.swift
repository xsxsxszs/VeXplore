//
//  TopicCommentsViewController.swift
//  VeXplore
//
//  Copyright © 2016 Jimmy. All rights reserved.
//


class TopicCommentsViewController: BaseTableViewController, CommentImageTapDelegate, CommentCellDelegate, OwnerViewActivityDelegate, UIActionSheetDelegate
{
    var currentPage = 1
    var totalPageNum = 1
    var topicId = R.String.Zero
    var topicComments = [TopicCommentModel]()
    var ownerComments = [TopicCommentModel]()
    var isOwnerView = false
    var isCommmentContext = false
    weak var inputVC: TopicReplyingViewController!
    var ownername: String? {
        didSet
        {
            if let ownername = ownername, ownername.isEmpty == false, topicComments.count > 0
            {
                // the owner name is from topic detail request, refresh visible comments when topic detail request completed
                if let indexPaths = tableView.indexPathsForVisibleRows
                {
                    tableView.reloadRows(at: indexPaths, with: .none)
                }
            }
        }
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        tableView.register(TopicCommentCell.self, forCellReuseIdentifier: String(describing: TopicCommentCell.self))
        initTopLoading()
        enableBottomLoading = false
        tableView.scrollsToTop = false
        NotificationCenter.default.addObserver(self, selector: #selector(refreshMyCommentIfNeed), name: NSNotification.Name.Topic.CommentAdded, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleContentSizeCategoryDidChanged), name: NSNotification.Name.UIContentSizeCategoryDidChange, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        // image view in comment cell may be moved to comment context cell
        // reload tableView to re-add image view to comment cell
        tableView.reloadData()
    }
    
    @objc
    private func handleContentSizeCategoryDidChanged()
    {
        for comment in topicComments
        {
            comment.contentAttributedString.addAttribute(NSFontAttributeName, value: R.Font.Medium)
        }
        super.prepareForReuse()
    }
    
    // MARK: - UITableViewDelegate
    override func topLoadingRequest()
    {
        V2Request.Topic.getComments(withTopicId: topicId, page: 1) { [weak self] (response) in
            guard let weakSelf = self else {
                return
            }
            
            weakSelf.stopLoading(withLoadingStyle: .top, success: response.success, completion: { (success) -> Void in
                if success, let comments = response.value
                {
                    weakSelf.topicComments = comments.0
                    weakSelf.totalPageNum = comments.1
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
                    
                    if weakSelf.topicComments.count == 0
                    {
                        weakSelf.topMessageLabel.text = R.String.NoRepliesNow
                        weakSelf.topMessageLabel.isHidden = false
                        weakSelf.topLoadingView.isHidden = true
                    }
                    else
                    {
                        weakSelf.tableView.reloadData()
                        UIView.animate(withDuration: R.Constant.InsetAnimationDuration, delay: 0, options: .beginFromCurrentState, animations: { () -> Void in
                            weakSelf.tableView.contentInset = .zero
                        }) { (_) in
                            if User.shared.isLogin
                            {
                                weakSelf.topReminderLabel.text = R.String.SwipeToDoMore
                                weakSelf.topReminderLabel.isHidden = false
                            }
                            
                            weakSelf.tableView.tableHeaderView = nil
                        }
                    }
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
        V2Request.Topic.getComments(withTopicId: topicId, page: currentPage) { [weak self] (response) in
            guard let weakSelf = self else {
                return
            }
            
            weakSelf.stopLoading(withLoadingStyle: .bottom, success: response.success, completion: { (success) -> Void in
                if success, let value = response.value
                {
                    weakSelf.bottomLoadingView.isHidden = true
                    let oldRowsCount = weakSelf.topicComments.count
                    weakSelf.topicComments.append(contentsOf: value.0)
                    let newRowsCount = weakSelf.topicComments.count
                    var insertIndexPaths = [IndexPath]()
                    for index in oldRowsCount..<newRowsCount
                    {
                        let indexPath = IndexPath(row: index, section: 0)
                        insertIndexPaths.append(indexPath)
                    }
                    
                    weakSelf.currentPage += 1
                    weakSelf.tableView.insertRows(at: insertIndexPaths, with: .none)
                    if weakSelf.currentPage > weakSelf.totalPageNum
                    {
                        weakSelf.tableView.tableFooterView = nil
                        weakSelf.enableBottomLoading = false
                    }
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
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return isOwnerView ? ownerComments.count : topicComments.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: TopicCommentCell.self), for: indexPath) as! TopicCommentCell
        let comment = isOwnerView ? ownerComments[indexPath.row] : topicComments[indexPath.row]
        cell.commentModel = comment
        if let avatar = comment.avatar, let url = URL(string: R.String.Https + avatar)
        {
            cell.avatarImageView.avatarImage(withURL: url)
        }
        cell.userNameLabel.text = comment.username
        cell.dateLabel.text = comment.date
        cell.likeNumLabel.text = String(comment.likeNum)
        if User.shared.isLogin, comment.isThanked
        {
            cell.likeImageView.tintColor = .lightPink
        }
        if let commentIndex = comment.commentIndex, commentIndex.isEmpty == false
        {
            cell.commentIndexLabel.text = String(format: R.String.CommentIndex, commentIndex)
        }
        if comment.username == ownername
        {
            cell.ownerLabel.isHidden = false
        }
        
        let size = CGSize(width: view.frame.width - 64, height: CGFloat.greatestFiniteMagnitude)
        if let layout = RichTextLayout(with: size, text: comment.contentAttributedString)
        {
            cell.commentLabel.textLayout = layout
            for attachment in layout.attachments
            {
                if let image = attachment as? CommentImageView
                {
                    image.delegate = self
                }
            }
        }
        
        cell.commentLabel.highlightTapAction = { [weak self]
            (url) -> Void in
            guard let weakSelf = self else {
                return
            }
            URLAnalyzer.Analyze(url: url, handleViewController: weakSelf)
        }
        
        cell.delegate = self
        return cell
    }
    
    // MARK: - UITableViewDelegate
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        let comment = isOwnerView ? ownerComments[indexPath.row] : topicComments[indexPath.row]
        let size = CGSize(width: view.frame.width - 64, height: CGFloat.greatestFiniteMagnitude)
        let layout = RichTextLayout(with: size, text: comment.contentAttributedString)
        let contentHeight = ceil(layout!.bounds.height)
        let height = 10 + ceil(R.Font.Small.lineHeight) + 4 + contentHeight + 8 + ceil(R.Font.ExtraSmall.lineHeight) + 4
        return height
    }
    
    func tableView(_ tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: IndexPath)
    {
        let preferences = UserDefaults.standard
        if preferences.bool(forKey: R.Key.EnableOwnerRepliesHighlighted)
        {
            let comment = isOwnerView ? ownerComments[indexPath.row] : topicComments[indexPath.row]
            if comment.username == ownername
            {
                cell.contentView.backgroundColor  = UIColor.lightPink.withAlphaComponent(0.07)
            }
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        for cell in tableView.visibleCells as! [TopicCommentCell]
        {
            cell.reset()
        }
    }
    
    // MARK: - UIScrollViewDelegate
    override func scrollViewDidScroll(_ scrollView: UIScrollView)
    {
        super.scrollViewDidScroll(scrollView)
        for cell in tableView.visibleCells as! [TopicCommentCell]
        {
            cell.reset()
        }
    }

    // MARK: - CommentImageTapDelegate
    func commentImageSingleTap(_ imageView: CommentImageView)
    {
        guard imageView.image != R.Image.ImagePlaceholder else {
            return
        }
        var imageInfo = ImageInfo()
        imageInfo.image = imageView.image
        imageInfo.originalData = imageView.originalData
        imageInfo.referenceRect = imageView.frame
        imageInfo.referenceView = imageView.superview
        let imageVC = ImageViewingController(imageInfo: imageInfo)
        imageVC.presented(by: self)
    }
    
    // MARK: - CommentCellDelegate
    func cellShouldBeginSwpipe() -> Bool
    {
        return isCommmentContext == false
    }
    
    func cellWillBeginSwipe(at indexPath: IndexPath)
    {
        for cell in tableView.visibleCells as! [TopicCommentCell]
        {
            if cell.isDirty, tableView.indexPath(for: cell)!.compare(indexPath) != .orderedSame
            {
                cell.reset()
            }
        }
    }
    
    func thankBtnTapped(withReplyId replyId: String, indexPath: IndexPath)
    {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        refreshTopicToken(completion: { (token) in
            V2Request.Topic.thankReply(withReplyId: replyId, token: token, completionHandler: { [weak self] (response) in
                guard let weakSelf = self else {
                    return
                }
                
                if response.success
                {
                    let cell = weakSelf.tableView.cellForRow(at: indexPath) as! TopicCommentCell
                    cell.likeImageView.tintColor = .lightPink
                    cell.commentModel?.isThanked = true
                    if let oldLikeNumText = cell.commentModel?.likeNum
                    {
                        cell.commentModel?.likeNum = oldLikeNumText + 1
                        cell.likeNumLabel.text = String(oldLikeNumText + 1)
                    }
                }
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            })
        })
    }
    
    func ignoreBtnTapped(withReplyId replyId: String)
    {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        V2Request.Topic.ignoreReply(withReplyId: replyId, completionHandler: { [weak self] (response) in
            guard let weakSelf = self else {
                return
            }
            
            if response.success
            {
                for comment in weakSelf.topicComments
                {
                    if comment.replyId == replyId
                    {
                        let index = weakSelf.topicComments.index(of: comment)
                        weakSelf.topicComments.remove(at: index!)
                        weakSelf.tableView.deleteRows(at: [IndexPath(row: index!, section: 0)], with: .automatic)
                    }
                }
            }
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        })
    }
    
    func replyBtnTapped(withUsername username: String)
    {
        inputVC.topicId = topicId
        inputVC.atSomeone = String(format: R.String.AtSomeone, username)
        present(inputVC, animated: true, completion: nil)
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
        })
    }
    
    // MARK: - CommentCellDelegate
    func longPress(at indexPath: IndexPath)
    {
        guard isCommmentContext == false else{
            return
        }
        
        if let parentVC = parent
        {
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            let cancelAction = UIAlertAction(title: R.String.Cancel, style: .cancel, handler: nil)
            alertController.addAction(cancelAction)
            let copyAction = UIAlertAction(title: R.String.CopyReplyText, style: .default) { (action) in
                self.copyComment(at: indexPath)
            }
            alertController.addAction(copyAction)
            let dialogueAction = UIAlertAction(title: R.String.ViewConversationContext, style: .default) { (action) in
                self.relevantComments(of: indexPath)
            }
            alertController.addAction(dialogueAction)
            
            let allRepliesAction = UIAlertAction(title: R.String.ViewUserAllReplies, style: .default) { (action) in
                self.allCommentsOfMember(at: indexPath)
            }
            alertController.addAction(allRepliesAction)
            
            if let cell = tableView.cellForRow(at: indexPath)
            {
                alertController.popoverPresentationController?.sourceView = cell
                alertController.popoverPresentationController?.sourceRect = cell.bounds
            }
            parentVC.present(alertController, animated: true, completion: nil)
        }
    }
    
    func copyComment(at indexPath: IndexPath)
    {
        let comment = isOwnerView ? ownerComments[indexPath.row] : topicComments[indexPath.row]
        UIPasteboard.general.string = comment.contentAttributedString.string
    }
    
    func relevantComments(of indexPath: IndexPath)
    {
        let comment = isOwnerView ? ownerComments[indexPath.row] : topicComments[indexPath.row]
        let relevantComments = comment.getRelevantComments(from: self.topicComments)
        let relevantVC = TopicCommentsViewController()
        relevantVC.enableTopLoading = false
        relevantVC.topicComments = relevantComments
        relevantVC.isCommmentContext = true
        relevantVC.navigationItem.title = R.String.ConversationContext
        if let parentVC = parent as? TopicViewController
        {
            parentVC.bouncePresent(navigationVCWith: relevantVC, completion: { 
                relevantVC.tableView.scrollsToTop = true
            })
        }
    }
    
    func allCommentsOfMember(at indexPath: IndexPath)
    {
        let comment = isOwnerView ? ownerComments[indexPath.row] : topicComments[indexPath.row]
        let allComments = comment.getUserAllComments(from: self.topicComments)
        let commentsVC = TopicCommentsViewController()
        commentsVC.enableTopLoading = false
        commentsVC.topicComments = allComments
        commentsVC.isCommmentContext = true
        commentsVC.navigationItem.title = String(format: R.String.MemberAllReplies, comment.username!)
        if let parentVC = parent as? TopicViewController
        {
            parentVC.bouncePresent(navigationVCWith: commentsVC, completion: {
                commentsVC.tableView.scrollsToTop = true
            })
        }
    }
    
    @objc
    private func refreshMyCommentIfNeed()
    {
        if isTopLoadingFail
        {
            topLoadingFromFailState()
        }
        else if currentPage > totalPageNum
        {
            V2Request.Topic.getComments(withTopicId: topicId, page: currentPage) { [weak self] (response) in
                guard let weakSelf = self else {
                    return
                }
                
                if response.success, let value = response.value
                {
                    var shouldAddComment = false
                    var insertIndexPaths = [IndexPath]()
                    if let comment = weakSelf.topicComments.last, let replayId = comment.replyId
                    {
                        for comment in value.0
                        {
                            if comment.replyId == replayId
                            {
                                shouldAddComment = true
                                continue
                            }
                            if shouldAddComment
                            {
                                let indexPath = IndexPath(row: weakSelf.topicComments.count, section: 0)
                                insertIndexPaths.append(indexPath)
                                weakSelf.topicComments.append(comment)
                            }
                        }
                    }
                    
                    if shouldAddComment == false
                    {
                        for comment in value.0
                        {
                            let indexPath = IndexPath(row: weakSelf.topicComments.count, section: 0)
                            insertIndexPaths.append(indexPath)
                            weakSelf.topicComments.append(comment)
                        }
                    }
                    if weakSelf.topicComments.count > 0
                    {
                        weakSelf.tableView.contentInset = .zero
                        weakSelf.tableView.tableHeaderView = nil
                    }
                    weakSelf.tableView.insertRows(at: insertIndexPaths, with: .none)
                }
            }
        }
    }
    
    func ownerViewActivityTapped()
    {
        guard isTopLoadingFail == false, topicComments.count > 0 else{
            return
        }
        
        ownerComments = topicComments.filter { (topicCommentModel) -> Bool in
           return topicCommentModel.username == ownername
        }
        isOwnerView = !isOwnerView
        if isOwnerView || currentPage > totalPageNum
        {
            enableBottomLoading = false
            tableView.tableFooterView = nil
        }
        else
        {
            enableBottomLoading = true
            tableView.tableFooterView = tableFooterView
        }
        tableView.reloadData()
    }
    
}
