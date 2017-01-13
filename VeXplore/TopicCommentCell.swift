//
//  TopicCommentCell.swift
//  VeXplore
//
//  Copyright © 2016 Jimmy. All rights reserved.
//


private enum ActionButtonType: Int
{
    case reply = 0
    case thank
    case hide
}

class TopicCommentCell: SwipCell
{
    lazy var avatarImageView: AvatarImageView = {
        let view = AvatarImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleToFill
        view.tintColor = .darkGray
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(avatarTapped)))
        
        return view
    }()
    
    lazy var ownerLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = R.Font.ExtraSmall
        label.textColor = .gray
        label.text = R.String.Owner
        label.isHidden = true
        
        return label
    }()
    
    lazy var userNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = R.Font.Small
        label.textColor = .middleGray
        label.setContentHuggingPriority(UILayoutPriorityRequired, for: .vertical)
        label.setContentCompressionResistancePriority(UILayoutPriorityDefaultLow, for: .vertical)
        
        return label
    }()
    
    lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = R.Font.ExtraSmall
        label.textColor = .borderGray
        label.setContentHuggingPriority(UILayoutPriorityRequired, for: .vertical)
        label.setContentCompressionResistancePriority(UILayoutPriorityDefaultLow, for: .vertical)

        return label
    }()
    
    lazy var likeImageView: UIImageView = {
        let view = UIImageView()
        view.image = R.Image.Like
        view.tintColor = .middleGray
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFit

        return view
    }()
    
    lazy var likeNumLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = R.Font.ExtraSmall
        label.textColor = .middleGray

        return label
    }()
    
    lazy var commentIndexLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = R.Font.ExtraSmall
        label.textColor = .middleGray
        label.text = R.String.Zero

        return label
    }()
    
    lazy var commentLabel: RichTextLabel = {
        let label = RichTextLabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setContentCompressionResistancePriority(UILayoutPriorityRequired, for: .vertical)

        return label
    }()
    
    lazy var separatorLine: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .borderGray
        
        return view
    }()
    
    weak var delegate: CommentCellDelegate?
    weak var commentModel: TopicCommentModel?
    var longPressGestureRecognizer: UILongPressGestureRecognizer!

    override init(style: UITableViewCellStyle, reuseIdentifier: String?)
    {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(avatarImageView)
        contentView.addSubview(ownerLabel)
        contentView.addSubview(userNameLabel)
        contentView.addSubview(dateLabel)
        contentView.addSubview(likeImageView)
        contentView.addSubview(likeNumLabel)
        contentView.addSubview(commentIndexLabel)
        contentView.addSubview(commentLabel)
        addSubview(separatorLine)
        let bindings = [
            "avatarImageView": avatarImageView,
            "ownerLabel": ownerLabel,
            "userNameLabel": userNameLabel,
            "dateLabel": dateLabel,
            "likeImageView": likeImageView,
            "likeNumLabel": likeNumLabel,
            "commentIndexLabel": commentIndexLabel,
            "commentLabel": commentLabel,
            "separatorLine": separatorLine,
            ]
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-8-[avatarImageView]-8-[userNameLabel]-8-[likeImageView]-1-[likeNumLabel]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: bindings))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[commentIndexLabel]-8-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: bindings))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[avatarImageView]-2-[ownerLabel]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: bindings))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[userNameLabel]-4-[commentLabel]-8-[dateLabel]-4-|", options: [.alignAllLeading], metrics: nil, views: bindings))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[separatorLine(0.5)]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: bindings))
        avatarImageView.widthAnchor.constraint(equalToConstant: R.Constant.AvatarSize).isActive = true
        avatarImageView.heightAnchor.constraint(equalToConstant: R.Constant.AvatarSize).isActive = true
        commentLabel.leadingAnchor.constraint(equalTo: userNameLabel.leadingAnchor).isActive = true
        userNameLabel.topAnchor.constraint(equalTo: avatarImageView.topAnchor).isActive = true
        likeImageView.centerYAnchor.constraint(equalTo: userNameLabel.centerYAnchor).isActive = true
        likeNumLabel.centerYAnchor.constraint(equalTo: userNameLabel.centerYAnchor).isActive = true
        commentIndexLabel.centerYAnchor.constraint(equalTo: userNameLabel.centerYAnchor).isActive = true
        ownerLabel.centerXAnchor.constraint(equalTo: avatarImageView.centerXAnchor).isActive = true
        commentLabel.trailingAnchor.constraint(equalTo: commentIndexLabel.trailingAnchor).isActive = true
        separatorLine.trailingAnchor.constraint(equalTo: commentIndexLabel.trailingAnchor).isActive = true
        separatorLine.leadingAnchor.constraint(equalTo: userNameLabel.leadingAnchor).isActive = true

        longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPress(_:)))
        addGestureRecognizer(longPressGestureRecognizer)
        longPressGestureRecognizer.delegate = self
        enableSwipe = User.shared.isLogin
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    
    override func prepareForReuse()
    {
        avatarImageView.cancelImageDownloadTaskIfNeed()
        super.prepareForReuse()
        avatarImageView.image = nil
        commentIndexLabel.text = R.String.Zero
        userNameLabel.font = R.Font.Small
        dateLabel.font = R.Font.ExtraSmall
        likeNumLabel.font = R.Font.ExtraSmall
        commentIndexLabel.font = R.Font.ExtraSmall
        likeImageView.tintColor = .middleGray
        ownerLabel.font = R.Font.ExtraSmall
        ownerLabel.isHidden = true
        contentView.backgroundColor = .white
    }
    
    @objc
    private func longPress(_ sender: UILongPressGestureRecognizer)
    {
        if sender.state == .began
        {
            reset()
            if let tableView = tableView(), let targetIndexPath = tableView.indexPath(for: self)
            {
                delegate?.longPress(at: targetIndexPath)
            }
        }
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
            if userNameLabel.text == User.shared.username
            {
                return false
            }
            if abs(panGestureRecognizer.velocity(in: self).y) > abs(panGestureRecognizer.velocity(in: self).x)
            {
                return false
            }
            if panGestureRecognizer.velocity(in: self).x > 0, isDirty == false
            {
                return false
            }
        }
        return true
    }
    
    // MARK: - Config swipe UI
    override func numberOfButtons() -> Int
    {
        return 3
    }
    
    override func iconViewForButton(atIndex index: Int) -> UIView
    {
        let iconView: UIImageView = {
            let view = UIImageView()
            view.tintColor = .middleGray
            view.translatesAutoresizingMaskIntoConstraints = false
            view.contentMode = .scaleAspectFit
            
            return view
        }()
        
        let btnType = ActionButtonType(rawValue: index)!
        switch btnType
        {
        case .reply:
            iconView.image = R.Image.Reply
            iconView.tintColor = .middleGray
        case .thank:
            iconView.image = R.Image.Thank
            if let commentModel = commentModel
            {
                iconView.tintColor = commentModel.isThanked ? .lightPink : .middleGray
            }
        case .hide:
            iconView.image = R.Image.Hide
            iconView.tintColor = .middleGray
        }

        return iconView
    }

    override func didTappedButton(atIndex index: Int)
    {
        cancelCellDragging()
        let btnType = ActionButtonType(rawValue: index)!
        switch btnType
        {
        case .reply:
            replayBtnTapped()
        case .thank:
            thankBtnTapped()
        case .hide:
            ignoreBtnTapped()
        }
    }
    
    // MARK: - Actions
    @objc
    private func avatarTapped()
    {
        if let username = commentModel?.username
        {
            delegate?.avatarTapped(withUsername: username)
        }
    }
    
    private func replayBtnTapped()
    {
        if let username = commentModel?.username
        {
            delegate?.replyBtnTapped(withUsername: username)
        }
    }
    
    private func thankBtnTapped()
    {
        if commentModel?.isThanked == false,
            let replyId = commentModel?.replyId,
            let tableView = tableView(),
            let targetIndexPath = tableView.indexPath(for: self)
        {
            delegate?.thankBtnTapped(withReplyId: replyId, indexPath: targetIndexPath)
        }
    }
    
    private func ignoreBtnTapped()
    {
        if let replyId = commentModel?.replyId
        {
            delegate?.ignoreBtnTapped(withReplyId: replyId)
        }
    }
    
}

