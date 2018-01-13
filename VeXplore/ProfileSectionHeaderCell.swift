//
//  ProfileSectionHeaderCell.swift
//  VeXplore
//
//  Copyright © 2016 Jimmy. All rights reserved.
//

import SharedKit

class ProfileSectionHeaderCell: BaseTableViewCell
{
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = SharedR.Font.Small
        label.textColor = .desc
        label.textAlignment = .center
        
        return label
    }()
    
    private lazy var bottomLine: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .border
        
        return view
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?)
    {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(bottomLine)
        let bindings = [
            "titleLabel": titleLabel,
            "bottomLine": bottomLine
        ]
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[titleLabel]|", metrics: nil, views: bindings))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-8-[titleLabel]-8-|", metrics: nil, views: bindings))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[bottomLine]|", metrics: nil, views: bindings))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[bottomLine(0.5)]|", metrics: nil, views: bindings))
        
        preservesSuperviewLayoutMargins = false
        layoutMargins = .zero
        selectionStyle = .none
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse()
    {
        super.prepareForReuse()
        titleLabel.font = SharedR.Font.Small
    }
    
    @objc
    override func refreshColorScheme()
    {
        super.refreshColorScheme()
        titleLabel.textColor = .desc
        bottomLine.backgroundColor = .border
        contentView.backgroundColor = .subBackground
    }
    
}
