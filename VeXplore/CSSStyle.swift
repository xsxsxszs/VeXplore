//
//  CSSStyle.swift
//  VeXplore
//
//  Copyright © 2016 Jimmy. All rights reserved.
//


class CSSStyle
{
    static let shared = CSSStyle()
    private let BASE_CSS = try! String(contentsOfFile: Bundle.main.path(forResource: "baseStyle", ofType: "css")!, encoding: .utf8)
    private let FONT_CSS = try! String(contentsOfFile: Bundle.main.path(forResource: "font", ofType: "css")!, encoding: .utf8)

    private init() {}
    
    func CSS() -> String
    {
        let FONT_SIZE_ARRAY = [
            FontSizeStyle(labelName:"<H1_FONT_SIZE>", defaultFontSize: Int(UIFont.preferredFont(forTextStyle: UIFontTextStyle.title1).pointSize)),
            FontSizeStyle(labelName:"<H2_FONT_SIZE>", defaultFontSize: Int(UIFont.preferredFont(forTextStyle: UIFontTextStyle.title2).pointSize)),
            FontSizeStyle(labelName:"<H3_FONT_SIZE>", defaultFontSize: Int(UIFont.preferredFont(forTextStyle: UIFontTextStyle.title3).pointSize)),
            FontSizeStyle(labelName:"<PRE_FONT_SIZE>", defaultFontSize: Int(UIFont.preferredFont(forTextStyle: UIFontTextStyle.subheadline).pointSize)),
            FontSizeStyle(labelName:"<BODY_FONT_SIZE>", defaultFontSize: Int(R.Font.Medium.pointSize)), // 正文
            FontSizeStyle(labelName:"<SUBTLE_FONT_SIZE>", defaultFontSize: Int(R.Font.Small.pointSize)), // 附言正文
            FontSizeStyle(labelName:"<SUBTLE_FADE_FONT_SIZE>", defaultFontSize: Int(R.Font.ExtraSmall.pointSize)) // 附言标题
        ]
        
        var fontCss = FONT_CSS
        FONT_SIZE_ARRAY.forEach { (fontSize) -> () in
            fontCss = fontCss.replacingOccurrences(of: fontSize.labelName, with: String(fontSize.defaultFontSize))
        }
        let CSS = BASE_CSS + fontCss
        return CSS
    }
    
    private struct FontSizeStyle
    {
        let labelName: String
        let defaultFontSize: Int
    }

}
