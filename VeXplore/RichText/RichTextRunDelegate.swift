//
//  RichTextRunDelegate.swift
//  VeXplore
//
//  Copyright © 2016 Jimmy. All rights reserved.
//

import Foundation

class RichTextRunDelegate
{
    var ascent: CGFloat = 0.0
    var descent: CGFloat = 0.0
    var width: CGFloat = 0.0
    
    var ctRunDelegate: CTRunDelegate? {
        var callbacks = CTRunDelegateCallbacks(version: kCTRunDelegateCurrentVersion, dealloc: { (refCon) -> Void in
        }, getAscent: { (refCon) -> CGFloat in
            let ref = unsafeBitCast(refCon, to: RichTextRunDelegate.self)
            return ref.ascent
        }, getDescent: { (refCon) -> CGFloat in
            let ref = unsafeBitCast(refCon, to: RichTextRunDelegate.self)
            return ref.descent
        }, getWidth: { (refCon) -> CGFloat in
            let ref = unsafeBitCast(refCon, to: RichTextRunDelegate.self)
            return ref.width
        })
        
        let selfPtr = UnsafeMutableRawPointer(Unmanaged.passRetained(self).toOpaque())
        return CTRunDelegateCreate(&callbacks, selfPtr)
    }
    
}
