//
//  Extensions.swift
//  VeXplore
//
//  Copyright © 2016 Jimmy. All rights reserved.
//

import SharedKit

extension UIColor
{
    func toHexString() -> String
    {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        let rgb:Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        return String(format:"#%06x", rgb)
    }
    
    private static let normalPalette = [
        "#FFFFFF", // background
        "#F8F8F8", // subBackground
        "#CDCDCD", // border
        "#999999", // note
        "#666666", // desc
        "#333333", // body
        "#C56FD5", // highlight
        "#00314F", // href
        "#FFFFF8"  // refBackground
    ]
    
    private static let nightPalette = [
        "#142634",
        "#172B44",
        "#38547A",
        "#50667B",
        "#7E8889",
        "#8FA9BC",
        "#D48872",
        "#EAC5A0",
        "#333333"
    ]

    private class var currentViewPalette: [String] {
        return UserDefaults.isNightModeEnabled ? nightPalette : normalPalette
    }
    
    class var background: UIColor {
        let colorString = currentViewPalette[0]
        return .colorWithHexString(colorString)
    }
    
    // background color of section header
    class var subBackground: UIColor {
        let colorString = currentViewPalette[1]
        return .colorWithHexString(colorString)
    }
    
    class var border: UIColor {
        let colorString = currentViewPalette[2]
        return .colorWithHexString(colorString)
    }
    
    // placeholder
    class var note: UIColor {
        let colorString = currentViewPalette[3]
        return .colorWithHexString(colorString)
    }
    
    // username, for description
    class var desc: UIColor {
        let colorString = currentViewPalette[4]
        return .colorWithHexString(colorString)
    }
    
    // topic title, topic body
    class var body: UIColor {
        let colorString = currentViewPalette[5]
        return .colorWithHexString(colorString)
    }
    
    class var highlight: UIColor {
        let colorString = currentViewPalette[6]
        return .colorWithHexString(colorString)
    }
    
    class var href: UIColor {
        let colorString = currentViewPalette[7]
        return .colorWithHexString(colorString)
    }
    
    class var refBackground: UIColor {
        let colorString = currentViewPalette[8]
        return .colorWithHexString(colorString)
    }

    
    private class func colorWithWhite(_ white:UInt) -> UIColor
    {
        return UIColor(white: CGFloat(white) / 255.0, alpha: 1.0)
    }
    
    private class func colorWithHexString (_ hex :String) -> UIColor
    {
        return .colorWithHexString(hex, alpha: 1.0)
    }
    
    private class func colorWithHexString (_ hex :String, alpha: CGFloat) -> UIColor
    {
        var cString = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if (cString.hasPrefix("#"))
        {
            let startIndex = cString.characters.index(cString.startIndex, offsetBy: 1)
            cString = cString.substring(from: startIndex)
        }
        if (cString.lenght != 6)
        {
            return .background
        }
        var rgbValue: UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: alpha
        )
    }
}

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


extension String
{
    var lenght: Int {
        get
        {
            return characters.count
        }
    }
    
    var floatValue: Float {
        get
        {
            return (self as NSString).floatValue
        }
    }
    
    var doubleValue: Double {
        get
        {
            return (self as NSString).doubleValue
        }
    }
    
    func stringByRemovingNewLinesAndWhitespace() -> String
    {
        let scanner = Scanner(string: self)
        scanner.charactersToBeSkipped = nil
        var result = R.String.Empty
        var temp: NSString? = nil
        let whitespaceCharacters = CharacterSet.whitespacesAndNewlines
        while scanner.isAtEnd == false
        {
            scanner.scanUpToCharacters(from: whitespaceCharacters, into: &temp)
            if temp != nil
            {
                result.append(temp! as String)
            }
            
            if scanner.scanCharacters(from: whitespaceCharacters, into: nil)
            {
                if result.isEmpty == false && scanner.isAtEnd == false
                {
                    result.append(" ")
                }
            }
        }
        return result
    }
    
