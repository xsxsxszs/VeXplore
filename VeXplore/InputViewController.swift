//
//  InputViewController.swift
//  VeXplore
//
//  Copyright © 2016 Jimmy. All rights reserved.
//

import SafariServices

class InputViewController: UIViewController, SquareLoadingViewDelegate, SFSafariViewControllerDelegate, UITextViewDelegate
{
    lazy var backgroudView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .offWhite
        view.alpha = 0.8
        view.isHidden = true
        
        return view
    }()
    
    lazy var inputContainerView: InputContainerView = {
        let view = InputContainerView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.titleTextView.delegate = self
        view.contentTextView.delegate = self
        view.cancelBtn.addTarget(self, action: #selector(closeBtnTapped), for: .touchUpInside)
        view.postBtn.addTarget(self, action: #selector(postBtnTapped), for: .touchUpInside)
        view.imageBtn.addTarget(self, action: #selector(imageBtnTapped), for: .touchUpInside)
        
        return view
    }()
    
    lazy var centerLoadingView: SquaresLoadingView = {
        let view = SquaresLoadingView(loadingStyle: LoadingStyle.bottom)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        view.delegate = self
        
        return view
    }()
    
    lazy var loadingCancelBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.translatesAutoresizingMaskIntoConstraints = false
        let image = R.Image.RoundClose
        btn.setImage(image, for: .normal)
        btn.tintColor = .darkGray
        btn.addTarget(self, action: #selector(cancelBtnTapped), for: .touchUpInside)
        btn.isHidden = true
        
        return btn
    }()
    
    private var isKeyboardShowed = false
    private var safariVC: SFSafariViewController!
    var copyedString = R.String.Empty
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?)
    {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        modalPresentationStyle = .custom
        transitioningDelegate  = ModalTransitioningDelegate.shared
        resetTextViews()
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        let bindings: [String: Any] = [
            "inputContainerView": inputContainerView,
            "backgroudView": backgroudView,
            "centerLoadingView": centerLoadingView,
            "loadingCancelBtn": loadingCancelBtn,
            "top": topLayoutGuide
        ]
        
        inputContainerView.addSubview(backgroudView)
        inputContainerView.addSubview(centerLoadingView)
        inputContainerView.addSubview(loadingCancelBtn)
        inputContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[backgroudView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: bindings))
        inputContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[backgroudView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: bindings))
        inputContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[centerLoadingView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: bindings))
        loadingCancelBtn.centerXAnchor.constraint(equalTo: inputContainerView.cancelBtn.centerXAnchor).isActive = true
        loadingCancelBtn.centerYAnchor.constraint(equalTo: inputContainerView.cancelBtn.centerYAnchor).isActive = true
        loadingCancelBtn.widthAnchor.constraint(equalTo: inputContainerView.cancelBtn.widthAnchor).isActive = true
        loadingCancelBtn.heightAnchor.constraint(equalTo: inputContainerView.cancelBtn.heightAnchor).isActive = true
        centerLoadingView.centerYAnchor.constraint(equalTo: inputContainerView.centerYAnchor).isActive = true
        centerLoadingView.heightAnchor.constraint(equalToConstant: R.Constant.LoadingViewHeight).isActive = true
        
        view.addSubview(inputContainerView)
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-8@999-[inputContainerView]-8@999-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: bindings))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(8@998)-[inputContainerView]-(8@999)-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: bindings))
        inputContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        inputContainerView.centerYAnchor.constraint(lessThanOrEqualTo: view.centerYAnchor).isActive = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleContentSizeCategoryDidChanged), name: NSNotification.Name.UIContentSizeCategoryDidChange, object: nil)
    }
    
    func resetTextViews()
    {
        loadingCancelBtn.isHidden = true
        backgroudView.isHidden = true
        centerLoadingView.isHidden = true
        inputContainerView.isPostEnabled = false
        inputContainerView.titleTextView.text = R.String.Empty
        inputContainerView.contentTextView.text = R.String.Empty
        inputContainerView.nodeBtn.setAttributedTitle(NSAttributedString(string: R.String.ChooseNode, attributes: [NSFontAttributeName: R.Font.Small, NSForegroundColorAttributeName: UIColor.lightPink]), for: .normal)
    }
    
    @objc
    private func handleContentSizeCategoryDidChanged()
    {
        inputContainerView.prepareForReuse()
    }
    
    // MARK: - UITextViewDelegate
    func textViewDidBeginEditing(_ textView: UITextView)
    {
        inputContainerView.isImageBtnEnabled = (textView == inputContainerView.contentTextView)
    }
    
    // MARK: - Actions
    @objc
    private func cancelBtnTapped()
    {
        backgroudView.isHidden = true
        loadingCancelBtn.isHidden = true
        centerLoadingView.isHidden = true
    }
    
    // may need to override this method in subclass
    func closeBtnTapped()
    {
        dismiss(animated: true) {
            if ModalTransitioningDelegate.shared.reverseDirection == true
            {
                self.resetTextViews()
            }
            ModalTransitioningDelegate.shared.reverseDirection = false
        }
    }
    
    // may need to override this method in subclass
    func imageBtnTapped()
    {
        if let urlString = R.String.ImageUploadUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
            let url = URL(string: urlString)
        {
            safariVC = SFSafariViewController(url: url, entersReaderIfAvailable: true)
            copyedString = UIPasteboard.general.string ?? R.String.Empty
            safariVC.delegate = self
            present(safariVC, animated: true, completion: nil)
        }
    }
    
    func postBtnTapped()
    {
        // override this method in subclass
    }
    
    func didTriggeredReloading()
    {
        centerLoadingView.beginLoading()
        postBtnTapped()
    }

}



