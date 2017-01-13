//
//  NotificationModel.swift
//  VeXplore
//
//  Copyright © 2016 Jimmy. All rights reserved.
//


class NotificationModel: NSObject
{
    private(set) var avatar: String?
    private(set) var username: String?
    private(set) var title: String?
    private(set) var date: String?
    private(set) var comment: String?
    private(set) var notificationId: String?
    private(set) var topicId: String?
    
    init(rootNode: HTMLNode)
    {
        avatar = rootNode.xPath(".//img[@class='avatar']").first?["src"]
        username = rootNode.xPath("./table/tr/td[2]/span[1]/a[1]/strong").first?.content
        title = rootNode.xPath("./table/tr/td[2]/span[1]").first?.content
        date = rootNode.xPath("./table/tr/td[2]/span[2]").first?.content
        comment = rootNode.xPath("./table/tr/td[2]/div[@class='payload']").first?.content
        notificationId = rootNode["id"]?.replacingOccurrences(of: "n_", with: R.String.Empty)
        let topicIdUrl = rootNode.xPath("./table/tr/td[2]/span[1]/a[2]").first?["href"]
        topicId = topicIdUrl?.extractId()
    }
    
    func encodeWithCoder(_ aCoder: NSCoder)
    {
        aCoder.encode(avatar, forKey: "avatar")
        aCoder.encode(username, forKey: "username")
        aCoder.encode(title, forKey: "title")
        aCoder.encode(date, forKey: "date")
        aCoder.encode(comment, forKey: "comment")
        aCoder.encode(notificationId, forKey: "notificationId")
        aCoder.encode(topicId, forKey: "topicId")
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init()
        avatar = aDecoder.decodeObject(forKey: "avatar") as? String
        username = aDecoder.decodeObject(forKey: "username") as? String
        title = aDecoder.decodeObject(forKey: "title") as? String
        date = aDecoder.decodeObject(forKey: "date") as? String
        comment = aDecoder.decodeObject(forKey: "comment") as? String
        notificationId = aDecoder.decodeObject(forKey: "notificationId") as? String
        topicId = aDecoder.decodeObject(forKey: "topicId") as? String
    }
    
}
