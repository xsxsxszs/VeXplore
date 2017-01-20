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

class SiteSearchViewController: SearchViewController, SquareLoadingViewDelegate
{
    lazy var tableFooterView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.width, height: 0))
        view.autoresizingMask = .flexibleWidth
        
        return view
    }()
    
    lazy var bottomLoadingView: SquaresLoadingView = {
        let view = SquaresLoadingView(loadingStyle: LoadingStyle.bottom)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.delegate = self
        
        return view
    }()
    
    private var enableBottomLoading = false
    private var isBottomLoading = false
    private var isBottomLoadingFail = false
    
    
    private var searchKey: String?
    private var page: Int = 0
    private var searchResults = [TopicItemModel]()
    private var memberProfile: ProfileModel?
    private var bingRequest: Request?
    private var googleRequest: Request?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        navigationItem.title = R.String.MemberAndTopicsSearch
        
        tableFooterView.addSubview(bottomLoadingView)
        let bindings = ["bottomLoadingView": bottomLoadingView]
        tableFooterView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[bottomLoadingView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: bindings))
        bottomLoadingView.topAnchor.constraint(equalTo: tableFooterView.topAnchor).isActive = true
        bottomLoadingView.heightAnchor.constraint(equalToConstant: R.Constant.LoadingViewHeight).isActive = true
        view.addSubview(tableView)
        tableView.tableFooterView = tableFooterView
        
        tableView.register(TopicSearchResultCell.self, forCellReuseIdentifier: String(describing: TopicSearchResultCell.self))
        searchBox.searchField.returnKeyType = .google
        searchBox.searchField.placeholder = R.String.SiteSearchPlaceholder
    }
    
    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        searchKey = textField.text
        if let searchKey = searchKey, searchKey.isEmpty == false
        {
            page = 0
            tableView.tableFooterView = nil
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
                    weakSelf.page += 1
                    weakSelf.enableBottomLoading = true
                    weakSelf.searchResults = result
                    weakSelf.tableView.setContentOffset(.zero, animated: false)
                    weakSelf.tableView.reloadData()
                    weakSelf.loadMoreIfNeed()
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
            enableBottomLoading = false
            tableView.tableFooterView = nil
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
    lazy private var heightCell: TopicSearchResultCell = {
        let cell = TopicSearchResultCell()
        cell.bounds = self.tableView.bounds
        cell.autoresizingMask = [.flexibleWidth]
        
        return cell
    }()
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        heightCell.prepareForReuse()
        let siteSearchResultSection = SiteSearchResultSection(rawValue: indexPath.section)!
        switch siteSearchResultSection
        {
        case .user:
            heightCell.cellTitleLabel.text = R.String.User
            heightCell.topicTitleLabel.text = memberProfile?.username
        case .topics:
            heightCell.cellTitleLabel.text = R.String.Topic
            heightCell.topicTitleLabel.text = searchResults[indexPath.row].topicTitle
        }
        heightCell.setNeedsLayout()
        heightCell.layoutIfNeeded()
        let height = ceil(heightCell.contentView.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height)
        return height
    }
    
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

    // MARK: - UIScrollViewDelegate
    override func scrollViewDidScroll(_ scrollView: UIScrollView)
    {
        super.scrollViewDidScroll(scrollView)
        loadMoreIfNeed()
    }
    
    private func loadMoreIfNeed()
    {
        // loading if content is not enough to fill tableview frame
        if enableBottomLoading && tableView.contentSize.height < tableView.frame.height && !isBottomLoading && !isBottomLoadingFail
        {
            beginBottomLoading()
        }
        // Bottom loading if enabled
        if enableBottomLoading && tableView.contentSize.height > tableView.frame.height && !isBottomLoading && !isBottomLoadingFail
        {
            tableFooterView.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: R.Constant.LoadingViewHeight)
            tableView.tableFooterView = tableFooterView
            if tableView.contentOffset.y + tableView.frame.height > tableView.contentSize.height - (tableView.tableFooterView?.bounds.height ?? 0)
            {
                beginBottomLoading()
            }
        }
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
    
    // MARK: - SquareLoadingViewDelegate
    func didTriggeredReloading()
    {
        beginBottomLoading()
    }
    
    func bottomLoadingRequest()
    {
        if let searchKey = searchKey
        {
            bingRequest = V2Request.Search.getResults(withKey: searchKey, startIndex: page * 10) { [weak self] (response) in
                guard let weakSelf = self else {
                    return
                }
                
                weakSelf.bottomLoadingView.stopLoading(withSuccess: response.success, completion: { (success) in
                    
                    weakSelf.isBottomLoading = false
                    if success, let result = response.value
                    {
                        weakSelf.page += 1
                        for topicItemModel in result
                        {
                            if weakSelf.searchResults.contains(where: {$0.topicId == topicItemModel.topicId}) == false
                            {
                                weakSelf.searchResults.append(topicItemModel)
                            }
                        }
                        weakSelf.isBottomLoadingFail = false
                        weakSelf.tableView.reloadData()
                        if result.count < 10
                        {
                            weakSelf.tableView.tableFooterView = nil
                            weakSelf.enableBottomLoading = false
                        }
                        weakSelf.loadMoreIfNeed()
                    }
                    else
                    {
                        weakSelf.isBottomLoadingFail = true
                    }
                })
            }
        }
    }
    
}
