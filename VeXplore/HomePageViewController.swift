//
//  HomePageViewController.swift
//  VeXplore
//
//  Copyright © 2016 Jimmy. All rights reserved.
//


class HomePageViewController: UIViewController, UIScrollViewDelegate, HorizontalTabsViewDelegate, TabsSortingDelegate
{
    private lazy var tabsScrollView: HorizontalTabsView = {
        let view = HorizontalTabsView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.tabsDelegate = self
        
        return view
    }()
    
    // automaticallyAdjustsScrollViewInsets defaults to true
    // when set navigationController?.navigationBar.isTranslucent = false
    // will invoke:
    // -[UINavigationController navigationBarDidChangeOpacity:]
    // -[UINavigationController _layoutTopViewController]
    // -[UINavigationController _layoutViewController:]
    // -[UINavigationController _computeAndApplyScrollContentInsetDeltaForViewController:]
    // -[UIViewController _setNavigationControllerContentInsetAdjustment:]
    // -[UIScrollView _isAutomaticContentOffsetAdjustmentEnabled]
    // which will invoke contentScrollView
    // To be safe, avoid using contentScrollView
    // change contentScrollView -> contentSlideView
    private lazy var contentSlideView: UIScrollView = {
        let view = UIScrollView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.delegate = self
        view.showsHorizontalScrollIndicator = false
        view.isPagingEnabled = true
        view.bounces = true
        
        return view
    }()
    
    private lazy var recentBtn: UIBarButtonItem = {
        let recentBtn = UIBarButtonItem(image: R.Image.Time, style: .plain, target: self, action:  #selector(recentBtnTapped))
        
        return recentBtn
    }()
    
    private var tabs = R.Array.AllTabsTitle
    private var currentTab: String!
    private var tabsVC = [HomePageTopicListViewController]()
    
    override func loadView()
    {
        super.loadView()
        let userDefaults = UserDefaults.standard
        if let showedTabsTitle = userDefaults.array(forKey: R.Key.ShowedTabs)
        {
            tabs = showedTabsTitle as! [String]
        }
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        automaticallyAdjustsScrollViewInsets = false
        navigationItem.title = R.String.Homepage

        view.addSubview(tabsScrollView)
        view.addSubview(contentSlideView)
        let bindings: [String: Any] = [
            "top": topLayoutGuide,
            "tabsScrollView": tabsScrollView,
            "contentSlideView": contentSlideView
        ]
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[tabsScrollView]|", metrics: nil, views: bindings))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[top][tabsScrollView(34)][contentSlideView]|", options: [.alignAllLeading, .alignAllTrailing], metrics: nil, views: bindings))
        
