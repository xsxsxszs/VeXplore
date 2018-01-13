//
//  NodeModel.swift
//  VeXplore
//
//  Copyright © 2016 Jimmy. All rights reserved.
//

import SharedKit


class NodeModel: NSObject, Codable
{
    private(set) var nodeId: String?
    private(set) var nodeName: String?
    private(set) var avatar: String? = nil
    
    //sort
    @objc var initialLetter: String? = nil
    @objc var allLetter: String?
    var allLetterWithoutSpace: String?
    
    private enum CodingKeys: String, CodingKey {
        case nodeId
        case nodeName
        case allLetter
        case allLetterWithoutSpace
    }
    
    init(json: JSON)
    {
        nodeId = json["name"].string
        nodeName = json["title"].string
    }
    
    init(rootNode: HTMLNode)
    {
        nodeName = rootNode.content
        if var href = rootNode["href"], let range = href.range(of: "/go/")
        {
            href.replaceSubrange(range, with: SharedR.String.Empty)
            nodeId = href
        }
        avatar = rootNode.xPath(".//img").first?["src"]
    }
    
    init(favoriteNode: HTMLNode)
    {
        nodeName = favoriteNode.xPath("./div/text()").first?.content
        if var href = favoriteNode["href"], let range = href.range(of: "/go/")
        {
            href.replaceSubrange(range, with: SharedR.String.Empty)
            nodeId = href
        }
        avatar = favoriteNode.xPath(".//img").first?["src"]
    }
    
}


struct NodeGroupModel: Codable
{
    private(set) var childNodes = [NodeModel]()
    private(set) var groupName: String?
    
    init(rootNode: HTMLNode)
    {
        groupName = rootNode.xPath("./td[1]/span").first?.content
        for node in rootNode.xPath("./td[2]/a")
        {
            childNodes.append(NodeModel(rootNode: node))
        }
    }

}

extension NodeGroupModel: Equatable {}

func ==(lhs: NodeGroupModel, rhs: NodeGroupModel) -> Bool
{
    guard lhs.groupName == rhs.groupName, lhs.childNodes.count == rhs.childNodes.count else {
        return false
    }
    
    for i in 0..<lhs.childNodes.count
    {
        if lhs.childNodes[i].nodeName != rhs.childNodes[i].nodeName
        {
            return false
        }
    }
    return true
}
