//
//  CSSStyle.swift
//  VeXplore
//
//  Copyright © 2016 Jimmy. All rights reserved.
//

import SharedKit

class CSSStyle
{
    class var `default`: String {
        let BASE_CSS = try! String(contentsOfFile: Bundle.main.path(forResource: "baseStyle", ofType: "css")!, encoding: .utf8)
        let FONT_CSS = try! String(contentsOfFile: Bundle.main.path(forResource: "font", ofType: "css")!, encoding: .utf8)
        
        let COLOR_STYLE_ARRAY = [
            ColorStyle(colorName: "H2_COLOR_PLACEHOLDER", colorString: UIColor.border.toHexString()),
            ColorStyle(colorName: "HREF_COLOR_PLACEHOLDER", colorString: UIColor.href.toHexString()),
            ColorStyle(colorName: "BODY_COLOR_PLACEHOLDER", colorString: UIColor.body.toHexString()),
            ColorStyle(colorName: "BODY_BACKGROUND_COLOR_PLACEHOLDER", colorString: UIColor.background.toHexString()),
            ColorStyle(colorName: "SUBTITLE_BACKGROUND_COLOR_PLACEHOLDER", colorString: UIColor.refBackground.toHexString()),
            ColorStyle(colorName: "SUBTITLE_FADE_COLOR_PLACEHOLDER", colorString: UIColor.note.toHexString()),
            ColorStyle(colorName: "SUBTITLE_FADE_BACKGROUND_COLOR_PLACEHOLDER", colorString: UIColor.subBackground.toHexString())
        ]
        var baseCss = BASE_CSS
        COLOR_STYLE_ARRAY.forEach { colorStyle in
            baseCss = baseCss.replacingOccurrences(of: colorStyle.colorName, with: colorStyle.colorString)
        }
        
        let FONT_SIZE_STYLE_ARRAY = [
            FontSizeStyle(labelName:"<H1_FONT_SIZE>", defaultFontSize: Int(UIFont.preferredFont(forTextStyle: UIFontTextStyle.title1).pointSize)),
            FontSizeStyle(labelName:"<H2_FONT_SIZE>", defaultFontSize: Int(UIFont.preferredFont(forTextStyle: UIFontTextStyle.title2).pointSize)),
            FontSizeStyle(labelName:"<H3_FONT_SIZE>", defaultFontSize: Int(UIFont.preferredFont(forTextStyle: UIFontTextStyle.title3).pointSize)),
            FontSizeStyle(labelName:"<PRE_FONT_SIZE>", defaultFontSize: Int(UIFont.preferredFont(forTextStyle: UIFontTextStyle.subheadline).pointSize)),
            FontSizeStyle(labelName:"<BODY_FONT_SIZE>", defaultFontSize: Int(SharedR.Font.Medium.pointSize)), // 正文
            FontSizeStyle(labelName:"<SUBTLE_FONT_SIZE>", defaultFontSize: Int(SharedR.Font.Small.pointSize)), // 附言正文
            FontSizeStyle(labelName:"<SUBTLE_FADE_FONT_SIZE>", defaultFontSize: Int(SharedR.Font.ExtraSmall.pointSize)) // 附言标题
        ]
        var fontCss = FONT_CSS
        FONT_SIZE_STYLE_ARRAY.forEach { fontSizeStyle in
            fontCss = fontCss.replacingOccurrences(of: fontSizeStyle.labelName, with: String(fontSizeStyle.defaultFontSize))
        }
        
        return baseCss + fontCss
    }
    
    private struct FontSizeStyle
    {
        let labelName: String
        let defaultFontSize: Int
    }
    
    private struct ColorStyle
    {
        let colorName: String
        let colorString: String
    }
    
}
