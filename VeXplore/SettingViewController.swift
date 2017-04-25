//
//  SettingViewController.swift
//  VeXplore
//
//  Copyright © 2016 Jimmy. All rights reserved.
//

import MessageUI

private enum SettingSection: Int
{
    case config = 0
    case feedback
    case version
}

private enum ConfigSectionRow: Int
{
    case title = 0
    case cleanCache
    case isShakeEnabled
    case enableTopicPullReply
    case enableOwnerRepliesHighlight
    case enableTabBarScrollHidden
    case enableNightMode
    case fontSetting
}

private enum FeedbackSectionRow: Int
{
    case title = 0
    case contact
    case evaluate
    case openSource
}

class SettingViewController: UITableViewController, MFMailComposeViewControllerDelegate
{
    var cacheSize: String?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        navigationItem.title = R.String.Setting
        refreshColorScheme()

        tableView.register(SettingHeaderCell.self, forCellReuseIdentifier: String(describing: SettingHeaderCell.self))
        tableView.register(SettingCell.self, forCellReuseIdentifier: String(describing: SettingCell.self))
        tableView.register(VersionCell.self, forCellReuseIdentifier: String(describing: VersionCell.self))
        tableView.separatorStyle = .none
        tableView.estimatedRowHeight = R.Constant.EstimatedRowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.cellLayoutMarginsFollowReadableWidth = false
        
