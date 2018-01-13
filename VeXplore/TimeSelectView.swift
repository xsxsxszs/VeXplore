//
//  TimeSelectView.swift
//  VeXplore
//
//  Created by Jing Chen on 19/12/2017.
//  Copyright © 2017 Jimmy. All rights reserved.
//

import UIKit
import SharedKit

class TimeSelectHeaderView: BaseView
{
    lazy var leftLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = SharedR.Font.Medium
        label.textColor = .body
        label.numberOfLines = 0
        
        return label
    }()
    
    lazy var rightLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = SharedR.Font.Medium
        label.textColor = .gray
        label.numberOfLines = 0
        
        return label
    }()
    
    lazy var topLine: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .border
        
        return view
    }()
    
    lazy var topShortLine: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .border
        view.isHidden = true

        return view
    }()
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        addSubview(leftLabel)
        addSubview(rightLabel)
        addSubview(topLine)
        addSubview(topShortLine)
        let bindings = [
            "leftLabel": leftLabel,
            "rightLabel": rightLabel,
            "topLine": topLine,
            "topShortLine": topShortLine
        ]
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[topLine]|", metrics: nil, views: bindings))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-12-[leftLabel]", metrics: nil, views: bindings))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[rightLabel]-12-|", metrics: nil, views: bindings))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[topLine(0.5)]-15-[leftLabel]-15-|", metrics: nil, views: bindings))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[topShortLine(0.5)]", metrics: nil, views: bindings))
        rightLabel.centerYAnchor.constraint(equalTo: leftLabel.centerYAnchor).isActive = true
        topShortLine.leadingAnchor.constraint(equalTo: leftLabel.leadingAnchor).isActive = true
        topShortLine.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
 
    @objc
    override func refreshColorScheme()
    {
        super.refreshColorScheme()
        leftLabel.textColor = .body
        rightLabel.textColor = .gray
        topLine.backgroundColor = .border
        topShortLine.backgroundColor = .border
    }
    
    func prepareForReuse()
    {
        leftLabel.font = SharedR.Font.Medium
        rightLabel.font = SharedR.Font.Medium
        topLine.isHidden = false
        topShortLine.isHidden = true
    }
    
}


class TimeSelectView: BaseView
{
    lazy var headerView: TimeSelectHeaderView = {
        let view = TimeSelectHeaderView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(headerViewTapped)))
        
        return view
    }()
    
    private lazy var pickerContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .background
        view.clipsToBounds = true
        
        return view
    }()
    
    lazy var datePicker: UIDatePicker = {
       let picker = UIDatePicker()
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.datePickerMode = .time
        picker.setValue(UIColor.gray, forKey: "textColor")
        
        return picker
    }()
    
    private lazy var pickerTopLine: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .border
        
        return view
    }()
    
    lazy var bottomLine: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .border
        
        return view
    }()
    
    lazy var bottomShortLine: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .border
        view.isHidden = true
        
        return view
    }()
    
    private var hidePickerCons: NSLayoutConstraint!
    private var showPickerCons: NSLayoutConstraint!
    private var isAnimating = false
    var expanded = false

    override init(frame: CGRect)
    {
        super.init(frame: frame)
        
        pickerContainerView.addSubview(datePicker)
        pickerContainerView.addSubview(pickerTopLine)
        addSubview(headerView)
        addSubview(pickerContainerView)
        addSubview(bottomLine)
        addSubview(bottomShortLine)
        let bindings = [
            "headerView": headerView,
            "pickerContainerView": pickerContainerView,
            "datePicker": datePicker,
            "pickerTopLine": pickerTopLine,
            "bottomLine": bottomLine,
            "bottomShortLine": bottomShortLine
        ]
        pickerContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-20-[datePicker]-20-|", metrics: nil, views: bindings))
        pickerContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[pickerTopLine(0.5)][datePicker]", metrics: nil, views: bindings))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[bottomLine]|", metrics: nil, views: bindings))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[headerView]|", metrics: nil, views: bindings))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[headerView][pickerContainerView][bottomLine(0.5)]|", options: [.alignAllLeading, .alignAllTrailing], metrics: nil, views: bindings))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[bottomShortLine(0.5)]|", metrics: nil, views: bindings))
        pickerTopLine.leadingAnchor.constraint(equalTo: headerView.topShortLine.leadingAnchor).isActive = true
        pickerTopLine.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        bottomShortLine.leadingAnchor.constraint(equalTo: headerView.topShortLine.leadingAnchor).isActive = true
        bottomShortLine.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        hidePickerCons = pickerContainerView.bottomAnchor.constraint(equalTo: pickerTopLine.topAnchor)
        showPickerCons = pickerContainerView.bottomAnchor.constraint(equalTo: datePicker.bottomAnchor)
        hidePickerCons.isActive = true
    }

    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    func prepareForReuse()
    {
        headerView.prepareForReuse()
    }
    
    @objc
    override func refreshColorScheme()
    {
        super.refreshColorScheme()
        pickerContainerView.backgroundColor = .background
        datePicker.backgroundColor = .background
        pickerTopLine.backgroundColor = .border
        bottomLine.backgroundColor = .border
        bottomShortLine.backgroundColor = .border
    }
    
    @objc
    private func headerViewTapped()
    {
        guard !isAnimating && !expanded else {
            return
        }
        
        hideOtherPickViews()
        changeExpandedStatus()
    }
    
    private func hideOtherPickViews()
    {
        if let superV = superview
        {
            for subView in superV.subviews
            {
                if subView.isMember(of: TimeSelectView.self) && subView != self
                {
                    let otherTimeSelectView = subView as! TimeSelectView
                    if otherTimeSelectView.expanded
                    {
                        otherTimeSelectView.changeExpandedStatus()
                    }
                }
            }
        }
    }
    
    private func changeExpandedStatus()
    {
        expanded = !expanded
        layoutSelfAndAncestorViewsIfNeed()
        UIView.animate(withDuration: CATransaction.animationDuration(), animations: {
            self.isAnimating = true
            if self.expanded
            {
                self.hidePickerCons.isActive = !self.expanded
                self.showPickerCons.isActive = self.expanded
            }
            else
            {
                self.showPickerCons.isActive = self.expanded
                self.hidePickerCons.isActive = !self.expanded
            }
            self.layoutSelfAndAncestorViewsIfNeed()
        }) { (_) in
            self.isAnimating = false
            self.scrollToVisibleInScrollView()
        }
    }
    
    private func layoutSelfAndAncestorViewsIfNeed()
    {
        self.layoutIfNeeded()
        var superV = self.superview
        while superV != nil
        {
            superV!.layoutIfNeeded()
            superV = superV!.superview
        }
    }
    
    private func scrollToVisibleInScrollView()
    {
        var superV = self.superview
        while superV != nil
        {
            if superV!.isMember(of: UIScrollView.self)
            {
                let scrollView = superV as! UIScrollView
                let rect = scrollView.convert(bounds, from: self)
                scrollView.scrollRectToVisible(rect, animated: true)
            }
            superV = superV!.superview
        }
    }
    
    
}
