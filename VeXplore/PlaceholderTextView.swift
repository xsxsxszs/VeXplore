//
//  PlaceholderTextView.swift
//  VeXplore
//
//  Copyright © 2016 Jimmy. All rights reserved.
//

import SharedKit

class PlaceholderTextView: BaseTextView
{
    var placeholderText: String = SharedR.String.Empty {
        didSet
        {
            text = SharedR.String.Empty
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

    override init()
    {
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(textDidChange), name: NSNotification.Name.UITextViewTextDidChange, object: self)
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
        let placeholderFont = font ?? SharedR.Font.Medium
        let placeholderInset = UIEdgeInsets(top: caretPos.origin.y + 0.5*(caretPos.height - placeholderFont.lineHeight), left: caretPos.origin.x + caretPos.width, bottom: textContainerInset.bottom, right: textContainerInset.right)
        let placeholderRect = UIEdgeInsetsInsetRect(bounds, placeholderInset)
        let attributes: [NSAttributedStringKey: Any] = [NSAttributedStringKey.font: placeholderFont, NSAttributedStringKey.foregroundColor: placeholderTextColor]
        placeholderText.draw(in: placeholderRect, withAttributes: attributes)
    }
    
    @objc
    override func refreshColorScheme()
    {
        super.refreshColorScheme()
        backgroundColor = .background
        placeholderTextColor = .border
    }

}