        let closeBtn = UIBarButtonItem(image: R.Image.Close, style: .plain, target: self, action: #selector(closeBtnTapped))
        navigationItem.leftBarButtonItem = closeBtn
        
        NotificationCenter.default.addObserver(self, selector: #selector(refreshFontSettingInfo), name: NSNotification.Name.Setting.FontsizeDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshColorScheme), name: NSNotification.Name.Setting.NightModeDidChange, object: nil)
    }
    
    @objc
    private func refreshColorScheme()
    {
        UIApplication.shared.statusBarStyle = UserDefaults.isNightModeEnabled ? .lightContent : .default
        navigationController?.navigationBar.setupNavigationbar()
        tableView.backgroundColor = .subBackground
    }
    
    @objc
    private func closeBtnTapped()
    {
        dismiss(animated: true, completion: nil)
    }
    
    @objc
    private func refreshFontSettingInfo()
    {
        tableView.reloadRows(at: [IndexPath(row: ConfigSectionRow.fontSetting.rawValue, section: SettingSection.config.rawValue)], with: .automatic)
    }

    // MARK: - UITableViewDataSource
    override func numberOfSections(in tableView: UITableView) -> Int
    {
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        let settingSection = SettingSection(rawValue: section)!
        switch settingSection
        {
        case .config:
            return 8
        case .feedback:
            return 4
        case .version:
            return 1
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let settingSection = SettingSection(rawValue: indexPath.section)!
        switch settingSection
        {
        case .config:
            let configSectionRow = ConfigSectionRow(rawValue: indexPath.row)!
            switch configSectionRow
            {
            case .title:
                let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SettingHeaderCell.self), for: indexPath) as! SettingHeaderCell
                cell.titleLabel.text = R.String.GeneralSetting
                return cell
            case .cleanCache:
                let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SettingCell.self), for: indexPath) as! SettingCell
                cell.leftLabel.text = R.String.CleanImageCache
                cell.rightLabel.text = cacheSize
                return cell
            case .isShakeEnabled:
                let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SettingCell.self), for: indexPath) as! SettingCell
                cell.leftLabel.text = R.String.ShakeToCallInputView
                cell.rightLabel.isHidden = true
                cell.rightSwitch.isOn = UserDefaults.isShakeEnabled
                cell.rightSwitch.isHidden = false
                cell.rightSwitch.removeTarget(self, action: nil, for: .valueChanged)
                cell.rightSwitch.addTarget(self, action: #selector(isShakeEnabledValueChanged), for: .valueChanged)
                return cell
            case .enableTopicPullReply:
                let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SettingCell.self), for: indexPath) as! SettingCell
                cell.leftLabel.text = R.String.PullToReplyInTopicView
                cell.rightLabel.isHidden = true
                cell.rightSwitch.isOn = UserDefaults.isPullReplyEnabled
                cell.rightSwitch.isHidden = false
                cell.rightSwitch.removeTarget(self, action: nil, for: .valueChanged)
                cell.rightSwitch.addTarget(self, action: #selector(isPullReplyEnabledValueChanged), for: .valueChanged)
                return cell
            case .enableOwnerRepliesHighlight:
                let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SettingCell.self), for: indexPath) as! SettingCell
                cell.leftLabel.text = R.String.HighlightOwnerReplies
                cell.rightLabel.isHidden = true
                cell.rightSwitch.isOn = UserDefaults.isHighlightOwnerRepliesEnabled
                cell.rightSwitch.isHidden = false
                cell.rightSwitch.removeTarget(self, action: nil, for: .valueChanged)
                cell.rightSwitch.addTarget(self, action: #selector(isHighlightOwnerRepliesEnabledValueChanged), for: .valueChanged)
                return cell
            case .enableTabBarScrollHidden:
                let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SettingCell.self), for: indexPath) as! SettingCell
                cell.leftLabel.text = R.String.HomepageHideTabBarWhenScroll
                cell.rightLabel.isHidden = true
                cell.rightSwitch.isOn = UserDefaults.isTabBarHiddenEnabled
                cell.rightSwitch.isHidden = false
                cell.rightSwitch.removeTarget(self, action: nil, for: .valueChanged)
                cell.rightSwitch.addTarget(self, action: #selector(isTabBarHiddenEnabledValueChanged), for: .valueChanged)
                return cell
            case .enableNightMode:
                let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SettingCell.self), for: indexPath) as! SettingCell
                cell.leftLabel.text = R.String.NightMode
                cell.rightLabel.isHidden = true
                cell.rightSwitch.isOn = UserDefaults.isNightModeEnabled
                cell.rightSwitch.isHidden = false
                cell.rightSwitch.removeTarget(self, action: nil, for: .valueChanged)
                cell.rightSwitch.addTarget(self, action: #selector(isisNightModeEnabledValueChanged), for: .valueChanged)
                cell.enable = isProEnabled
                return cell
            case .fontSetting:
                let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SettingCell.self), for: indexPath) as! SettingCell
                cell.leftLabel.text = R.String.TopicTitleFont
                cell.rightLabel.text = String(format: R.String.Sccale, UserDefaults.fontScaleString)
                cell.accessoryType = .disclosureIndicator
                cell.longLine.isHidden = false
                return cell
            }
        case .feedback:
            let feedbackSectionRow = FeedbackSectionRow(rawValue: indexPath.row)!
            switch feedbackSectionRow
            {
            case .title:
                let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SettingHeaderCell.self), for: indexPath) as! SettingHeaderCell
                cell.titleLabel.text = R.String.Feedback
                return cell
            case .contact:
                let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SettingCell.self), for: indexPath) as! SettingCell
                cell.leftLabel.text = R.String.ContactDeveloper
                return cell
            case .evaluate:
                let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SettingCell.self), for: indexPath) as! SettingCell
                cell.leftLabel.text = R.String.RatingApp
                return cell
            case .openSource:
                let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SettingCell.self), for: indexPath) as! SettingCell
                cell.leftLabel.text = R.String.OpenSource
                cell.longLine.isHidden = false
                return cell
            }
        case .version:
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: VersionCell.self), for: indexPath) as! VersionCell
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath)
    {
        let settingSection = SettingSection(rawValue: indexPath.section)!
        switch settingSection
        {
        case .config:
            let configSectionRow = ConfigSectionRow(rawValue: indexPath.row)!
            switch configSectionRow
            {
            case .enableNightMode:
                let cell = cell as! SettingCell
                cell.enable = isProEnabled
            default:
                break
            }
        default:
            break
        }
    }
    
    // MARK: - UITableViewDelegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let settingSection = SettingSection(rawValue: indexPath.section)!
        switch settingSection
        {
        case .config:
            let configSectionRow = ConfigSectionRow(rawValue: indexPath.row)!
            switch configSectionRow
            {
            case .cleanCache:
                let cell = tableView.cellForRow(at: indexPath) as! SettingCell
                let cache = ImageCache.default
                let cleaningAlertController = UIAlertController(title: nil, message: R.String.ImageCacheCleaning, preferredStyle: .alert)
                DispatchQueue.main.async(execute: {
                    self.present(cleaningAlertController, animated: true) {
                        cache.clearDiskCache(completionHandler: { [weak self] in
                            guard let weakSelf = self else {
                                return
                            }
                            cleaningAlertController.dismiss(animated: true, completion: {
                                let alertController = UIAlertController(title: nil, message: R.String.ImageCacheCleaningCompleted, preferredStyle: .alert)
                                let confirmAction = UIAlertAction(title: R.String.Confirm, style: .cancel, handler: nil)
                                alertController.addAction(confirmAction)
                                weakSelf.present(alertController, animated: true) {
                                    cell.rightLabel.text = String(format: R.String.CacheSize, R.String.Zero)
                                }
                            })
                        })
                    }
                })
                return
            case .enableNightMode:
                if !isProEnabled
                {
                    let alertController = UIAlertController(title: nil, message: R.String.NotSupportedForFreeVersion, preferredStyle: .alert)
                    let confirmAction = UIAlertAction(title: R.String.Confirm, style: .cancel, handler: nil)
                    alertController.addAction(confirmAction)
                    DispatchQueue.main.async(execute: {
                        self.present(alertController, animated: true, completion: nil)
                    })
                }
            case .fontSetting:
                let fontSettingVC = FontSettingViewController()
                navigationController?.pushViewController(fontSettingVC, animated: true)
                return
            default:
                return
            }
        case .feedback:
            let feedbackSectionRow = FeedbackSectionRow(rawValue: indexPath.row)!
            switch feedbackSectionRow
            {
            case .contact:
                if MFMailComposeViewController.canSendMail()
                {
                    let mailCompose = MFMailComposeViewController()
                    mailCompose.mailComposeDelegate = self
                    mailCompose.setToRecipients([R.String.MyGmail])
                    DispatchQueue.main.async(execute: {
                        self.present(mailCompose, animated: true, completion: nil)
                    })
                }
                else
                {
                    let alertController = UIAlertController(title: nil, message: R.String.EmailNotSetAlert, preferredStyle: .alert)
                    let copyAction = UIAlertAction(title: R.String.Confirm, style: .default) { (action) in
                        UIPasteboard.general.string = R.String.MyGmail
                    }
                    alertController.addAction(copyAction)
                    DispatchQueue.main.async(execute: {
                        self.present(alertController, animated: true, completion: nil)
                    })
                }
                return
            case .evaluate:
                if let url = URL(string: R.String.AppStoreUrl)
                {
                    UIApplication.shared.openURL(url)
                }
                return
            case .openSource:
                if let url = URL(string: R.String.OpenSourceUrl)
                {
                    UIApplication.shared.openURL(url)
                }
            default:
                return
            }
        default:
            return
        }
    }
    
    // MARK: - Actions
    @objc
    private func isShakeEnabledValueChanged(_ sender: UISwitch)
    {
        UserDefaults.isShakeEnabled = sender.isOn
    }
    
    @objc
    private func isPullReplyEnabledValueChanged(_ sender: UISwitch)
    {
        UserDefaults.isPullReplyEnabled = sender.isOn
    }
    
    @objc
    private func isHighlightOwnerRepliesEnabledValueChanged(_ sender: UISwitch)
    {
        UserDefaults.isHighlightOwnerRepliesEnabled = sender.isOn
    }
    
    @objc
    private func isTabBarHiddenEnabledValueChanged(_ sender: UISwitch)
    {
        UserDefaults.isTabBarHiddenEnabled = sender.isOn
    }
    
    @objc
    private func isisNightModeEnabledValueChanged(_ sender: UISwitch)
    {
        UserDefaults.isNightModeEnabled = sender.isOn
        NotificationCenter.default.post(name: Notification.Name.Setting.NightModeDidChange, object: nil)
    }
    
    // MARK: - MFMailComposeViewControllerDelegate
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?)
    {
        dismiss(animated: true, completion: nil)
    }

}
