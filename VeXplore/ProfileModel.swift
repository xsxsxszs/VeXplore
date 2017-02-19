//
//  ProfileModel.swift
//  VeXplore
//
//  Copyright © 2016 Jimmy. All rights reserved.
//


class ProfileModel: NSObject
{
    private(set) var avatar: String?
    private(set) var username: String?
    private(set) var createdInfo: String?
    private(set) var website: String?
    private(set) var twitter: String?
    private(set) var psn: String?
    private(set) var location: String?
    private(set) var twitch: String?
    private(set) var dribbble: String?
    private(set) var github: String?
    private(set) var bio: String?
    private(set) var tagline: String?
    private(set) var followText: String?
    private(set) var blockText: String?
    private(set) var followUrl: String?
    private(set) var blockUrl: String?
    private(set) var topicHidden = false
    private(set) var topicsNum: Int = 0
    private(set) var repliesNum: Int = 0
    private(set) var hasMoreReplies = false
    private(set) var favoriteNodesNum: String?
    private(set) var favoriteTopicsNum: String?
    private(set) var followingsNum: String?
    
    init(rootNode: HTMLNode)
    {
        avatar = rootNode.xPath(".//img[@class='avatar']").first?["src"]
        username = rootNode.xPath("./div[1]/div[1]/table/tr/td[3]/h1").first?.content
        tagline = rootNode.xPath("./div[1]/div[1]/table/tr/td[3]/span[@class='bigger']").first?.content
        createdInfo = rootNode.xPath("./div[1]/div[1]/table/tr/td[3]/span[@class='gray']").first?.content
        twitter = rootNode.xPath("./div[1]/div[2]/img[@src='/static/img/twitter@2x.png']/following-sibling::a").first?["href"]
        website = rootNode.xPath("./div[1]/div[2]/img[@src='/static/img/mobileme@2x.png']/following-sibling::a").first?["href"]
        location = rootNode.xPath("./div[1]/div[2]/img[@src='/static/img/location@2x.png']/following-sibling::a").first?["href"]
        psn = rootNode.xPath("./div[1]/div[2]/img[@src='/static/img/psn@2x.png']/following-sibling::a").first?["href"]
        twitch = rootNode.xPath("./div[1]/div[2]/img[@src='/static/img/twitch@2x.png']/following-sibling::a").first?["href"]
        dribbble = rootNode.xPath("./div[1]/div[2]/img[@src='/static/img/dribbble@2x.png']/following-sibling::a").first?["href"]
        github = rootNode.xPath("./div[1]/div[2]/img[@src='/static/img/github@2x.png']/following-sibling::a").first?["href"]
        bio = rootNode.xPath("./div[1]/div[3]").first?.content
        followText = rootNode.xPath(".//input[contains(@onclick,'follow')]").first?["value"] ?? R.String.Empty
        blockText = rootNode.xPath(".//input[contains(@onclick,'block')]").first?["value"] ?? R.String.Empty
        let followUrlText = rootNode.xPath(".//input[contains(@onclick,'follow')]").first?["onclick"]
        let blockUrlText = rootNode.xPath(".//input[contains(@onclick,'block')]").first?["onclick"]
        followUrl =  followUrlText?.components(separatedBy: "\'").filter({$0.contains("follow")})[0] ?? R.String.Empty
        blockUrl =  blockUrlText?.components(separatedBy: "\'").filter({$0.contains("block")})[0] ?? R.String.Empty
        topicHidden = rootNode.xPath(".//td[@class='topic_content']").first?.content?.contains(R.String.AllTopicsHidden) ?? false
        topicsNum = rootNode.xPath(".//div[@class='cell item']").count
        repliesNum = rootNode.xPath(".//*[@class='dock_area']").count
        hasMoreReplies = rootNode.xPath(".//*[contains(text(),'创建的更多回复')]").count > 0
        favoriteNodesNum = rootNode.xPath(".//a[@href='/my/nodes']/span[@class='bigger']").first?.content ?? R.String.Zero
        favoriteTopicsNum = rootNode.xPath(".//a[@href='/my/topics']/span[@class='bigger']").first?.content ?? R.String.Zero
        followingsNum = rootNode.xPath(".//a[@href='/my/following']/span[@class='bigger']").first?.content ?? R.String.Zero
    }
    
    func encodeWithCoder(_ aCoder: NSCoder)
    {
        aCoder.encode(avatar, forKey: "avatar")
        aCoder.encode(username, forKey: "username")
        aCoder.encode(tagline, forKey: "tagline")
        aCoder.encode(createdInfo, forKey: "createdInfo")
        aCoder.encode(twitter, forKey: "twitter")
        aCoder.encode(website, forKey: "website")
        aCoder.encode(location, forKey: "location")
        aCoder.encode(psn, forKey: "psn")
        aCoder.encode(twitch, forKey: "twitch")
        aCoder.encode(dribbble, forKey: "dribbble")
        aCoder.encode(github, forKey: "github")
        aCoder.encode(bio, forKey: "bio")
        aCoder.encode(topicsNum, forKey: "topicsNum")
        aCoder.encode(repliesNum, forKey: "repliesNum")
        aCoder.encode(followText, forKey: "followText")
        aCoder.encode(blockText, forKey: "blockText")
        aCoder.encode(followUrl, forKey: "followUrl")
        aCoder.encode(blockUrl, forKey: "blockUrl")
        aCoder.encode(topicHidden, forKey: "topicHidden")
        aCoder.encode(favoriteNodesNum, forKey: "favoriteNodesNum")
        aCoder.encode(favoriteTopicsNum, forKey: "favoriteTopicsNum")
        aCoder.encode(followingsNum, forKey: "followingsNum")
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init()
        avatar = aDecoder.decodeObject(forKey: "avatar") as? String
        username = aDecoder.decodeObject(forKey: "username") as? String
        tagline = aDecoder.decodeObject(forKey: "tagline") as? String
        createdInfo = aDecoder.decodeObject(forKey: "createdInfo") as? String
        twitter = aDecoder.decodeObject(forKey: "twitter") as? String
        website = aDecoder.decodeObject(forKey: "website") as? String
        location = aDecoder.decodeObject(forKey: "location") as? String
        psn = aDecoder.decodeObject(forKey: "psn") as? String
        twitch = aDecoder.decodeObject(forKey: "twitch") as? String
        dribbble = aDecoder.decodeObject(forKey: "dribbble") as? String
        github = aDecoder.decodeObject(forKey: "github") as? String
        bio = aDecoder.decodeObject(forKey: "bio") as? String
        topicsNum = aDecoder.decodeInteger(forKey: "topicsNum")
        repliesNum = aDecoder.decodeInteger(forKey: "repliesNum")
        followText = aDecoder.decodeObject(forKey: "followText") as? String
        blockText = aDecoder.decodeObject(forKey: "blockText") as? String
        followUrl = aDecoder.decodeObject(forKey: "followUrl") as? String
        blockUrl = aDecoder.decodeObject(forKey: "blockUrl") as? String
        topicHidden = aDecoder.decodeBool(forKey: "topicHidden")
        favoriteNodesNum = aDecoder.decodeObject(forKey: "favoriteNodesNum") as? String
        favoriteTopicsNum = aDecoder.decodeObject(forKey: "favoriteTopicsNum") as? String
        followingsNum = aDecoder.decodeObject(forKey: "followingsNum") as? String
    }
    
}
