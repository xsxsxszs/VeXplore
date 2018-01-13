//
//  MemberReplyCell.swift
//  VeXplore
//
//  Copyright © 2016 Jimmy. All rights reserved.
//

import SharedKit

class MemberReplyCell: BaseTableViewCell
{
    lazy var indexLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = SharedR.Font.Small
        label.textColor = .desc
        label.setContentHuggingPriority(UILayoutPriority.required, for: .vertical)
        
        return label
    }()
    
    lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = SharedR.Font.ExtraSmall
        label.textColor = .desc
        
        return label
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = SharedR.Font.Medium
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.textColor = .body
        label.setContentHuggingPriority(UILayoutPriority.required, for: .vertical)
        label.setContentCompressionResistancePriority(UILayoutPriority.required, for: .vertical)
        
        return label
    }()
    
    lazy var commentLabel: RichTextLabel = {
        let label = RichTextLabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .refBackground
        
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
        
        contentView.addSubview(indexLabel)
        contentView.addSubview(dateLabel)
        contentView.addSubview(titleLabel)
        contentView.addSubview(commentLabel)
        contentView.addSubview(bottomLine)
        let bindings = [
            "titleLabel": titleLabel,
            "indexLabel": indexLabel,
            "dateLabel": dateLabel,
            "commentLabel": commentLabel,
            "bottomLine": bottomLine,
            ]
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-12-[indexLabel]", metrics: nil, views: bindings))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[dateLabel]-12-|", metrics: nil, views: bindings))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-12-[titleLabel]-12-|", metrics: nil, views: bindings))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-12-[commentLabel]-12-|", metrics: nil, views: bindings))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-12-[bottomLine]-12-|", metrics: nil, views: bindings))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-8-[indexLabel]-10-[titleLabel]-10-[commentLabel]-8-|", metrics: nil, views: bindings))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[bottomLine(0.5)]|", metrics: nil, views: bindings))
        dateLabel.centerYAnchor.constraint(equalTo: indexLabel.centerYAnchor).isActive = true
        
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
        indexLabel.font = SharedR.Font.Small
        dateLabel.font = SharedR.Font.ExtraSmall
        titleLabel.font = SharedR.Font.Medium
    }
    
    @objc
    override func refreshColorScheme()
    {
        super.refreshColorScheme()
        indexLabel.textColor = .desc
        dateLabel.textColor = .desc
        titleLabel.textColor = .body
        commentLabel.backgroundColor = .refBackground
        bottomLine.backgroundColor = .border
    }
    
}
