//
//  NotificationModel.swift
//  VeXplore
//
//  Copyright © 2016 Jimmy. All rights reserved.
//

import SharedKit

struct NotificationModel: Codable
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
        notificationId = rootNode["id"]?.replacingOccurrences(of: "n_", with: SharedR.String.Empty)
        let topicIdUrl = rootNode.xPath("./table/tr/td[2]/span[1]/a[2]").first?["href"]
        topicId = topicIdUrl?.extractId()
    }
}

