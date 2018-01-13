//
//  ActionViewController.swift
//  ActionExtension
//
//  Created by Jing Chen on 22/11/2017.
//  Copyright © 2017 Jimmy. All rights reserved.
//

import SharedKit
import MobileCoreServices

class ActionNavigationController: UINavigationController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        viewControllers = [ActionViewController()]
    }
    
}


class ActionViewController: UIViewController
{
    var topicURL: String?

    let descLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = SharedR.Font.Medium
        label.textColor = .note
        label.textAlignment = .center
        label.numberOfLines = 0
        
        return label
    }()
    
    private lazy var viewBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(viewBtnTapped), for: .touchUpInside)
        let normalText = NSMutableAttributedString(string: SharedR.String.ViewInApp, attributes: [.font: SharedR.Font.VeryLarge, .foregroundColor: UIColor.desc])
        btn.setAttributedTitle(normalText, for: .normal)
        btn.layer.borderWidth = 1.0
        btn.layer.cornerRadius = 5.0
        btn.layer.borderColor = UIColor.desc.cgColor
        btn.isHidden = true
        
        return btn
    }()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        view.backgroundColor = .refBackground
        navigationItem.title = SharedR.String.V2EX
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonTapped(_:)))
        
        view.addSubview(descLabel)
        descLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        descLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        descLabel.text = SharedR.String.InvalidTopic
        
        view.addSubview(viewBtn)
        viewBtn.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        viewBtn.topAnchor.constraint(equalTo: descLabel.bottomAnchor, constant: 20.0).isActive = true
        viewBtn.widthAnchor.constraint(equalToConstant: 112.0).isActive = true
        viewBtn.heightAnchor.constraint(equalToConstant: 44.0).isActive = true
        
        var found = false
        for item in self.extensionContext!.inputItems as! [NSExtensionItem]
        {
            for provider in item.attachments! as! [NSItemProvider]
            {
                if provider.hasItemConformingToTypeIdentifier(kUTTypeURL as String)
                {

                    provider.loadItem(forTypeIdentifier: kUTTypeURL as String, options: nil, completionHandler: { (item, error) in
                        if let url = item as? URL
                        {
                            let topicURL = url.absoluteString
                            let result = URLAnalysisResult(url: topicURL)
                            if result.type == .topic
                            {
                                self.topicURL = topicURL
                                dispatch_async_safely_to_main_queue {
                                    self.descLabel.text = SharedR.String.ValidTopic
                                    self.viewBtn.isHidden = false
                                }
                            }
                        }
                    })
                    found = true
                }
                break
            }
            if found
            {
                break
            }
        }
    }
    
    @objc
    private func viewBtnTapped(_ sender: UIBarButtonItem)
    {
        if let topicURL = self.topicURL, let url = URL(string: "vexplore://?\(topicURL)")
        {
            openUrl(url: url)
            extensionContext!.completeRequest(returningItems: nil, completionHandler: nil)
        }
    }
    
    private func openUrl(url: URL?)
    {
        let selector = sel_registerName("openURL:")
        var responder = self as UIResponder?
        while let r = responder, !r.responds(to: selector)
        {
            responder = r.next
        }
        _ = responder?.perform(selector, with: url)
    }
    
    @objc
    private func cancelButtonTapped(_ sender: UIBarButtonItem)
    {
        extensionContext!.completeRequest(returningItems: nil, completionHandler: nil)
    }
    
}
