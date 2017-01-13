//
//  PresentAnimation.swift
//  VeXplore
//
//  Copyright © 2016 Jimmy. All rights reserved.
//


class SwipeDismissInteractiveTransition: UIPercentDrivenInteractiveTransition, UIGestureRecognizerDelegate
{
    weak private var presentedVC: SwipeTransitionViewController!
    fileprivate var interactionEnabled = false
    private var shouldComplete = false
    private var touchStartPoint: CGPoint!
    fileprivate var dismissStyle: TransitionDismissStyle = .down

    convenience init(presentedVC: SwipeTransitionViewController)
    {
        self.init()
        self.presentedVC = presentedVC
        dismissStyle = presentedVC.dismissStyle
        
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(handleGesture(_:)))
        gesture.delegate = self
        presentedVC.view.addGestureRecognizer(gesture)
    }
    
    // MARK: - UIGestureRecognizerDelegate
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool
    {
        var shouldBegin = presentedVC?.programaticScrollEnabled ?? false
        if shouldBegin,
            dismissStyle == .right,
            let gesture = gestureRecognizer as? UIPanGestureRecognizer,
            abs(gesture.velocity(in: presentedVC?.view).y) > abs(gesture.velocity(in: presentedVC?.view).x) || gesture.velocity(in: presentedVC?.view).x < 0
        {
            shouldBegin = false
        }
        return shouldBegin
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool
    {
        return true
    }
    
    @objc
    private func handleGesture(_ gestureRecognizer: UIPanGestureRecognizer)
    {
        switch gestureRecognizer.state
        {
        case .began:
            interactionEnabled = true
            presentedVC?.dismiss(animated: true, completion: nil)
        case .changed:
            if let gestureView = gestureRecognizer.view
            {
                let translation = gestureRecognizer.translation(in: gestureView.superview)
                if let superView = gestureView.superview
                {
                    let superViewBounds = superView.bounds
                    var fraction: CGFloat = 0
                    switch dismissStyle
                    {
                    case .down:
                        fraction = translation.y / superViewBounds.height
                    case .right:
                        fraction = translation.x / superViewBounds.height
                    default:
                        break
                    }
                    shouldComplete = (fraction > 0.25)
                    update(fraction)
                }
            }
        case .ended, .cancelled:
            interactionEnabled = false
            if !shouldComplete || gestureRecognizer.state == .cancelled
            {
                cancel()
            }
            else
            {
                finish()
            }
        default:
            break
        }
    }
    
}


class BouncePresentTransition: NSObject, UIViewControllerAnimatedTransitioning
{
    private let presentDuration = 0.6
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval
    {
        return presentDuration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning)
    {
        if let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from),
            let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)
        {
            let containerView = transitionContext.containerView
            let finalFrame = transitionContext.finalFrame(for: toVC)
            toVC.view.frame = finalFrame.offsetBy(dx: 0, dy: containerView.bounds.height)
            containerView.addSubview(toVC.view)
            UIView.animate(withDuration: presentDuration, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 3, options: .curveEaseOut, animations: {
                fromVC.view.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
                fromVC.view.alpha = 0.3
                toVC.view.frame = finalFrame
                }, completion: { (_) in
                    fromVC.view.transform = CGAffineTransform.identity
                    transitionContext.completeTransition(true)
            })
        }
    }
}

class SwipeDismissTransition: NSObject, UIViewControllerAnimatedTransitioning
{
    private let dismissDuration = 0.45
    fileprivate var dismissStyle: TransitionDismissStyle = .down
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval
    {
        return dismissDuration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning)
    {
        if let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from),
            let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)
        {
            let containerView = transitionContext.containerView
            let intialFrame = transitionContext.initialFrame(for: fromVC)
            var finalFrame: CGRect = .zero
            switch dismissStyle
            {
            case .down:
                finalFrame = intialFrame.offsetBy(dx: 0, dy: containerView.bounds.height)
            case .right:
                finalFrame = intialFrame.offsetBy(dx: containerView.bounds.width, dy: 0)
            default:
                break
            }
            toVC.view.frame = intialFrame
            containerView.addSubview(toVC.view)
            containerView.sendSubview(toBack: toVC.view)
            toVC.view.alpha = 0.3
            toVC.view.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            
            let animations: (Void) -> Void = {
                fromVC.view.frame = finalFrame
                toVC.view.alpha = 1.0
                toVC.view.transform = CGAffineTransform.identity
            }
            let completion: (Bool) -> Void = { _ in
                if transitionContext.transitionWasCancelled
                {
                    toVC.view.transform = CGAffineTransform.identity
                    toVC.view.removeFromSuperview()
                }
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
            UIView.animate(withDuration: dismissDuration, delay: 0, options: .curveEaseInOut, animations: animations, completion: completion)
        }
    }
    
}


enum TransitionDismissStyle: Int
{
    case down
    case right
    case none
}

class SwipeTransitionViewController: UIViewController, UIViewControllerTransitioningDelegate
{
    private let presentTransition = BouncePresentTransition()
    private var dismissTransition: SwipeDismissTransition!
    private var swipeDismissInteractiveTransition: SwipeDismissInteractiveTransition!
    var dismissStyle: TransitionDismissStyle = .down
    var programaticScrollEnabled = true

    override func viewDidLoad()
    {
        super.viewDidLoad()
        switch dismissStyle
        {
        case .down, .right:
            dismissTransition = SwipeDismissTransition()
            swipeDismissInteractiveTransition = SwipeDismissInteractiveTransition(presentedVC: self)
        default:
            break
        }
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning?
    {
        return presentTransition
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning?
    {
        dismissTransition.dismissStyle = dismissStyle
        return dismissTransition
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning?
    {
        swipeDismissInteractiveTransition.dismissStyle = dismissStyle
        return swipeDismissInteractiveTransition.interactionEnabled ? swipeDismissInteractiveTransition : nil
    }
    
    // MARK: - UIScrollViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView)
    {
        switch dismissStyle
        {
        case .down:
            programaticScrollEnabled = scrollView.contentOffset.y <= 0
        case .right:
            programaticScrollEnabled = scrollView.contentOffset.x <= 0
        default:
            programaticScrollEnabled = false
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView)
    {
        switch dismissStyle
        {
        case .down:
            programaticScrollEnabled = scrollView.contentOffset.y <= 0
        case .right:
            programaticScrollEnabled = scrollView.contentOffset.x <= 0
        default:
            programaticScrollEnabled = false
        }
    }

}
