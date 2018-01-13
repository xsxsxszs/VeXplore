//
//  TextLine.swift
//  YYText
//
//  Copyright © 2016 ibireme. All rights reserved.
//

import Foundation

class TextLine
{
    private(set) var ctLine: CTLine!
    private(set) var bounds: CGRect!
    private(set) var ascent: CGFloat = 0.0
    private(set) var descent: CGFloat = 0.0
    private(set) var leading: CGFloat = 0.0
    private(set) var lineWidth: CGFloat = 0.0
    private(set) var attachments = [UIImageView]()
    private(set) var attachmentRects = [CGRect]()
    private var firstGlyphPosX: CGFloat = 0
    
    // baseline position
    var position: CGPoint! {
        didSet
        {
            reloadBounds()
        }
    }

    var size: CGSize {
        return bounds.size
    }
    
    var width: CGFloat {
        return bounds.width
    }
    
    var height: CGFloat {
        return bounds.height
    }
    
    var top: CGFloat {
        return bounds.minY
    }
    
    var bottom: CGFloat {
        return bounds.maxY
    }
    
    var left: CGFloat {
        return bounds.minX
    }
    
    var right: CGFloat {
        return bounds.maxX
    }
    
    required init(ctLine: CTLine, position: CGPoint)
    {
        self.ctLine = ctLine
        self.position = position
        commonInit()
    }
    
    private func commonInit()
    {
        lineWidth = CGFloat(CTLineGetTypographicBounds(ctLine, &ascent, &descent, &leading));
        if CTLineGetGlyphCount(ctLine) > 0
        {
            let runs = CTLineGetGlyphRuns(ctLine) as! [CTRun]
            let run = runs[0]
            var pos: CGPoint = .zero
            CTRunGetPositions(run, CFRangeMake(0, 1), &pos)
            firstGlyphPosX = pos.x
            reloadBounds()
        }
    }
    
    private func reloadBounds()
    {
        bounds = CGRect(x: position.x + firstGlyphPosX, y: position.y - ascent, width: lineWidth, height: ascent + descent)
        let runs = CTLineGetGlyphRuns(ctLine)
        let runsCount = CFArrayGetCount(runs)
        guard ctLine != nil && runsCount > 0 else {
            return
        }
        
        attachments.removeAll()
        attachmentRects.removeAll()
        for i in 0..<runsCount
        {
            let run = unsafeBitCast(CFArrayGetValueAtIndex(runs, i), to:CTRun.self)
            guard CTRunGetGlyphCount(run) > 0 else {
                continue
            }
            
            let attrs = CTRunGetAttributes(run) as NSDictionary
            if let attachment = attrs[AttachmentAttributeName] as? UIImageView
            {
                var runPos: CGPoint = .zero
                CTRunGetPositions(run, CFRangeMake(0, 1), &runPos)
                var ascent: CGFloat = 0.0
                var descent: CGFloat = 0.0
                let runWidth: CGFloat = CGFloat(CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &ascent, &descent, nil))
                runPos.x = position.x + runPos.x
                runPos.y = position.y - runPos.y
                let runTypoBounds = CGRect(x: runPos.x, y: runPos.y - ascent, width: runWidth, height: ascent + descent)
                attachments.append(attachment)
                attachmentRects.append(runTypoBounds)
            }
        }
    }

}
