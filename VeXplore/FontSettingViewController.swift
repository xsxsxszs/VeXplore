//
//  FontSettingViewController.swift
//  VeXplore
//
//  Copyright © 2016 Jimmy. All rights reserved.
//


class FontSettingViewController: UIViewController, SliderDelegate
{
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
    
    weak var settingVC: SettingViewController?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        navigationController?.navigationBar.isTranslucent = false
        title = R.String.FontSettingTitle
        
        if let settingVC = settingVC
        {
            slider.selectedIndex = slider.options?.index(of: settingVC.fontScaleString)
        }
        
        view.addSubview(slider)
        view.addSubview(topicCellView)
        let bindings: [String: Any] = [
            "slider": slider,
            "topicCellView": topicCellView,
            ]
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|-20-[slider]-20-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: bindings))
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|[topicCellView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: bindings))
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|-25-[slider]-25-[topicCellView]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: bindings))
        
        let closeBtn = UIBarButtonItem(image: R.Image.Close, style: .plain, target: self, action: #selector(closeBtnTapped))
        closeBtn.tintColor = .middleGray
        navigationItem.leftBarButtonItem = closeBtn
        view.backgroundColor = .offWhite
        NotificationCenter.default.addObserver(self, selector: #selector(handleContentSizeCategoryDidChanged), name: NSNotification.Name.UIContentSizeCategoryDidChange, object: nil)
    }
    
    @objc
    private func handleContentSizeCategoryDidChanged()
    {
        slider.prepareForReuse()
        topicCellView.prepareForReuse()
    }
    
    @objc
    private func closeBtnTapped()
    {
       _ = navigationController?.popViewController(animated: true)
    }

    // MARK: - SliderDelegate
    func didSelect(at index: Int)
    {
        let fontScale = CGFloat(slider.options![index].doubleValue)
        let scaledFontSize = round(R.Font.Medium.pointSize * fontScale)
        let font = R.Font.Medium.withSize(scaledFontSize)
        topicCellView.topicTitleLabel.font = font
        settingVC?.fontScaleString = slider.options![index]
        settingVC?.tableView.reloadData()
    }
    
}

class TopicCellView: UIView
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
        label.font = R.Font.Small
        label.textColor = .middleGray
        label.text = R.String.WangXizhi

        return label
    }()
    
    lazy var topicTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = R.Font.Medium
        label.numberOfLines = 0
        label.textColor = .darkGray
        label.text = R.String.PrefaceOfLantingExcerpt
        return label
    }()
    
    private lazy var nodeNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = R.Font.ExtraSmall
        label.textColor = .middleGray
        label.text = R.String.PrefaceOfLanting

        return label
    }()
    
    private lazy var nodeNameContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.borderColor = UIColor.middleGray.cgColor
        view.layer.borderWidth = 1
        view.layer.cornerRadius = 3
        
        return view
    }()
    
    private lazy var commentImageView: UIImageView = {
        let view = UIImageView()
        view.image = R.Image.Comment
        view.tintColor = .middleGray
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFit
        
        return view
    }()
    
    private lazy var repliesNumberLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = R.Font.ExtraSmall
        label.textColor = .middleGray
        label.text = R.String.Zero
        
        return label
    }()
    
    private lazy var lastReplayDateAndUserLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = R.Font.ExtraSmall
        label.textColor = .borderGray
        label.text = R.String.PrefaceOfLantingPublicTime

        return label
    }()
    
    private lazy var separatorLine: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .borderGray
        
        return view
    }()
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        
        let bindings = [
            "avatarImageView": avatarImageView,
            "userNameLabel": userNameLabel,
            "nodeNameLabel": nodeNameLabel,
            "nodeNameContainerView": nodeNameContainerView,
            "commentImageView": commentImageView,
            "repliesNumberLabel": repliesNumberLabel,
            "topicTitleLabel": topicTitleLabel,
            "lastReplayDateAndUserLabel": lastReplayDateAndUserLabel,
            "separatorLine": separatorLine
        ]
        
        nodeNameContainerView.addSubview(nodeNameLabel)
        nodeNameContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-3-[nodeNameLabel]-3-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: bindings))
        nodeNameContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-1-[nodeNameLabel]-1-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: bindings))
        
        addSubview(avatarImageView)
        addSubview(userNameLabel)
        addSubview(nodeNameContainerView)
        addSubview(commentImageView)
        addSubview(repliesNumberLabel)
        addSubview(topicTitleLabel)
        addSubview(lastReplayDateAndUserLabel)
        addSubview(separatorLine)
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-8-[avatarImageView]-8-[userNameLabel]-8-[nodeNameContainerView]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: bindings))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[commentImageView]-1-[repliesNumberLabel]-8-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: bindings))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[userNameLabel]-6-[topicTitleLabel]-6-[lastReplayDateAndUserLabel]-4-[separatorLine(0.5)]|", options: [.alignAllLeading], metrics: nil, views: bindings))
        avatarImageView.topAnchor.constraint(equalTo: topAnchor, constant: 8).isActive = true
        avatarImageView.widthAnchor.constraint(equalToConstant: R.Constant.AvatarSize).isActive = true
        avatarImageView.heightAnchor.constraint(equalToConstant: R.Constant.AvatarSize).isActive = true
        commentImageView.centerYAnchor.constraint(equalTo: userNameLabel.centerYAnchor).isActive = true
        repliesNumberLabel.centerYAnchor.constraint(equalTo: userNameLabel.centerYAnchor).isActive = true
        nodeNameContainerView.centerYAnchor.constraint(equalTo: userNameLabel.centerYAnchor).isActive = true
        userNameLabel.topAnchor.constraint(equalTo: avatarImageView.topAnchor).isActive = true
        separatorLine.trailingAnchor.constraint(equalTo: repliesNumberLabel.trailingAnchor).isActive = true
        topicTitleLabel.trailingAnchor.constraint(equalTo: repliesNumberLabel.trailingAnchor).isActive = true
        lastReplayDateAndUserLabel.trailingAnchor.constraint(equalTo: repliesNumberLabel.trailingAnchor).isActive = true
        
        backgroundColor = .white
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    func prepareForReuse()
    {
        userNameLabel.font = R.Font.Small
        topicTitleLabel.font = R.Font.Medium
        nodeNameLabel.font = R.Font.ExtraSmall
        repliesNumberLabel.font = R.Font.ExtraSmall
        lastReplayDateAndUserLabel.font = R.Font.ExtraSmall
    }
    
}
