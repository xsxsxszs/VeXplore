//
//  MemberTopicsViewController.swift
//  VeXplore
//
//  Copyright © 2016 Jimmy. All rights reserved.
//


class MemberTopicsViewController: BaseTableViewController
{
    lazy var pageNumView: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: R.Constant.defaulViewtSize, height: R.Constant.defaulViewtSize))
        label.textAlignment = .right
        label.font = R.Font.Small
        label.textColor = .desc
        
        return label
    }()
    
    private var memberTopicList = [MemberTopicItemModel]()
    private var currentPage = 1
    private var totalPageNum = 1
    var username: String!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        title = String(format: R.String.MemberAllTopics, username)
        
        tableView.register(MemberTopicCell.self, forCellReuseIdentifier: String(describing: MemberTopicCell.self))
        let closeBtn = UIBarButtonItem(image: R.Image.Close, style: .plain, target: self, action: #selector(closeBtnTapped))
        let pageNumItem = UIBarButtonItem(customView: pageNumView)
        navigationItem.leftBarButtonItem = closeBtn
        navigationItem.rightBarButtonItem = pageNumItem
        enableBottomLoading = false
    }
    
    @objc
    private func closeBtnTapped()
    {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Loading request
    override func topLoadingRequest()
    {
        V2Request.Profile.getMemberTopics(withUsername: username, page: 1) { [weak self] (response) in
            guard let weakSelf = self else {
                return
            }
            
            weakSelf.stopLoading(withLoadingStyle: .top, success: response.success, completion: { (success) -> Void in
                if success, let value = response.value
                {
                    weakSelf.memberTopicList = value.0
                    weakSelf.currentPage = 2
                    weakSelf.pageNumView.text = value.2
                    weakSelf.totalPageNum = value.1
                    if weakSelf.currentPage > weakSelf.totalPageNum
                    {
                        weakSelf.enableBottomLoading = false
                    }
                    else
                    {
                        weakSelf.tableView.tableFooterView = weakSelf.tableFooterView
                        weakSelf.enableBottomLoading = true
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
        V2Request.Profile.getMemberTopics(withUsername: username, page: currentPage) { [weak self] (response) in
            guard let weakSelf = self else {
                return
            }
            
            weakSelf.stopLoading(withLoadingStyle: .bottom, success: response.success, completion: { (success) -> Void in
                if success, let value = response.value
                {
                    weakSelf.memberTopicList.append(contentsOf: value.0)
                    weakSelf.currentPage += 1
                    let contentOffset = weakSelf.tableView.contentOffset
                    weakSelf.tableView.reloadData()
                    weakSelf.tableView.setContentOffset(contentOffset, animated: false)
                    weakSelf.isBottomLoadingFail = false
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
        return memberTopicList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: MemberTopicCell.self), for: indexPath) as! MemberTopicCell
        let topicItem = memberTopicList[indexPath.row]
        cell.memberTopicItemModel = topicItem
        cell.topicTitleLabel.text = topicItem.topicTitle
        cell.userNameLabel.text = R.String.IndexNumber + String(indexPath.row + 1)
        cell.nodeNameBtn.setTitle(topicItem.nodeName, for: .normal)
        if let repliesNumber = topicItem.repliesNumber, repliesNumber.isEmpty == false
        {
            cell.repliesNumberLabel.text = repliesNumber
        }
        if let lastReplyDate = topicItem.lastReplyDate
        {
            if topicItem.lastReplyUserName != nil
            {
                cell.lastReplayDateAndUserLabel.text = lastReplyDate
            }
            else
            {
                cell.lastReplayDateAndUserLabel.text = String(format: R.String.PublicDate, lastReplyDate)
            }
        }
        cell.delegate = self
        return cell
    }
    
    // MARK: - UITableViewDelegate
    lazy private var heightCell: MemberTopicCell = {
        let cell = MemberTopicCell()
        cell.bounds = self.tableView.bounds
        cell.autoresizingMask = [.flexibleWidth]
        
        return cell
    }()
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        heightCell.prepareForReuse()
        let model = memberTopicList[indexPath.row]
        heightCell.topicTitleLabel.text = model.topicTitle
        heightCell.userNameLabel.text = R.String.Placeholder
        heightCell.lastReplayDateAndUserLabel.text = R.String.Placeholder
        heightCell.setNeedsLayout()
        heightCell.layoutIfNeeded()
        let height = ceil(heightCell.contentView.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height)
        return height
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if let topicId = memberTopicList[indexPath.row].topicId
        {
            let topicVC = TopicViewController()
            topicVC.topicId = topicId
            DispatchQueue.main.async(execute: {
                self.bouncePresent(navigationVCWith: topicVC, completion: nil)
            })
        }
    }

}
