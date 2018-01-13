//
//  RecentListViewController.swift
//  VeXplore
//
//  Copyright © 2016 Jimmy. All rights reserved.
//


class RecentListViewController: SwipeTableViewController
{
    var page = 0
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        tableView.register(TopicCell.self, forCellReuseIdentifier: String(describing: TopicCell.self))
        tableView.estimatedRowHeight = R.Constant.EstimatedRowHeight
    }
    
    // MARK: - Loading request
    override func topLoadingRequest()
    {
        request = V2Request.Topic.getRecentList(withPage: page) { [weak self] (response) in
            guard let weakSelf = self else {
                return
            }
            
            weakSelf.stopLoading(withLoadingStyle: .top, success: response.success, completion: { (success) -> Void in
                if success, let value = response.value
                {
                    weakSelf.topicList = value
                    weakSelf.tableView.reloadData()
                    UIView.animate(withDuration: R.Constant.InsetAnimationDuration, delay: 0, options: .beginFromCurrentState, animations: {
                        weakSelf.tableView.contentInset = .zero
                        }, completion: nil)
                    weakSelf.isTopLoadingFail = false
                    weakSelf.enableTopLoading = false
                    weakSelf.tableView.tableHeaderView = nil
                }
                else
                {
                    weakSelf.isTopLoadingFail = true
                }
                weakSelf.isTopLoading = false
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
        cell.nodeNameBtn.setTitle(topicItem.nodeName, for: .normal)
        if topicItem.repliesNumber != nil
        {
            cell.repliesNumberLabel.text = topicItem.repliesNumber
        }
        if let avatar = topicItem.avatar, let url = URL(string: R.String.Https + avatar)
        {
            cell.avatarImageView.avatarImage(withURL: url)
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
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if let topicId = topicList[indexPath.row].topicId
        {
            let topicVC = TopicViewController(topicId: topicId)
            topicVC.ignoreHandler = { [weak self] topicId -> Void in
                guard let weakSelf = self else {
                    return
                }
                weakSelf.removeTopic(withId: topicId)
            }
            DispatchQueue.main.async(execute: {
                self.bouncePresent(navigationVCWith: topicVC, completion: nil)
            })
        }
    }
    
}
