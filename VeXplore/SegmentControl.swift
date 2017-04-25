//
//  SegmentControl.swift
//  VeXplore
//
//  Copyright © 2016 Jimmy. All rights reserved.
//


class SegmentControl: UIControl, UIGestureRecognizerDelegate
{
    private class IndicatorView: UIView
    {
        private var cornerRadius: CGFloat! {
            didSet
            {
                layer.cornerRadius = cornerRadius
                titleMaskView.layer.cornerRadius = cornerRadius
            }
        }
        
        override var frame: CGRect {
            didSet
            {
                titleMaskView.frame = frame
            }
        }
        
        fileprivate let titleMaskView = UIView()

        init()
        {
            super.init(frame: CGRect.zero)
            layer.masksToBounds = true
            titleMaskView.backgroundColor = .black
        }
        
        required init?(coder aDecoder: NSCoder)
        {
            fatalError("init(coder:) has not been implemented")
        }
        
    }
    
    private lazy var indicatorView: IndicatorView = {
        let view = IndicatorView()
        view.layer.cornerRadius = 11
        view.layer.masksToBounds = true
        view.backgroundColor = .highlight
        
        return view
    }()
    
    private var titles: [String] {
        get
        {
            let titleLabels = titleLabelsView.subviews as! [UILabel]
            return titleLabels.map { $0.text! }
        }
        set
        {
            guard newValue.count > 1 else {
                return
            }
            
            let labels: [(UILabel, UILabel)] = newValue.map { (string) -> (UILabel, UILabel) in
                let titleLabel = UILabel()
                titleLabel.textColor = .desc
                titleLabel.text = string
                titleLabel.lineBreakMode = .byTruncatingTail
                titleLabel.textAlignment = .center
                titleLabel.font = R.Font.StaticMedium
                
                let selectedTitleLabel = UILabel()
                selectedTitleLabel.textColor = .background
                selectedTitleLabel.text = string
                selectedTitleLabel.lineBreakMode = .byTruncatingTail
                selectedTitleLabel.textAlignment = .center
                selectedTitleLabel.font = R.Font.StaticMedium
                
                return (titleLabel, selectedTitleLabel)
            }
            
            titleLabelsView.subviews.forEach({ $0.removeFromSuperview() })
            selectedTitleLabelsView.subviews.forEach({ $0.removeFromSuperview() })
            for (inactiveLabel, activeLabel) in labels
            {
                titleLabelsView.addSubview(inactiveLabel)
                selectedTitleLabelsView.addSubview(activeLabel)
            }
            setNeedsLayout()
        }
    }
    
    // set only property
    var indicatorOffset: CGFloat {
        set
        {
            var newFrame = indicatorView.frame
            newFrame.origin.x = newFrame.width * newValue + indicatorViewInset
            indicatorView.frame = newFrame
        }
        get
        {
            fatalError("You cannot read from this object.")
        }
    }
    
    private let titleLabelsView = UIView()
    private let selectedTitleLabelsView = UIView()
    private var initialIndicatorViewFrame: CGRect?
    private var titleLabelsCount: Int { return titleLabelsView.subviews.count }
    private var titleLabels: [UILabel] { return titleLabelsView.subviews as! [UILabel] }
    private var selectedTitleLabels: [UILabel] { return selectedTitleLabelsView.subviews as! [UILabel] }
    private var allTitleLabels: [UILabel] { return titleLabels + selectedTitleLabels }
    private let indicatorViewInset: CGFloat = 2.0
    private var totalInsetSize: CGFloat { return indicatorViewInset * 2.0 }
    private var tapGestureRecognizer: UITapGestureRecognizer!
    private var panGestureRecognizer: UIPanGestureRecognizer!
    private(set) var selectedIndex = 0
    
