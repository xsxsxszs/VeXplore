//
//  AppDelegate.swift
//  VeXplore
//
//  Copyright © 2016 Jimmy. All rights reserved.
//


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate
{
    var window: UIWindow?
    lazy var mainVC = MainViewController.shared
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool
    {
        // clear cache if user update to new version
        if UserDefaults.standard[R.Key.LastCacheVersion] != currentVersion()
        {
            clearPageCache()
            UserDefaults.standard[R.Key.LastCacheVersion] = currentVersion()
        }
        UIApplication.shared.statusBarStyle = UserDefaults.isNightModeEnabled ? .lightContent : .default

        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.rootViewController = mainVC
        self.window?.makeKeyAndVisible()
        ImageCache.default.cleanExpiredDiskCache()

        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool
    {
        if url.scheme == "todayExtension", let topicId = url.query
        {
            let topicVC = TopicViewController()
            topicVC.topicId = topicId
            DispatchQueue.main.async(execute: {
                UIApplication.topViewController()?.bouncePresent(navigationVCWith: topicVC, completion: nil)
            })
        }
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

}

