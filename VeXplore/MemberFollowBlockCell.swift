//
//  MemberFollowBlockCell.swift
//  VeXplore
//
//  Copyright © 2016 Jimmy. All rights reserved.
//


protocol MemberFollowBlockCellDelegate: class
{
    func followViewTapped()
    func blockViewViewTapped()
}

class MemberFollowBlockCell: BaseTableViewCell
{
    lazy var followView: ProfileActionView = {
        let view = ProfileActionView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(followViewTapped)))
        
        return view
    }()
    
    lazy var blockView: ProfileActionView = {
        let view = ProfileActionView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.verticalLine.isHidden = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(blockViewViewTapped)))
        
        return view
    }()
    
    private lazy var bottomLine: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .border
        
        return view
    }()
    
    weak var delegate: MemberFollowBlockCellDelegate?

    override init(style: UITableViewCellStyle, reuseIdentifier: String?)
    {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(followView)
        contentView.addSubview(blockView)
        contentView.addSubview(bottomLine)
        let bindings = [
            "followView": followView,
            "blockView": blockView,
            "bottomLine": bottomLine
            ]
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[followView][blockView]|", options: [.alignAllTop, .alignAllBottom], metrics: nil, views: bindings))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[bottomLine]|", metrics: nil, views: bindings))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-8-[blockView]-8-[bottomLine(0.5)]|", metrics: nil, views: bindings))
        followView.widthAnchor.constraint(equalTo: blockView.widthAnchor).isActive = true
        
        selectionStyle = .none
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    
    // MARK: - Actions
    @objc
    private func followViewTapped()
    {
        delegate?.followViewTapped()
    }
    
    @objc
    private func blockViewViewTapped()
    {
        delegate?.blockViewViewTapped()
    }
    
    override func prepareForReuse()
    {
        super.prepareForReuse()
        followView.prepareForReuse()
        blockView.prepareForReuse()
    }
    
    @objc
    override func refreshColorScheme()
    {
        super.refreshColorScheme()
        bottomLine.backgroundColor = .border
    }
    
}