    init(titles: [String], selectedIndex: Int)
    {
        super.init(frame: .zero)
        self.selectedIndex = selectedIndex
        self.titles = titles
        setup()
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup()
    {
        layer.masksToBounds = true
        layer.cornerRadius = 13.0
        layer.borderWidth = 1.0
        layer.borderColor = UIColor.note.cgColor
        backgroundColor = .clear
        
        addSubview(titleLabelsView)
        addSubview(indicatorView)
        addSubview(selectedTitleLabelsView)
        selectedTitleLabelsView.layer.mask = indicatorView.titleMaskView.layer
        
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped(_:)))
        addGestureRecognizer(tapGestureRecognizer)
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(pan(_:)))
        panGestureRecognizer.delegate = self
        addGestureRecognizer(panGestureRecognizer)
    }
    
    // MARK: - UIGestureRecognizerDelegate
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool
    {
        if gestureRecognizer == panGestureRecognizer
        {
            return indicatorView.frame.contains(gestureRecognizer.location(in: self))
        }
        return super.gestureRecognizerShouldBegin(gestureRecognizer)
    }
    
    // MARK: - Actions
    @objc
    private func tapped(_ gestureRecognizer: UITapGestureRecognizer)
    {
        let location = gestureRecognizer.location(in: self)
        setSelectedIndex(nearestIndex(toPoint: location))
    }
    
    @objc
    private func pan(_ gestureRecognizer: UIPanGestureRecognizer)
    {
        switch gestureRecognizer.state
        {
        case .began:
            initialIndicatorViewFrame = indicatorView.frame
        case .changed:
            var frame = initialIndicatorViewFrame!
            frame.origin.x += gestureRecognizer.translation(in: self).x
            frame.origin.x = max(min(frame.origin.x, bounds.width - indicatorViewInset - frame.width), indicatorViewInset)
            indicatorView.frame = frame
        case .ended, .failed, .cancelled:
            setSelectedIndex(nearestIndex(toPoint: indicatorView.center))
        default:
            break
        }
    }
    
    // MARK: - Animations
    private func moveIndicator(to index: Int, animated: Bool, shouldSendEvent: Bool)
    {
        if shouldSendEvent
        {
            sendActions(for: .valueChanged)
        }
        if animated
        {
            UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 0.75, initialSpringVelocity: 0.0, options: [.beginFromCurrentState, .curveEaseOut], animations: {
                self.moveIndicatorView()
                }, completion: nil)
        }
        else
        {
            moveIndicatorView()
        }
    }
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        guard titleLabelsCount > 1 else {
            return
        }
        
        titleLabelsView.frame = bounds
        selectedTitleLabelsView.frame = bounds
        indicatorView.frame = elementFrame(forIndex: selectedIndex)
        for index in 0..<titleLabelsCount
        {
            let frame = elementFrame(forIndex: index)
            titleLabelsView.subviews[index].frame = frame
            selectedTitleLabelsView.subviews[index].frame = frame
        }
    }
    
    // MARK: - Public
    func setSelectedIndex(_ index: Int, animated: Bool = true)
    {
        let oldIndex = selectedIndex
        selectedIndex = index
        moveIndicator(to: index, animated: animated, shouldSendEvent: selectedIndex != oldIndex)
    }
    
    // MARK: - Private
    private func elementFrame(forIndex index: Int) -> CGRect
    {
        let elementWidth = (bounds.width - totalInsetSize) / CGFloat(titleLabelsCount)
        return CGRect(x: CGFloat(index) * elementWidth + indicatorViewInset,
                      y: indicatorViewInset,
                      width: elementWidth,
                      height: bounds.height - totalInsetSize)
    }
    
    private func nearestIndex(toPoint point: CGPoint) -> Int
    {
        let distances = titleLabels.map { abs(point.x - $0.center.x) }
        return distances.index(of: distances.min()!)!
    }
    
    private func moveIndicatorView()
    {
        self.indicatorView.frame = self.titleLabels[selectedIndex].frame
        self.layoutIfNeeded()
    }
    
}

