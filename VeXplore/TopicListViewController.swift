//
//  TopicListViewController.swift
//  VeXplore
//
//  Copyright © 2016 Jimmy. All rights reserved.
//


class TopicListViewController: BaseTableViewController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        tableView.register(TopicCell.self, forCellReuseIdentifier: String(describing: TopicCell.self))
        NotificationCenter.default.addObserver(self, selector: #selector(handleFontsizeDidChanged), name: NSNotification.Name.Setting.FontsizeDidChange, object: nil)
    }
    
    func handleFontsizeDidChanged()
    {
        tableView.reloadData()
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
        if let repliesNumberString = topicItem.repliesNumber, repliesNumberString.isEmpty == false
        {
            cell.repliesNumberLabel.text = repliesNumberString
        }
        if let avatar = topicItem.avatar, let url = URL(string: R.String.Https + avatar)
        {
            cell.avatarImageView.avatarImage(withURL: url)
        }
        cell.lastReplayDateAndUserLabel.text = R.String.NoRepliesNow
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
            let topicVC = TopicViewController()
            topicVC.topicId = topicId
            topicVC.ignoreHandler = { topicId -> Void in
                self.removeTopic(withId: topicId)
            }
            DispatchQueue.main.async(execute: {
                self.bouncePresent(navigationVCWith: topicVC, completion: nil)
            })
        }
    }

}
