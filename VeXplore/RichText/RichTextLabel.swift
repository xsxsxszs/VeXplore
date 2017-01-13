//
//  RichTextLabel.swift
//  VeXplore
//
//  Copyright © 2016 Jimmy. All rights reserved.
//


class RichTextLabel: UIView
{
    typealias HighlightAction = (_ url: String) -> Void

    private var attachmentViews = [UIImageView]()
    private var url: String?
    var highlightTapAction: HighlightAction?
    
    var textLayout: RichTextLayout? {
        didSet
        {
            layer.setNeedsDisplay()
        }
    }
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        backgroundColor = .clear
        layer.contentsScale = UIScreen.main.scale
        contentMode = .redraw
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func display(_ layer: CALayer)
    {
        for attachmentView in self.attachmentViews
        {
            attachmentView.removeFromSuperview()
        }
        self.attachmentViews.removeAll()
        
        UIGraphicsBeginImageContextWithOptions(layer.bounds.size, layer.isOpaque, layer.contentsScale)
        
        if let layout = textLayout, layout.needsDrawText == true, let context = UIGraphicsGetCurrentContext()
        {
            var point = CGPoint(x: 0, y: layer.bounds.size.height - layout.bounds.height)
            point = point.pixelRound()
            layout.drawText(in: context, size: layer.bounds.size, origin: point)
        }
        let contentImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        layer.contents = contentImage?.cgImage
        
        if let layout = textLayout, layout.needsDrawAttachments == true
        {
            var point = CGPoint(x: 0, y: layer.bounds.height - layout.bounds.height)
            point = point.pixelRound()
            layout.drawAttachment(in: self, origin: point)
            for attachmentView in layout.attachments
            {
                self.attachmentViews.append(attachmentView)
            }
        }
    }
    
    // MARK: - Touches
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        if let touch = touches.first
        {
            let point = touch.location(in: self)
            url = getHighlightText(at: point)
        }
        super.touchesBegan(touches, with: event)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        if let touch = touches.first
        {
            let point = touch.location(in: self)
            if let url = url, getHighlightText(at: point) == url
            {
                highlightTapAction?(url)
            }
        }
        super.touchesEnded(touches, with: event)
    }
    
    // MARK: Privates
    private func getHighlightText(at point: CGPoint) -> String?
    {
        guard let layout = textLayout, layout.text.length > 0, layout.hasHighlightText == true else {
            return nil
        }
        let pointInLayout = convert(point: point, to: layout)
        guard let index = layout.glyphIndex(for: pointInLayout) else {
            return nil
        }
        let url = layout.text.attribute(HighlightAttributeName, at: index, effectiveRange: nil) as? String
        return url
    }
    
    private func convert(point: CGPoint, to layout: RichTextLayout?) -> CGPoint
    {
        guard let layout = layout else {
            return point
        }
        let targetY = point.y + max(bounds.height - layout.bounds.height, 0)
        return CGPoint(x: point.x, y: targetY)
    }
    
    private func convert(point: CGPoint, from layout: RichTextLayout?) -> CGPoint
    {
        guard let layout = layout else {
            return point
        }
        let targetY = point.y - (bounds.height - layout.bounds.height)
        return CGPoint(x: point.x, y: targetY)
    }
    
    private func convert(rect: CGRect, from layout: RichTextLayout?) -> CGRect
    {
        guard let layout = layout else {
            return rect
        }
        let origin = convert(point: rect.origin, from: layout)
        return CGRect(origin: origin, size: rect.size)
    }

}
