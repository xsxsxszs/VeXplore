//
//  Extension.swift
//  SharedKit
//
//  Created by Jing Chen on 09/12/2017.
//  Copyright © 2017 Jimmy. All rights reserved.
//

import UIKit

extension UIColor
{
    public func toHexString() -> String
    {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        let rgb:Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        return String(format:"#%06x", rgb)
    }
    
    private static let normalPalette: [UIColor] = [
        .colorWithHexString("#FFFFFF"), // background
        .colorWithHexString("#F8F8F8"), // subBackground
        .colorWithHexString("#CDCDCD"), // border
        .colorWithHexString("#999999"), // note
        .colorWithHexString("#666666"), // desc
        .colorWithHexString("#333333"), // body
        .colorWithHexString("#C56FD5"), // highlight
        .colorWithHexString("#00314F"), // href
        .colorWithHexString("#FFFFF8")  // refBackground
    ]
    
    private static let nightPalette: [UIColor] = [
        .colorWithHexString("#142634"),
        .colorWithHexString("#172B44"),
        .colorWithHexString("#38547A"),
        .colorWithHexString("#50667B"),
        .colorWithHexString("#7E8889"),
        .colorWithHexString("#8FA9BC"),
        .colorWithHexString("#D48872"),
        .colorWithHexString("#EAC5A0"),
        .colorWithHexString("#333333")
    ]
    
    private class var currentViewPalette: [UIColor] {
        return UserDefaults.isNightModeEnabled ? nightPalette : normalPalette
    }

    public class var background: UIColor {
        return currentViewPalette[0]
    }
    
    // background color of section header
    public class var subBackground: UIColor {
        return currentViewPalette[1]
    }
    
    public class var border: UIColor {
        return currentViewPalette[2]
    }
    
    // placeholder
    public class var note: UIColor {
        return currentViewPalette[3]
    }
    
    // username, for description
    public class var desc: UIColor {
        return currentViewPalette[4]
    }
    
    // topic title, topic body
    public class var body: UIColor {
        return currentViewPalette[5]
    }
    
    public class var highlight: UIColor {
        return currentViewPalette[6]
    }
    
    public class var href: UIColor {
        return currentViewPalette[7]
    }
    
    public class var refBackground: UIColor {
        return currentViewPalette[8]
    }
    
    public func reverseNightMode() -> UIColor?
    {
        for (index, color) in UIColor.currentViewPalette.enumerated()
        {
            if self == color
            {
                return UserDefaults.isNightModeEnabled ? UIColor.normalPalette[index] : UIColor.nightPalette[index]
            }
        }
        return nil
    }
    
    
    private class func colorWithWhite(_ white:UInt) -> UIColor
    {
        return UIColor(white: CGFloat(white) / 255.0, alpha: 1.0)
    }
    
    private class func colorWithHexString (_ hex :String) -> UIColor
    {
        return .colorWithHexString(hex, alpha: 1.0)
    }
    
    private class func colorWithHexString (_ hex :String, alpha: CGFloat) -> UIColor
    {
        var cString = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if (cString.hasPrefix("#"))
        {
            let startIndex = cString.index(cString.startIndex, offsetBy: 1)
            cString = String(cString[startIndex...])
        }
        if (cString.count != 6)
        {
            return .background
        }
        var rgbValue: UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: alpha
        )
    }
    
}

extension String
{
    public var boolValue: Bool {
        get
        {
            return (self as NSString).boolValue
        }
    }
    
    public var floatValue: Float {
        get
        {
            return (self as NSString).floatValue
        }
    }
    
    public var doubleValue: Double {
        get
        {
            return (self as NSString).doubleValue
        }
    }
    
    public var intValue: Int {
        get
        {
            return (self as NSString).integerValue
        }
    }
    
    public func contains(_ find: String) -> Bool
    {
        return self.range(of: find) != nil
    }
    
    public func containsIgnoringCase(_ find: String) -> Bool
    {
        return self.range(of: find, options: .caseInsensitive) != nil
    }
    
