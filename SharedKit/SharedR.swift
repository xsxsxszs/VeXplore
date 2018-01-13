//
//  SharedR.swift
//  VeXplore
//
//  Copyright © 2017 Jimmy. All rights reserved.
//


public struct SharedR
{
    struct Array
    {
        static let URLPatterns = [
            "^(http:\\/\\/|https:\\/\\/)?(www\\.)?(v2ex.com)?(/)?t/[0-9]+",
            "^(http:\\/\\/|https:\\/\\/)?(www\\.)?(v2ex.com)?(/)?member/[a-zA-Z0-9_]+$",
            "^(http:\\/\\/|https:\\/\\/)?(www\\.)?(v2ex.com)?(/)?go/[a-zA-Z0-9_]+$",
            "^mailto:.*@.*\\..*$",
            "^(http|ftp|https):\\/\\/[\\w\\-_]+(\\.[\\w\\-_]+)+([\\w\\-\\.,@?^=%&amp;:/~\\+#]*[\\w\\-\\@?^=%&amp;/~\\+#])?"
        ]
        
        static let ValidImgUrls = [
            "imgur.com",
            "sinaimg.cn",
            "ooo.0o0.ooo"
        ]
    }
    
    public struct Dict
    {
        public static let MobileClientHeaders = ["user-agent": String.MobileUserAgent]
        public static let DesktopClientHeaders = ["user-agent": String.DesktopUserAgent]
    }
    
    struct Key
    {
        static let Username = "vexplore.userDefaults.key.username"
        static let ShowedTabs = "vexplore.userDefaults.key.showedTabs"
        static let HiddenTabs = "vexplore.userDefaults.key.hiddenTabs"
        static let CurrentTab = "vexplore.userDefaults.key.currentTab"
        static let EnableShake = "vexplore.userDefaults.key.enableShake"
        static let EnablePullReply = "vexplore.userDefaults.key.enablePullReply"
        static let EnableTabBarHidden = "vexplore.userDefaults.key.enableTabBarHidden"
        static let EnableShowReplyIndex = "vexplore.userDefaults.key.enableShowReplyIndex"
        static let EnableHighlightOwnerReplies = "vexplore.userDefaults.key.EnableHighlightOwnerReplies"
        static let DynamicTitleFontScale = "vexplore.userDefaults.key.dynamicTitleFontScale"
        static let AllNodesEtag = "vexplore.userDefaults.key.allNodesEtag"
        static let HomePageTopicList = "vexplore.topicList.homePage.key.%@"
        static let LastCacheVersion = "vexplore.userDefaults.key.lastCacheVersion"
        static let EnableNightMode = "vexplore.userDefaults.key.enableNightMode"
        static let AlwaysEnableNightMode = "vexplore.userDefaults.key.alwaysEnableNightMode"
        static let EnableSchedule = "vexplore.userDefaults.key.enableSchedule"
        static let ScheduleStartDate = "vexplore.userDefaults.key.scheduleStartDate"
        static let ScheduleEndDate = "vexplore.userDefaults.key.scheduleEndDate"
        static let BaiduAccessToken = "vexplore.userDefaults.key.baiduAccessToken"
        static let BaiduTokenExpiresDate = "vexplore.userDefaults.key.baiduTokenExpiresDate"
    }
    
    public struct String
    {
        public static let Empty = ""
        public static let V2EX = "V2EX"
        public static let ViewInApp = "打开"
        public static let InvalidTopic = "该页面不是V2EX帖子\n无法使用VeXplore查看🤷‍♀️"
        public static let ValidTopic = "该页面为V2EX帖子\n可以使用VeXplore查看👏"
        public static let MobileUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 8_0 like Mac OS X) AppleWebKit/600.1.3 (KHTML, like Gecko) Version/8.0 Mobile/12A4345d Safari/600.1.4"
        public static let DesktopUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/50.0.2661.94 Safari/537.36"
    }
    
    public static var Font: RFont { return RFont() }
    public struct RFont
    {
        fileprivate init(){}
        public var VeryLarge: UIFont { return UIFont.preferredFont(forTextStyle: .title3) }
        public var Large: UIFont { return UIFont.preferredFont(forTextStyle: .body) }
        public var Medium: UIFont { return UIFont.preferredFont(forTextStyle: .callout) } // topic title, comment
        public var Small: UIFont { return UIFont.preferredFont(forTextStyle: .footnote) }
        public var VerySmall: UIFont { return UIFont.preferredFont(forTextStyle: .caption1) }
        public var ExtraSmall: UIFont { return UIFont.preferredFont(forTextStyle: .caption2) } // date
        
        public var StaticMedium: UIFont { return UIFont.systemFont(ofSize: 14.0) }
        public var DynamicMedium: UIFont {
            let fontScaleString = UserDefaults.fontScaleString
            let fontScale = CGFloat(fontScaleString.doubleValue)
            let scaledFontSize = round(SharedR.Font.Medium.pointSize * fontScale)
            let font = SharedR.Font.Medium.withSize(scaledFontSize)
            return font
        }
    }
    
}
