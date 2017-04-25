//
//  VersionCell.swift
//  VeXplore
//
//  Copyright © 2016 Jimmy. All rights reserved.
//


class VersionCell: UITableViewCell
{
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = R.Font.ExtraSmall
        label.textColor = .desc
        label.textAlignment = .center
        label.text = versionBuild()
        
        return label
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?)
    {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        addSubview(titleLabel)
        let bindings = ["titleLabel": titleLabel]
        titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-16-[titleLabel]-16-|", metrics: nil, views: bindings))

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
        titleLabel.font = R.Font.ExtraSmall
    }
    
    @objc
    private func refreshColorScheme()
    {
        titleLabel.textColor = .desc
        contentView.backgroundColor = .subBackground
    }

}
