//
//  NotificationCell.swift
//  VeXplore
//
//  Copyright © 2016 Jimmy. All rights reserved.
//


class NotificationCell: SwipCell
{
    lazy var avatarImageView: AvatarImageView = {
        let view = AvatarImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleToFill
        view.tintColor = .body
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(avatarTapped)))
        
        return view
    }()

    lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = R.Font.ExtraSmall
        label.textColor = .gray
        
        return label
    }()
    
    lazy var topicTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = R.Font.Medium
        label.numberOfLines = 0
        label.textColor = .body
        
        return label
    }()
    
    lazy var commentLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = R.Font.Small
        label.numberOfLines = 0
        label.textColor = .desc
        label.backgroundColor = .refBackground
        
        return label
    }()
    
    private lazy var separatorLine: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .border
        
        return view
    }()
    
    var notificationModel: NotificationModel? {
        didSet
        {
            if let notification = notificationModel
            {
                dateLabel.text = notification.date
                topicTitleLabel.text = notification.title
                commentLabel.text = notification.comment
            }
        }
    }
    
    weak var delegate: NotificationCellDelegate?

    override init(style: UITableViewCellStyle, reuseIdentifier: String?)
    {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(avatarImageView)
        contentView.addSubview(dateLabel)
        contentView.addSubview(topicTitleLabel)
        contentView.addSubview(commentLabel)
        addSubview(separatorLine)
        let bindings = [
            "avatarImageView": avatarImageView,
            "dateLabel": dateLabel,
            "topicTitleLabel": topicTitleLabel,
            "commentLabel": commentLabel,
            "separatorLine": separatorLine
        ]
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-8-[avatarImageView]-8-[dateLabel]-8-|", metrics: nil, views: bindings))
        contentView.addConstraint(NSLayoutConstraint(item: topicTitleLabel, attribute: .leading, relatedBy: .equal, toItem: dateLabel, attribute: .leading, multiplier: 1.0, constant: 0.0))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[dateLabel]-6-[topicTitleLabel]-6-[commentLabel]-4-|", options: [.alignAllLeading, .alignAllTrailing], metrics: nil, views: bindings))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-8-[avatarImageView]", metrics: nil, views: bindings))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[separatorLine(0.5)]|", metrics: nil, views: bindings))
        avatarImageView.widthAnchor.constraint(equalToConstant: R.Constant.AvatarSize).isActive = true
        avatarImageView.heightAnchor.constraint(equalToConstant: R.Constant.AvatarSize).isActive = true
        dateLabel.topAnchor.constraint(equalTo: avatarImageView.topAnchor).isActive = true
        topicTitleLabel.trailingAnchor.constraint(equalTo: dateLabel.trailingAnchor).isActive = true
        separatorLine.trailingAnchor.constraint(equalTo: topicTitleLabel.trailingAnchor).isActive = true
        separatorLine.leadingAnchor.constraint(equalTo: topicTitleLabel.leadingAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse()
    {
        avatarImageView.cancelImageDownloadTaskIfNeed()
        super.prepareForReuse()
        avatarImageView.image = nil
        commentLabel.text = nil
        dateLabel.font = R.Font.ExtraSmall
        topicTitleLabel.font = R.Font.Medium
        commentLabel.font = R.Font.Small
    }
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool
    {
        if let tableView = tableView(), let targetIndexPath = tableView.indexPath(for: self)
        {
            delegate?.cellWillBeginSwipe(at: targetIndexPath)
        }
        
        if delegate?.cellShouldBeginSwpipe() == false
        {
            return false
        }
        
        if gestureRecognizer == panGestureRecognizer
        {
            if abs(panGestureRecognizer.velocity(in: self).y) > abs(panGestureRecognizer.velocity(in: self).x)
            {
                return false
            }
            if panGestureRecognizer.velocity(in: self).x > 0 && isDirty == false
            {
                return false
            }
        }
        return true
    }
    
    // MARK: - Config swipe UI
    override func numberOfButtons() -> Int
    {
        return 1
    }
    
    override func widthForButton() -> CGFloat
    {
        return 100.0
    }
    
    override func iconViewForButton(atIndex index: Int) -> UIView
    {
        let iconView: UIImageView = {
            let view = UIImageView(image: R.Image.Delete)
            view.tintColor = .desc
            view.translatesAutoresizingMaskIntoConstraints = false
            view.contentMode = .scaleAspectFit
            
            return view
        }()
        
        return iconView
    }
    
    override func didTappedButton(atIndex index: Int)
    {
        cancelCellDragging()
        ignoreBtnTapped()
    }
    
    // MARK: - Actions
    @objc
    private func avatarTapped()
    {
        if let username = notificationModel?.username
        {
            delegate?.avatarTapped(withUsername: username)
        }
    }

    @objc
    private func ignoreBtnTapped()
    {
        if let notificationId = notificationModel?.notificationId
        {
            delegate?.deleteNotification(withId: notificationId)
        }
    }
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        contentView.layoutSubviews()
        topicTitleLabel.preferredMaxLayoutWidth = topicTitleLabel.bounds.width
        commentLabel.preferredMaxLayoutWidth = commentLabel.bounds.width
    }
    
}