//////////////////
////// VIEW //////
//////////////////

class InputContainerView: UIView
{
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = R.Font.VeryLarge
        label.textColor = .gray
        label.text = User.shared.username
        
        return label
    }()
    
    lazy var cancelBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.translatesAutoresizingMaskIntoConstraints = false
        let image = R.Image.RoundClose
        btn.setImage(image, for: .normal)
        btn.tintColor = .middleGray
        
        return btn
    }()
    
    lazy var postBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.translatesAutoresizingMaskIntoConstraints = false
        let image = R.Image.Send
        btn.setImage(image, for: .normal)
        btn.tintColor = .borderGray
        btn.isEnabled = false
        
        return btn
    }()
    
    lazy var topLine: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .borderGray
        
        return view
    }()
    
    lazy var middleLine: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .borderGray
        
        return view
    }()
    
    lazy var bottomLine: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .borderGray
        
        return view
    }()
    
    private lazy var imageBtnIcon: UIImageView = {
        let view = UIImageView()
        view.image = R.Image.ImageIcon
        view.tintColor = .borderGray
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFit
        
        return view
    }()
    
    lazy var imageBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.backgroundColor = .clear
        btn.isEnabled = false
        
        return btn
    }()
    
    lazy var nodeBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.translatesAutoresizingMaskIntoConstraints = false
        let title = NSAttributedString(string: R.String.ChooseNode, attributes: [NSFontAttributeName: R.Font.Small, NSForegroundColorAttributeName: UIColor.lightPink])
        btn.setAttributedTitle(title, for: .normal)
        btn.isHidden = true
        
        return btn
    }()
    
    private lazy var bottomLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = R.Font.Small
        label.textColor = .borderGray
        label.text = R.String.CopyUrlAfterUploadingImage
        label.setContentHuggingPriority(UILayoutPriorityRequired, for: .vertical)
        
        return label
    }()
    
    lazy var titleTextView: PlaceholderTextView = {
        let view = PlaceholderTextView()
        view.font = R.Font.Medium
        view.textContainerInset = UIEdgeInsetsMake(4, 6, 4, 6)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.tintColor = .lightPink
        view.textColor = .darkGray
        view.autocorrectionType = .no
        let style = NSMutableParagraphStyle()
        style.lineHeightMultiple = 1.1
        view.typingAttributes[NSParagraphStyleAttributeName] = style
        
        return view
    }()
    
    lazy var contentTextView: PlaceholderTextView = {
        let view = PlaceholderTextView()
        view.font = R.Font.Medium
        view.textContainerInset = UIEdgeInsetsMake(8, 6, 8, 6)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.tintColor = .lightPink
        view.textColor = .darkGray
        view.autocorrectionType = .no
        let style = NSMutableParagraphStyle()
        style.lineHeightMultiple = 1.1
        view.typingAttributes[NSParagraphStyleAttributeName] = style
        
        return view
    }()
    
    var isPostEnabled: Bool = false {
        didSet
        {
            postBtn.isEnabled = isPostEnabled
            postBtn.tintColor = isPostEnabled ? .lightPink : .borderGray
        }
    }
    
    var isImageBtnEnabled: Bool = false {
        didSet
        {
            imageBtn.isEnabled = isImageBtnEnabled
            imageBtnIcon.tintColor = isImageBtnEnabled ? .middleGray : .borderGray
            bottomLabel.textColor = isImageBtnEnabled ? .middleGray : .borderGray
        }
    }
    
    var titleTextViewHeight: NSLayoutConstraint!
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)

        addSubview(titleLabel)
        addSubview(cancelBtn)
        addSubview(postBtn)
        addSubview(topLine)
        addSubview(contentTextView)
        addSubview(titleTextView)
        addSubview(middleLine)
        addSubview(bottomLine)
        addSubview(imageBtnIcon)
        addSubview(nodeBtn)
        addSubview(bottomLabel)
        addSubview(imageBtn)
        let bindings = [
            "titleLabel": titleLabel,
            "cancelBtn": cancelBtn,
            "postBtn": postBtn,
            "topLine": topLine,
            "contentTextView": contentTextView,
            "titleTextView": titleTextView,
            "middleLine": middleLine,
            "bottomLine": bottomLine,
            "imageBtnIcon": imageBtnIcon,
            "imageBtn": imageBtn,
            "nodeBtn": nodeBtn,
            "bottomLabel": bottomLabel
        ]
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[cancelBtn(41)]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: bindings))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[postBtn(41)]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: bindings))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[topLine]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: bindings))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[middleLine]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: bindings))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[bottomLine]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: bindings))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[contentTextView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: bindings))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[titleTextView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: bindings))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[postBtn][topLine(0.5)][titleTextView][middleLine(0.5)][contentTextView][bottomLine(0.5)]-10-[imageBtnIcon]-10-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: bindings))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-8-[imageBtnIcon(25)]-8-[bottomLabel]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: bindings))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[nodeBtn]-8-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: bindings))
        cancelBtn.heightAnchor.constraint(equalTo: cancelBtn.widthAnchor).isActive = true
        postBtn.heightAnchor.constraint(equalTo: postBtn.widthAnchor).isActive = true
        cancelBtn.centerYAnchor.constraint(equalTo: postBtn.centerYAnchor).isActive = true
        titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        titleLabel.centerYAnchor.constraint(equalTo: postBtn.centerYAnchor).isActive = true
        bottomLabel.centerYAnchor.constraint(equalTo: imageBtn.centerYAnchor).isActive = true
        nodeBtn.centerYAnchor.constraint(equalTo: imageBtnIcon.centerYAnchor).isActive = true
        imageBtnIcon.heightAnchor.constraint(equalTo: imageBtnIcon.widthAnchor).isActive = true
        imageBtn.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        imageBtn.trailingAnchor.constraint(equalTo: bottomLabel.trailingAnchor).isActive = true
        imageBtn.topAnchor.constraint(equalTo: bottomLine.bottomAnchor).isActive = true
        imageBtn.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        heightAnchor.constraint(lessThanOrEqualToConstant: R.Constant.InputViewHeightMax - 16).isActive = true
        widthAnchor.constraint(lessThanOrEqualToConstant: R.Constant.InputViewWidthMax - 16).isActive = true
        titleTextViewHeight = NSLayoutConstraint(item: titleTextView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 0)
        addConstraint(titleTextViewHeight)
        
        layer.cornerRadius = 10
        clipsToBounds = true
        layer.shadowOpacity = 0.7
        layer.shadowOffset = CGSize.zero
        layer.shadowPath = UIBezierPath(rect: layer.bounds).cgPath
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    func prepareForReuse()
    {
        titleLabel.font = R.Font.VeryLarge
        bottomLabel.font = R.Font.Small
        titleTextView.font = R.Font.Medium
        contentTextView.font = R.Font.Medium
        titleTextView.setNeedsDisplay()
        contentTextView.setNeedsDisplay()
        let nodeName = nodeBtn.attributedTitle(for: .normal)?.string ?? R.String.ChooseNode
        nodeBtn.setAttributedTitle(NSAttributedString(string: nodeName, attributes: [NSFontAttributeName: R.Font.Small, NSForegroundColorAttributeName: UIColor.lightPink]), for: .normal)
    }
    
}
