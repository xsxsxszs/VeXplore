//
//  FontSettingViewController.swift
//  VeXplore
//
//  Copyright © 2016 Jimmy. All rights reserved.
//

import SharedKit

class FontSettingViewController: BaseViewController, SliderDelegate
{
    private var fontScaleString = UserDefaults.fontScaleString
    private lazy var slider: Slider = {
        let slider = Slider(frame: self.view.bounds)
        slider.options = R.Array.FontSettingScales
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.delegate = self
        
        return slider
    }()
    
    private lazy var topicCellView: TopicCellView = {
        let cell = TopicCellView()
        cell.translatesAutoresizingMaskIntoConstraints = false
       
        return cell
    }()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        title = R.String.FontSettingTitle
        
        view.addSubview(slider)
        view.addSubview(topicCellView)
        let bindings: [String : Any] = [
            "slider": slider,
            "topicCellView": topicCellView,
            ]
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|-20-[slider]-20-|", metrics: nil, views: bindings))
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|[topicCellView]|", metrics: nil, views: bindings))
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|-25-[slider]-25-[topicCellView]", metrics: nil, views: bindings))
        
        let closeBtn = UIBarButtonItem(image: R.Image.Close, style: .plain, target: self, action: #selector(closeBtnTapped))
        let confirmBtn = UIBarButtonItem(image: R.Image.Confirm, style: .plain, target: self, action: #selector(confirmBtnTapped))
        confirmBtn.tintColor = .highlight
        navigationItem.leftBarButtonItem = closeBtn
        navigationItem.rightBarButtonItem = confirmBtn

        slider.selectedIndex = slider.options?.index(of: fontScaleString) ?? 0
    }
    
    @objc
    override func refreshColorScheme()
    {
        super.refreshColorScheme()
        view.backgroundColor = .subBackground
    }
    
    @objc
    override func handleContentSizeCategoryDidChanged()
    {
        super.handleContentSizeCategoryDidChanged()
        slider.prepareForReuse()
        topicCellView.prepareForReuse()
    }
    
    @objc
    private func closeBtnTapped()
    {
       _ = navigationController?.popViewController(animated: true)
    }
    
    @objc
    private func confirmBtnTapped()
    {
        UserDefaults.fontScaleString = fontScaleString
        NotificationCenter.default.post(name: Notification.Name.Setting.FontsizeDidChange, object: nil)
        _ = navigationController?.popViewController(animated: true)
    }

    // MARK: - SliderDelegate
    func didSelect(at index: Int)
    {
        let fontScale = CGFloat(slider.options![index].doubleValue)
        let scaledFontSize = round(SharedR.Font.Medium.pointSize * fontScale)
        let font = SharedR.Font.Medium.withSize(scaledFontSize)
        topicCellView.topicTitleLabel.font = font
        fontScaleString = slider.options![index]
    }
    
}

class TopicCellView: BaseView
{
    private lazy var avatarImageView: UIImageView = {
        let view = UIImageView()
        view.image = R.Image.WangXizhi.roundCornerImage()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleToFill

        return view
    }()
    
    private lazy var userNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = SharedR.Font.Small
        label.textColor = .desc
        label.text = R.String.WangXizhi

        return label
    }()
    
