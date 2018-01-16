//
//  InputViewController.swift
//  VeXplore
//
//  Copyright © 2016 Jimmy. All rights reserved.
//

import SafariServices
import SharedKit

class InputViewController: BaseViewController, SquareLoadingViewDelegate, SFSafariViewControllerDelegate, UITextViewDelegate
{
    lazy var backgroudView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .subBackground
        view.alpha = 0.8
        view.isHidden = true
        
        return view
    }()
    
    lazy var inputContainerView: InputContainerView = {
        let view = InputContainerView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .background
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
        btn.setImage(R.Image.RoundClose, for: .normal)
        btn.tintColor = .body
        btn.addTarget(self, action: #selector(cancelBtnTapped), for: .touchUpInside)
        btn.isHidden = true
        
        return btn
    }()
    
    private var isKeyboardShowed = false
    private var safariVC: SFSafariViewController!
    var copyedString = SharedR.String.Empty
    
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
        
        let bindings: [String : Any] = [
            "inputContainerView": inputContainerView,
            "backgroudView": backgroudView,
            "centerLoadingView": centerLoadingView,
            "loadingCancelBtn": loadingCancelBtn,
            "top": topLayoutGuide
        ]
        
        inputContainerView.addSubview(backgroudView)
        inputContainerView.addSubview(centerLoadingView)
        inputContainerView.addSubview(loadingCancelBtn)
        inputContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[backgroudView]|", metrics: nil, views: bindings))
        inputContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[backgroudView]|", metrics: nil, views: bindings))
        loadingCancelBtn.centerXAnchor.constraint(equalTo: inputContainerView.cancelBtn.centerXAnchor).isActive = true
        loadingCancelBtn.centerYAnchor.constraint(equalTo: inputContainerView.cancelBtn.centerYAnchor).isActive = true
        loadingCancelBtn.widthAnchor.constraint(equalTo: inputContainerView.cancelBtn.widthAnchor).isActive = true
        loadingCancelBtn.heightAnchor.constraint(equalTo: inputContainerView.cancelBtn.heightAnchor).isActive = true
        centerLoadingView.centerXAnchor.constraint(equalTo: inputContainerView.centerXAnchor).isActive = true
        centerLoadingView.centerYAnchor.constraint(equalTo: inputContainerView.centerYAnchor).isActive = true
        centerLoadingView.heightAnchor.constraint(equalToConstant: R.Constant.LoadingViewHeight).isActive = true
        
        view.addSubview(inputContainerView)
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-8@999-[inputContainerView]-8@999-|", metrics: nil, views: bindings))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(8@998)-[inputContainerView]-(8@999)-|", metrics: nil, views: bindings))
        inputContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        inputContainerView.centerYAnchor.constraint(lessThanOrEqualTo: view.centerYAnchor).isActive = true
    }
    
    @objc
    override func refreshColorScheme()
    {
        super.refreshColorScheme()
        view.backgroundColor = .clear
        backgroudView.backgroundColor = .subBackground
        inputContainerView.backgroundColor = .background
    }
    
    func resetTextViews()
    {
        loadingCancelBtn.isHidden = true
        backgroudView.isHidden = true
        centerLoadingView.isHidden = true
        inputContainerView.isPostEnabled = false
        inputContainerView.titleTextView.text = SharedR.String.Empty
        inputContainerView.contentTextView.text = SharedR.String.Empty
        inputContainerView.nodeBtn.setAttributedTitle(NSAttributedString(string: R.String.ChooseNode, attributes: [NSAttributedStringKey.font: SharedR.Font.Small, NSAttributedStringKey.foregroundColor: UIColor.highlight]), for: .normal)
    }
    
    @objc
    override func handleContentSizeCategoryDidChanged()
    {
        super.handleContentSizeCategoryDidChanged()
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
    @objc
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
    @objc
    func imageBtnTapped()
    {
        if let urlString = R.String.ImageUploadUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
            let url = URL(string: urlString)
        {
            safariVC = SFSafariViewController(url: url, entersReaderIfAvailable: true)
            copyedString = UIPasteboard.general.string ?? SharedR.String.Empty
            safariVC.delegate = self
            present(safariVC, animated: true, completion: nil)
        }
    }
    
    @objc
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

class InputContainerView: BaseView
{
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = SharedR.Font.VeryLarge
        label.textColor = .gray
        label.text = User.shared.username
        
        return label
    }()
    
    lazy var cancelBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setImage(R.Image.RoundClose, for: .normal)
        btn.tintColor = .desc
        
        return btn
    }()
    
    lazy var postBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setImage(R.Image.Send, for: .normal)
        btn.tintColor = .border
        btn.isEnabled = false
        
        return btn
    }()
    
    lazy var topLine: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .border
        
        return view
    }()
    
    lazy var middleLine: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .border
        
        return view
    }()
    
    lazy var bottomLine: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .border
        
        return view
    }()
    
    private lazy var imageBtnIcon: UIImageView = {
        let view = UIImageView()
        view.image = R.Image.ImageIcon
        view.tintColor = .border
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
        let title = NSAttributedString(string: R.String.ChooseNode, attributes: [NSAttributedStringKey.font: SharedR.Font.Small, NSAttributedStringKey.foregroundColor: UIColor.highlight])
        btn.setAttributedTitle(title, for: .normal)
        btn.isHidden = true
        
        return btn
    }()
    
    private lazy var bottomLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = SharedR.Font.Small
        label.textColor = .border
        label.text = R.String.CopyUrlAfterUploadingImage
        label.setContentHuggingPriority(UILayoutPriority.required, for: .vertical)
        
        return label
    }()
    
    lazy var titleTextView: PlaceholderTextView = {
        let view = PlaceholderTextView()
        view.font = SharedR.Font.Medium
        view.textContainerInset = UIEdgeInsetsMake(4, 6, 4, 6)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.tintColor = .highlight
        view.textColor = .body
        view.autocorrectionType = .no
        let style = NSMutableParagraphStyle()
        style.lineHeightMultiple = 1.1
        view.typingAttributes[NSAttributedStringKey.paragraphStyle.rawValue] = style
        
        return view
    }()
    
    lazy var contentTextView: PlaceholderTextView = {
        let view = PlaceholderTextView()
        view.font = SharedR.Font.Medium
        view.textContainerInset = UIEdgeInsetsMake(8, 6, 8, 6)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.tintColor = .highlight
        view.textColor = .body
        view.autocorrectionType = .no
        let style = NSMutableParagraphStyle()
        style.lineHeightMultiple = 1.1
        view.typingAttributes[NSAttributedStringKey.paragraphStyle.rawValue] = style
        
        return view
    }()
    
    var isPostEnabled: Bool = false {
        didSet
        {
            postBtn.isEnabled = isPostEnabled
            postBtn.tintColor = isPostEnabled ? .highlight : .border
        }
    }
    
    var isImageBtnEnabled: Bool = false {
        didSet
        {
            imageBtn.isEnabled = isImageBtnEnabled
            imageBtnIcon.tintColor = isImageBtnEnabled ? .desc : .border
            bottomLabel.textColor = isImageBtnEnabled ? .desc : .border
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
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[cancelBtn(41)]", metrics: nil, views: bindings))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[postBtn(41)]|", metrics: nil, views: bindings))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[topLine]|", metrics: nil, views: bindings))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[middleLine]|", metrics: nil, views: bindings))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[bottomLine]|", metrics: nil, views: bindings))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[contentTextView]|", metrics: nil, views: bindings))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[titleTextView]|", metrics: nil, views: bindings))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[postBtn][topLine(0.5)][titleTextView][middleLine(0.5)][contentTextView][bottomLine(0.5)]-10-[imageBtnIcon]-10-|", metrics: nil, views: bindings))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-8-[imageBtnIcon(25)]-8-[bottomLabel]", metrics: nil, views: bindings))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[nodeBtn]-8-|", metrics: nil, views: bindings))
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
        layer.borderWidth = 1
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
        titleLabel.font = SharedR.Font.VeryLarge
        bottomLabel.font = SharedR.Font.Small
        titleTextView.font = SharedR.Font.Medium
        contentTextView.font = SharedR.Font.Medium
        titleTextView.setNeedsDisplay()
        contentTextView.setNeedsDisplay()
        let nodeName = nodeBtn.attributedTitle(for: .normal)?.string ?? R.String.ChooseNode
        nodeBtn.setAttributedTitle(NSAttributedString(string: nodeName, attributes: [NSAttributedStringKey.font: SharedR.Font.Small, NSAttributedStringKey.foregroundColor: UIColor.highlight]), for: .normal)
    }
    
    @objc
    override func refreshColorScheme()
    {
        super.refreshColorScheme()
        layer.borderColor = UIColor.border.cgColor
        titleLabel.textColor = .gray
        cancelBtn.tintColor = .desc
        postBtn.tintColor = .border
        topLine.backgroundColor = .border
        middleLine.backgroundColor = .border
        bottomLine.backgroundColor = .border
        imageBtnIcon.tintColor = .border
        imageBtn.backgroundColor = .clear
        let title = NSAttributedString(string: R.String.ChooseNode, attributes: [NSAttributedStringKey.font: SharedR.Font.Small, NSAttributedStringKey.foregroundColor: UIColor.highlight])
        nodeBtn.setAttributedTitle(title, for: .normal)
        bottomLabel.textColor = .border
        titleTextView.tintColor = .highlight
        titleTextView.textColor = .body
        contentTextView.tintColor = .highlight
        contentTextView.textColor = .body
    }
    
}
