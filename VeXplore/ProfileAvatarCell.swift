//
//  ProfileAvatarCell.swift
//  VeXplore
//
//  Copyright © 2016 Jimmy. All rights reserved.
//


protocol ProfileAvatarCellDelegate: class
{
    func writeBtnTapped()
}

class ProfileAvatarCell: UITableViewCell
{
    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = R.Font.Medium
        label.textColor = .body
        
        return label
    }()
    
    lazy var avatarImageView: AvatarImageView = {
        let view = AvatarImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFit
        view.image = R.Image.AvatarPlaceholder
        view.tintColor = .body
        
        return view
    }()
    
    lazy var joinTimeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = R.Font.ExtraSmall
        label.textColor = .gray
        
        return label
    }()
    
    lazy var contentLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = R.Font.Small
        label.textColor = .desc
        
        return label
    }()
    
    private lazy var bottomLine: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .border
        
        return view
    }()
    
    lazy var writeBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setImage(R.Image.Write, for: .normal)
        btn.imageEdgeInsets = UIEdgeInsetsMake(-16, -12, -16, -12)
        btn.tintColor = .desc
        btn.addTarget(self, action: #selector(writeBtnTapped), for: .touchUpInside)
        btn.isHidden = true
        
        return btn
    }()
    
    weak var delegate: ProfileAvatarCellDelegate?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?)
    {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(writeBtn)
        contentView.addSubview(nameLabel)
        contentView.addSubview(avatarImageView)
        contentView.addSubview(joinTimeLabel)
        contentView.addSubview(contentLabel)
        contentView.addSubview(bottomLine)
        let bindings = [
            "writeBtn": writeBtn,
            "nameLabel": nameLabel,
            "avatarImageView": avatarImageView,
            "joinTimeLabel": joinTimeLabel,
            "contentLabel": contentLabel,
            "bottomLine": bottomLine
        ]
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[writeBtn(44)]", metrics: nil, views: bindings))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[writeBtn(52)]", metrics: nil, views: bindings))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-12-[nameLabel]-12-|", metrics: nil, views: bindings))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-24-[joinTimeLabel]-24-|", metrics: nil, views: bindings))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-24-[contentLabel]-24-|", metrics: nil, views: bindings))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[bottomLine]|", metrics: nil, views: bindings))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(30@999)-[avatarImageView(50@999)]-4-[nameLabel]-4-[joinTimeLabel]-8-[contentLabel]-8-[bottomLine(0.5)]|", metrics: nil, views: bindings))
        avatarImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        avatarImageView.heightAnchor.constraint(equalTo: avatarImageView.widthAnchor).isActive = true
        
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
        avatarImageView.cancelImageDownloadTaskIfNeed()
        super.prepareForReuse()
        avatarImageView.image = R.Image.AvatarPlaceholder
        contentLabel.text = nil
        joinTimeLabel.text = nil
        nameLabel.font = R.Font.Medium
        joinTimeLabel.font = R.Font.ExtraSmall
        contentLabel.font = R.Font.Small
    }
    
    @objc
    private func refreshColorScheme()
    {
        nameLabel.textColor = .body
        avatarImageView.tintColor = .body
        joinTimeLabel.textColor = .gray
        contentLabel.textColor = .desc
        bottomLine.backgroundColor = .border
        writeBtn.tintColor = .desc
        contentView.backgroundColor = .background
    }
    
    @objc
    private func writeBtnTapped(_ sender:UIButton)
    {
        delegate?.writeBtnTapped()
    }
    
}
