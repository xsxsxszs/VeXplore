//
//  MyProfileViewController.swift
//  VeXplore
//
//  Copyright © 2016 Jimmy. All rights reserved.
//

import SafariServices
import SharedKit

class MyProfileViewController: BaseProfileViewController, MyFavoriteCellDelegate, ProfileAvatarCellDelegate
{
    private lazy var logoutBtn: UIBarButtonItem = {
        let barButtonItem = UIBarButtonItem(image: R.Image.Logout, style: .plain, target: self, action: #selector(logoutBtnTapped))
        
        return barButtonItem
    }()
    
    private lazy var settingBtn: UIBarButtonItem = {
        let barButtonItem = UIBarButtonItem(image: R.Image.Setting, style: .plain, target: self, action: #selector(settingBtnTapped))

        return barButtonItem
    }()
    
    private var needRefreshProfile = false
    private let inputVC = TopicCreatingViewController()
    private var cacheSize: String?
    private var getMemberInfoRequest: Request?
    
    init()
    {
        super.init(nibName: nil, bundle: nil)
        dismissStyle = .none
    }
    
    override func encode(with aCoder: NSCoder)
    {
        aCoder.encode(userProfile, forKey: "userProfile")
    }
    
    required convenience init?(coder aDecoder: NSCoder)
    {
        self.init()
        userProfile = aDecoder.decodeObject(forKey: "userProfile") as? ProfileModel
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        navigationItem.title = R.String.Profile
        
        profileTableView.register(MyFavoriteCell.self, forCellReuseIdentifier: String(describing: MyFavoriteCell.self))
        navigationItem.leftBarButtonItem = settingBtn
        
        NotificationCenter.default.addObserver(self, selector: #selector(profileDidChanged), name: NSNotification.Name.Profile.NeedRefresh, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshProfile), name: NSNotification.Name.Profile.Refresh, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshProfile), name: NSNotification.Name.User.DidLogout, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.transform = .identity
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
        if let presentedVC = presentedViewController, presentedVC is TopicCreatingViewController
        {
            let topicCreatingVC = presentedVC as! TopicCreatingViewController
            let firstResponder = topicCreatingVC.recorededResponder ?? topicCreatingVC.inputContainerView.contentTextView
            firstResponder.becomeFirstResponder()
            return
        }
        refreshProfile()
        ImageCache.default.calculateDiskCacheSize { (size) in
            let cacheSize = String(format:"%.1f", Float(size)/1024.0/1024.0)
            self.cacheSize = String(format: R.String.CacheSize, cacheSize)
        }
    }
    
    @objc
    private func profileDidChanged()
    {
        needRefreshProfile = true
    }
    
    // MARK: - Setting
    @objc
    private func settingBtnTapped()
    {
        let settingVC = SettingViewController()
        settingVC.cacheSize = cacheSize
        let settingNav = UINavigationController(rootViewController: settingVC)
        present(settingNav, animated: true, completion: nil)
    }
    
    // MARK: - login and logout
    @objc
    private func loginBtnTapped()
    {
        let loginVC = LoginViewController()
        loginVC.successHandler = {
            (username) -> Void in
            self.username = username
            self.refreshProfile()
            self.navigationItem.rightBarButtonItem = self.logoutBtn
        }
        navigationController?.present(loginVC, animated: true, completion: nil)
    }
    
    @objc
    private func logoutBtnTapped()
    {
        getMemberInfoRequest?.cancel()
        User.shared.logout()
    }
    
    // MARK: - View Data
    func refreshProfile()
    {
        getMemberInfoRequest?.cancel()
        if User.shared.isLogin
        {
            username = User.shared.username
            navigationItem.rightBarButtonItem = logoutBtn
        }
        else
        {
            resetProfileView()
            return
        }
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        getMemberInfoRequest = V2Request.Profile.getMemberInfo(withUsername: User.shared.username!) { [weak self] (response: ValueResponse<ProfileModel>) -> Void in
            guard let weakSelf = self else {
                return
            }
            
            if response.success
            {
                weakSelf.userProfile = response.value
                weakSelf.profileTableView.reloadData()
                weakSelf.needRefreshProfile = false
                if let diskCachePath = cachePathString(withFilename: weakSelf.classForCoder.description())
                {
                    NSKeyedArchiver.archiveRootObject(weakSelf, toFile: diskCachePath)
                }
            }
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
    }
    
    private func resetProfileView()
    {
        userProfile = nil
        username = nil
        profileTableView.reloadData()
        navigationItem.rightBarButtonItem = nil
    }
    
    // MARK: - UITableViewDataSource
    override func numberOfSections(in tableView: UITableView) -> Int
    {
        return 6
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        var numberOfRow = 0
        let profileSection = ProfileSection(rawValue: section)!
        switch profileSection
        {
        case .avatar:
            numberOfRow = 1
        case .favorite:
            numberOfRow = 1
        case .forumActivity:
            numberOfRow = 3
        case .personInfo:
            numberOfRow = numberOfPersonalInfoCell()
        case .bio:
            if let bio = userProfile?.bio, bio.isEmpty == false
            {
                numberOfRow = 2
            }
        default:
            break
        }
        return numberOfRow
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let profileSection = ProfileSection(rawValue: indexPath.section)!
        switch profileSection
        {
        case .avatar:
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ProfileAvatarCell.self), for: indexPath) as! ProfileAvatarCell
            cell.delegate = self
            cell.writeBtn.isHidden = !User.shared.isLogin
            cell.nameLabel.text = userProfile?.username ??  R.String.NotLogin
            if let avatar = userProfile?.avatar
            {
                let url = URL(string: R.String.Https + avatar)!
                cell.avatarImageView.avatarImage(withURL: url)
            }
            cell.joinTimeLabel.text = userProfile?.createdInfo
            if let tagline = userProfile?.tagline, tagline.isEmpty == false
            {
                cell.contentLabel.text = R.String.PersonalTagline + tagline
            }
            return cell
        case .favorite:
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: MyFavoriteCell.self), for: indexPath) as! MyFavoriteCell
            if let userProfile = userProfile
            {
                cell.topicsView.numLabel.text = userProfile.favoriteTopicsNum
                cell.nodesView.numLabel.text = userProfile.favoriteNodesNum
                cell.followingView.numLabel.text = userProfile.followingsNum
                cell.delegate = self
            }
            return cell
        case .forumActivity:
            let forumActivitySectionRow = ForumActivitySectionRow(rawValue: indexPath.row)!
            switch forumActivitySectionRow
            {
            case .header:
                let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ProfileSectionHeaderCell.self), for: indexPath) as! ProfileSectionHeaderCell
                cell.titleLabel.text = R.String.ForumActivity
                return cell
            case .topics:
                let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: PersonalInfoCell.self), for: indexPath) as! PersonalInfoCell
                if userProfile == nil || userProfile?.topicsNum == 0
                {
                    cell.contentLabel.text = R.String.AllTopicsZero
                }
                else
                {
                    cell.contentLabel.text = String(format: R.String.AllTopicsMoreThan, userProfile?.topicsNum ?? 0)
                }
                cell.iconImageView.image = R.Image.Topics
                cell.iconImageView.tintColor = .body
                return cell
            case .replies:
                let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: PersonalInfoCell.self), for: indexPath) as! PersonalInfoCell
                if userProfile == nil || userProfile?.repliesNum == 0
                {
                    cell.contentLabel.text = R.String.AllRepliesZero
                }
                else
                {
                    cell.contentLabel.text = String(format: R.String.AllRepliesMoreThan, userProfile?.repliesNum ?? 0)
                }
                cell.longLine.isHidden = false
                cell.iconImageView.image = R.Image.Replies
                cell.iconImageView.tintColor = .body
                return cell
            }
        case .personInfo:
            if indexPath.row == 0
            {
                let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ProfileSectionHeaderCell.self), for: indexPath) as! ProfileSectionHeaderCell
                cell.titleLabel.text = R.String.PersonalInfo
                return cell
            }
            else
            {
                let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: PersonalInfoCell.self), for: indexPath) as! PersonalInfoCell
                if personInfos.count > indexPath.row - 1
                {
                    let personInfo = personInfos[indexPath.row - 1]
                    cell.iconImageView.image = R.Dict.PersonInfoIcons[personInfo.type]
                    cell.iconImageView.tintColor = .body
                    cell.contentLabel.text = personInfo.text
                }
                cell.longLine.isHidden = (indexPath.row != personInfos.count)
                return cell
            }
        case .bio:
            if indexPath.row == 0
            {
                let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ProfileSectionHeaderCell.self), for: indexPath) as! ProfileSectionHeaderCell
                cell.titleLabel.text = R.String.PersonalBio
                return cell
            }
            else
            {
                let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: AboutMeCell.self), for: indexPath) as! AboutMeCell
                cell.contentLabel.text = userProfile?.bio
                return cell
            }
        default:
            return UITableViewCell()
        }
    }
    
    // MARK: - UITableViewDelegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if User.shared.isLogin
        {
            super.tableView(tableView, didSelectRowAt: indexPath)
        }
        else
        {
            let profileSection = ProfileSection(rawValue: indexPath.section)!
            switch profileSection
            {
            case .avatar:
                DispatchQueue.main.async(execute: {
                    self.loginBtnTapped()
                })
            default:
                break
            }
        }
    }
    
    // MARK: - MyFavoriteCellDelegate
    func favoriteTopicsTapped()
    {
        guard let userProfile = userProfile, let favoriteTopicsNum = userProfile.favoriteTopicsNum, favoriteTopicsNum != R.String.Zero else{
            return
        }
        let favoriteTopicVC = FavoriteTopicsViewController()
        DispatchQueue.main.async {
            self.bouncePresent(navigationVCWith: favoriteTopicVC, completion: {
                favoriteTopicVC.startLoading()
            })
        }
    }
    
    func favoriteNodesTapped()
    {
        guard let userProfile = userProfile, let favoriteNodesNum = userProfile.favoriteNodesNum, favoriteNodesNum != R.String.Zero else{
            return
        }
        let favoriteNodesVC = FavoriteNodesViewController()
        DispatchQueue.main.async {
            self.bouncePresent(navigationVCWith: favoriteNodesVC, completion: nil)
        }
    }
    
    func myFollowingsTapped()
    {
        guard let userProfile = userProfile, let followingsNum = userProfile.followingsNum, followingsNum != R.String.Zero else{
            return
        }
        let myFollowingVC = MyFollowingsViewController()
        DispatchQueue.main.async {
            self.bouncePresent(navigationVCWith: myFollowingVC, completion: nil)
        }
    }
    
    // MARK: - Write Topic
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?)
    {
        guard User.shared.isLogin else{
            return
        }
        
        if motion == .motionShake, UserDefaults.isShakeEnabled
        {
            present(inputVC, animated: true, completion: nil)
        }
    }
    
    func writeBtnTapped()
    {
        present(inputVC, animated: true, completion: nil)
    }
    
}
