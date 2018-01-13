//
//  URLAnalysisResult.swift
//  VeXplore
//
//  Copyright © 2016 Jimmy. All rights reserved.
//

public struct URLAnalysisResult
{
    public enum URLType: Int
    {
        case topic = 0
        case member
        case node
        case email
        case url
        case undefined
    }
    
    static let patternsRE: [NSRegularExpression] = SharedR.Array.URLPatterns.map{ try! NSRegularExpression(pattern: $0, options: .caseInsensitive) }
    public var type: URLType = .undefined
    public var value: String?
    
    public init(url: String)
    {
        for (index, regex) in URLAnalysisResult.patternsRE.enumerated()
        {
            if regex.numberOfMatches(in: url, options: .withoutAnchoringBounds, range: NSMakeRange(0, url.count)) > 0
            {
                type = URLType(rawValue: index)!
                switch type
                {
                case .topic:
                    if let range = url.range(of: "/t/")
                    {
                        var topicId = url[range.upperBound...]
                        if let range = topicId.range(of: "?")
                        {
                            topicId = topicId[..<range.lowerBound]
                        }
                        if let range = topicId.range(of: "#")
                        {
                            topicId = topicId[..<range.lowerBound]
                        }
                        value = String(topicId)
                    }
                case .member:
                    if let range = url.range(of: "/member/")
                    {
                        let username = url[range.upperBound...]
                        value = String(username)
                    }
                case .node:
                    if let range = url.range(of: "/go/")
                    {
                        let nodeID = url[range.upperBound...]
                        value = String(nodeID)
                    }
                case .email:
                    if let range = url.range(of: "mailto:")
                    {
                        let recipient = url[range.upperBound...]
                        value = String(recipient)
                    }
                case .url:
                    value = url
                default:
                    break
                }
                break
            }
        }
    }
    
}
