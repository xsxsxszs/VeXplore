//
//  ModalPresenter.swift
//  VeXplore
//
//  Copyright © 2016 Jimmy. All rights reserved.
//


/////////////////////////////////////
////// Presentation Controller //////
/////////////////////////////////////

class ModalPresentationController: UIPresentationController
{
    private var dimmingView = UIView()
    private var isKeyboardShowed = false
    private var presentdeViewHeight = R.Constant.InputViewHeightMax
    private var frameOffsetYOfPresentedView: CGFloat = 0

    override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?)
    {
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame(_:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
    }
    
    // UIPresentationController callback
    override func containerViewWillLayoutSubviews()
    {
        guard let containerView = containerView else {
            return
        }
        
        dimmingView.frame = containerView.bounds
        presentedView?.frame = frameOfPresentedViewInContainerView
    }
    
    override var frameOfPresentedViewInContainerView: CGRect
    {
        guard let containerView = containerView else {
            return .zero
        }
        
        let size = CGSize(width: min(R.Constant.InputViewWidthMax, containerView.bounds.width), height: presentdeViewHeight)
        let frame = CGRect(x: (containerView.bounds.width - size.width) / 2.0, y: (containerView.bounds.height - size.height) / 2.0 + frameOffsetYOfPresentedView, width: size.width, height: size.height)
        return frame
    }
    
    override func presentationTransitionWillBegin()
    {
        dimmingView.backgroundColor = UIColor(white: 0, alpha: 0.25)
        dimmingView.frame = containerView!.bounds
        dimmingView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        dimmingView.alpha = 0
        containerView?.insertSubview(dimmingView, at: 0)
        if let transitionCoordinator = presentedViewController.transitionCoordinator
        {
            transitionCoordinator.animate(alongsideTransition: { (context) in
                self.dimmingView.alpha = 1
                }, completion: nil)
        }
        else
        {
            dimmingView.alpha = 1
        }
    }
    
    override func presentationTransitionDidEnd(_ completed: Bool)
    {
        if !completed
        {
            dimmingView.removeFromSuperview()
        }
    }
    
    override func dismissalTransitionWillBegin()
    {
        if let transitionCoordinator = presentedViewController.transitionCoordinator
        {
            transitionCoordinator.animate(alongsideTransition: { [weak self] (context) -> Void in
                self?.dimmingView.alpha = 0
                }, completion: nil)
        }
        else
        {
            dimmingView.alpha = 0
        }
    }
    
    override func dismissalTransitionDidEnd(_ completed: Bool)
    {
        if completed
        {
            dimmingView.removeFromSuperview()
        }
    }
    
    // handle keyboard event
    @objc
    private func keyboardWillShow(_ notification: Notification)
    {
        guard isKeyboardShowed == false else {
            return
        }
        isKeyboardShowed = true
        keyboardWillUpdate(notification)
    }
    
    @objc
    private func keyboardWillHide(_ notification: Notification)
    {
        guard isKeyboardShowed == true else {
            return
        }
        isKeyboardShowed = false
        keyboardWillUpdate(notification)
    }
    
    @objc
    private func keyboardWillChangeFrame(_ notification: Notification)
    {
        keyboardWillUpdate(notification)
    }
    
    @objc
    private func keyboardWillUpdate(_ notification: Notification)
    {
        if let userInfo = notification.userInfo,
            let newKeyboardSize = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
            let duration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue,
            let animationOption = (userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber)?.uintValue
        {
            guard newKeyboardSize != CGRect.zero, let containerView = containerView else {
                return
            }
            
            let windowContainer = containerView.window ?? containerView
            presentdeViewHeight = min(presentdeViewHeight, windowContainer.bounds.height - newKeyboardSize.height - statusBarHeight())
            let keyboardFrame = containerView.convert(newKeyboardSize, from: nil)
            let minY = max(containerView.bounds.height - keyboardFrame.height, keyboardFrame.minY) - presentdeViewHeight
            let offsetY = minY - (containerView.bounds.height - presentdeViewHeight) / 2.0
            frameOffsetYOfPresentedView = min(0, offsetY)
            
            let animations: (Void) -> Void = {
                self.presentedView?.frame.origin.y = self.frameOfPresentedViewInContainerView.origin.y
            }
            let completion: (Bool) -> Void = { finished in
                // set presentedView's frame if keyboard showed
                if self.isKeyboardShowed
                {
                    self.presentedView?.frame = self.frameOfPresentedViewInContainerView
                }
            }
            UIView.animate(withDuration: duration, delay: 0, options: [UIViewAnimationOptions(rawValue: animationOption)], animations: animations, completion: completion)
        }
    }
    
}



//////////////////////
////// Animator //////
//////////////////////

class ModalTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning
{
    var present = true // If set to false, perform dismiss transitioning
    var reverseDirection = false // If set to true, view will be presented from top
    private let durantion = 0.25
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval
    {
        return durantion
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning)
    {
        if let fromVC = transitionContext.viewController(forKey: .from),
            let toVC = transitionContext.viewController(forKey: .to)
        {
            let containerView = transitionContext.containerView
            let fromView = transitionContext.view(forKey: .from)
            let toView = transitionContext.view(forKey: .to)
            
            let viewToAnimate: UIView! = present ? toView : fromView
            let controllerToAnimate = present ? toVC : fromVC
            
            let intialFrame = transitionContext.initialFrame(for: controllerToAnimate)
            let finalFrame = transitionContext.finalFrame(for: controllerToAnimate)
            
            if present
            {
                viewToAnimate.frame = finalFrame
                if reverseDirection
                {
                    viewToAnimate.transform = CGAffineTransform(translationX: 0, y: -finalFrame.maxY)
                }
                else
                {
                    viewToAnimate.transform = CGAffineTransform(translationX: 0, y: containerView.bounds.height - finalFrame.minY)
                }
            }
            else
            {
                viewToAnimate.frame = intialFrame
                viewToAnimate.transform = CGAffineTransform.identity
            }
            
            containerView.addSubview(viewToAnimate)
            
            let animations: (Void) -> Void = {
                if self.present
                {
                    viewToAnimate.transform = CGAffineTransform.identity
                }
                else
                {
                    if self.reverseDirection
                    {
                        viewToAnimate.transform = CGAffineTransform(translationX: 0, y: -intialFrame.maxY)
                    }
                    else
                    {
                        viewToAnimate.transform = CGAffineTransform(translationX: 0, y: containerView.bounds.height - intialFrame.minY)
                    }
                }
            }
            
            let completion: (Bool) -> Void = { finished in
                if self.present == false
                {
                    viewToAnimate.transform = CGAffineTransform.identity
                    viewToAnimate.removeFromSuperview()
                }
                transitionContext.completeTransition(finished)
            }
            
            UIView.animate(withDuration: durantion, delay: 0, options: .curveEaseInOut, animations: animations, completion: completion)
        }
    }
    
}



////////////////////////////////////
////// Transitioning Delegate //////
////////////////////////////////////

class ModalTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate
{
    static let shared = ModalTransitioningDelegate()
    private let transitionAnimator = ModalTransitionAnimator()
    var reverseDirection: Bool = false
    
    private override init()
    {
        super.init()
    }
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return ModalPresentationController(presentedViewController: presented, presenting: presenting)
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning?
    {
        transitionAnimator.present = true
        transitionAnimator.reverseDirection = false
        return transitionAnimator
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning?
    {
        transitionAnimator.present = false
        transitionAnimator.reverseDirection = reverseDirection
        return transitionAnimator
    }
    
}

