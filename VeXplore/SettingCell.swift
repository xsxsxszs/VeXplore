//
//  SettingCell.swift
//  VeXplore
//
//  Copyright © 2016 Jimmy. All rights reserved.
//


class SettingCell: UITableViewCell
{
    lazy var leftLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = R.Font.Medium
        label.textColor = .body
        
        return label
    }()
    
    lazy var rightLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = R.Font.Medium
        label.textColor = .gray
        
        return label
    }()
    
    lazy var rightSwitch: UISwitch = {
        let switcher = UISwitch()
        switcher.translatesAutoresizingMaskIntoConstraints = false
        switcher.tintColor = UIColor.highlight.withAlphaComponent(0.8)
        switcher.onTintColor = UIColor.highlight.withAlphaComponent(0.8)
        switcher.isHidden = true
        
        return switcher
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
    
    var enable: Bool = true {
        didSet
        {
            alpha = enable ? 1.0 : 0.3
            rightSwitch.isUserInteractionEnabled = enable
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?)
    {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(leftLabel)
        contentView.addSubview(rightLabel)
        contentView.addSubview(rightSwitch)
        addSubview(line)
        addSubview(longLine)
        let bindings = [
            "leftLabel": leftLabel,
            "rightLabel": rightLabel,
            "rightSwitch": rightSwitch,
            "line": line,
            "longLine": longLine
        ]
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-12-[leftLabel]", metrics: nil, views: bindings))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[rightLabel]-12-|", metrics: nil, views: bindings))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[rightSwitch]-12-|", metrics: nil, views: bindings))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[longLine]|", metrics: nil, views: bindings))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-15-[leftLabel]-15-|", metrics: nil, views: bindings))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[line(0.5)]|", metrics: nil, views: bindings))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[longLine(0.5)]|", metrics: nil, views: bindings))
        rightLabel.centerYAnchor.constraint(equalTo: leftLabel.centerYAnchor).isActive = true
        rightSwitch.centerYAnchor.constraint(equalTo: leftLabel.centerYAnchor).isActive = true
        line.leadingAnchor.constraint(equalTo: leftLabel.leadingAnchor).isActive = true
        line.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        
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
        rightLabel.isHidden = false
        rightSwitch.isHidden = true
        leftLabel.font = R.Font.Medium
        rightLabel.font = R.Font.Medium
        enable = true
    }
    
    @objc
    private func refreshColorScheme()
    {
        leftLabel.textColor = .body
        rightLabel.textColor = .gray
        rightSwitch.tintColor = UIColor.highlight.withAlphaComponent(0.8)
        rightSwitch.onTintColor = UIColor.highlight.withAlphaComponent(0.8)
        line.backgroundColor = .border
        longLine.backgroundColor = .border
        backgroundColor = .background
        tintColor = .red
    }

}
