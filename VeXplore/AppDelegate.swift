//
//  AppDelegate.swift
//  VeXplore
//
//  Copyright © 2016 Jimmy. All rights reserved.
//

import SharedKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate
{
    var window: UIWindow?
    lazy var mainVC = MainViewController.shared
    var timer: Timer?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool
    {
        // clear cache if user update to new version
        if UserDefaults.standard[R.Key.LastCacheVersion] != currentVersion()
        {
            clearPageCache()
            UserDefaults.standard[R.Key.LastCacheVersion] = currentVersion()
        }

        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.rootViewController = mainVC
        self.window?.makeKeyAndVisible()
        ImageCache.default.cleanExpiredDiskCache()

        NotificationCenter.default.addObserver(self, selector: #selector(nightModeDidChange), name: NSNotification.Name.Setting.NightModeDidChange, object: nil)

        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool
    {
        if let topicURL = url.query
        {
            let result = URLAnalysisResult(url: topicURL)
            if result.type == .topic, let topicId = result.value
            {
                let topicVC = TopicViewController(topicId: topicId)
                UIApplication.topViewController()?.bouncePresent(navigationVCWith: topicVC, completion: nil)
            }
        }
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication)
    {
        timer?.invalidate()
        timer = nil
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication)
    {
        openURLFromPasteboard()
        NotificationCenter.default.post(name: Notification.Name.Setting.NightModeDidChange, object: nil)
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    // MARK: - Private
    private func openURLFromPasteboard()
    {
        if let url = UIPasteboard.general.string
        {
            let result = URLAnalysisResult(url: url)
            if result.type == .topic, let topicId = result.value
            {
                V2Request.Topic.getDetail(withTopicId: topicId) { (response) in
                    UIPasteboard.general.string = SharedR.String.Empty
                    let alertController = UIAlertController(title: R.String.Topic, message: response.value?.topicTitle, preferredStyle: .alert)
                    let okAction = UIAlertAction(title: R.String.ViewDetail, style: .default, handler: { (_) in
                        let topicVC = TopicViewController(topicId: topicId)
                        UIApplication.topViewController()?.bouncePresent(navigationVCWith: topicVC, completion: nil)
                    })
                    let cancelAction = UIAlertAction(title: R.String.Cancel, style: .cancel, handler: nil)
                    alertController.addAction(okAction)
                    alertController.addAction(cancelAction)
                    
                    UIApplication.dismissTopAlert(completion: {
                        UIApplication.topViewController()?.present(alertController, animated: true, completion: nil)
                    })
                }
            }
        }
    }
    
    @objc
    private func nightModeDidChange()
    {
        refreshColorScheme()
        if !UserDefaults.isNightModeAlwaysEnabled && UserDefaults.isNightModeScheduleEnabled
        {
            scheduleTimer()
        }
        else
        {
            timer?.invalidate()
            timer = nil
        }
    }
    
    private func refreshColorScheme()
    {
        UIApplication.shared.statusBarStyle = UserDefaults.isNightModeEnabled ? .lightContent : .default
    }
    
    private func scheduleTimer()
    {
        timer?.invalidate()
        if let fireDate = targetScheduleDate()
        {
            timer = Timer(fireAt: fireDate, interval: 1, target: self, selector: #selector(changeNightMode), userInfo: nil, repeats: false)
            RunLoop.current.add(timer!, forMode: .commonModes)
        }
    }
    
    @objc
    private func changeNightMode()
    {
        NotificationCenter.default.post(name: Notification.Name.Setting.NightModeDidChange, object: nil)
    }
    
    private func targetScheduleDate() -> Date?
    {
        let calendar = Calendar.current
        var targetDate: Date?
        let currentDate = Date()
        if let startDate = UserDefaults.scheduleStartDate,
            let endDate = UserDefaults.scheduleEndDate
        {
            if endDate.compareTimeOnly(startDate) == .orderedAscending
            {
                if startDate.compareTimeOnly(currentDate) == .orderedAscending // current < start < end
                {
                    targetDate = startDate
                    let targetTimeComponents = calendar.dateComponents([.hour, .minute, .second], from: targetDate!)
                    targetDate = calendar.date(bySettingHour: targetTimeComponents.hour ?? 0, minute: targetTimeComponents.minute ?? 0, second: targetTimeComponents.second ?? 0, of: currentDate)
                }
                else if endDate.compareTimeOnly(currentDate) == .orderedAscending // start < current < end
                {
                    targetDate = endDate
                    let targetTimeComponents = calendar.dateComponents([.hour, .minute, .second], from: targetDate!)
                    targetDate = calendar.date(bySettingHour: targetTimeComponents.hour ?? 0, minute: targetTimeComponents.minute ?? 0, second: targetTimeComponents.second ?? 0, of: currentDate)
                }
                else // start < end < current
                {
                    // next day
                    var dayComponent = DateComponents()
                    dayComponent.day = 1
                    if let nextDate = calendar.date(byAdding: dayComponent, to: currentDate)
                    {
                        targetDate = startDate
                        let targetTimeComponents = calendar.dateComponents([.hour, .minute, .second], from: targetDate!)
                        targetDate = calendar.date(bySettingHour: targetTimeComponents.hour ?? 0, minute: targetTimeComponents.minute ?? 0, second: targetTimeComponents.second ?? 0, of: nextDate)
                    }
                }
            }
            else if endDate.compareTimeOnly(startDate) == .orderedDescending
            {
                if endDate.compareTimeOnly(currentDate) == .orderedAscending // current < end < start
                {
                    targetDate = endDate
                    let targetTimeComponents = calendar.dateComponents([.hour, .minute, .second], from: targetDate!)
                    targetDate = calendar.date(bySettingHour: targetTimeComponents.hour ?? 0, minute: targetTimeComponents.minute ?? 0, second: targetTimeComponents.second ?? 0, of: currentDate)
                }
                else if startDate.compareTimeOnly(currentDate) == .orderedAscending // end < current < start
                {
                    targetDate = startDate
                    let targetTimeComponents = calendar.dateComponents([.hour, .minute, .second], from: targetDate!)
                    targetDate = calendar.date(bySettingHour: targetTimeComponents.hour ?? 0, minute: targetTimeComponents.minute ?? 0, second: targetTimeComponents.second ?? 0, of: currentDate)
                }
                else // end < start < current
                {
                    // next day
                    var dayComponent = DateComponents()
                    dayComponent.day = 1
                    if let nextDate = calendar.date(byAdding: dayComponent, to: currentDate)
                    {
                        targetDate = endDate
                        let targetTimeComponents = calendar.dateComponents([.hour, .minute, .second], from: targetDate!)
                        targetDate = calendar.date(bySettingHour: targetTimeComponents.hour ?? 0, minute: targetTimeComponents.minute ?? 0, second: targetTimeComponents.second ?? 0, of: nextDate)
                    }
                }
            }
        }
        return targetDate
    }
    
}

