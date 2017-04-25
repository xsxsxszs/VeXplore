//
//  NodeModel.swift
//  VeXplore
//
//  Copyright © 2016 Jimmy. All rights reserved.
//

import SharedKit


class NodeModel: NSObject
{
    private(set) var nodeId: String?
    private(set) var nodeName: String?
    private(set) var avatar: String?
    
    //sort
    var initialLetter: String?
    var allLetter: String?
    var allLetterWithoutSpace: String?
    
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
            href.replaceSubrange(range, with: R.String.Empty)
            nodeId = href
        }
        avatar = rootNode.xPath(".//img").first?["src"]
    }
    
    func encodeWithCoder(_ aCoder: NSCoder)
    {
        aCoder.encode(nodeId, forKey: "nodeId")
        aCoder.encode(nodeName, forKey: "nodeName")
        aCoder.encode(allLetter, forKey: "allLetter")
        aCoder.encode(allLetterWithoutSpace, forKey: "allLetterWithoutSpace")
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init()
        nodeId = aDecoder.decodeObject(forKey: "nodeId") as? String
        nodeName = aDecoder.decodeObject(forKey: "nodeName") as? String
        allLetter = aDecoder.decodeObject(forKey: "allLetter") as? String
        allLetterWithoutSpace = aDecoder.decodeObject(forKey: "allLetterWithoutSpace") as? String
    }
    
}


class NodeGroupModel: NSObject
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
    
    func encodeWithCoder(_ aCoder: NSCoder)
    {
        aCoder.encode(groupName, forKey: "groupName")
        aCoder.encode(childNodes, forKey: "childNodes")
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init()
        groupName = aDecoder.decodeObject(forKey: "groupName") as? String
        childNodes = aDecoder.decodeObject(forKey: "childNodes") as! [NodeModel]
    }
    
    override func isEqual(_ object: Any?) -> Bool
    {
        guard let other = object as? NodeGroupModel, groupName == other.groupName, childNodes.count == other.childNodes.count else {
            return false
        }
        
        for i in 0..<childNodes.count
        {
            if childNodes[i].nodeName != other.childNodes[i].nodeName
            {
                return false
            }
        }
        return true
    }

}
