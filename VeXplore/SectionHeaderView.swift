//
//  SectionHeaderView.swift
//  VeXplore
//
//  Copyright © 2016 Jimmy. All rights reserved.
//


class SectionHeaderView: UITableViewHeaderFooterView
{
    lazy var contentLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = R.Font.VeryLarge
        label.textColor = .darkGray
        
        return label
    }()
    
    override init(reuseIdentifier: String?)
    {
        super.init(reuseIdentifier: reuseIdentifier)

        contentView.addSubview(contentLabel)
        let bindings = ["contentLabel": contentLabel]
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-14-[contentLabel]-12-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: bindings))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-2-[contentLabel]-2-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: bindings))

        backgroundView = {
            let view = UIView(frame: bounds)
            view.backgroundColor = UIColor.lightGray.withAlphaComponent(0.8)
            
            return view
        }()
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
}
