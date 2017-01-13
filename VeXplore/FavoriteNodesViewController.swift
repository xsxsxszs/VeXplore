//
//  FavoriteNodesViewController.swift
//  VeXplore
//
//  Copyright © 2016 Jimmy. All rights reserved.
//


class FavoriteNodesViewController: BaseCenterLoadingViewController
{
    private var nodesList = [NodeModel]()
    var nodeToDelete: String?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        title = R.String.MyFavoriteNodes

        tableView.register(MyFollowingCell.self, forCellReuseIdentifier: String(describing: MyFollowingCell.self))
        tableView.isHidden = false
        tableView.estimatedRowHeight = R.Constant.EstimatedRowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        let closeBtn = UIBarButtonItem(image: R.Image.Close, style: .plain, target: self, action: #selector(closeBtnTapped))
        closeBtn.tintColor = .middleGray
        navigationItem.leftBarButtonItem = closeBtn
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        if let nodeToDelete = nodeToDelete, let index = nodesList.index(where: {$0.nodeId == nodeToDelete})
        {
            nodesList.remove(at: index)
            tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
        }
    }
    
    @objc
    private func closeBtnTapped()
    {
        dismiss(animated: true, completion: nil)
    }
    
    override func loadingRequest()
    {
        V2Request.Profile.getFavoriteNodes(completion: { [weak self]  (response) in
            guard let weakSelf = self else {
                return
            }
            
            weakSelf.stopLoading(withSuccesse: response.success, completion: { (success) in
                if response.message.count > 0 && response.message[0] == R.String.NeedLoginError
                {
                    User.shared.logout()
                }
                else if success, let value = response.value
                {
                    weakSelf.nodesList = value
                    weakSelf.tableView.reloadData()
                    weakSelf.centerLoadingView.removeFromSuperview()
                }
            })
        })
    }
    
    // MARK: - UITableViewDataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return nodesList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: MyFollowingCell.self), for: indexPath) as! MyFollowingCell
        let followingMember = nodesList[indexPath.row]
        cell.contentLabel.text = followingMember.nodeName
        if let avatar = followingMember.avatar, let url = URL(string: R.String.Https + avatar)
        {
            cell.avatarImageView.avatarImage(withURL: url)
        }
        return cell
    }

    // MARK: - UITableViewDelegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let nodeModel = nodesList[indexPath.row]
        let nodeTopicListVC = NodeTopicListViewController()
        nodeTopicListVC.node = nodeModel
        nodeTopicListVC.title = nodeModel.nodeName
        nodeTopicListVC.favoriteNodesVC = self
        DispatchQueue.main.async {
            self.bouncePresent(navigationVCWith: nodeTopicListVC, completion: {
                nodeTopicListVC.startLoading()
            })
        }
    }

}
