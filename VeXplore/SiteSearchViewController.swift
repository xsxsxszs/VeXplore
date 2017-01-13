//
//  SiteSearchViewController.swift
//  VeXplore
//
//  Copyright © 2016 Jimmy. All rights reserved.
//

import SharedKit


private enum SiteSearchResultSection: Int
{
    case user = 0
    case topics
}

class SiteSearchViewController: SearchViewController
{
    private var searchResults = [TopicItemModel]()
    private var memberProfile: ProfileModel?
    private var bingRequest: Request?
    private var googleRequest: Request?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        navigationItem.title = R.String.MemberAndTopicsSearch
        
        tableView.register(TopicSearchResultCell.self, forCellReuseIdentifier: String(describing: TopicSearchResultCell.self))
        searchBox.searchField.returnKeyType = .google
        searchBox.searchField.placeholder = R.String.SiteSearchPlaceholder
    }
    
    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        if let searchKey = textField.text, searchKey.isEmpty == false
        {
            var topicSearching = true
            var memberSearching = true
            bingRequest?.cancel()
            googleRequest?.cancel()
            memberProfile = nil
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            
            bingRequest = V2Request.Search.getResults(withKey: searchKey, searchType: .bing) { [weak self] (response) in
                guard let weakSelf = self else {
                    return
                }
                
                if response.success, let result = response.value
                {
                    weakSelf.searchResults = result
                    weakSelf.tableView.reloadData()
                    weakSelf.googleRequest = V2Request.Search.getResults(withKey: searchKey, searchType: .google) { (response) in
                        if response.success, let result = response.value
                        {
                            for topicItemModel in result
                            {
                                if weakSelf.searchResults.contains(where: {$0.topicId == topicItemModel.topicId}) == false
                                {
                                    weakSelf.searchResults.append(topicItemModel)
                                }
                            }
                            weakSelf.tableView.reloadData()
                        }
                    }
                }
                topicSearching = false
                if memberSearching == false
                {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
            }
            
            V2Request.Profile.getMemberInfo(withUsername: searchKey) { (response: ValueResponse<ProfileModel>) -> Void in
                if response.success, let avatar = response.value?.avatar, avatar.isEmpty == false
                {
                    self.memberProfile = response.value
                    self.tableView.reloadData()
                }
                memberSearching = false
                if topicSearching == false
                {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
            }
        }
        return true
    }
    
    override func searchFieldDidChange(_ textField: UITextField)
    {
        bingRequest?.cancel()
        googleRequest?.cancel()
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        guard let searchKey = textField.text, searchKey.isEmpty == false else{
            searchResults.removeAll()
            memberProfile = nil
            tableView.reloadData()
            return
        }
    }
    
    // MARK: - UITableViewDataSource
    func numberOfSectionsInTableView(_ tableView: UITableView) -> Int
    {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        let siteSearchResultSection = SiteSearchResultSection(rawValue: section)!
        switch siteSearchResultSection
        {
        case .user:
            return memberProfile != nil ? 1 : 0
        case .topics:
            return searchResults.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: TopicSearchResultCell.self), for: indexPath) as! TopicSearchResultCell
        let siteSearchResultSection = SiteSearchResultSection(rawValue: indexPath.section)!
        switch siteSearchResultSection
        {
        case .user:
            cell.cellTitleLabel.text = R.String.User
            cell.topicTitleLabel.text = memberProfile?.username
        case .topics:
            cell.cellTitleLabel.text = R.String.Topic
            cell.topicTitleLabel.text = searchResults[indexPath.row].topicTitle
        }
        return cell
    }
    
    // MARK: - UITableViewDelegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let siteSearchResultSection = SiteSearchResultSection(rawValue: indexPath.section)!
        switch siteSearchResultSection
        {
        case .user:
            guard let username = memberProfile?.username, username.isEmpty == false else{
                return
            }
            let profileVC = OtherProfileViewController()
            profileVC.username = username
            DispatchQueue.main.async(execute: {
                self.bouncePresent(viewController: profileVC, completion: {
                })
            })
        case .topics:
            let topic = searchResults[indexPath.row]
            if let topicId = topic.topicId
            {
                let topicVC = TopicViewController()
                topicVC.topicId = topicId
                DispatchQueue.main.async(execute: {
                    self.bouncePresent(navigationVCWith: topicVC, completion: nil)
                })
            }
        }
    }
    
}
