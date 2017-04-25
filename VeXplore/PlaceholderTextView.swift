//
//  PlaceholderTextView.swift
//  VeXplore
//
//  Copyright © 2016 Jimmy. All rights reserved.
//


class PlaceholderTextView: UITextView
{
    var placeholderText: String = R.String.Empty {
        didSet
        {
            text = R.String.Empty
            isPlaceholder = true
            setNeedsDisplay()
        }
    }
    
    var placeholderTextColor: UIColor = .border {
        didSet
        {
            setNeedsDisplay()
        }
    }
    
    override var text: String! {
        didSet
        {
            setNeedsDisplay()
        }
    }
    
    private var isPlaceholder = true

    init()
    {
        super.init(frame: .zero, textContainer: nil)
        
        refreshColorScheme()
        
        NotificationCenter.default.addObserver(self, selector: #selector(textDidChange), name: NSNotification.Name.UITextViewTextDidChange, object: self)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshColorScheme), name: NSNotification.Name.Setting.NightModeDidChange, object: nil)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc
    private func textDidChange()
    {
        if (text.isEmpty == false && isPlaceholder) || text.isEmpty
        {
            setNeedsDisplay()
        }
        isPlaceholder = text.isEmpty
    }
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        if text.isEmpty
        {
            setNeedsDisplay()
        }
    }
    
    override func draw(_ rect: CGRect)
    {
        guard text.isEmpty else {
            return
        }
        
        let caretPos = caretRect(for: beginningOfDocument)
        let placeholderFont = font ?? R.Font.Medium
        let placeholderInset = UIEdgeInsets(top: caretPos.origin.y + 0.5*(caretPos.height - placeholderFont.lineHeight), left: caretPos.origin.x + caretPos.width, bottom: textContainerInset.bottom, right: textContainerInset.right)
        let placeholderRect = UIEdgeInsetsInsetRect(bounds, placeholderInset)
        let attributes: [String: Any] = [NSFontAttributeName: placeholderFont, NSForegroundColorAttributeName: placeholderTextColor]
        placeholderText.draw(in: placeholderRect, withAttributes: attributes)
    }
    
    @objc
    private func refreshColorScheme()
    {
        backgroundColor = .background
        placeholderTextColor = .border
    }

}
