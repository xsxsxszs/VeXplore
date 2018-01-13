//
//  TabsSettingTabCell.swift
//  VeXplore
//
//  Copyright © 2016 Jimmy. All rights reserved.
//

import SharedKit

class TabsSettingTabCell: BaseTableViewCell
{
    lazy var lockImageView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFit
        view.image = R.Image.Lock
        view.tintColor = .desc
        view.isHidden = true
        
        return view
    }()
    
    lazy var invisibleImageView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFit
        view.image = R.Image.Invisible
        view.tintColor = .gray

        view.isHidden = true
        
        return view
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = SharedR.Font.Large
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
        
        contentView.addSubview(lockImageView)
        contentView.addSubview(invisibleImageView)
        contentView.addSubview(titleLabel)
        addSubview(line)
        addSubview(longLine)
        let bindings = [
            "lockImageView": lockImageView,
            "invisibleImageView": invisibleImageView,
            "titleLabel": titleLabel,
            "line": line,
            "longLine": longLine
        ]
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-12-[titleLabel]-12-|", metrics: nil, views: bindings))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-4-[lockImageView(20)]-8-[titleLabel]-|", metrics: nil, views: bindings))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[line(0.5)]|", metrics: nil, views: bindings))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[longLine]|", metrics: nil, views: bindings))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[longLine(0.5)]|", metrics: nil, views: bindings))
        lockImageView.heightAnchor.constraint(equalTo: lockImageView.widthAnchor).isActive = true
        lockImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        invisibleImageView.widthAnchor.constraint(equalTo: lockImageView.widthAnchor).isActive = true
        invisibleImageView.heightAnchor.constraint(equalTo: invisibleImageView.widthAnchor).isActive = true
        invisibleImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        invisibleImageView.centerXAnchor.constraint(equalTo: lockImageView.centerXAnchor).isActive = true
        line.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor).isActive = true
        line.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor).isActive = true
        
        selectionStyle = .none
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    func prepareForMove()
    {
        titleLabel.text = R.String.Placeholder
        titleLabel.isHidden = true
        lockImageView.isHidden = true
        invisibleImageView.isHidden = true
        longLine.isHidden = true
    }
    
    override func prepareForReuse()
    {
        super.prepareForReuse()
        titleLabel.isHidden = false
        lockImageView.isHidden = true
        invisibleImageView.isHidden = true
        longLine.isHidden = true
        titleLabel.font = SharedR.Font.Large
        contentView.alpha = 1.0
        contentView.backgroundColor = .background
    }
    
    @objc
    override func refreshColorScheme()
    {
        super.refreshColorScheme()
        lockImageView.tintColor = .desc
        invisibleImageView.tintColor = .gray
        titleLabel.textColor = .desc
        line.backgroundColor = .border
        longLine.backgroundColor = .border
    }
    
}


class TabsSettingHeaderCell: BaseTableViewCell
{
    lazy var descLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = SharedR.Font.ExtraSmall
        label.textColor = .desc
        
        return label
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = SharedR.Font.VerySmall
        label.textColor = .body
        
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
        
        contentView.addSubview(descLabel)
        contentView.addSubview(titleLabel)
        contentView.addSubview(bottomLine)
        let bindings = [
            "descLabel": descLabel,
            "titleLabel": titleLabel,
            "bottomLine": bottomLine
        ]
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-8-[titleLabel]|", metrics: nil, views: bindings))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[bottomLine]|", metrics: nil, views: bindings))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-8-[descLabel]-10-[titleLabel]-8-|", metrics: nil, views: bindings))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[bottomLine(0.5)]|", metrics: nil, views: bindings))
        descLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true

        selectionStyle = .none
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse()
    {
        super.prepareForReuse()
        descLabel.text = nil
        descLabel.font = SharedR.Font.ExtraSmall
        titleLabel.font = SharedR.Font.VerySmall
    }
    
    @objc
    override func refreshColorScheme()
    {
        super.refreshColorScheme()
        descLabel.textColor = .desc
        titleLabel.textColor = .body
        bottomLine.backgroundColor = .border
        contentView.backgroundColor = .subBackground
    }
    
}


class TabsSettingPlaceholderCell: BaseTableViewCell
{
    override init(style: UITableViewCellStyle, reuseIdentifier: String?)
    {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }

    @objc
    override func refreshColorScheme()
    {
        super.refreshColorScheme()
        contentView.backgroundColor = .subBackground
    }
    
}