    public func stringByRemovingNewLinesAndWhitespace() -> String
    {
        let scanner = Scanner(string: self)
        scanner.charactersToBeSkipped = nil
        var result = SharedR.String.Empty
        var temp: NSString? = nil
        let whitespaceCharacters = CharacterSet.whitespacesAndNewlines
        while scanner.isAtEnd == false
        {
            scanner.scanUpToCharacters(from: whitespaceCharacters, into: &temp)
            if temp != nil
            {
                result.append(temp! as String)
            }
            
            if scanner.scanCharacters(from: whitespaceCharacters, into: nil)
            {
                if result.isEmpty == false && scanner.isAtEnd == false
                {
                    result.append(" ")
                }
            }
        }
        return result
    }
    
    public func getUppercaseLatinString() -> String
    {
        
        if let str1 = applyingTransform(.mandarinToLatin, reverse: false),
            let str2 = str1.applyingTransform(.stripCombiningMarks, reverse: false)
        {
            return str2.uppercased()
        }
        return uppercased()
    }
    
    public func replace(_ string: String, with replacement:String) -> String
    {
        return self.replacingOccurrences(of: string, with: replacement, options: NSString.CompareOptions.literal, range: nil)
    }
    
    public func removeWhitespace() -> String
    {
        return replace(" ", with: SharedR.String.Empty)
    }
    
    public func stringByRemovingWhitespaceAtBeginAndEnd() -> String
    {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    public func isValidImgUrl() -> Bool
    {
        return SharedR.Array.ValidImgUrls.filter{ return self.contains($0) }.count > 0
    }
    
    public func extractId() -> String?
    {
        var result: String?
        if let startRange = range(of: "/t/"),
            let endRange = range(of: "#")
        {
            result = String(self[startRange.upperBound..<endRange.lowerBound])
        }
        return result
    }
    
    public func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat
    {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font: font], context: nil)
        return boundingBox.height
    }
    
    public func isValidCaptcha() -> Bool
    {
        return NSPredicate(format:"SELF MATCHES %@", "[a-zA-Z0-9]{8}").evaluate(with: self)
    }

}

extension UserDefaults
{
    public subscript(key: String) -> String? {
        get
        {
            return UserDefaults.standard.object(forKey: key) as? String
        }
        set
        {
            UserDefaults.standard.setValue(newValue, forKey: key)
        }
    }
    
    public class var fontScaleString: String {
        get
        {
            return UserDefaults.standard.string(forKey: SharedR.Key.DynamicTitleFontScale) ?? "1.0"
        }
        
        set
        {
            UserDefaults.standard.set(newValue, forKey: SharedR.Key.DynamicTitleFontScale)
        }
    }
    
    public class var isPullReplyEnabled: Bool {
        get
        {
            return UserDefaults.standard.bool(forKey: SharedR.Key.EnablePullReply)
        }
        
        set
        {
            UserDefaults.standard.set(newValue, forKey: SharedR.Key.EnablePullReply)
        }
    }
    
    public class var isHighlightOwnerRepliesEnabled: Bool {
        get
        {
            return UserDefaults.standard.bool(forKey: SharedR.Key.EnableHighlightOwnerReplies)
        }
        
        set
        {
            UserDefaults.standard.set(newValue, forKey: SharedR.Key.EnableHighlightOwnerReplies)
        }
    }
    
    public class var isShakeEnabled: Bool {
        get
        {
            if let isShakeEnabled = UserDefaults.standard.object(forKey: SharedR.Key.EnableShake) as? NSNumber
            {
                return isShakeEnabled.boolValue
            }
            return false
        }
        
        set
        {
            UserDefaults.standard.set(NSNumber(value: newValue as Bool), forKey: SharedR.Key.EnableShake)
        }
    }
    
    public class var isTabBarHiddenEnabled: Bool {
        get
        {
            return UserDefaults.standard.bool(forKey: SharedR.Key.EnableTabBarHidden)
        }
        
        set
        {
            UserDefaults.standard.set(newValue, forKey: SharedR.Key.EnableTabBarHidden)
        }
    }
    
    public class var isShowReplyIndexEnabled: Bool {
        get
        {
            return UserDefaults.standard.bool(forKey: SharedR.Key.EnableShowReplyIndex)
        }
        
        set
        {
            UserDefaults.standard.set(newValue, forKey: SharedR.Key.EnableShowReplyIndex)
        }
    }
    
