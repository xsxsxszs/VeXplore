//
//  HomePageTopicListViewController.swift
//  VeXplore
//
//  Copyright © 2016 Jimmy. All rights reserved.
//


class HomePageTopicListViewController: TopicListViewController
{
    private let TabbarHiddenDuration = 0.25
    var tabId = "tech"
    var isInitiated = false
    var lastOffsetY: CGFloat = 0.0

    override func viewDidLoad()
    {
        super.viewDidLoad()
        tableView.estimatedRowHeight = R.Constant.EstimatedRowHeight
    }
    
    func loadCache()
    {
        let cacheKey = String(format: R.Key.HomePageTopicList, tabId)
        if let diskCachePath = cachePathString(withFilename: cacheKey),
            let cachedTopicList = NSKeyedUnarchiver.unarchiveObject(withFile: diskCachePath) as? [TopicItemModel]
        {
            topicList = cachedTopicList
            tableView.reloadData()
        }
    }
    
    // MARK: - Loading request
    override func topLoadingRequest()
    {
        V2Request.Topic.getTabList(withTabId: tabId) { [weak self] (response) in
            guard let weakSelf = self else {
                return
            }
            
            weakSelf.stopLoading(withLoadingStyle: .top, success: response.success, completion: { (success) -> Void in
                if success, let value = response.value
                {
                    weakSelf.topicList = value
                    weakSelf.tableView.reloadData()
                    UIView.animate(withDuration: R.Constant.InsetAnimationDuration, delay: 0, options: .beginFromCurrentState, animations: {
                        weakSelf.tableView.contentInset = .zero
                    }) { (_) in
                        weakSelf.topLoadingView.initSquaresPosition()
                        let cacheKey = String(format: R.Key.HomePageTopicList, weakSelf.tabId)
                        if let diskCachePath = cachePathString(withFilename: cacheKey)
                        {
                            NSKeyedArchiver.archiveRootObject(value, toFile: diskCachePath)
                        }
                    }
                    weakSelf.isTopLoadingFail = false
                }
                else
                {
                    // load cache if fail to refresh topics
                    weakSelf.loadCache()
                    weakSelf.isTopLoadingFail = true
                }
                weakSelf.isTopLoading = false
            })
        }
    }
    
    // MARK: - UIScrollViewDelegate
    override func scrollViewDidScroll(_ scrollView: UIScrollView)
    {
        super.scrollViewDidScroll(scrollView)
     
        if enableTabarHidden && scrollView.contentSize.height >= scrollView.frame.height
        {
            var inset = tableView.contentInset
            if inset.bottom != 0.0
            {
                inset.bottom = 0.0
                tableView.contentInset = inset
            }
        }
        else
        {
            var inset = tableView.contentInset
            if let tabarHeight = tabBarController?.tabBar.frame.height, inset.bottom != tabarHeight
            {
                inset.bottom = tabarHeight
                tableView.contentInset = inset
            }
        }
        
        guard isInitiated && enableTabarHidden else {
            return
        }

        if let tabarFrame = tabBarController?.tabBar.frame
        {
            if scrollView.contentSize.height < scrollView.frame.height
            {
                UIView.animate(withDuration: TabbarHiddenDuration, animations: {
                    self.tabBarController?.tabBar.transform = .identity
                })
                return
            }
            if scrollView.contentOffset.y < 0
            {
                UIView.animate(withDuration: TabbarHiddenDuration, animations: {
                    self.tabBarController?.tabBar.transform = .identity
                })
                return
            }
            if scrollView.contentOffset.y + scrollView.frame.height > scrollView.contentSize.height
            {
                UIView.animate(withDuration: TabbarHiddenDuration, animations: {
                    self.tabBarController?.tabBar.transform = CGAffineTransform(translationX: 0, y: tabarFrame.height)
                })
                return
            }
            
            let scrollOffsetY = scrollView.contentOffset.y - lastOffsetY
            if scrollOffsetY > 2
            {
                UIView.animate(withDuration: TabbarHiddenDuration, animations: {
                    self.tabBarController?.tabBar.transform = CGAffineTransform(translationX: 0, y: tabarFrame.height)
                })
            }
            if scrollOffsetY < -2
            {
                UIView.animate(withDuration: TabbarHiddenDuration, animations: {
                    self.tabBarController?.tabBar.transform = .identity
                })
            }
        }
        lastOffsetY = scrollView.contentOffset.y
    }
    
}
