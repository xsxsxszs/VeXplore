//
//  MainViewController.swift
//  VeXplore
//
//  Copyright © 2016 Jimmy. All rights reserved.
//


class MainViewController: UITabBarController, UITabBarControllerDelegate
{
    static let shared = MainViewController()
    private let homeVC = HomePageViewController()
    private let nodesVC = NodesViewController()
    private let searchVC = SiteSearchViewController()
    private var notificationVC: NotificationViewController!
    private var profileVC: MyProfileViewController!
    private var notificationTabItem: UITabBarItem!

    private init()
    {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        buildUI()
        delegate = self
    }
    
    private func buildUI()
    {
        if User.shared.isLogin == true, let diskCachePath = cachePathString(withFilename: NotificationViewController.description()), let unarchiveVC = NSKeyedUnarchiver.unarchiveObject(withFile: diskCachePath), unarchiveVC is NotificationViewController
        {
            let VC = unarchiveVC as! NotificationViewController
            if VC.username == User.shared.username
            {
                notificationVC = VC
            }
        }
        
        notificationVC = notificationVC ?? NotificationViewController()
        
        if User.shared.isLogin == true,
            let diskCachePath = cachePathString(withFilename: MyProfileViewController.description()),
            let unarchiveVC = NSKeyedUnarchiver.unarchiveObject(withFile: diskCachePath),
            unarchiveVC is MyProfileViewController
        {
            profileVC = unarchiveVC as! MyProfileViewController
        }
        else
        {
            profileVC = MyProfileViewController()
        }
        
        nodesVC.searchVC.getAllNodesIfNeed()
        
        let homeNav = UINavigationController(rootViewController: homeVC)
        let nodesNav = UINavigationController(rootViewController: nodesVC)
        let searchNav = UINavigationController(rootViewController: searchVC)
        let notificationNav = UINavigationController(rootViewController: notificationVC)
        let profileNav = UINavigationController(rootViewController:profileVC)
        
        homeNav.tabBarItem = UITabBarItem(title: nil, image: R.Image.Home, selectedImage: R.Image.Home)
        nodesNav.tabBarItem = UITabBarItem(title: nil, image: R.Image.Nodes, selectedImage: R.Image.Nodes)
        searchNav.tabBarItem = UITabBarItem(title: nil, image: R.Image.TabarSearch, selectedImage: R.Image.TabarSearch)
        notificationTabItem = UITabBarItem(title: nil, image: R.Image.Notification, selectedImage: R.Image.Notification)
        notificationNav.tabBarItem = notificationTabItem
        profileNav.tabBarItem = UITabBarItem(title: nil, image: R.Image.Profile, selectedImage: R.Image.Profile)
        
        viewControllers = [homeNav, nodesNav, searchNav, notificationNav, profileNav]
        
        refreshColorScheme()
        
        NotificationCenter.default.addObserver(self, selector: #selector(refreshColorScheme), name: NSNotification.Name.Setting.NightModeDidChange, object: nil)
    }
    
    @objc
    private func refreshColorScheme()
    {
        tabBar.setupTabBar()
    }
    
    func setNotificationNum(_ number: Int)
    {
        notificationTabItem.badgeValue = number > 0 ? String(number) : nil
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool
    {
        if viewControllers![selectedIndex] == viewController
        {
            if selectedIndex == 0
            {
                homeVC.doubleTapTabarItem()
            }
            else if selectedIndex == 1
            {
                nodesVC.doubleTapTabarItem()
            }
            else if selectedIndex == 3
            {
                notificationVC.doubleTapTabarItem()
            }
            return false
        }
        return true
    }
    
}
