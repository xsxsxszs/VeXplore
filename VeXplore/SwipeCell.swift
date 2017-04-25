//
//  SwipCell.swift
//  VeXplore
//
//  Copyright © 2016 Jimmy. All rights reserved.
//


class SwipCell: UITableViewCell
{
    lazy var panGestureRecognizer: UIPanGestureRecognizer = ({
        let gesture =  UIPanGestureRecognizer(target: self, action: #selector(pan(sender:)))
        gesture.delegate = self
        
        return gesture
    })()
    
    private lazy var tapGestureRecognizer: UITapGestureRecognizer = ({
        let gesture =  UITapGestureRecognizer(target: self, action: #selector(tap))
        gesture.delegate = self
        
        return gesture
    })()
    
    // swipe is enabled by default
    var enableSwipe = true {
        didSet
        {
            panGestureRecognizer.isEnabled = enableSwipe
            tapGestureRecognizer.isEnabled = enableSwipe
        }
    }
    
    private var isStickState = false
    private var snapshot: UIView!
    private var originalContentViewCenter: CGPoint!
    private var btnIcons = [UIView]()
    private var buttons = [UIButton]()
    private lazy var btnWidth: CGFloat = self.widthForButton()
    var isDirty = false
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?)
    {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addGestureRecognizer(panGestureRecognizer)
        addGestureRecognizer(tapGestureRecognizer)
        preservesSuperviewLayoutMargins = false
        layoutMargins = .zero
        contentView.backgroundColor = .background
        backgroundColor = .subBackground
        selectionStyle = .none
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }

    // MARK: - Actions
    @objc
    private func pan(sender: UIPanGestureRecognizer)
    {
        switch sender.state
        {
        case .began:
            if isDirty
            {
                originalContentViewCenter = snapshot.center
            }
            else
            {
                isDirty = true
                buildUI()
                originalContentViewCenter = contentView.center
            }
        case .changed:
            guard isDirty, isUserInteractionEnabled else {
                return
            }
            let translation = sender.translation(in: sender.view)
            let offsetX = min(originalContentViewCenter.x + translation.x, contentView.center.x)
            snapshot.center = CGPoint(x: offsetX, y: originalContentViewCenter.y)
            let count = numberOfButtons()
            for i in 0..<count
            {
                let icon = btnIcons[i]
                let scale = min(max(contentView.center.x - offsetX - btnWidth * CGFloat(i), 0) / btnWidth, 1.0)
                icon.transform = CGAffineTransform(scaleX: scale, y: scale)
            }
        default:
            if isStickState || snapshot.center.x > contentView.center.x - btnWidth * 0.5
            {
                cancelCellDragging()
            }
            else
            {
                stickSnapshotView()
            }
        }
    }
    
    @objc
    private func tap()
    {
        cancelCellDragging()
    }
    
    override func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool
    {
        if gestureRecognizer == tapGestureRecognizer
        {
            return isStickState
        }
        return true
    }
    
    // MARK: - Private
    private func buildUI()
    {
        snapshot = contentView.snapshotView(afterScreenUpdates: true)
        snapshot.frame = contentView.frame
        contentView.isHidden = true
        insertSubview(snapshot, aboveSubview: contentView)
        let count = numberOfButtons()
        guard count > 0 else {
            return
        }
        
        for i in 0..<count
        {
            let button: UIButton = {
                let btn = UIButton(type: .custom)
                btn.tag = i
                btn.translatesAutoresizingMaskIntoConstraints = false
                btn.addTarget(self, action: #selector(didTappedButton(button:)), for: .touchUpInside)
                
                return btn
            }()
            
            let icon = iconViewForButton(atIndex: i)
            icon.translatesAutoresizingMaskIntoConstraints = false
            btnIcons.append(icon)
            button.addSubview(icon)
            icon.centerXAnchor.constraint(equalTo: button.centerXAnchor).isActive = true
            icon.centerYAnchor.constraint(equalTo: button.centerYAnchor).isActive = true
            
            buttons.append(button)
            addSubview(button)
            
            var previousView: UIView!
            if i == 0
            {
                previousView = snapshot
            }
            else
            {
                previousView = buttons[i - 1]
            }
            button.leadingAnchor.constraint(equalTo: previousView.trailingAnchor).isActive = true
            button.topAnchor.constraint(equalTo: topAnchor).isActive = true
            button.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
            button.widthAnchor.constraint(equalToConstant: btnWidth).isActive = true
        }
    }
    
    @objc
    private func didTappedButton(button: UIButton)
    {
        let index = button.tag
        didTappedButton(atIndex: index)
    }
    
    private func removeAllBtns()
    {
        for btn in buttons
        {
            btn.removeFromSuperview()
        }
        btnIcons.removeAll()
        buttons.removeAll()
    }
    
    private func minimizeBtnIcons()
    {
        for icon in btnIcons
        {
            icon.transform = CGAffineTransform(scaleX: CGFloat.leastNormalMagnitude, y: CGFloat.leastNormalMagnitude) // just make the icon scaled to invisible
        }
    }
    
    private func normalizeBtnIcons()
    {
        for icon in btnIcons
        {
            icon.transform = .identity
        }
    }
    
    private func stickSnapshotView()
    {
        isUserInteractionEnabled = false
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: [.curveEaseInOut], animations: {
            self.snapshot.center = CGPoint(x: self.contentView.center.x - self.btnWidth * CGFloat(self.numberOfButtons()), y: self.contentView.center.y)
            self.normalizeBtnIcons()
        }) { (_) in
            self.isUserInteractionEnabled = true
            self.isStickState = true
        }
    }
    
    // MARK: - Public
    func cancelCellDragging()
    {
        isUserInteractionEnabled = false
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: [.curveEaseInOut], animations: {
            self.snapshot.center = self.contentView.center
            self.minimizeBtnIcons()
            self.layoutIfNeeded() // must call this method to make auto layout views animating
        }) { (_) in
            self.contentView.isHidden = false
            self.snapshot.removeFromSuperview()
            self.removeAllBtns()
            self.isStickState = false
            self.isDirty = false
            self.isUserInteractionEnabled = true
        }
    }
    
    func reset()
    {
        guard isDirty else{
            return
        }
        cancelCellDragging()
    }
    
    // Override these methods in subclass
    func numberOfButtons() -> Int
    {
        // override this method in subclass
        return 1
    }
    
    func widthForButton() -> CGFloat
    {
        // override this method in subclass
        return 50.0
    }
    
    func iconViewForButton(atIndex index: Int) -> UIView
    {
        // override this method in subclass
        return UIView()
    }
    
    func didTappedButton(atIndex index: Int)
    {
        // override this method in subclass
    }
    
}
