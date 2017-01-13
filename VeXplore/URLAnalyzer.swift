//
//  URLAnalyzer.swift
//  VeXplore
//
//  Copyright © 2016 Jimmy. All rights reserved.
//

import SafariServices
import MessageUI

struct URLAnalyzer
{
    @discardableResult
    static func Analyze(url:String, handleViewController: BaseTableViewController) -> Bool
    {
        let result = URLAnalysisResult(url: url)
        dispatch_async_safely_to_main_queue {
            switch result.type
            {
            case .url:
                if let urlString = result.value, let url = URL(string: urlString)
                {
                    // open in safari
                    let safariVC = SFSafariViewController(url: url, entersReaderIfAvailable: true)
                    handleViewController.present(safariVC, animated: true, completion: nil)
                }
            case .member:
                if let username = result.value
                {
                    let profileVC = OtherProfileViewController()
                    profileVC.username = username
                    handleViewController.bouncePresent(viewController: profileVC, completion: nil)
                }
            case .topic:
                if let topicId = result.value
                {
                    let topicVC = TopicViewController()
                    topicVC.topicId = topicId
                    handleViewController.bouncePresent(navigationVCWith: topicVC, completion: nil)
                }
            case .node:
                if let nodeId = result.value
                {
                    let nodeTopicListVC = NodeTopicListViewController()
                    nodeTopicListVC.nodeId = nodeId
                    handleViewController.bouncePresent(navigationVCWith: nodeTopicListVC, completion: {
                        nodeTopicListVC.startLoading()
                    })
                }
            case .email:
                if let recipient = result.value
                {
                    if MFMailComposeViewController.canSendMail()
                    {
                        let mailCompose = MFMailComposeViewController()
                        mailCompose.mailComposeDelegate = handleViewController
                        mailCompose.setToRecipients([recipient])
                        dispatch_async_safely_to_main_queue {
                            handleViewController.present(mailCompose, animated: true, completion: nil)
                        }
                    }
                    else
                    {
                        let alertController = UIAlertController(title: nil, message: R.String.EmailNotSetAlert, preferredStyle: .alert)
                        let copyAction = UIAlertAction(title: R.String.Confirm, style: .default) { (action) in
                            UIPasteboard.general.string = recipient
                        }
                        alertController.addAction(copyAction)
                        dispatch_async_safely_to_main_queue {
                            handleViewController.present(alertController, animated: true, completion: nil)
                        }
                    }
                }
            case .undefined:
                break
            }
        }
        if result.type == .undefined
        {
            return false
        }
        return true
    }

}


struct URLAnalysisResult
{
    enum URLType: Int
    {
        case url = 0
        case member
        case topic
        case node
        case email
        case undefined
    }
    
    static let patternsRE: [NSRegularExpression] = R.Array.URLPatterns.map{ try! NSRegularExpression(pattern: $0, options: .caseInsensitive) }
    var type: URLType = .undefined
    var value: String?
    
    init(url: String)
    {
        for (index, regex) in URLAnalysisResult.patternsRE.enumerated()
        {
            if regex.numberOfMatches(in: url, options: .withoutAnchoringBounds, range: NSMakeRange(0, url.lenght)) > 0
            {
                type = URLType(rawValue: index)!
                switch type
                {
                case .url:
                    value = url
                case .member:
                    if let range = url.range(of: "/member/")
                    {
                        let username = url.substring(from: range.upperBound)
                        value = username
                    }
                case .topic:
                    if let range = url.range(of: "/t/")
                    {
                        var topicId = url.substring(from: range.upperBound)
                        if let range = topicId.range(of: "?")
                        {
                            topicId = topicId.substring(to: range.lowerBound)
                        }
                        if let range = topicId.range(of: "#")
                        {
                            topicId = topicId.substring(to: range.lowerBound)
                        }
                        value = topicId
                    }
                case .node:
                    if let range = url.range(of: "/go/")
                    {
                        let nodeID = url.substring(from: range.upperBound)
                        value = nodeID
                    }
                case .email:
                    if let range = url.range(of: "mailto:")
                    {
                        let recipient = url.substring(from: range.upperBound)
                        value = recipient
                    }
                default:
                    break
                }
            }
        }
    }
    
}
