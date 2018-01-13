//
//  URLAnalyzer.swift
//  VeXplore
//
//  Copyright © 2016 Jimmy. All rights reserved.
//

import SafariServices
import MessageUI
import SharedKit

struct URLAnalyzer
{
    @discardableResult
    static func Analyze(url:String, handleViewController: SwipeTableViewController) -> Bool
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
                    let topicVC = TopicViewController(topicId: topicId)
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