    lazy var topicTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = SharedR.Font.Medium
        label.numberOfLines = 0
        label.textColor = .body
        label.text = R.String.PrefaceOfLantingExcerpt
        return label
    }()
    
    lazy var nodeNameBtn: UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.layer.borderColor = UIColor.desc.cgColor
        btn.layer.borderWidth = 1
        btn.layer.cornerRadius = 3
        btn.setTitleColor(.desc, for: .normal)
        btn.titleLabel?.font = SharedR.Font.ExtraSmall
        btn.setTitle(R.String.PrefaceOfLanting, for: .normal)
        btn.contentEdgeInsets = UIEdgeInsets(top: 1, left: 3, bottom: 1, right: 3)
        btn.isUserInteractionEnabled = false
        
        return btn
    }()

    private lazy var commentImageView: UIImageView = {
        let view = UIImageView()
        view.image = R.Image.Comment
        view.tintColor = .desc
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFit
        
        return view
    }()
    
    private lazy var repliesNumberLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = SharedR.Font.ExtraSmall
        label.textColor = .desc
        label.text = R.String.Zero
        
        return label
    }()
    
    private lazy var lastReplayDateAndUserLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = SharedR.Font.ExtraSmall
        label.textColor = .note
        label.text = R.String.PrefaceOfLantingPublicTime

        return label
    }()
    
    private lazy var separatorLine: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .border
        
        return view
    }()
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        
        let bindings = [
            "avatarImageView": avatarImageView,
            "userNameLabel": userNameLabel,
            "nodeNameBtn": nodeNameBtn,
            "commentImageView": commentImageView,
            "repliesNumberLabel": repliesNumberLabel,
            "topicTitleLabel": topicTitleLabel,
            "lastReplayDateAndUserLabel": lastReplayDateAndUserLabel,
            "separatorLine": separatorLine
        ]

        
        addSubview(avatarImageView)
        addSubview(userNameLabel)
        addSubview(nodeNameBtn)
        addSubview(commentImageView)
        addSubview(repliesNumberLabel)
        addSubview(topicTitleLabel)
        addSubview(lastReplayDateAndUserLabel)
        addSubview(separatorLine)
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-8-[avatarImageView]-8-[userNameLabel]-8-[nodeNameBtn]", metrics: nil, views: bindings))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[commentImageView]-1-[repliesNumberLabel]-8-|", metrics: nil, views: bindings))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[userNameLabel]-6-[topicTitleLabel]-6-[lastReplayDateAndUserLabel]-4-[separatorLine(0.5)]|", options: [.alignAllLeading], metrics: nil, views: bindings))
        avatarImageView.topAnchor.constraint(equalTo: topAnchor, constant: 8).isActive = true
        avatarImageView.widthAnchor.constraint(equalToConstant: R.Constant.AvatarSize).isActive = true
        avatarImageView.heightAnchor.constraint(equalToConstant: R.Constant.AvatarSize).isActive = true
        commentImageView.centerYAnchor.constraint(equalTo: userNameLabel.centerYAnchor).isActive = true
        repliesNumberLabel.centerYAnchor.constraint(equalTo: userNameLabel.centerYAnchor).isActive = true
        nodeNameBtn.centerYAnchor.constraint(equalTo: userNameLabel.centerYAnchor).isActive = true
        userNameLabel.topAnchor.constraint(equalTo: avatarImageView.topAnchor).isActive = true
        separatorLine.trailingAnchor.constraint(equalTo: repliesNumberLabel.trailingAnchor).isActive = true
        topicTitleLabel.trailingAnchor.constraint(equalTo: repliesNumberLabel.trailingAnchor).isActive = true
        lastReplayDateAndUserLabel.trailingAnchor.constraint(equalTo: repliesNumberLabel.trailingAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    func prepareForReuse()
    {
        userNameLabel.font = SharedR.Font.Small
        topicTitleLabel.font = SharedR.Font.Medium
        nodeNameBtn.titleLabel?.font = SharedR.Font.ExtraSmall
        repliesNumberLabel.font = SharedR.Font.ExtraSmall
        lastReplayDateAndUserLabel.font = SharedR.Font.ExtraSmall
    }
    
    @objc
    override func refreshColorScheme()
    {
        super.refreshColorScheme()
        avatarImageView.tintColor = .body
        userNameLabel.textColor = .desc
        topicTitleLabel.textColor = .body
        nodeNameBtn.layer.borderColor = UIColor.desc.cgColor
        nodeNameBtn.setTitleColor(.desc, for: .normal)
        commentImageView.tintColor = .desc
        repliesNumberLabel.textColor = .desc
        lastReplayDateAndUserLabel.textColor = .note
        separatorLine.backgroundColor = .border
    }
    
}
