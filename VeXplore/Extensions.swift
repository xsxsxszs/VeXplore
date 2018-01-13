//
//  Extensions.swift
//  VeXplore
//
//  Copyright © 2016 Jimmy. All rights reserved.
//

import SharedKit

extension Array
{
    func shift(withDistance distance: Int = 1) -> Array<Element>
    {
        let index = distance >= 0 ?
            self.index(startIndex, offsetBy: distance, limitedBy: endIndex) :
            self.index(endIndex, offsetBy: distance, limitedBy: startIndex)
        guard index != nil else {
            return self
        }
        return Array(self[index! ..< endIndex] + self[startIndex ..< index!])
    }
    
    mutating func shiftInPlace(withDistance distance: Index = 1)
    {
        self = shift(withDistance: distance)
    }
}


extension UIImage
{
    func roundCornerImage() -> UIImage
    {
        let w = size.width
        let h = size.height
        let cornerRadius = max(min(w * 0.5, h * 0.5), 12) // set minimum corner radius for anti-aliasing 
        let imageFrame = CGRect(x: w * 0.5 - cornerRadius, y: h * 0.5 - cornerRadius, width: cornerRadius * 2, height: cornerRadius * 2)
        UIGraphicsBeginImageContextWithOptions(imageFrame.size, false, UIScreen.main.scale)
        let context = UIGraphicsGetCurrentContext()
        context?.translateBy(x: -imageFrame.origin.x, y: -imageFrame.origin.y) // shift the image
        UIBezierPath(roundedRect: imageFrame, cornerRadius: cornerRadius).addClip()
        draw(in: imageFrame)
        
        // draw border
        UIColor.border.setStroke()
        context?.strokeEllipse(in: imageFrame)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
    class func drawImage(size: CGSize, color: UIColor) -> UIImage?
    {
        let rect = CGRect(x: 0, y: 0, width: size.width, height: 1)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, UIScreen.main.scale)
        let context = UIGraphicsGetCurrentContext()
        color.setFill()
        context?.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}

extension UIViewController
{
    func presentContentModalViewController(_ viewController: UIViewController, animated: Bool, completion: (() -> Void)?)
    {
        viewController.view.frame = view.bounds
        addChildViewController(viewController)
        viewController.didMove(toParentViewController: self)
        view.addSubview(viewController.view)
        viewController.view.transform = CGAffineTransform(translationX: 0, y: viewController.view.bounds.height)
        
        UIView.animate(withDuration: animated ? 0.3 : 0, animations: {
            viewController.view.transform = CGAffineTransform.identity
            }, completion: { (_) in
                completion?()
        })
    }
    
    func dismissContentModalViewController(_ viewController: UIViewController, animated: Bool, completion: (() -> Void)?)
    {
        UIView.animate(withDuration: animated ? 0.3 : 0, animations: {
            viewController.view.transform = CGAffineTransform(translationX: 0, y: viewController.view.bounds.height)
            }, completion: { (_) in
                viewController.view.removeFromSuperview()
                viewController.willMove(toParentViewController: self)
                viewController.removeFromParentViewController()
                viewController.view.transform = CGAffineTransform.identity
                completion?()
        })
    }
    
    func bouncePresent(viewController: SwipeTransitionViewController, completion: (() -> Void)?)
    {
        viewController.transitioningDelegate = viewController
        present(viewController, animated: true, completion: completion)
    }
    
    func bouncePresent(navigationVCWith viewController: SwipeTransitionViewController, completion: (() -> Void)?)
    {
        let navigationVC = UINavigationController(rootViewController: viewController)
        navigationVC.transitioningDelegate = viewController
        present(navigationVC, animated: true, completion: completion)
    }
    
}


extension UITableViewCell
{
    func tableView() -> UITableView?
    {
        var superview = self.superview
        var tableView: UITableView?
        while superview != nil
        {
            if superview!.isKind(of: UITableView.self)
            {
                tableView = superview as? UITableView
                break
            }
            superview = superview!.superview
        }
        return tableView
    }
    
}

extension Notification.Name
{
    struct Setting
    {
        static let FontsizeDidChange = Notification.Name(rawValue: "vexplore.notification.name.setting.fontsizeDidChange")
        static let NightModeDidChange = Notification.Name(rawValue: "vexplore.notification.name.setting.nightModeDidChange")
    }
    
    struct Profile
    {
        static let NeedRefresh = Notification.Name(rawValue: "vexplore.notification.name.profile.needRefresh")
        static let Refresh = Notification.Name(rawValue: "vexplore.notification.name.profile.refresh")
    }
    
