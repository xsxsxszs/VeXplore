//
//  TopicReplyingViewController.swift
//  VeXplore
//
//  Copyright © 2016 Jimmy. All rights reserved.
//

import SafariServices
import StoreKit

class TopicReplyingViewController: InputViewController
{
    var atSomeone: String? {
        set
        {
            if let atSomeone = newValue
            {
                inputContainerView.contentTextView.text.append(atSomeone)
                inputContainerView.isPostEnabled = true
            }
        }
        get
        {
            fatalError("You cannot read from this object.")
        }
    }
    
    var topicId: String?

    override func viewDidLoad()
    {
        super.viewDidLoad()
        inputContainerView.titleLabel.text = R.String.Reply
        inputContainerView.imageBtn.isEnabled = true
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        inputContainerView.contentTextView.becomeFirstResponder()
    }
    
    override func resetTextViews()
    {
        super.resetTextViews()
        inputContainerView.contentTextView.placeholderText = R.String.ReplyPlaceholder
        inputContainerView.contentTextView.placeholderTextColor = .border
    }
    
    func textViewDidChange(_ textView: UITextView)
    {
        if textView == inputContainerView.contentTextView
        {
            inputContainerView.isPostEnabled = (textView.text.isEmpty == false)
        }
    }
    
    override func closeBtnTapped()
    {
        inputContainerView.contentTextView.resignFirstResponder()
        super.closeBtnTapped()
    }
    
    override func postBtnTapped()
    {
        if inputContainerView.contentTextView.text.isEmpty == false, let topicId = topicId
        {
            backgroudView.isHidden = false
            loadingCancelBtn.isHidden = false
            centerLoadingView.isHidden = false
            centerLoadingView.initSquaresNormalPostion()
            centerLoadingView.beginLoading()
            V2Request.Topic.reply(withTopicId: topicId, content: inputContainerView.contentTextView.text) { [weak self] (response) in
                guard let weakSelf = self else {
                    return
                }
                
                weakSelf.centerLoadingView.stopLoading(withSuccess: response.success, completion: { (success) in
                    if success
                    {
                        NotificationCenter.default.post(name: NSNotification.Name.Topic.CommentAdded, object: nil)
                        NotificationCenter.default.post(name: NSNotification.Name.Profile.NeedRefresh, object: nil)
                        ModalTransitioningDelegate.shared.reverseDirection = true
                        weakSelf.closeBtnTapped()
                        if #available(iOS 10.3, *)
                        {
                            SKStoreReviewController.requestReview()
                        }
                    }
                })
            }
        }
    }
    
    func safariViewControllerDidFinish(_ controller: SFSafariViewController)
    {
        if let newCopyString = UIPasteboard.general.string, newCopyString != copyedString, newCopyString.isValidImgUrl()
        {
            inputContainerView.contentTextView.text.append(newCopyString)
            inputContainerView.isPostEnabled = true
        }
    }
    
}
