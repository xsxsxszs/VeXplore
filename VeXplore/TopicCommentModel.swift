//
//  TopicCommentModel.swift
//  VeXplore
//
//  Copyright © 2016 Jimmy. All rights reserved.
//


class BaseTopicCommentModel: NSObject
{
    private(set) var images = [String]()
    fileprivate(set) var contentAttributedString: NSMutableAttributedString!
    fileprivate(set) var date: String?

    fileprivate func getContentAttributedString(withNodes nodes: [HTMLNode]) -> NSMutableAttributedString
    {
        let commentAttributedString = NSMutableAttributedString()
        for node in nodes
        {
            if node.tag == "text", let content = node.content
            {
                let clearedContent = content.stringByRemovingNewLinesAndWhitespace()
                commentAttributedString.append(NSMutableAttributedString(string: clearedContent, attributes: [NSFontAttributeName: R.Font.Medium, NSForegroundColorAttributeName: UIColor.middleGray]))
                commentAttributedString.set(lineSpacing: 1)
            }
            else if node.tag == "img", var imageURL = node["src"]
            {
                let image = CommentImageView()
                if imageURL.hasPrefix("//")
                {
                    imageURL = R.String.Https + imageURL
                }
                image.imageURL = imageURL
                let imageAttributedString = NSMutableAttributedString.attachmentString(with: image, size: CGSize(width: R.Constant.CommentImageSize, height: R.Constant.CommentImageSize), alignTo: R.Font.Medium)
                commentAttributedString.append(imageAttributedString)
                images.append(imageURL)
            }
            else if node.tag == "a", let content = node.content, let url = node["href"]
            {
                let subNodes = node.xPath("./node()")
                if subNodes.first?.tag != "text", subNodes.count > 0
                {
                    commentAttributedString.append(getContentAttributedString(withNodes: subNodes))
                }
                if content.isEmpty == false
                {
                    let contentWithSpace = content + " " // add space after @ someone
                    let attr = NSMutableAttributedString(string: contentWithSpace, attributes: [NSFontAttributeName: R.Font.Medium])
                    attr.setHighlightText(withColor: .hrefColor, url: url)
                    commentAttributedString.append(attr)
                }
            }
            else if node.tag == "div"
            {
                let subNodes = node.xPath("./node()")
                if subNodes.count > 0
                {
                    commentAttributedString.append(getContentAttributedString(withNodes: subNodes))
                }
            }
            else if node.tag == "br"
            {
                commentAttributedString.append(NSMutableAttributedString(string: "\n",  attributes: [NSForegroundColorAttributeName: UIColor.middleGray]))
            }
            else if let content = node.content
            {
                commentAttributedString.append(NSMutableAttributedString(string: content,  attributes: [NSForegroundColorAttributeName: UIColor.middleGray]))
            }
        }
        return commentAttributedString
    }

}


class TopicCommentModel: BaseTopicCommentModel
{
    private(set) var replyId: String?
    private(set) var avatar: String?
    private(set) var username: String?
    private(set) var comment: String?
    private(set) var commentIndex: String?
    private(set) var commentTotalPages = 1
    var likeNum = 0
    var isThanked = false
    
    init(rootNode: HTMLNode)
    {
        super.init()
        
        if let replyIdText = rootNode["id"], replyIdText.hasPrefix("r_")
        {
            replyId = replyIdText.replacingOccurrences(of: "r_", with: R.String.Empty)
        }
        if rootNode.xPath(".//div[@class='thank_area thanked']").count > 0
        {
            isThanked = true
        }
        avatar = rootNode.xPath(".//img[@class='avatar']").first?["src"]
        username = rootNode.xPath(".//a[contains(@href,'/member/')]").first?.content
        date = rootNode.xPath(".//span[@class='fade small']").first?.content
        commentIndex = rootNode.xPath(".//span[@class='no']").first?.content
        if let favorite = rootNode.xPath(".//span[@class='small fade']").first?.content
        {
            let array = favorite.components(separatedBy: " ")
            if array.count == 2, let likeNum = Int(array[1])
            {
                self.likeNum = likeNum
            }
        }
        let nodes = rootNode.xPath(".//div[@class='reply_content']/node()")
        contentAttributedString = getContentAttributedString(withNodes: nodes)
    }
    
    func getRelevantComments(from topicComments:[TopicCommentModel]) -> [TopicCommentModel]
    {
        var relevantComments = [TopicCommentModel]()
        let relevantUsers = getUsersInComment()
        var beforeCurrentComment = true
        for comment in topicComments
        {
            if comment.replyId == replyId
            {
                beforeCurrentComment = false
                relevantComments.append(comment)
                continue
            }
            let commentUsers = comment.getUsersInComment()
            if relevantUsers.count == 0, commentUsers.contains(username!), beforeCurrentComment == false // if someone @ self(current comment owner) after current comment
            {
                relevantComments.append(comment)
                continue
            }
            if let commentOwnerName = comment.username
            {
                if commentOwnerName == username, commentUsers.intersection(relevantUsers).count > 0 // self(current comment owner) replies current comment relevant users
                {
                    relevantComments.append(comment)
                    continue
                }
                if relevantUsers.contains(commentOwnerName)
                {
                    // relevant users replies topic before current comment
                    // or relevant user @ self(current comment owner)
                    if beforeCurrentComment || commentUsers.contains(username!)
                    {
                        relevantComments.append(comment)
                        continue
                    }
                }
            }
        }
        return relevantComments
    }
    
    func getUserAllComments(from topicComments:[TopicCommentModel]) -> [TopicCommentModel]
    {
        var allComments:[TopicCommentModel] = []
        for comment in topicComments
        {
            if comment.username == self.username
            {
                allComments.append(comment)
            }
        
        }
        return allComments
    }
    
    func getUsersInComment() -> Set<String>
    {
        var users: Set<String> = []
        contentAttributedString.enumerateAttribute(HighlightAttributeName, in: NSMakeRange(0, contentAttributedString.length), options: []) {(attribute, range, stop) -> Void in
            if let url = attribute as? String
            {
                let result = URLAnalysisResult(url: url)
                if result.type == .member, let username = result.value
                {
                    users.insert(username)
                }
            }
        }
        return users
    }
    
}


class MemberReplyModel: BaseTopicCommentModel
{
    private(set) var topicId: String?
    private(set) var title: String?
    private(set) var reply: String?
    
    init(rootNode: HTMLNode)
    {
        super.init()
        
        if let node = rootNode.xPath(".//a[attribute::href]").first
        {
            title = node.content
            let topicIdUrl = node["href"]
            topicId = topicIdUrl?.extractId()
        }
        date = rootNode.xPath("./table/tr/td/div/span")[0].content
        contentAttributedString = NSMutableAttributedString()
        if let replyNode = rootNode.nextSibling
        {
            let nodes = replyNode.xPath(".//div[@class='reply_content']/node()")
            contentAttributedString = getContentAttributedString(withNodes: nodes)
        }
    }
    
}
