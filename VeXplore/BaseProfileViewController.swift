//
//  BaseProfileViewController.swift
//  VeXplore
//
//  Copyright © 2016 Jimmy. All rights reserved.
//

import SafariServices

enum PersonInfoType: Int
{
    case homepage = 0
    case twitter
    case location
    case github
    case twitch
    case psn
}

class BaseProfileViewController: SwipeTransitionViewController, UITableViewDataSource, UITableViewDelegate
{
    enum ProfileSection: Int
    {
        case avatar = 0
        case favorite
        case followBlock
        case forumActivity
        case personInfo
        case bio
    }
    
    enum ForumActivitySectionRow: Int
    {
        case header = 0
        case topics
        case replies
    }
    
    lazy var profileTableView: UITableView = {
        let tableView = UITableView(frame: self.view.bounds, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(ProfileAvatarCell.self, forCellReuseIdentifier: String(describing: ProfileAvatarCell.self))
        tableView.register(ProfileSectionHeaderCell.self, forCellReuseIdentifier: String(describing: ProfileSectionHeaderCell.self))
        tableView.register(AboutMeCell.self, forCellReuseIdentifier: String(describing: AboutMeCell.self))
        tableView.register(PersonalInfoCell.self, forCellReuseIdentifier: String(describing: PersonalInfoCell.self))
        tableView.estimatedRowHeight = R.Constant.EstimatedRowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.backgroundColor = .background
        tableView.separatorStyle = .none
        
        return tableView
    }()
    
    private var personInfoIconDict = [String: String]()
    var userProfile: ProfileModel?
    var username: String?
    var personInfos = [PersonInfo]()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        view.addSubview(profileTableView)
        let bindings: [String : Any] = [
            "profileTableView": profileTableView,
            "top": topLayoutGuide
        ]
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[profileTableView]|", metrics: nil, views: bindings))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[top][profileTableView]|", metrics: nil, views: bindings))
    }
    
    @objc
    override func refreshColorScheme()
    {
        super.refreshColorScheme()
        profileTableView.backgroundColor = .background
    }
    
    func numberOfPersonalInfoCell() -> Int
    {
        var numberOfPersonalInfoCell = 0
        personInfos.removeAll()
        personInfoIconDict.removeAll()
        if let website = userProfile?.website, website.isEmpty == false
        {
            numberOfPersonalInfoCell += 1
            let personInfo = PersonInfo(type: .homepage, text: website)
            personInfos.append(personInfo)
        }
        if let twitter = userProfile?.twitter, twitter.isEmpty == false
        {
            numberOfPersonalInfoCell += 1
            let personInfo = PersonInfo(type: .twitter, text: twitter)
            personInfos.append(personInfo)
        }
        if let location = userProfile?.location, location.isEmpty == false
        {
            numberOfPersonalInfoCell += 1
            let personInfo = PersonInfo(type: .location, text: location)
            personInfos.append(personInfo)
        }
        if let github = userProfile?.github, github.isEmpty == false
        {
            numberOfPersonalInfoCell += 1
            let personInfo = PersonInfo(type: .github, text: github)
            personInfos.append(personInfo)
        }
        if let twitch = userProfile?.twitch, twitch.isEmpty == false
        {
            numberOfPersonalInfoCell += 1
            let personInfo = PersonInfo(type: .twitch, text: twitch)
            personInfos.append(personInfo)
        }
        if let psn = userProfile?.psn, psn.isEmpty == false
        {
            numberOfPersonalInfoCell += 1
            let personInfo = PersonInfo(type: .psn, text: psn)
            personInfos.append(personInfo)
        }
        return numberOfPersonalInfoCell > 0 ? (numberOfPersonalInfoCell + 1) : 0
    }
    
    // MARK: - UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int
    {
        // override this method in subclass
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        // override this method in subclass
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        // override this method in subclass
        return UITableViewCell()
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let profileSection = ProfileSection(rawValue: indexPath.section)!
        switch profileSection
        {
        case .forumActivity:
            let forumActivitySectionRow = ForumActivitySectionRow(rawValue: indexPath.row)!
            switch forumActivitySectionRow
            {
            case .topics:
                guard let userProfile = userProfile, userProfile.topicHidden == false, userProfile.topicsNum > 0 else {
                    return
                }
                let memberTopicsVC = MemberTopicsViewController()
                memberTopicsVC.username = username
                DispatchQueue.main.async(execute: {
                    self.bouncePresent(navigationVCWith: memberTopicsVC, completion: {
                        memberTopicsVC.startLoading()
                    })
                })
            case .replies:
                guard let userProfile = userProfile, userProfile.repliesNum > 0 || userProfile.hasMoreReplies else{
                    return
                }
                let memberRepliesVC = MemberRepliesViewController()
                memberRepliesVC.username = username
                DispatchQueue.main.async(execute: {
                    self.bouncePresent(navigationVCWith: memberRepliesVC, completion: {
                        memberRepliesVC.startLoading()
                    })
                })
            default:
                break
            }
        case .personInfo:
            if indexPath.row > 0
            {
                let personInfo = personInfos[indexPath.row - 1]
                let escapedString = personInfo.text.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                if let urlString = escapedString, let url = URL(string: urlString)
                {
                    let safariVC = SFSafariViewController(url: url, entersReaderIfAvailable: true)
                    present(safariVC, animated: true, completion: nil)
                }
            }
        default:
            break
        }
    }
    
    struct PersonInfo
    {
        let type: PersonInfoType
        let text: String
    }

}