    public class var isNightModeAlwaysEnabled: Bool {
        get
        {
            return UserDefaults.standard.bool(forKey: SharedR.Key.AlwaysEnableNightMode)
        }
        
        set
        {
            UserDefaults.standard.set(newValue, forKey: SharedR.Key.AlwaysEnableNightMode)
        }
    }
    
    public class var isNightModeEnabled: Bool {
        get
        {
            if UserDefaults.isNightModeAlwaysEnabled
            {
                return true
            }
            else if !UserDefaults.isNightModeScheduleEnabled
            {
                return false
            }
            else if let startDate = UserDefaults.scheduleStartDate,
                let endDate = UserDefaults.scheduleEndDate
            {
                return Date.isCurrentBetween(startDate: startDate, endDate: endDate)
            }
            return UserDefaults.standard.bool(forKey: SharedR.Key.EnableNightMode)
        }
        
        set
        {
            UserDefaults.standard.set(newValue, forKey: SharedR.Key.EnableNightMode)
        }
    }
    
    public class var isNightModeScheduleEnabled: Bool {
        get
        {
            return UserDefaults.standard.bool(forKey: SharedR.Key.EnableSchedule)
        }
        
        set
        {
            UserDefaults.standard.set(newValue, forKey: SharedR.Key.EnableSchedule)
        }
    }
    
    public class var scheduleStartDate: Date? {
        get
        {
            return UserDefaults.standard.object(forKey: SharedR.Key.ScheduleStartDate) as? Date
        }
        
        set
        {
            UserDefaults.standard.set(newValue, forKey: SharedR.Key.ScheduleStartDate)
        }
    }
    
    public class var scheduleEndDate: Date? {
        get
        {
            return UserDefaults.standard.object(forKey: SharedR.Key.ScheduleEndDate) as? Date
        }
        
        set
        {
            UserDefaults.standard.set(newValue, forKey: SharedR.Key.ScheduleEndDate)
        }
    }
    
    public class var baiduAccessToken: String? {
        get
        {
            return UserDefaults.standard.object(forKey: SharedR.Key.BaiduAccessToken) as? String
        }
        
        set
        {
            UserDefaults.standard.set(newValue, forKey: SharedR.Key.BaiduAccessToken)
        }
    }
    
    public class var baiduTokenExpiresDate: Date? {
        get
        {
            return UserDefaults.standard.object(forKey: SharedR.Key.BaiduTokenExpiresDate) as? Date
        }
        
        set
        {
            UserDefaults.standard.set(newValue, forKey: SharedR.Key.BaiduTokenExpiresDate)
        }
    }
    
}

extension Date
{
    static let dateFormatter: DateFormatter = {
        let obj = DateFormatter()
        obj.dateStyle = .none
        obj.timeStyle = .short
        
        return obj
    }()
    
    public func stringValue() -> String
    {
        let dateString = Date.dateFormatter.string(from: self)
        return dateString
    }
    
    static func isCurrentBetween(startDate: Date, endDate: Date) -> Bool
    {
        let currentDate = Date()
        if (startDate.compareTimeOnly(currentDate) != .orderedAscending && currentDate.compareTimeOnly(endDate) == .orderedDescending) // start <= current < end
            || (endDate.compareTimeOnly(startDate) == .orderedDescending && startDate.compareTimeOnly(currentDate) != .orderedAscending) // end < start <= current
            || (currentDate.compareTimeOnly(endDate) == .orderedDescending && endDate.compareTimeOnly(startDate) == .orderedDescending) // current < end < start
        {
            return true
        }
        return false
    }
    

    public func compareTimeOnly(_ other: Date) -> ComparisonResult
    {
        let calendar = Calendar.current

        let leftHour = calendar.component(.hour, from: self)
        let leftMinute = calendar.component(.minute, from: self)
        let rightHour = calendar.component(.hour, from: other)
        let rightMinute = calendar.component(.minute, from: other)
        
        if (leftHour > rightHour)
            || (leftHour == rightHour && leftMinute > rightMinute)
        {
            return .orderedAscending
        }
        else if leftHour == rightHour && leftMinute == rightMinute
        {
            return .orderedSame
        }
        return .orderedDescending
    }
    
}