        if User.shared.isLogin
        {
            navigationItem.leftBarButtonItem = recentBtn
        }
        let sortBtn = UIBarButtonItem(image: R.Image.Sort, style: .plain, target: self, action:  #selector(sortBtnTapped))
        navigationItem.rightBarButtonItem = sortBtn
        
        edgesForExtendedLayout = .bottom
        extendedLayoutIncludesOpaqueBars = true
        
        refreshColorScheme()
        setup()
        
        NotificationCenter.default.addObserver(self, selector: #selector(refreshColorScheme), name: NSNotification.Name.Setting.NightModeDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didLogout), name: NSNotification.Name.User.DidLogout, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didLogin), name: NSNotification.Name.User.DidLogin, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        if let currentIndex = self.tabs.index(of: self.currentTab)
        {
            self.showPage(atIndex: currentIndex, animated: false)
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator)
    {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { (_) in
            if let currentIndex = self.tabs.index(of: self.currentTab)
            {
                self.showPage(atIndex: currentIndex, animated: false)
            }
        }, completion: nil)
    }
    
    @objc
    private func refreshColorScheme()
    {
        navigationController?.navigationBar.setupNavigationbar()
        contentSlideView.backgroundColor = .background
    }
    
    @objc
    private func didLogin()
    {
        navigationItem.leftBarButtonItem = recentBtn
    }
    
    @objc
    private func didLogout()
    {
        navigationItem.leftBarButtonItem = nil
    }
    
    // MARK: - Action
    @objc
    private func recentBtnTapped()
    {
        let recentVC = RecentPageViewController()
        let recentNav = UINavigationController(rootViewController: recentVC)
        navigationController?.present(recentNav, animated: true, completion: nil)
    }
    
    @objc
    private func sortBtnTapped()
    {
        let settingVC = TabsSettingViewController()
        settingVC.delegate = self
        settingVC.currentTab = currentTab
        let settingNav = UINavigationController(rootViewController: settingVC)
        navigationController?.present(settingNav, animated: true, completion: nil)
    }
    
    // MARK: - Setup
    private func setup()
    {
        view.layoutIfNeeded()
        setupTabs()
        var index = 0
        if let currentTab = UserDefaults.standard[R.Key.CurrentTab],
            let savedIndex = tabs.index(of: currentTab)
        {
            index = savedIndex
        }
        setupcontentSlideViewAndShowPage(atIndex: index)
    }
    
    private func setupTabs()
    {
        var previousView: UIView?
        for index in 0..<tabs.count
        {
            let topicListVC = HomePageTopicListViewController()
            topicListVC.view.translatesAutoresizingMaskIntoConstraints = false
            topicListVC.dismissStyle = .none
            addChildViewController(topicListVC)
            tabsVC.append(topicListVC)
            topicListVC.didMove(toParentViewController: self)
            
            contentSlideView.addSubview(topicListVC.view)
            topicListVC.view.widthAnchor.constraint(equalTo: contentSlideView.widthAnchor).isActive = true
            topicListVC.view.heightAnchor.constraint(equalTo: contentSlideView.heightAnchor).isActive = true
            topicListVC.view.topAnchor.constraint(equalTo: contentSlideView.topAnchor).isActive = true

            if let previousView = previousView
            {
                topicListVC.view.leadingAnchor.constraint(equalTo: previousView.trailingAnchor).isActive = true
            }
            else
            {
                topicListVC.view.leadingAnchor.constraint(equalTo: contentSlideView.leadingAnchor).isActive = true
            }
            if index == tabs.count - 1
            {
                topicListVC.view.trailingAnchor.constraint(equalTo: contentSlideView.trailingAnchor).isActive = true
            }
            previousView = topicListVC.view
        }
    }
    
    private func resetTabs()
    {
        //remove child view controllers
        for childVC in childViewControllers
        {
            childVC.view.removeFromSuperview()
            childVC.willMove(toParentViewController: self)
            childVC.removeFromParentViewController()
        }
        tabsVC.removeAll()
        setupTabs()
    }
    
    private func setupcontentSlideViewAndShowPage(atIndex index: Int)
    {
        contentSlideView.contentSize = CGSize(width: CGFloat(tabs.count) * view.frame.width, height: 0)
        showPage(atIndex: index, animated: false)
    }
    
    // MARK: - HorizontalTabsViewDelegate
    func numberOfTabs(in horizontalTabsView: HorizontalTabsView) -> Int
    {
        return tabs.count
    }
    
    func titleOfTabs(in horizontalTabsView: HorizontalTabsView, forIndex index: Int) -> String
    {
        return tabs[index]
    }
    
    func horizontalTabsView(_ horizontalTabsView: HorizontalTabsView, didSelectItemAt index: Int)
    {
        showPage(atIndex: index, animated: true)
    }

    // MARK: - UIScrollViewDelegate
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView)
    {
        let index = Int(scrollView.contentOffset.x / scrollView.frame.width)
        showPage(atIndex: index, animated: true)
        scrollView.panGestureRecognizer.isEnabled = true
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView)
    {
        let index = Int(scrollView.contentOffset.x / scrollView.frame.width)
        if scrollView.contentOffset.x >= 0 && scrollView.contentOffset.x + scrollView.frame.width <= scrollView.contentSize.width
        {
            showPage(atIndex: index, animated: true)
        }
        scrollView.panGestureRecognizer.isEnabled = true
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView)
    {
        if scrollView.isDecelerating
        {
            scrollView.panGestureRecognizer.isEnabled = false
        }
    }
    
    func showPage(atIndex index: Int, animated: Bool)
    {
        let indexPath = IndexPath(row: index, section: 0)
        tabsScrollView.selectItem(at: indexPath, animated: animated, scrollPosition: .centeredHorizontally)
        let offsetX = contentSlideView.bounds.width * CGFloat(index)
        contentSlideView.setContentOffset(CGPoint(x: offsetX, y: 0.0), animated: animated)
        
        // save current tab
        currentTab = tabs[index]
        saveCurrentTab(withTitle: currentTab)
        
        // load view first time
        let tabVC = tabsVC[index]
        if tabVC.isInitiated == false, let tabId = R.Dict.TabsRequestMapping[tabs[index]]
        {
            tabVC.tabId = tabId
            tabVC.initTopLoading()
            tabVC.isInitiated = true
        }
    }
    
    // MARK: - Data Persistence
    private func saveCurrentTab(withTitle title: String)
    {
        UserDefaults.standard[R.Key.CurrentTab] = title
    }
    
    func saveSortedTabs(_ newTabs: [String])
    {
        // save last view
        if tabs != newTabs
        {
            tabs = newTabs
            resetTabs()
            tabsScrollView.reloadData()
            let index = tabs.index(of: currentTab) ?? 0
            setupcontentSlideViewAndShowPage(atIndex: index)
        }
    }
    
    // MARK: - Double tap tabar item
    func doubleTapTabarItem()
    {
        if let index = tabs.index(of: currentTab)
        {
            let tabVC = tabsVC[index]
            if tabVC.tableView.contentOffset.y > 0
            {
                tabVC.tableView.setContentOffset(.zero, animated: true)
            }
            else if tabVC.tableView.contentOffset.y == 0, tabVC.isTopLoadingFail == false
            {
                tabVC.initTopLoading()
            }
        }
    }
    
}
