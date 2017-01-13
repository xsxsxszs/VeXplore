//
//  RichTextLayout.swift
//  VeXplore
//
//  Copyright © 2016 Jimmy. All rights reserved.
//

import Foundation

class RichTextLayout
{
    private(set) var text: NSAttributedString!
    private(set) var lines = [TextLine]()
    private(set) var attachments = [UIImageView]()
    private(set) var attachmentRects = [CGRect]()
    private(set) var bounds: CGRect = .zero
    private(set) var hasHighlightText = false
    private(set) var needsDrawText = false
    private(set) var needsDrawAttachments = false
    
    init?(with size: CGSize, text: NSAttributedString)
    {
        guard size.width > 0, size.height > 0 else {
            return nil
        }
        
        self.text = text
        let rect = CGRect(x: 0, y: 0, width: size.width, height: min(size.height, 0x0FFFFFFF))
        var transform = CGAffineTransform(scaleX: 1, y: -1)
        let cgPath = CGPath(rect: rect, transform: &transform)
        let frameSetter = CTFramesetterCreateWithAttributedString(text)
        let ctFrame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, text.length), cgPath, nil)
        let ctLines = CTFrameGetLines(ctFrame) as! [CTLine]
        var lineOrigins = [CGPoint](repeating: .zero, count: ctLines.count)
        CTFrameGetLineOrigins(ctFrame, CFRangeMake(0, 0), &lineOrigins)
        for i in 0..<ctLines.count
        {
            let ctLine = ctLines[i]
            let ctRuns = CTLineGetGlyphRuns(ctLine)
            guard CFArrayGetCount(ctRuns) > 0 else {
                continue
            }
            let ctLineOrigin = lineOrigins[i]
            // convert to UIKit coordinate system
            let position = CGPoint(x: rect.origin.x + ctLineOrigin.x, y: rect.maxY - ctLineOrigin.y)
            let line = TextLine(ctLine: ctLine, position: position)
            if line.attachments.count > 0, line.attachmentRects.count > 0
            {
                attachments.append(contentsOf: line.attachments)
                attachmentRects.append(contentsOf: line.attachmentRects)
            }
            
            lines.append(line)
            bounds = bounds.union(line.bounds)
        }
        
        let visibleRange = NSRange(with: CTFrameGetVisibleStringRange(ctFrame))
        if visibleRange.length > 0
        {
            needsDrawText = true
            text.enumerateAttributes(in: visibleRange, options: .longestEffectiveRangeNotRequired, using: { (attrs, range, stop) in
                if attrs[HighlightAttributeName] != nil
                {
                    hasHighlightText = true
                }
                if attrs[AttachmentAttributeName] != nil
                {
                    needsDrawAttachments = true
                }
            })
        }
    }
    
    func drawText(in context: CGContext, size: CGSize, origin: CGPoint)
    {
        guard needsDrawText else {
            return
        }
        
        context.saveGState()
        context.translateBy(x: origin.x, y: origin.y)
        context.translateBy(x: 0, y: size.height)
        context.scaleBy(x: 1, y: -1)
        for line in lines
        {
            let runs: NSArray = CTLineGetGlyphRuns(line.ctLine)
            for run in runs
            {
                let glyphRun = run as! CTRun
                let textPos = CGPoint(x: line.position.x, y: size.height - line.position.y)
                context.textMatrix = .identity
                context.textPosition = textPos
                CTRunDraw(glyphRun, context, CFRangeMake(0, 0))
            }
        }
        context.restoreGState()
    }
    
    func drawAttachment(in targetView: UIView, origin: CGPoint)
    {
        guard needsDrawAttachments, attachments.count == attachmentRects.count else {
            return
        }
        
        for i in 0..<attachments.count
        {
            let attachment = attachments[i]
            var rect = attachmentRects[i]
            rect = rect.pixelRound()
            rect.origin = CGPoint(x: rect.origin.x + origin.x, y: rect.origin.y + origin.y)
            attachment.frame = rect
            targetView.addSubview(attachment)
        }
    }
    
    func glyphIndex(for location: CGPoint) -> Int?
    {
        for line in lines
        {
            if location.y >= line.top, location.y <= line.bottom
            {
                let runs = CTLineGetGlyphRuns(line.ctLine)
                let runsCount = CFArrayGetCount(runs)
                var lineWidth = 0.0
                for i in 0..<runsCount
                {
                    let run = unsafeBitCast(CFArrayGetValueAtIndex(runs, i), to:CTRun.self)
                    let runWidth = CTRunGetTypographicBounds(run, CFRangeMake(0, 0), nil, nil, nil)
                    lineWidth = lineWidth + runWidth
                    if location.x <= CGFloat(lineWidth)
                    {
                        let index = CTRunGetStringRange(run).location
                        return index
                    }
                }
            }
        }
        return nil
    }
    
}
