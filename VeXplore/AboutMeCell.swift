//
//  AboutMeCell.swift
//  VeXplore
//
//  Copyright © 2016 Jimmy. All rights reserved.
//

import SharedKit

class AboutMeCell: BaseTableViewCell
{
    lazy var contentLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.font = SharedR.Font.Medium
        label.textColor = UIColor.desc
        
        return label
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?)
    {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(contentLabel)
        let bindings = ["contentLabel": contentLabel]
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-12-[contentLabel]-12-|", metrics: nil, views: bindings))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-8-[contentLabel]-8-|", metrics: nil, views: bindings))

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
        contentLabel.font = SharedR.Font.Medium
    }
    
    @objc
    override func refreshColorScheme()
    {
        super.refreshColorScheme()
        contentLabel.textColor = .desc
    }
    
}
