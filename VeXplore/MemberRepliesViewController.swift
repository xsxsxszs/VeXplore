//
//  MemberRepliesViewController.swift
//  VeXplore
//
//  Copyright © 2016 Jimmy. All rights reserved.
//


class MemberRepliesViewController: BaseTableViewController
{
    private lazy var pageNumView: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: R.Constant.defaulViewtSize, height: R.Constant.defaulViewtSize))
        label.textAlignment = .right
        label.font = R.Font.Small
        label.textColor = .desc
        
        return label
    }()
    
    private var memberRepliesList = [MemberReplyModel]()
    private var currentPage = 1
    private var totalPageNum = 1
    var username: String!

    override func viewDidLoad()
    {
        super.viewDidLoad()
        title = String(format: R.String.MemberAllReplies, username)

        tableView.register(MemberReplyCell.self, forCellReuseIdentifier: String(describing: MemberReplyCell.self))
        enableBottomLoading = false
        let closeBtn = UIBarButtonItem(image: R.Image.Close, style: .plain, target: self, action: #selector(closeBtnTapped))
        let pageNumItem = UIBarButtonItem(customView: pageNumView)
        navigationItem.leftBarButtonItem = closeBtn
        navigationItem.rightBarButtonItem = pageNumItem
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleContentSizeCategoryDidChanged), name: NSNotification.Name.UIContentSizeCategoryDidChange, object: nil)
    }
    
    @objc
    private func handleContentSizeCategoryDidChanged()
    {
        for memberReply in memberRepliesList
        {
            memberReply.contentAttributedString.addAttribute(NSFontAttributeName, value: R.Font.Medium)
        }
        super.prepareForReuse()
    }
    
    @objc
    private func closeBtnTapped()
    {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Loading request
    override func topLoadingRequest()
    {
        V2Request.Profile.getMemberReplies(withUsername: username!, page: 1) { [weak self] (response) in
            guard let weakSelf = self else {
                return
            }
            
            weakSelf.stopLoading(withLoadingStyle: .top, success: response.success, completion: { (success) -> Void in
                if success, let value = response.value
                {
                    weakSelf.memberRepliesList = value.0
                    weakSelf.currentPage = 2
                    weakSelf.totalPageNum = value.1
                    weakSelf.pageNumView.text = value.2
                    if weakSelf.currentPage > weakSelf.totalPageNum
                    {
                        weakSelf.enableBottomLoading = false
                    }
                    else
                    {
                        weakSelf.enableBottomLoading = true
                        weakSelf.tableView.tableFooterView = weakSelf.tableFooterView
                    }
                    weakSelf.tableView.reloadData()
                    UIView.animate(withDuration: R.Constant.InsetAnimationDuration, delay: 0, options: .beginFromCurrentState, animations: {
                        weakSelf.tableView.contentInset = .zero
                    }) { (_) in
                        weakSelf.tableView.tableHeaderView = nil
                    }
                    weakSelf.isTopLoadingFail = false
                    weakSelf.enableTopLoading = false
                    weakSelf.programaticScrollEnabled = true
                }
                else
                {
                    weakSelf.programaticScrollEnabled = false
                    weakSelf.isTopLoadingFail = true
                }
                weakSelf.isTopLoading = false
            })
        }
    }
    
    override func bottomLoadingRequest()
    {
        V2Request.Profile.getMemberReplies(withUsername: username!, page: currentPage) { [weak self] (response) in
            guard let weakSelf = self else {
                return
            }
            
            weakSelf.stopLoading(withLoadingStyle: .bottom, success: response.success, completion: { (success) -> Void in
                if success, let value = response.value
                {
                    weakSelf.bottomLoadingView.isHidden = true
                    
                    let oldRowsCount = weakSelf.memberRepliesList.count
                    weakSelf.memberRepliesList.append(contentsOf: value.0)
                    let newRowsCount = weakSelf.memberRepliesList.count
                    
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
        return memberRepliesList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: MemberReplyCell.self), for: indexPath) as! MemberReplyCell
        let replyItem = memberRepliesList[indexPath.row]
        cell.titleLabel.text = replyItem.title
        cell.dateLabel.text = replyItem.date
        cell.indexLabel.text = R.String.IndexNumber + String(indexPath.row + 1)
        
        let size = CGSize(width: view.frame.width - 24, height: CGFloat.greatestFiniteMagnitude)
        if let layout = RichTextLayout(with: size, text: replyItem.contentAttributedString)
        {
            cell.commentLabel.textLayout = layout
        }
        
        cell.commentLabel.highlightTapAction = { [weak self]
            (url) -> Void in
            guard let weakSelf = self else {
                return
            }
            URLAnalyzer.Analyze(url: url, handleViewController: weakSelf)
        }
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        let replyItem = memberRepliesList[indexPath.row]
        let size = CGSize(width: view.frame.width - 24, height: CGFloat.greatestFiniteMagnitude)
        let topicTitleRect = replyItem.title!.boundingRect(
            with: size,
            options: .usesLineFragmentOrigin,
            attributes: [NSFontAttributeName: R.Font.Medium], context: nil)
        let topicTitleHeight = ceil(topicTitleRect.height)
        let layout = RichTextLayout(with: size, text: replyItem.contentAttributedString)
        let commentHeight = ceil(layout!.bounds.height)
        let height = 8 + ceil(R.Font.Small.lineHeight) + 10 + topicTitleHeight + 10 + commentHeight + 8
        return height
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if let topicId = memberRepliesList[indexPath.row].topicId
        {
            let topicVC = TopicViewController()
            topicVC.topicId = topicId
            DispatchQueue.main.async(execute: {
                self.bouncePresent(navigationVCWith: topicVC, completion: nil)
            })
        }
    }
    
}
