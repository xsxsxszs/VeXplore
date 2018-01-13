//
//  RichTextUtils.swift
//  VeXplore
//
//  Copyright © 2016 Jimmy. All rights reserved.
//

import Foundation


let AttachmentAttributeName = "vexplore.textAttributeName.attachment"
let HighlightAttributeName = "vexplore.textAttributeName.highlight"

extension NSMutableAttributedString
{
    class func attachmentString(with imageView: UIImageView, size: CGSize, alignTo font: UIFont) -> NSMutableAttributedString
    {
        let attrs = NSMutableAttributedString(string: " ")
        attrs.addAttribute(AttachmentAttributeName, value: imageView)
        let delegate = RichTextRunDelegate()
        delegate.width = size.width
        delegate.ascent = max(size.height + font.descender, 0)
        delegate.descent = size.height - delegate.ascent
        if let ctRunDelegate = delegate.ctRunDelegate
        {
            attrs.addAttribute(kCTRunDelegateAttributeName as String, value: ctRunDelegate)
        }
        return attrs
    }
    
    func setHighlightText(withColor color: UIColor, url: String)
    {
        addAttribute(NSAttributedStringKey.foregroundColor.rawValue, value: color)
        addAttribute(HighlightAttributeName, value: url)
    }
    
    func set(lineSpacing: CGFloat)
    {
        let style = NSMutableParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        style.lineSpacing = lineSpacing
        addAttribute(NSAttributedStringKey.paragraphStyle.rawValue, value: style)
    }
    
    func addAttribute(_ name: String, value: Any)
    {
        addAttribute(NSAttributedStringKey(rawValue: name), value: value, range: NSMakeRange(0, length))
    }

}
