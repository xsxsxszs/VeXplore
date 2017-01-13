//
//  MyFollowingsViewController.swift
//  VeXplore
//
//  Copyright © 2016 Jimmy. All rights reserved.
//


class MyFollowingsViewController: BaseCenterLoadingViewController
{
    private var followingList = [(String, String)]() // (url, username)
    override func viewDidLoad()
    {
        super.viewDidLoad()
        title = R.String.MyFollowings
        
        tableView.register(MyFollowingCell.self, forCellReuseIdentifier: String(describing: MyFollowingCell.self))
        tableView.isHidden = false
        tableView.estimatedRowHeight = R.Constant.EstimatedRowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        let closeBtn = UIBarButtonItem(image: R.Image.Close, style: .plain, target: self, action: #selector(closeBtnTapped))
        closeBtn.tintColor = .middleGray
        navigationItem.leftBarButtonItem = closeBtn
    }
    
    override func loadingRequest()
    {
        V2Request.Profile.getFollowings(completion: { [weak self]  (response) in
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
                    weakSelf.followingList = value
                    weakSelf.tableView.reloadData()
                    weakSelf.centerLoadingView.removeFromSuperview()
                }
            })
        })
    }
    
    @objc
    private func closeBtnTapped()
    {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - UITableViewDataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return followingList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: MyFollowingCell.self), for: indexPath) as! MyFollowingCell
        let followingMember = followingList[indexPath.row]
        cell.contentLabel.text = followingMember.1
        if let url = URL(string: R.String.Https + followingMember.0)
        {
            cell.avatarImageView.avatarImage(withURL: url)
        }
        return cell
    }

    // MARK: - UITableViewDelegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let username = followingList[indexPath.row].1
        let profileVC = OtherProfileViewController()
        profileVC.username = username
        profileVC.unfollowingHandler = { [weak self] username -> Void in
            guard let weakSelf = self else{
                return
            }
            weakSelf.removeUser(withUsername: username)
        }
        DispatchQueue.main.async(execute: {
            self.bouncePresent(viewController: profileVC, completion: nil)
        })
    }
    
    func removeUser(withUsername username: String)
    {
        if let index = followingList.index(where: {$0.1 == username})
        {
            followingList.remove(at: index)
            tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
        }
    }
    
}
