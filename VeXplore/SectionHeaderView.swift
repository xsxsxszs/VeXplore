//
//  SectionHeaderView.swift
//  VeXplore
//
//  Copyright © 2016 Jimmy. All rights reserved.
//

import SharedKit

class SectionHeaderView: BaseTableViewHeaderFooterView
{
    lazy var contentLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = SharedR.Font.VeryLarge
        label.textColor = .body
        
        return label
    }()
    
    override init(reuseIdentifier: String?)
    {
        super.init(reuseIdentifier: reuseIdentifier)

        contentView.addSubview(contentLabel)
        let bindings = ["contentLabel": contentLabel]
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-14-[contentLabel]-12-|", metrics: nil, views: bindings))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-2-[contentLabel]-2-|", metrics: nil, views: bindings))

        backgroundView = {
            let view = UIView(frame: bounds)
            view.backgroundColor = UIColor.border.withAlphaComponent(0.8)
            
            return view
        }()
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc
    override func refreshColorScheme()
    {
        super.refreshColorScheme()
        contentLabel.textColor = .body
        backgroundView?.backgroundColor = UIColor.border.withAlphaComponent(0.8)
    }
    
}
