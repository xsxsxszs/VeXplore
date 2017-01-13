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
    case enableShake
    case enableTopicPullReply
    case enableOwnerRepliesHighlight
    case enableTabbarScrollHidden
    case fontSetting
}

private enum FeedbackSectionRow: Int
{
    case title = 0
    case contact
    case evaluate
}

class SettingViewController: UITableViewController, MFMailComposeViewControllerDelegate
{
    var cacheSize: String?
    var enableShake = true
    var enablePullReply = false
    var enableOwnerRepliesHighlighted = false
    var fontScaleString: String!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        navigationController?.navigationBar.isTranslucent = false
        navigationItem.title = R.String.Setting

        tableView.register(SettingHeaderCell.self, forCellReuseIdentifier: String(describing: SettingHeaderCell.self))
        tableView.register(SettingCell.self, forCellReuseIdentifier: String(describing: SettingCell.self))
        tableView.register(VersionCell.self, forCellReuseIdentifier: String(describing: VersionCell.self))
        tableView.backgroundColor = .offWhite
        tableView.separatorStyle = .none
        tableView.estimatedRowHeight = R.Constant.EstimatedRowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.cellLayoutMarginsFollowReadableWidth = false
        
        let closeBtn = UIBarButtonItem(image: R.Image.Close, style: .plain, target: self, action: #selector(closeBtnTapped))
        closeBtn.tintColor = .middleGray
        navigationItem.leftBarButtonItem = closeBtn

        let confirmImage = R.Image.Confirm
        let confirmBtn = UIBarButtonItem(image: confirmImage, style: .plain, target: self, action: #selector(confirmBtnTapped))
        confirmBtn.tintColor = .lightPink
        navigationItem.rightBarButtonItem = confirmBtn
        
        let preferences = UserDefaults.standard
        fontScaleString = preferences.string(forKey: R.Key.DynamicTitleFontScale) ?? "1.0"
        enablePullReply = preferences.bool(forKey: R.Key.EnablePullReply)
        enableOwnerRepliesHighlighted = preferences.bool(forKey: R.Key.EnableOwnerRepliesHighlighted)
        if let enableShake = preferences.object(forKey: R.Key.EnableShake) as? NSNumber
        {
            self.enableShake = enableShake.boolValue
        }
    }

    @objc
    private func closeBtnTapped()
    {
        dismiss(animated: true, completion: nil)
    }
    
    @objc
    private func confirmBtnTapped()
    {
        let preferences = UserDefaults.standard
        preferences.set(NSNumber(value: enableShake as Bool), forKey: R.Key.EnableShake)
        preferences.set(enablePullReply, forKey: R.Key.EnablePullReply)
        preferences.set(enableOwnerRepliesHighlighted, forKey: R.Key.EnableOwnerRepliesHighlighted)
        preferences.set(enableTabarHidden, forKey: R.Key.EnableTabbarHidden)
        preferences.set(fontScaleString, forKey: R.Key.DynamicTitleFontScale)
        NotificationCenter.default.post(name: Notification.Name.Setting.FontSizeDidChange, object: nil)
        dismiss(animated: true, completion: nil)
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
            return 7
        case .feedback:
            return 3
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
            case .enableShake:
                let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SettingCell.self), for: indexPath) as! SettingCell
                cell.leftLabel.text = R.String.ShakeToCallInputView
                cell.rightLabel.isHidden = true
                cell.rightSwitch.isOn = enableShake
                cell.rightSwitch.isHidden = false
                cell.rightSwitch.removeTarget(self, action: nil, for: .valueChanged)
                cell.rightSwitch.addTarget(self, action: #selector(enableShakeValueChanged), for: .valueChanged)
                return cell
            case .enableTopicPullReply:
                let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SettingCell.self), for: indexPath) as! SettingCell
                cell.leftLabel.text = R.String.PullToReplyInTopicView
                cell.rightLabel.isHidden = true
                cell.rightSwitch.isOn = enablePullReply
                cell.rightSwitch.isHidden = false
                cell.rightSwitch.removeTarget(self, action: nil, for: .valueChanged)
                cell.rightSwitch.addTarget(self, action: #selector(enablePullReplyValueChanged), for: .valueChanged)
                return cell
            case .enableOwnerRepliesHighlight:
                let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SettingCell.self), for: indexPath) as! SettingCell
                cell.leftLabel.text = R.String.HighlightOwnerReplies
                cell.rightLabel.isHidden = true
                cell.rightSwitch.isOn = enableOwnerRepliesHighlighted
                cell.rightSwitch.isHidden = false
                cell.rightSwitch.removeTarget(self, action: nil, for: .valueChanged)
                cell.rightSwitch.addTarget(self, action: #selector(enableOwnerRepliesHighlightedValueChanged), for: .valueChanged)
                return cell
            case .enableTabbarScrollHidden:
                let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SettingCell.self), for: indexPath) as! SettingCell
                cell.leftLabel.text = R.String.HomepageHideTabbarWhenScroll
                cell.rightLabel.isHidden = true
                cell.rightSwitch.isOn = enableTabarHidden
                cell.rightSwitch.isHidden = false
                cell.rightSwitch.removeTarget(self, action: nil, for: .valueChanged)
                cell.rightSwitch.addTarget(self, action: #selector(enableTabarHiddenValueChanged), for: .valueChanged)
                return cell
            case .fontSetting:
                let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SettingCell.self), for: indexPath) as! SettingCell
                cell.leftLabel.text = R.String.TopicTitleFont
                cell.rightLabel.text = String(format: R.String.Sccale, fontScaleString)
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
                cell.longLine.isHidden = false
                return cell
            }
        case .version:
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: VersionCell.self), for: indexPath) as! VersionCell
            return cell
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
            case .fontSetting:
                let fontSettingVC = FontSettingViewController()
                fontSettingVC.settingVC = self
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
            default:
                return
            }
        default:
            return
        }
    }
    
    // MARK: - Actions
    @objc
    private func enableShakeValueChanged(_ sender: UISwitch)
    {
        enableShake = sender.isOn
    }
    
    @objc
    private func enablePullReplyValueChanged(_ sender: UISwitch)
    {
        enablePullReply = sender.isOn
    }
    
    @objc
    private func enableOwnerRepliesHighlightedValueChanged(_ sender: UISwitch)
    {
        enableOwnerRepliesHighlighted = sender.isOn
    }
    
    @objc
    private func enableTabarHiddenValueChanged(_ sender: UISwitch)
    {
        enableTabarHidden = sender.isOn
    }
    
    // MARK: - MFMailComposeViewControllerDelegate
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?)
    {
        dismiss(animated: true, completion: nil)
    }

}
