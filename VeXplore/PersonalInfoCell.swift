//
//  PersonalInfoCell.swift
//  VeXplore
//
//  Copyright © 2016 Jimmy. All rights reserved.
//


class PersonalInfoCell: UITableViewCell
{
    lazy var iconImageView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFit
        
        return view
    }()
    
    lazy var contentLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = R.Font.Medium
        label.textColor = .desc
        
        return label
    }()
    
    private lazy var line: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .border
        
        return view
    }()
    
    lazy var longLine: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .border
        view.isHidden = true
        
        return view
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?)
    {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(iconImageView)
        contentView.addSubview(contentLabel)
        contentView.addSubview(line)
        contentView.addSubview(longLine)
        let bindings = [
            "iconImageView": iconImageView,
            "contentLabel": contentLabel,
            "line": line,
            "longLine": longLine
        ]
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-12-[iconImageView(20)]-12-[contentLabel]-12-|", metrics: nil, views: bindings))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[longLine]|", metrics: nil, views: bindings))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-8-[contentLabel]-8-|", metrics: nil, views: bindings))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[line(0.5)]|", metrics: nil, views: bindings))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[longLine(0.5)]|", metrics: nil, views: bindings))
        iconImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        iconImageView.heightAnchor.constraint(equalTo: iconImageView.widthAnchor).isActive = true
        line.leadingAnchor.constraint(equalTo: contentLabel.leadingAnchor).isActive = true
        line.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true

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
        line.isHidden = false
        longLine.isHidden = true
        contentLabel.font = R.Font.Medium
    }
    
    @objc
    private func refreshColorScheme()
    {
        contentLabel.textColor = .desc
        line.backgroundColor = .border
        longLine.backgroundColor = .border
        contentView.backgroundColor = .background
    }
    
}