    func getUppercaseLatinString() -> String
    {
        
        if let str1 = applyingTransform(.mandarinToLatin, reverse: false),
            let str2 = str1.applyingTransform(.stripCombiningMarks, reverse: false)
        {
            return str2.uppercased()
        }
        return uppercased()
    }
    
    func replace(_ string: String, with replacement:String) -> String
    {
        return self.replacingOccurrences(of: string, with: replacement, options: NSString.CompareOptions.literal, range: nil)
    }
    
    func removeWhitespace() -> String
    {
        return replace(" ", with: R.String.Empty)
    }
    
    func stringByRemovingWhitespaceAtBeginAndEnd() -> String
    {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func isValidImgUrl() -> Bool
    {
        return R.Array.ValidImgUrls.filter{ return self.contains($0) }.count > 0
    }
    
    func extractId() -> String?
    {
        var result: String?
        if let startRange = range(of: "/t/"),
        let endRange = range(of: "#")
        {
            result = substring(with: Range(startRange.upperBound..<endRange.lowerBound))
        }
        return result
    }
    
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat
    {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil)
        return boundingBox.height
    }
}


extension UIViewController
{
    func presentContentModalViewController(_ viewController: UIViewController, animated: Bool, completion: ((Void) -> Void)?)
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
    
    func dismissContentModalViewController(_ viewController: UIViewController, animated: Bool, completion: ((Void) -> Void)?)
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

extension UserDefaults
{
    subscript(key: String) -> String? {
        get
        {
            return UserDefaults.standard.object(forKey: key) as? String
        }
        set
        {
            UserDefaults.standard.setValue(newValue, forKey: key)
        }
    }
    
    class var fontScaleString: String {
        get
        {
            return UserDefaults.standard.string(forKey: R.Key.DynamicTitleFontScale) ?? "1.0"
        }
        
        set
        {
            UserDefaults.standard.set(newValue, forKey: R.Key.DynamicTitleFontScale)
        }
    }
    
    class var isPullReplyEnabled: Bool {
        get
        {
            return UserDefaults.standard.bool(forKey: R.Key.EnablePullReply)
        }
        
        set
        {
            UserDefaults.standard.set(newValue, forKey: R.Key.EnablePullReply)
        }
    }
    
    class var isHighlightOwnerRepliesEnabled: Bool {
        get
        {
            return UserDefaults.standard.bool(forKey: R.Key.EnableHighlightOwnerReplies)
        }
        
        set
        {
            UserDefaults.standard.set(newValue, forKey: R.Key.EnableHighlightOwnerReplies)
        }
    }
    
    class var isShakeEnabled: Bool {
        get
        {
            if let isShakeEnabled = UserDefaults.standard.object(forKey: R.Key.EnableShake) as? NSNumber
            {
                return isShakeEnabled.boolValue
            }
            return false
        }
        
        set
        {
            UserDefaults.standard.set(NSNumber(value: newValue as Bool), forKey: R.Key.EnableShake)
        }
    }
    
    class var isTabBarHiddenEnabled: Bool {
        get
        {
            return UserDefaults.standard.bool(forKey: R.Key.EnableTabBarHidden)
        }
        
        set
        {
            UserDefaults.standard.set(newValue, forKey: R.Key.EnableTabBarHidden)
        }
    }
    
    class var isNightModeEnabled: Bool {
        get
        {
            return UserDefaults.standard.bool(forKey: R.Key.EnableNightMode)
        }
        
        set
        {
            UserDefaults.standard.set(newValue, forKey: R.Key.EnableNightMode)
        }
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
    
}


extension UINavigationBar
{
    func setupNavigationbar()
    {
        isTranslucent = false
        barTintColor = .background
        tintColor = .desc
        titleTextAttributes = [NSForegroundColorAttributeName : UIColor.body]
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
