//
//  ProfileModel.swift
//  VeXplore
//
//  Copyright © 2016 Jimmy. All rights reserved.
//

import SharedKit

struct ProfileModel: Codable
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
    private(set) var needLoginToViewTopics = false
    private(set) var favoriteNodesNum: String?
    private(set) var favoriteTopicsNum: String?
    private(set) var followingsNum: String?
    
    private enum CodingKeys: String, CodingKey
    {
        case avatar
        case username
        case tagline
        case createdInfo
        case twitter
        case website
        case location
        case psn
        case twitch
        case dribbble
        case github
        case bio
        case topicsNum
        case repliesNum
        case followText
        case blockText
        case followUrl
        case blockUrl
        case topicHidden
        case hasMoreReplies
        case needLoginToViewTopics
        case favoriteNodesNum
        case favoriteTopicsNum
        case followingsNum
    }
    
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
        followText = rootNode.xPath(".//input[contains(@onclick,'follow')]").first?["value"] ?? SharedR.String.Empty
        blockText = rootNode.xPath(".//input[contains(@onclick,'block')]").first?["value"] ?? SharedR.String.Empty
        let followUrlText = rootNode.xPath(".//input[contains(@onclick,'follow')]").first?["onclick"]
        let blockUrlText = rootNode.xPath(".//input[contains(@onclick,'block')]").first?["onclick"]
        followUrl =  followUrlText?.components(separatedBy: "\'").filter({$0.contains("follow")})[0] ?? SharedR.String.Empty
        blockUrl =  blockUrlText?.components(separatedBy: "\'").filter({$0.contains("block")})[0] ?? SharedR.String.Empty
        topicHidden = rootNode.xPath(".//td[@class='topic_content']").first?.content?.contains(R.String.AllTopicsHidden) ?? false
        topicsNum = rootNode.xPath(".//div[@class='cell item']").count
        repliesNum = rootNode.xPath(".//*[@class='dock_area']").count
        hasMoreReplies = rootNode.xPath(".//*[contains(text(),'创建的更多回复')]").count > 0
        needLoginToViewTopics = rootNode.xPath(".//*[contains(text(),'主题列表只有在你登录之后才可查看')]").count > 0
        favoriteNodesNum = rootNode.xPath(".//a[@href='/my/nodes']/span[@class='bigger']").first?.content ?? R.String.Zero
        favoriteTopicsNum = rootNode.xPath(".//a[@href='/my/topics']/span[@class='bigger']").first?.content ?? R.String.Zero
        followingsNum = rootNode.xPath(".//a[@href='/my/following']/span[@class='bigger']").first?.content ?? R.String.Zero
    }

}
