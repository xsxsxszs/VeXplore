//
//  TopicItemModel.swift
//  VeXplore
//
//  Copyright © 2016 Jimmy. All rights reserved.
//


class BaseTopicItemModel: NSObject
{
    fileprivate(set) var topicId: String?
    fileprivate(set) var topicTitle: String?
    fileprivate(set) var nodeName: String?
    fileprivate(set) var nodeId: String?
    fileprivate(set) var lastReplyDate: String?
    fileprivate(set) var repliesNumber: String?
}


class TopicItemModel: BaseTopicItemModel
{
    private(set) var avatar: String?
    private(set) var username: String?
    private(set) var lastReplyUserName: String?
    
    func encodeWithCoder(_ aCoder: NSCoder)
    {
        aCoder.encode(topicId, forKey: "topicId")
        aCoder.encode(avatar, forKey: "avatar")
        aCoder.encode(nodeName, forKey: "nodeName")
        aCoder.encode(nodeId, forKey: "nodeId")
        aCoder.encode(username, forKey: "username")
        aCoder.encode(topicTitle, forKey: "topicTitle")
        aCoder.encode(lastReplyDate, forKey: "lastReplyDate")
        aCoder.encode(lastReplyUserName, forKey: "lastReplyUserName")
        aCoder.encode(repliesNumber, forKey: "repliesNumber")
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init()
        topicId = aDecoder.decodeObject(forKey: "topicId") as? String
        avatar = aDecoder.decodeObject(forKey: "avatar") as? String
        nodeName = aDecoder.decodeObject(forKey: "nodeName") as? String
        nodeId = aDecoder.decodeObject(forKey: "nodeId") as? String
        username = aDecoder.decodeObject(forKey: "username") as? String
        topicTitle = aDecoder.decodeObject(forKey: "topicTitle") as? String
        lastReplyDate = aDecoder.decodeObject(forKey: "lastReplyDate") as? String
        lastReplyUserName = aDecoder.decodeObject(forKey: "lastReplyUserName") as? String
        repliesNumber = aDecoder.decodeObject(forKey: "repliesNumber") as? String
    }
    
    init(id: String, title: String)
    {
        super.init()
        self.topicId = id
        self.topicTitle = title
    }
    
    init(rootNode: HTMLNode)
    {
        super.init()
        avatar = rootNode.xPath(".//img[@class='avatar']").first?["src"]
        username = rootNode.xPath(".//a[@class='node']/following-sibling::strong/a").first?.content
        if let node = rootNode.xPath(".//a[@class='node']").first
        {
            nodeName = node.content
            if var href = node["href"],
                let range = href.range(of: "/go/")
            {
                href.replaceSubrange(range, with: R.String.Empty)
                nodeId = href
            }
        }
        
        if let topicNode = rootNode.xPath(".//span[@class='item_title']/a").first
        {
            topicTitle = topicNode.content
            let topicIdUrl = topicNode["href"]
            topicId = topicIdUrl?.extractId()
        }
        lastReplyDate = rootNode.xPath("./table/tr/td[3]/span[3]").first?.content
        lastReplyUserName = rootNode.xPath("./table/tr/td[3]/span[3]/strong[1]/a[1]").first?.content
        repliesNumber = rootNode.xPath("./table/tr/td[4]/a[1]").first?.content
    }
    
    init(nodeRootNode: HTMLNode)
    {
        super.init()
        avatar = nodeRootNode.xPath(".//img[@class='avatar']").first?["src"]
        username = nodeRootNode.xPath("./table/tr/td[3]/span[2]/strong").first?.content
        if let topicNode = nodeRootNode.xPath(".//span[@class='item_title']/a").first
        {
            topicTitle = topicNode.content
            let topicIdUrl = topicNode["href"]
            topicId = topicIdUrl?.extractId()
        }
        
        if let lastReplyDateString = nodeRootNode.xPath("./table/tr/td[3]/span[2]").first?.content?.components(separatedBy: "  •  ")
        {
            if lastReplyDateString.count > 2
            {
                lastReplyDate = lastReplyDateString[1] + "  •  " + lastReplyDateString[2]
            }
            else if lastReplyDateString.count > 1
            {
                lastReplyDate = lastReplyDateString[1]
            }
        }
        lastReplyUserName = nodeRootNode.xPath("./table/tr/td[3]/span[2]/strong[2]").first?.content
        repliesNumber = nodeRootNode.xPath("./table/tr/td[4]/a[1]").first?.content
    }
    
    init(favoritesRootNode: HTMLNode)
    {
        super.init()
        avatar = favoritesRootNode.xPath(".//img[@class='avatar']").first?["src"]
        username = favoritesRootNode.xPath(".//a[@class='node']/following-sibling::strong/a").first?.content
        if let node = favoritesRootNode.xPath(".//a[@class='node']").first
        {
            nodeName = node.content
            if var href = node["href"],
                let range = href.range(of: "/go/")
            {
                href.replaceSubrange(range, with: R.String.Empty)
                nodeId = href
            }
        }
        
        if let topicNode = favoritesRootNode.xPath(".//span[@class='item_title']/a").first
        {
            topicTitle = topicNode.content
            let topicIdUrl = topicNode["href"]
            topicId = topicIdUrl?.extractId()
        }
        
        if let date = favoritesRootNode.xPath("./table/tr/td[3]/span[2]").first?.content
        {
            let array = date.components(separatedBy: "•")
            if array.count == 4
            {
                lastReplyDate = array[3].trimmingCharacters(in: .whitespaces)
            }
        }
        lastReplyUserName = favoritesRootNode.xPath("./table/tr/td[3]/span[2]/strong[2]/a[1]").first?.content
        repliesNumber = favoritesRootNode.xPath("./table/tr/td[4]/a[1]").first?.content
    }
    
}


class MemberTopicItemModel: BaseTopicItemModel
{
    private(set) var lastReplyUserName: String?
    
    init(rootNode: HTMLNode)
    {
        super.init()
        nodeName = rootNode.xPath(".//a[@class='node']").first?.content
        if var href = rootNode.xPath(".//a[@class='node']").first?["href"], let range = href.range(of: "/go/")
        {
            href.replaceSubrange(range, with: R.String.Empty)
            nodeId = href
        }
        topicTitle = rootNode.xPath(".//span[@class='item_title']").first?.content
        let topicIdUrl = rootNode.xPath(".//span[@class='item_title']/a").first?["href"]
        topicId = topicIdUrl?.extractId()
        lastReplyDate = rootNode.xPath("./table/tr/td[1]/span[3]").first?.content
        lastReplyUserName  = rootNode.xPath("./table/tr/td[1]/span[3]/strong[1]/a[1]").first?.content
        repliesNumber  = rootNode.xPath("./table/tr/td[2]/a[1]").first?.content
    }
    
}

