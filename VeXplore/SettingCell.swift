//
//  SettingCell.swift
//  VeXplore
//
//  Copyright © 2016 Jimmy. All rights reserved.
//

import SharedKit

class SeparatorCell: BaseTableViewCell
{
    override init(style: UITableViewCellStyle, reuseIdentifier: String?)
    {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        heightAnchor.constraint(equalToConstant: 0.5).isActive = true
    }

    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc
    override func refreshColorScheme()
    {
        super.refreshColorScheme()
        contentView.backgroundColor = .border
    }
    
}

class SettingCellView: BaseView
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
    
    lazy var rightSwitch: UISwitch = {
        let switcher = UISwitch()
        switcher.translatesAutoresizingMaskIntoConstraints = false
        switcher.tintColor = UIColor.highlight.withAlphaComponent(0.8)
        switcher.onTintColor = UIColor.highlight.withAlphaComponent(0.8)
        switcher.isHidden = true
        
        return switcher
    }()
    
    lazy var topLine: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .border
        view.isHidden = true
        
        return view
    }()
    
    lazy var bottomLine: UIView = {
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
        addSubview(rightSwitch)
        addSubview(topLine)
        addSubview(bottomLine)
        let bindings: [String : Any] = [
            "leftLabel": leftLabel,
            "rightLabel": rightLabel,
            "rightSwitch": rightSwitch,
            "topLine": topLine,
            "bottomLine": bottomLine
        ]
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[topLine]|", metrics: nil, views: bindings))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[bottomLine]|", metrics: nil, views: bindings))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-12-[leftLabel]", metrics: nil, views: bindings))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[rightLabel]-12-|", metrics: nil, views: bindings))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[rightSwitch]-12-|", metrics: nil, views: bindings))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[topLine(0.5)]-15-[leftLabel]-15-[bottomLine(0.5)]|", metrics: nil, views: bindings))
        rightLabel.centerYAnchor.constraint(equalTo: leftLabel.centerYAnchor).isActive = true
        rightSwitch.centerYAnchor.constraint(equalTo: leftLabel.centerYAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    func prepareForReuse()
    {
        rightLabel.isHidden = true
        rightSwitch.isHidden = true
        topLine.isHidden = true
        bottomLine.isHidden = true
        leftLabel.font = SharedR.Font.Medium
        rightLabel.font = SharedR.Font.Medium
    }
    
    @objc
    override func refreshColorScheme()
    {
        super.refreshColorScheme()
        leftLabel.textColor = .body
        rightLabel.textColor = .gray
        rightSwitch.tintColor = UIColor.highlight.withAlphaComponent(0.8)
        rightSwitch.onTintColor = UIColor.highlight.withAlphaComponent(0.8)
        topLine.backgroundColor = .border
        bottomLine.backgroundColor = .border
    }
    
}

class SettingCell: BaseTableViewCell
{
    lazy var cellView: SettingCellView = {
        let view = SettingCellView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    lazy var line: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .border
        
        return view
    }()
    
    var enable: Bool = true {
        didSet
        {
            alpha = enable ? 1.0 : 0.3
            cellView.rightSwitch.isUserInteractionEnabled = enable
        }
    }
    
    var leftLabel: UILabel {
        return cellView.leftLabel
    }
    
    var rightLabel: UILabel {
        return cellView.rightLabel
    }
    
    var rightSwitch: UISwitch {
        return cellView.rightSwitch
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?)
    {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(cellView)
        addSubview(line)
        let bindings = [
            "cellView": cellView,
            "line": line,
        ]
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[cellView]|", metrics: nil, views: bindings))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[cellView]|", metrics: nil, views: bindings))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[line(0.5)]", metrics: nil, views: bindings))
        line.leadingAnchor.constraint(equalTo: cellView.leftLabel.leadingAnchor).isActive = true
        line.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        
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
        cellView.prepareForReuse()
        line.isHidden = false
        enable = true
    }
    
    @objc
    override func refreshColorScheme()
    {
        super.refreshColorScheme()
        line.backgroundColor = .border
    }

}


class SettingHeaderCell: BaseTableViewCell
{
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = SharedR.Font.Small
        label.textColor = .desc
        label.textAlignment = .left
        
        return label
    }()
    
    lazy var bottomLine: UIView = {
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
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-12-[titleLabel]-12-|", metrics: nil, views: bindings))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-24-[titleLabel]-8-|", metrics: nil, views: bindings))
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



class VersionCell: BaseTableViewCell
{
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = SharedR.Font.ExtraSmall
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
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse()
    {
        super.prepareForReuse()
        titleLabel.font = SharedR.Font.ExtraSmall
    }
    
    @objc
    override func refreshColorScheme()
    {
        super.refreshColorScheme()
        titleLabel.textColor = .desc
        contentView.backgroundColor = .subBackground
    }
    
}
