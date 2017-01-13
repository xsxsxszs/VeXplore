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
        label.textColor = .darkGray
        
        return label
    }()
    
    lazy var avatarImageView: AvatarImageView = {
        let view = AvatarImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFit
        view.image = R.Image.AvatarPlaceholder
        view.tintColor = .darkGray
        
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
        label.textColor = .middleGray
        
        return label
    }()
    
    private lazy var bottomLine: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .borderGray
        
        return view
    }()
    
    lazy var writeBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.translatesAutoresizingMaskIntoConstraints = false
        let image = R.Image.Write
        btn.setImage(image, for: .normal)
        btn.imageEdgeInsets = UIEdgeInsetsMake(-16, -12, -16, -12)
        btn.tintColor = .middleGray
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
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[writeBtn(44)]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: bindings))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[writeBtn(52)]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: bindings))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-12-[nameLabel]-12-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: bindings))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-24-[joinTimeLabel]-24-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: bindings))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-24-[contentLabel]-24-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: bindings))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[bottomLine]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: bindings))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(30@999)-[avatarImageView(50@999)]-4-[nameLabel]-4-[joinTimeLabel]-8-[contentLabel]-8-[bottomLine(0.5)]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: bindings))
        avatarImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        avatarImageView.heightAnchor.constraint(equalTo: avatarImageView.widthAnchor).isActive = true
        
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
        avatarImageView.image = R.Image.AvatarPlaceholder
        contentLabel.text = nil
        joinTimeLabel.text = nil
        nameLabel.font = R.Font.Medium
        joinTimeLabel.font = R.Font.ExtraSmall
        contentLabel.font = R.Font.Small
    }
    
    @objc
    private func writeBtnTapped(_ sender:UIButton)
    {
        delegate?.writeBtnTapped()
    }
    
}
