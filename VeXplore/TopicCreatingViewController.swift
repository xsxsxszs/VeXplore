//
//  TopicCreatingViewController.swift
//  VeXplore
//
//  Copyright © 2016 Jimmy. All rights reserved.
//

import SafariServices

class TopicCreatingViewController: InputViewController, NodeSelectDelegate
{
    private var nodeId = R.String.Empty
    var recorededResponder: UITextView?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        inputContainerView.titleLabel.text = R.String.CreateNewTopic
        inputContainerView.titleTextViewHeight.constant = R.Constant.InputViewTitleHeight
        inputContainerView.nodeBtn.isHidden = false
        inputContainerView.nodeBtn.addTarget(self, action: #selector(nodeBtnTapped), for: .touchUpInside)
    }
    
    override func resetTextViews()
    {
        super.resetTextViews()
        inputContainerView.titleTextView.placeholderText = String(format: R.String.TitleCharactersLessThan, R.Constant.TopicTitleCharactersMax)
        inputContainerView.titleTextView.placeholderTextColor = .borderGray
        inputContainerView.contentTextView.placeholderText = String(format: R.String.ContentCharactersLessThan, R.Constant.TopicContentCharactersMax)
        inputContainerView.contentTextView.placeholderTextColor = .borderGray
        recorededResponder = nil
        nodeId = R.String.Empty
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        let firstResponder = recorededResponder ?? inputContainerView.titleTextView
        firstResponder.becomeFirstResponder()
    }
    
    func textViewDidChange(_ textView: UITextView)
    {
        if textView == inputContainerView.titleTextView
        {
            inputContainerView.isPostEnabled = (textView.text.isEmpty == false && nodeId.isEmpty == false)
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool
    {
        if textView == inputContainerView.titleTextView
        {
            return textView.text.lenght + (text.lenght - range.length) <= R.Constant.TopicTitleCharactersMax
        }
        else
        {
            return textView.text.lenght + (text.lenght - range.length) <= R.Constant.TopicContentCharactersMax
        }
    }
    
    // MARK: - NodeSelectDelegate
    func didSelectNode(_ node: NodeModel)
    {
        if let nodeName = node.nodeName, let nodeId = node.nodeId
        {
            let title = NSAttributedString(string: nodeName, attributes: [NSFontAttributeName: R.Font.Small, NSForegroundColorAttributeName: UIColor.lightPink])
            inputContainerView.nodeBtn.setAttributedTitle(title, for: .normal)
            self.nodeId = nodeId
            inputContainerView.isPostEnabled = (inputContainerView.titleTextView.text.isEmpty == false)
        }
    }
    
    // MARK: - Actions
    @objc
    private func nodeBtnTapped()
    {
        if inputContainerView.titleTextView.isFirstResponder
        {
            recorededResponder = inputContainerView.titleTextView
            inputContainerView.titleTextView.resignFirstResponder()
        }
        else
        {
            recorededResponder = inputContainerView.contentTextView
            inputContainerView.contentTextView.resignFirstResponder()
        }
        let searchVC = NodeSelectViewController()
        searchVC.getAllNodesIfNeed()
        searchVC.delegate = self
        let searchNav = UINavigationController(rootViewController: searchVC)
        searchNav.title = R.String.ChooseNode
        present(searchNav, animated: true, completion: nil)
    }
    
    override func closeBtnTapped()
    {
        super.closeBtnTapped()
        if inputContainerView.titleTextView.isFirstResponder
        {
            recorededResponder = inputContainerView.titleTextView
            inputContainerView.titleTextView.resignFirstResponder()
        }
        else
        {
            recorededResponder = inputContainerView.contentTextView
            inputContainerView.contentTextView.resignFirstResponder()
        }
    }
    
    override func imageBtnTapped()
    {
        recorededResponder = inputContainerView.titleTextView.isFirstResponder ? inputContainerView.titleTextView : inputContainerView.contentTextView
        super.imageBtnTapped()
    }
    
    override func postBtnTapped()
    {
        if inputContainerView.titleTextView.text.isEmpty == false, nodeId.isEmpty == false
        {
            backgroudView.isHidden = false
            loadingCancelBtn.isHidden = false
            centerLoadingView.isHidden = false
            centerLoadingView.initSquaresNormalPostion()
            centerLoadingView.beginLoading()
            V2Request.Topic.postTopic(withNodeId: nodeId, title: inputContainerView.titleTextView.text, content: inputContainerView.contentTextView.text, completionHandler: { [weak self] (response) in
                guard let weakSelf = self else {
                    return
                }
                
                weakSelf.centerLoadingView.stopLoading(withSuccess: response.success, completion: { (success) in
                    if success
                    {
                        NotificationCenter.default.post(name: NSNotification.Name.Profile.Refresh, object: nil)
                        ModalTransitioningDelegate.shared.reverseDirection = true
                        weakSelf.closeBtnTapped()
                    }
                })
            })
        }
    }
    
    // MARK: - SFSafariViewControllerDelegate
    func safariViewControllerDidFinish(_ controller: SFSafariViewController)
    {
        if let newCopyString = UIPasteboard.general.string, newCopyString != copyedString, newCopyString.isValidImgUrl()
        {
            inputContainerView.contentTextView.text.append(newCopyString)
        }
    }
    
}
