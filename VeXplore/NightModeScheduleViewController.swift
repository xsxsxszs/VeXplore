//
//  NightModeScheduleViewController.swift
//  VeXplore
//
//  Created by Jimmy Chan on 12/18/17.
//  Copyright © 2017 Jimmy. All rights reserved.
//

import UIKit
import SharedKit

protocol NightModeScheduleDelegate: class
{
    func nightModeScheduleDidChange()
}

class NightModeScheduleViewController: BaseViewController
{
    private lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.showsHorizontalScrollIndicator = false
        view.alwaysBounceVertical = true
        
        return view
    }()
    
    private lazy var selectContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        
        return view
    }()
    
    private lazy var settingView: SettingCellView = {
        let view = SettingCellView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.leftLabel.text = R.String.ScheduleNightMode
        view.rightSwitch.isHidden = false
        view.topLine.isHidden = false
        view.bottomLine.isHidden = false
        view.rightSwitch.isOn = UserDefaults.isNightModeScheduleEnabled
        view.rightSwitch.addTarget(self, action: #selector(isEnableScheduleValueChanged), for: .valueChanged)

        return view
    }()
    
    private lazy var fromTimeSelectView: TimeSelectView = {
        let view = TimeSelectView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.headerView.leftLabel.text = R.String.TurnOnAt
        view.bottomLine.isHidden = true
        view.bottomShortLine.isHidden = false
        let date = UserDefaults.scheduleStartDate ?? Date()
        view.headerView.rightLabel.text = date.stringValue()
        view.datePicker.date = date
        view.datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        
        return view
    }()
    
    private lazy var toTimeSelectView: TimeSelectView = {
        let view = TimeSelectView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.headerView.leftLabel.text = R.String.TurnOffAt
        view.headerView.topLine.isHidden = true
        let date = UserDefaults.scheduleEndDate ?? Date()
        view.headerView.rightLabel.text = date.stringValue()
        view.datePicker.date = date
        view.datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)

        return view
    }()
    
    private var hideSelectCons: NSLayoutConstraint!
    private var showSelectCons: NSLayoutConstraint!
    private var isAnimating = false
    weak var delegate: NightModeScheduleDelegate?

    override func viewDidLoad()
    {
        super.viewDidLoad()
        title = R.String.Schedule

        selectContainerView.addSubview(fromTimeSelectView)
        selectContainerView.addSubview(toTimeSelectView)
        scrollView.addSubview(settingView)
        scrollView.addSubview(selectContainerView)
        view.addSubview(scrollView)
        let bindings: [String : Any] = [
            "fromTimeSelectView": fromTimeSelectView,
            "toTimeSelectView": toTimeSelectView,
            "settingView": settingView,
            "selectContainerView": selectContainerView,
            "scrollView": scrollView
        ]
        selectContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[fromTimeSelectView]|", metrics: nil, views: bindings))
        selectContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-20-[fromTimeSelectView][toTimeSelectView]", options: [.alignAllLeading, .alignAllTrailing], metrics: nil, views: bindings))
        scrollView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[settingView]|", metrics: nil, views: bindings))
        scrollView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-20-[settingView][selectContainerView]|", options: [.alignAllLeading, .alignAllTrailing], metrics: nil, views: bindings))
        settingView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[scrollView]|", metrics: nil, views: bindings))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[scrollView]|", metrics: nil, views: bindings))
        hideSelectCons = selectContainerView.bottomAnchor.constraint(equalTo: settingView.bottomAnchor)
        showSelectCons = selectContainerView.bottomAnchor.constraint(equalTo: toTimeSelectView.bottomAnchor)
        hideSelectCons.isActive = !UserDefaults.isNightModeScheduleEnabled;
        showSelectCons.isActive = UserDefaults.isNightModeScheduleEnabled;
    }
    
    @objc
    override func handleContentSizeCategoryDidChanged()
    {
        super.handleContentSizeCategoryDidChanged()
        settingView.prepareForReuse()
        fromTimeSelectView.prepareForReuse()
        toTimeSelectView.prepareForReuse()
    }
    
    @objc
    override func refreshColorScheme()
    {
        super.refreshColorScheme()
        view.backgroundColor = .subBackground
    }
    
    @objc
    private func closeBtnTapped()
    {
        _ = navigationController?.popViewController(animated: true)
    }
    
    @objc
    private func dateChanged(_ sender: UIDatePicker)
    {
        if sender == fromTimeSelectView.datePicker
        {
            fromTimeSelectView.headerView.rightLabel.text = sender.date.stringValue()
            UserDefaults.scheduleStartDate = sender.date
        }
        else if sender == toTimeSelectView.datePicker
        {
            toTimeSelectView.headerView.rightLabel.text = sender.date.stringValue()
            UserDefaults.scheduleEndDate = sender.date
        }
        delegate?.nightModeScheduleDidChange()
        NotificationCenter.default.post(name: Notification.Name.Setting.NightModeDidChange, object: nil)
    }


    @objc
    private func isEnableScheduleValueChanged(_ sender: UISwitch)
    {
        UserDefaults.isNightModeScheduleEnabled = sender.isOn
        delegate?.nightModeScheduleDidChange()
        view.layoutIfNeeded()
        UIView.animate(withDuration: CATransaction.animationDuration(), animations: {
            self.isAnimating = true
            if sender.isOn
            {
                self.hideSelectCons.isActive = false
                self.showSelectCons.isActive = true
            }
            else
            {
                self.showSelectCons.isActive = false
                self.hideSelectCons.isActive = true
            }
            self.view.layoutIfNeeded()
        }) { (_) in
            self.isAnimating = false
            NotificationCenter.default.post(name: Notification.Name.Setting.NightModeDidChange, object: nil)
        }
    }
    
}
