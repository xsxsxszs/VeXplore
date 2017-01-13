//
//  OtherProfileViewController.swift
//  VeXplore
//
//  Copyright © 2016 Jimmy. All rights reserved.
//

import SafariServices

class OtherProfileViewController: BaseProfileViewController, MemberFollowBlockCellDelegate
{
    private var isFollowing = true
    var unfollowingHandler: UnfollowingHandler?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        profileTableView.register(MemberFollowBlockCell.self, forCellReuseIdentifier: String(describing: MemberFollowBlockCell.self))
        profileTableView.bounces = false
        if let diskCachePath = cachePathString(withFilename: classForCoder.description()),
            let userProfile = NSKeyedUnarchiver.unarchiveObject(withFile: diskCachePath) as? ProfileModel,
            userProfile.username == username
        {
            self.userProfile = userProfile
            self.profileTableView.reloadData()
        }
        else
        {
            profileLoadingRequest()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool)
    {
        if let username = username, isFollowing == false
        {
            self.unfollowingHandler?(username)
        }
        super.viewDidDisappear(animated)
    }
    
    func profileLoadingRequest()
    {
        guard let username = username else{
            return
        }
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        V2Request.Profile.getMemberInfo(withUsername: username) { [weak self] (response: ValueResponse<ProfileModel>) -> Void in
            guard let weakSelf = self else {
                return
            }
            
            if response.success, let value = response.value
            {
                weakSelf.userProfile = value
                weakSelf.profileTableView.reloadData()
                if let diskCachePath = cachePathString(withFilename: weakSelf.classForCoder.description())
                {
                    NSKeyedArchiver.archiveRootObject(weakSelf.userProfile!, toFile: diskCachePath)
                }
            }
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
    }

    // MARK: - UITableViewDataSource
    override func numberOfSections(in tableView: UITableView) -> Int
    {
        return userProfile != nil ? 6 : 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        var numberOfRow = 0
        let profileSection = ProfileSection(rawValue: section)!
        switch profileSection
        {
        case .avatar:
            numberOfRow = 1
        case .followBlock:
            if User.shared.isLogin, username != User.shared.username
            {
                numberOfRow = 1
            }
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
            cell.nameLabel.text = userProfile?.username
            if let avatar = userProfile?.avatar, let url = URL(string: R.String.Https + avatar)
            {
                cell.avatarImageView.avatarImage(withURL: url)
            }
            cell.joinTimeLabel.text = userProfile?.createdInfo
            if let tagline = userProfile?.tagline, tagline.isEmpty == false
            {
                cell.contentLabel.text = R.String.PersonalTagline + tagline
            }
            return cell
        case .followBlock:
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: MemberFollowBlockCell.self), for: indexPath) as! MemberFollowBlockCell
            cell.followView.numLabel.text = userProfile?.followText
            cell.blockView.numLabel.text = userProfile?.blockText
            cell.delegate = self
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
                cell.contentLabel.text = R.String.AllTopicsZero
                if let userProfile = userProfile
                {
                    if userProfile.topicHidden == true
                    {
                        cell.contentLabel.text = R.String.AllTopicsHidden
                    }
                    else if userProfile.topicsNum > 0
                    {
                        cell.contentLabel.text = String(format: R.String.AllTopicsMoreThan, userProfile.topicsNum)
                    }
                }
                cell.iconImageView.image = R.Image.Topics
                cell.iconImageView.tintColor = .darkGray
                return cell
            case .replies:
                let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: PersonalInfoCell.self), for: indexPath) as! PersonalInfoCell
                cell.contentLabel.text = R.String.AllRepliesZero
                if let userProfile = userProfile, userProfile.repliesNum > 0
                {
                    cell.contentLabel.text = String(format: R.String.AllRepliesMoreThan, userProfile.repliesNum)
                }
                cell.longLine.isHidden = false
                cell.iconImageView.image = R.Image.Replies
                cell.iconImageView.tintColor = .darkGray
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
                    cell.iconImageView.tintColor = .darkGray
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
    
    // MARK: - MemberFollowBlockCellDelegate
    func followViewTapped()
    {
        if let username = username, let urlText = userProfile?.followUrl
        {
            followOrBlockRequst(withUsername: username, urlText: urlText)
        }
    }
    
    func blockViewViewTapped()
    {
        if let username = username, let urlText = userProfile?.blockUrl
        {
            followOrBlockRequst(withUsername: username, urlText: urlText)
        }
    }
    
    private func followOrBlockRequst(withUsername username: String, urlText: String)
    {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        V2Request.Profile.followOrBlockMember(withUsername: username, urlText: urlText, completionHandler: { (response) in
            if response.success
            {
                self.profileLoadingRequest()
                self.isFollowing = !urlText.contains("unfollow")
            }
            else
            {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        })
    }
    
}
