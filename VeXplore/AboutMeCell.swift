//
//  AboutMeCell.swift
//  VeXplore
//
//  Copyright © 2016 Jimmy. All rights reserved.
//


class AboutMeCell: UITableViewCell
{
    lazy var contentLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.font = R.Font.Medium
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

        contentView.backgroundColor = .background
        preservesSuperviewLayoutMargins = false
        layoutMargins = .zero
        selectionStyle = .none
        
        refreshColorScheme()
        
        NotificationCenter.default.addObserver(self, selector: #selector(refreshColorScheme), name: NSNotification.Name.Setting.NightModeDidChange, object: nil)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse()
    {
        super.prepareForReuse()
        contentLabel.font = R.Font.Medium
    }
    
    @objc
    private func refreshColorScheme()
    {
        contentLabel.textColor = .desc
        contentView.backgroundColor = .background
    }
    
}
