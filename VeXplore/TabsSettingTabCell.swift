//
//  TabsSettingTabCell.swift
//  VeXplore
//
//  Copyright © 2016 Jimmy. All rights reserved.
//


class TabsSettingTabCell: UITableViewCell
{
    lazy var lockImageView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFit
        view.image = R.Image.Lock
        view.tintColor = .middleGray
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
        label.font = R.Font.Large
        label.textColor = .middleGray
        
        return label
    }()
    
    private lazy var line: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .borderGray
        
        return view
    }()
    
    lazy var longLine: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .borderGray
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
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-12-[titleLabel]-12-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: bindings))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-4-[lockImageView(20)]-8-[titleLabel]-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: bindings))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[line(0.5)]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: bindings))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[longLine]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: bindings))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[longLine(0.5)]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: bindings))
        lockImageView.heightAnchor.constraint(equalTo: lockImageView.widthAnchor).isActive = true
        lockImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        invisibleImageView.widthAnchor.constraint(equalTo: lockImageView.widthAnchor).isActive = true
        invisibleImageView.heightAnchor.constraint(equalTo: invisibleImageView.widthAnchor).isActive = true
        invisibleImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        invisibleImageView.centerXAnchor.constraint(equalTo: lockImageView.centerXAnchor).isActive = true
        line.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor).isActive = true
        line.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor).isActive = true
        
        selectionStyle = .none
        contentView.backgroundColor = .white
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
        titleLabel.font = R.Font.Large
        contentView.alpha = 1.0
        contentView.backgroundColor = .white
    }
    
}


class TabsSettingHeaderCell: UITableViewCell
{
    lazy var descLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = R.Font.ExtraSmall
        label.textColor = .middleGray
        
        return label
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = R.Font.VerySmall
        label.textColor = .darkGray
        
        return label
    }()
    
    private lazy var bottomLine: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .borderGray
        
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
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-8-[titleLabel]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: bindings))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[bottomLine]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: bindings))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-8-[descLabel]-10-[titleLabel]-8-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: bindings))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[bottomLine(0.5)]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: bindings))
        descLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true

        contentView.backgroundColor = .offWhite
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
        descLabel.font = R.Font.ExtraSmall
        titleLabel.font = R.Font.VerySmall
    }
    
}


class TabsSettingPlaceholderCell: UITableViewCell
{
    override init(style: UITableViewCellStyle, reuseIdentifier: String?)
    {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        contentView.backgroundColor = .offWhite
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }

}