    struct Topic
    {
        static let CommentAdded = Notification.Name(rawValue: "vexplore.notification.name.topic.commentAdded")
    }
    
    struct User
    {
        static let DidLogin = Notification.Name(rawValue: "vexplore.notification.name.user.didLogin")
        static let DidLogout = Notification.Name(rawValue: "vexplore.notification.name.user.didLogout")
    }
    
}

extension NSRange
{
    init(with cfRange: CFRange)
    {
        self.location = cfRange.location
        self.length = cfRange.length
    }
    
}

extension CFRange
{
    init(with nsRange: NSRange)
    {
        self.location = nsRange.location
        self.length = nsRange.length
    }
    
}

extension CGPoint
{
    func pixelRound() -> CGPoint
    {
        let scale = UIScreen.main.scale
        return CGPoint(x: round(x * scale) / scale, y: round(y * scale) / scale)
    }
}

extension CGRect
{
    func pixelRound() -> CGRect
    {
        let scale = UIScreen.main.scale
        return CGRect(x: round(origin.x * scale) / scale, y: round(origin.y * scale) / scale, width: round(width * scale) / scale, height: round(height * scale) / scale)
    }
}


extension Request
{
    // MARK: - HTMLDoc Response
    @discardableResult
    func responseParsableHtml(completion completionHandler: @escaping (DataResponse<HTMLDoc>) -> Void) -> Self
    {
        return response(responseSerializer: htmlResponseSerializer()) { (response) in
            completionHandler(response)
        }
    }
    
    private func htmlResponseSerializer() -> DataResponseSerializer<HTMLDoc>
    {
        enum VeXploreError: Int
        {
            case requestError = 10004
            case serverError = 10005
            case invalidDataError = 10006
            case dataSerializationError = 10007
        }
        
        return DataResponseSerializer { request, response, data, error in
            if let statusCode = response?.statusCode
            {
                if statusCode % 100 == 4
                {
                    let error = NSError(domain: R.String.ErrorDomain, code: VeXploreError.requestError.rawValue, userInfo: nil)
                    return .failure(error)
                }
                else if statusCode % 100 == 5
                {
                    let error = NSError(domain: R.String.ErrorDomain, code: VeXploreError.serverError.rawValue, userInfo: nil)
                    return .failure(error)
                }
            }
            
            guard error == nil else {
                return .failure(error!)
            }
            
            guard let validData = data else {
                let error = NSError(domain: R.String.ErrorDomain, code: VeXploreError.invalidDataError.rawValue, userInfo: nil)
                return .failure(error)
            }
            
            if let htmlDoc = HTMLDoc(htmlData: validData)
            {
                return .success(htmlDoc)
            }
            
            let error = NSError(domain: R.String.ErrorDomain, code: VeXploreError.dataSerializationError.rawValue, userInfo: nil)
            return .failure(error)
        }
    }
    
}


extension UIApplication
{
    class func topViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController?
    {
        if let nav = base as? UINavigationController
        {
            return topViewController(base: nav.visibleViewController)
        }
        
        if let tab = base as? UITabBarController
        {
            let moreNavigationController = tab.moreNavigationController
            if let top = moreNavigationController.topViewController, top.view.window != nil
            {
                return topViewController(base: top)
            }
            else if let selected = tab.selectedViewController
            {
                return topViewController(base: selected)
            }
        }
        
        if let presented = base?.presentedViewController
        {
            return topViewController(base: presented)
        }
        
        return base
    }
    
    class func dismissTopAlert(completion: (() -> Swift.Void)? = nil)
    {
        if let topVC = UIApplication.topViewController(), topVC.isKind(of: UIAlertController.self)
        {
            topVC.dismiss(animated: false, completion: {
                self.dismissTopAlert(completion: completion)
            })
        }
        else
        {
            completion?()
        }
    }
    
}


extension UINavigationBar
{
    func setupNavigationbar()
    {
        isTranslucent = false
        barTintColor = .background
        tintColor = .desc
        titleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor.body]
        shadowImage = UIImage.drawImage(size: CGSize(width: frame.width, height: 1), color: .border)
        setBackgroundImage(UIImage(), for: .default)
    }
}


extension UITabBar
{
    func setupTabBar()
    {
        for tabBarItem in items!
        {
            tabBarItem.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0)
        }
        tintColor = .highlight
        isTranslucent = false
        barTintColor = .background
        shadowImage = UIImage.drawImage(size: CGSize(width: frame.width, height: 1), color: .border)
        backgroundImage = UIImage()
    }
}

