//
//  User.swift
//  VeXplore
//
//  Copyright © 2016 Jimmy. All rights reserved.
//


class User
{
    private(set) var notificationCount: Int = 0 {
        didSet
        {
            MainViewController.shared.setNotificationNum(notificationCount)
        }
    }
    
    var isLogin: Bool {
        return username != nil
    }
    
    static let shared = User()
    var once: String?
    var username: String?
    
    private init()
    {
        username = UserDefaults.standard[R.Key.Username]
        if isLogin
        {
            V2Request.Account.verifyLoginStatus()
        }
    }
    
    func logout()
    {
        removeAllCookies()
        username = nil
        once = nil
        notificationCount = 0
        UserDefaults.standard[R.Key.Username] = nil
        NotificationCenter.default.post(name: NSNotification.Name.User.DidLogout, object: nil)
    }
    
    func removeAllCookies()
    {
        let storage = HTTPCookieStorage.shared
        if let cookies = storage.cookies
        {
            for cookie in cookies
            {
                storage.deleteCookie(cookie)
            }
        }
    }
    
    func getNotificationsNum(withNode rootNode: HTMLNode)
    {
        if let notificationString = rootNode.xPath(".//head/title").first?.content
        {
            notificationCount = 0
            let regex = try! NSRegularExpression(pattern: "\\([0-9]+\\)", options: [.caseInsensitive])
            let range = regex.rangeOfFirstMatch(in: notificationString, options: [.withoutAnchoringBounds], range: NSMakeRange(0, notificationString.lenght))
            guard range.length > 0 else {
                return
            }
            if let startIndex = notificationString.index(notificationString.startIndex, offsetBy: range.location + 1, limitedBy: notificationString.endIndex),
                let endIndex = notificationString.index(notificationString.startIndex, offsetBy: range.location + range.length - 1, limitedBy: notificationString.endIndex)
            {
                let subRange = Range<String.Index>(startIndex..<endIndex)
                let countString = notificationString.substring(with: subRange)
                if let count = Int(countString)
                {
                    notificationCount = count
                }
            }
        }
    }
    
}
