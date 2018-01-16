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
    case nightMode
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
    case addReplyIndex
    case fontSetting
    case separator
}

private enum NightModeSectionRow: Int
{
    case title = 0
    case alwaysEnableNightMode
    case nightModeSchedule
    case separator
}

private enum FeedbackSectionRow: Int
{
    case title = 0
    case contact
    case evaluate
    case openSource
    case separator
}

class SettingViewController: BaseTableViewController, MFMailComposeViewControllerDelegate, NightModeScheduleDelegate
{
    var cacheSize: String?
    private var scheduledTime: String {
        if UserDefaults.isNightModeScheduleEnabled,
            let startTime = UserDefaults.scheduleStartDate?.stringValue(),
            let endTime = UserDefaults.scheduleEndDate?.stringValue()
        {
            return String(format: R.String.ScheduledTime, startTime, endTime)
        }
        else
        {
            return R.String.TurnedOff
        }
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        navigationItem.title = R.String.Setting

        tableView.register(SettingHeaderCell.self, forCellReuseIdentifier: String(describing: SettingHeaderCell.self))
        tableView.register(SettingCell.self, forCellReuseIdentifier: String(describing: SettingCell.self))
        tableView.register(SeparatorCell.self, forCellReuseIdentifier: String(describing: SeparatorCell.self))
        tableView.register(VersionCell.self, forCellReuseIdentifier: String(describing: VersionCell.self))
        tableView.separatorStyle = .none
        tableView.estimatedRowHeight = R.Constant.EstimatedRowHeight
        tableView.cellLayoutMarginsFollowReadableWidth = false
        
        let closeBtn = UIBarButtonItem(image: R.Image.Close, style: .plain, target: self, action: #selector(closeBtnTapped))
        navigationItem.leftBarButtonItem = closeBtn
        
        NotificationCenter.default.addObserver(self, selector: #selector(refreshFontSettingInfo), name: Notification.Name.Setting.FontsizeDidChange, object: nil)
    }
    
    private func alwaysEnableNightModeDidChange()
    {
        tableView.reloadRows(at: [IndexPath(row: NightModeSectionRow.nightModeSchedule.rawValue, section: SettingSection.nightMode.rawValue)], with: .automatic)
        NotificationCenter.default.post(name: Notification.Name.Setting.NightModeDidChange, object: nil)
    }
    
    @objc
    override func refreshColorScheme()
    {
        super.refreshColorScheme()
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
        return 4
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        let settingSection = SettingSection(rawValue: section)!
        switch settingSection
        {
        case .config:
            return 9
        case .nightMode:
            return 4
        case .feedback:
            return 5
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
                cell.rightLabel.isHidden = false
                cell.rightLabel.text = cacheSize
                cell.line.isHidden = (indexPath.row == 1)
                return cell
            case .isShakeEnabled:
                let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SettingCell.self), for: indexPath) as! SettingCell
                cell.leftLabel.text = R.String.ShakeToCallInputView
                cell.rightSwitch.isOn = UserDefaults.isShakeEnabled
                cell.rightSwitch.isHidden = false
                cell.rightSwitch.removeTarget(self, action: nil, for: .valueChanged)
                cell.rightSwitch.addTarget(self, action: #selector(isShakeEnabledValueChanged), for: .valueChanged)
                cell.line.isHidden = (indexPath.row == 1)
                return cell
            case .enableTopicPullReply:
                let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SettingCell.self), for: indexPath) as! SettingCell
                cell.leftLabel.text = R.String.PullToReplyInTopicView
                cell.rightSwitch.isOn = UserDefaults.isPullReplyEnabled
                cell.rightSwitch.isHidden = false
                cell.rightSwitch.removeTarget(self, action: nil, for: .valueChanged)
                cell.rightSwitch.addTarget(self, action: #selector(isPullReplyEnabledValueChanged), for: .valueChanged)
                cell.line.isHidden = (indexPath.row == 1)
                return cell
            case .enableOwnerRepliesHighlight:
                let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SettingCell.self), for: indexPath) as! SettingCell
                cell.leftLabel.text = R.String.HighlightOwnerReplies
                cell.rightSwitch.isOn = UserDefaults.isHighlightOwnerRepliesEnabled
                cell.rightSwitch.isHidden = false
                cell.rightSwitch.removeTarget(self, action: nil, for: .valueChanged)
                cell.rightSwitch.addTarget(self, action: #selector(isHighlightOwnerRepliesEnabledValueChanged), for: .valueChanged)
                cell.line.isHidden = (indexPath.row == 1)
                return cell
            case .enableTabBarScrollHidden:
                let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SettingCell.self), for: indexPath) as! SettingCell
                cell.leftLabel.text = R.String.HomepageHideTabBarWhenScroll
                cell.rightSwitch.isOn = UserDefaults.isTabBarHiddenEnabled
                cell.rightSwitch.isHidden = false
                cell.rightSwitch.removeTarget(self, action: nil, for: .valueChanged)
                cell.rightSwitch.addTarget(self, action: #selector(isTabBarHiddenEnabledValueChanged), for: .valueChanged)
                cell.line.isHidden = (indexPath.row == 1)
                return cell
            case .addReplyIndex:
                let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SettingCell.self), for: indexPath) as! SettingCell
                cell.leftLabel.text = R.String.ShowReplyIndex
                cell.rightSwitch.isOn = UserDefaults.isShowReplyIndexEnabled
                cell.rightSwitch.isHidden = false
                cell.rightSwitch.removeTarget(self, action: nil, for: .valueChanged)
                cell.rightSwitch.addTarget(self, action: #selector(isShowReplyIndexEnabledValueChanged), for: .valueChanged)
                cell.line.isHidden = (indexPath.row == 1)
                return cell
            case .fontSetting:
                let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SettingCell.self), for: indexPath) as! SettingCell
                cell.leftLabel.text = R.String.TopicTitleFont
                cell.rightLabel.isHidden = false
                cell.rightLabel.text = String(format: R.String.Sccale, UserDefaults.fontScaleString)
                cell.accessoryType = .disclosureIndicator
                cell.line.isHidden = (indexPath.row == 1)
                return cell
            case .separator:
                let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SeparatorCell.self), for: indexPath) as! SeparatorCell
                return cell
            }
        case .nightMode:
            let nightModeSectionRow = NightModeSectionRow(rawValue: indexPath.row)!
            switch nightModeSectionRow
            {
            case .title:
                let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SettingHeaderCell.self), for: indexPath) as! SettingHeaderCell
                cell.titleLabel.text = R.String.NightMode
                return cell
            case .alwaysEnableNightMode:
                let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SettingCell.self), for: indexPath) as! SettingCell
                cell.leftLabel.text = R.String.AlwaysEnable
                cell.rightSwitch.isOn = UserDefaults.isNightModeAlwaysEnabled
                cell.rightSwitch.isHidden = false
                cell.rightSwitch.removeTarget(self, action: nil, for: .valueChanged)
                cell.rightSwitch.addTarget(self, action: #selector(isNightModeAlwaysEnabledValueChanged), for: .valueChanged)
                cell.enable = isProEnabled
                cell.line.isHidden = (indexPath.row == 1)
                return cell
            case .nightModeSchedule:
                let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SettingCell.self), for: indexPath) as! SettingCell
                cell.leftLabel.text = R.String.ScheduleEnable
                cell.rightLabel.isHidden = false
                cell.rightLabel.text = scheduledTime
                cell.accessoryType = .disclosureIndicator
                cell.line.isHidden = (indexPath.row == 1)
                return cell
            case .separator:
                let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SeparatorCell.self), for: indexPath) as! SeparatorCell
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
                cell.line.isHidden = (indexPath.row == 1)
                return cell
            case .evaluate:
                let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SettingCell.self), for: indexPath) as! SettingCell
                cell.leftLabel.text = R.String.RatingApp
                cell.line.isHidden = (indexPath.row == 1)
                return cell
            case .openSource:
                let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SettingCell.self), for: indexPath) as! SettingCell
                cell.leftLabel.text = R.String.OpenSource
                cell.line.isHidden = (indexPath.row == 1)
                return cell
            case .separator:
                let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SeparatorCell.self), for: indexPath) as! SeparatorCell
                return cell
            }
        case .version:
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: VersionCell.self), for: indexPath) as! VersionCell
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        let settingSection = SettingSection(rawValue: indexPath.section)!
        switch settingSection
        {
        case .nightMode:
            let nightModeSectionRow = NightModeSectionRow(rawValue: indexPath.row)!
            switch nightModeSectionRow
            {
            case .nightModeSchedule:
                return UserDefaults.isNightModeAlwaysEnabled ? 0 : UITableViewAutomaticDimension
            default:
                break
            }
        default:
            break
        }
        return UITableViewAutomaticDimension
    }

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath)
    {
        let settingSection = SettingSection(rawValue: indexPath.section)!
        switch settingSection
        {
        case .nightMode:
            let nightModeSectionRow = NightModeSectionRow(rawValue: indexPath.row)!
            switch nightModeSectionRow
            {
            case .alwaysEnableNightMode:
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
                                    cell.rightLabel.text = ByteCountFormatter.string(fromByteCount: 0, countStyle: .file)
                                }
                            })
                        })
                    }
                })
                return
            case .fontSetting:
                let fontSettingVC = FontSettingViewController()
                navigationController?.pushViewController(fontSettingVC, animated: true)
                return
            default:
                return
            }
        case .nightMode:
            let nightModeSectionRow = NightModeSectionRow(rawValue: indexPath.row)!
            switch nightModeSectionRow
            {
            case .alwaysEnableNightMode:
                if !isProEnabled
                {
                    let alertController = UIAlertController(title: nil, message: R.String.NotSupportedForFreeVersion, preferredStyle: .alert)
                    let confirmAction = UIAlertAction(title: R.String.Confirm, style: .cancel, handler: nil)
                    alertController.addAction(confirmAction)
                    DispatchQueue.main.async(execute: {
                        self.present(alertController, animated: true, completion: nil)
                    })
                }
                return
            case .nightModeSchedule:
                let nightModeScheduleVC = NightModeScheduleViewController()
                nightModeScheduleVC.delegate = self
                navigationController?.pushViewController(nightModeScheduleVC, animated: true)
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
    private func isShowReplyIndexEnabledValueChanged(_ sender: UISwitch)
    {
        UserDefaults.isShowReplyIndexEnabled = sender.isOn
    }
    
    @objc
    private func isNightModeAlwaysEnabledValueChanged(_ sender: UISwitch)
    {
        UserDefaults.isNightModeAlwaysEnabled = sender.isOn
        alwaysEnableNightModeDidChange()
    }
    
    // MARK: - MFMailComposeViewControllerDelegate
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?)
    {
        dismiss(animated: true, completion: nil)
    }

    // MARK: - NightModeScheduleDelegate
    func nightModeScheduleDidChange()
    {
        tableView.reloadRows(at: [IndexPath(row: 2, section: SettingSection.nightMode.rawValue)], with: .automatic)
    }
    
}
