//
//  TopicDetailHeaderCell.swift
//  VeXplore
//
//  Copyright © 2016 Jimmy. All rights reserved.
//


class TopicDetailHeaderCell: UITableViewCell
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
    
    lazy var userNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = R.Font.Small
        label.textColor = .middleGray
        
        return label
    }()
    
    lazy var topicTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = R.Font.Medium
        label.numberOfLines = 0
        label.textColor = .darkGray
        
        return label
    }()
    
    lazy var nodeNameBtn: UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.layer.borderColor = UIColor.middleGray.cgColor
        btn.layer.borderWidth = 1
        btn.layer.cornerRadius = 3
        btn.setTitleColor(.middleGray, for: .normal)
        btn.titleLabel?.font = R.Font.ExtraSmall
        btn.contentEdgeInsets = UIEdgeInsets(top: 1, left: 3, bottom: 1, right: 3)
        btn.addTarget(self, action: #selector(nodeTapped), for: .touchUpInside)
        
        return btn
    }()
    
    lazy var commentImageView: UIImageView = {
        let view = UIImageView()
        view.image = R.Image.Comment
        view.tintColor = .middleGray
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFit
        
        return view
    }()
    
    lazy var repliesNumberLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = R.Font.ExtraSmall
        label.textColor = .middleGray
        label.text = R.String.Zero
        
        return label
    }()
    
    lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = R.Font.ExtraSmall
        label.textColor = .borderGray
        label.textAlignment = .left
        label.setContentHuggingPriority(UILayoutPriorityDefaultLow, for: .horizontal)
        label.setContentCompressionResistancePriority(UILayoutPriorityDefaultLow, for: .horizontal)
        
        return label
    }()
    
    lazy var favoriteContainerView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        let gesture =  UITapGestureRecognizer(target: self, action: #selector(favoriteBtnTapped))
        view.addGestureRecognizer(gesture)
        view.isUserInteractionEnabled = true
        view.isHidden = true
        
        return view
    }()
    
    lazy var likeImageView: UIImageView = {
        let view = UIImageView()
        view.image = R.Image.Like
        view.tintColor = .middleGray
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFit
        
        return view
    }()
    
    lazy var favoriteNumLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = R.Font.ExtraSmall
        label.textColor = .middleGray
        label.textAlignment = .right
        label.setContentHuggingPriority(UILayoutPriorityRequired, for: .horizontal)
        label.setContentCompressionResistancePriority(UILayoutPriorityRequired, for: .horizontal)
        label.text = R.String.NoFavorite
        
        return label
    }()

    lazy var separatorLine: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .borderGray
        
        return view
    }()
    
    var topicDetailModel: TopicDetailModel?
    weak var delegate: TopicDetailDelegate?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?)
    {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    
        let bindings = [
            "avatarImageView": avatarImageView,
            "userNameLabel": userNameLabel,
            "nodeNameBtn": nodeNameBtn,
            "commentImageView": commentImageView,
            "repliesNumberLabel": repliesNumberLabel,
            "topicTitleLabel": topicTitleLabel,
            "dateLabel": dateLabel,
            "favoriteContainerView": favoriteContainerView,
            "likeImageView": likeImageView,
            "favoriteNumLabel": favoriteNumLabel,
            "separatorLine": separatorLine
        ]
        
        favoriteContainerView.addSubview(likeImageView)
        favoriteContainerView.addSubview(favoriteNumLabel)
        favoriteContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-12-[likeImageView]-1-[favoriteNumLabel]-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: bindings))
        favoriteContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-12-[likeImageView]-1-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: bindings))
        favoriteNumLabel.centerYAnchor.constraint(equalTo: likeImageView.centerYAnchor).isActive = true
        
        contentView.addSubview(avatarImageView)
        contentView.addSubview(userNameLabel)
        contentView.addSubview(nodeNameBtn)
        contentView.addSubview(commentImageView)
        contentView.addSubview(repliesNumberLabel)
        contentView.addSubview(topicTitleLabel)
        contentView.addSubview(dateLabel)
        contentView.addSubview(favoriteContainerView)
        contentView.addSubview(separatorLine)
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-8-[avatarImageView]-8-[userNameLabel]-8-[nodeNameBtn]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: bindings))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[commentImageView]-1-[repliesNumberLabel]-8-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: bindings))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[userNameLabel]-6-[topicTitleLabel]-6-[dateLabel]-4-|", options: [.alignAllLeading], metrics: nil, views: bindings))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[dateLabel]-(>=0)-[favoriteContainerView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: bindings))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-8-[avatarImageView]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: bindings))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[separatorLine]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: bindings))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[separatorLine(1)]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: bindings))
        avatarImageView.widthAnchor.constraint(equalToConstant: R.Constant.AvatarSize).isActive = true
        avatarImageView.heightAnchor.constraint(equalToConstant: R.Constant.AvatarSize).isActive = true
        userNameLabel.topAnchor.constraint(equalTo: avatarImageView.topAnchor).isActive = true
        commentImageView.centerYAnchor.constraint(equalTo: userNameLabel.centerYAnchor).isActive = true
        repliesNumberLabel.centerYAnchor.constraint(equalTo: userNameLabel.centerYAnchor).isActive = true
        nodeNameBtn.centerYAnchor.constraint(equalTo: userNameLabel.centerYAnchor).isActive = true
        topicTitleLabel.leadingAnchor.constraint(equalTo: userNameLabel.leadingAnchor).isActive = true
        topicTitleLabel.trailingAnchor.constraint(equalTo: repliesNumberLabel.trailingAnchor).isActive = true
        likeImageView.centerYAnchor.constraint(equalTo: dateLabel.centerYAnchor).isActive = true

        contentView.backgroundColor = .white
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
        avatarImageView.cancelImageDownloadTaskIfNeed()
        super.prepareForReuse()
        avatarImageView.image = nil
        repliesNumberLabel.text = R.String.Zero
        favoriteNumLabel.text = R.String.NoFavorite
        favoriteContainerView.isHidden = true
        userNameLabel.font = R.Font.Small
        topicTitleLabel.font = R.Font.Medium
        nodeNameBtn.titleLabel?.font = R.Font.ExtraSmall
        repliesNumberLabel.font = R.Font.ExtraSmall
        dateLabel.font = R.Font.ExtraSmall
        favoriteNumLabel.font = R.Font.ExtraSmall
    }
    
    // MARK: - Actions
    @objc
    private func avatarTapped()
    {
        if let username = topicDetailModel?.username
        {
            delegate?.avatarTapped(withUsername: username)
        }
    }
    
    @objc
    private func nodeTapped()
    {
        if let nodeId = topicDetailModel?.nodeId
        {
            delegate?.nodeTapped(withNodeId: nodeId, nodeName: topicDetailModel?.nodeName)
        }
    }
    
    @objc
    private func favoriteBtnTapped()
    {
        delegate?.favoriteBtnTapped()
    }
    
}
