//
//  RecentPageViewController.swift
//  VeXplore
//
//  Copyright © 2016 Jimmy. All rights reserved.
//


class RecentPageViewController: UIViewController, UIScrollViewDelegate, DataPickerViewDelegate, DataPickerViewDataSource
{
    private lazy var pagePicker: DataPickerView = {
        let view = DataPickerView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.delegate = self
        view.dataSource = self
       
        return view
    }()
    
    private lazy var contentScrollView: UIScrollView = {
        let view = UIScrollView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.delegate = self
        view.showsHorizontalScrollIndicator = false
        view.isPagingEnabled = true
        view.bounces = true
        view.backgroundColor = .white
        
        return view
    }()
    
    private lazy var pageNumView: SpringTextView = {
        let view = SpringTextView(frame: CGRect(x: 0, y: 0, width: R.Constant.defaulViewtSize, height: R.Constant.defaulViewtSize))
        
        return view
    }()
    
    private var views = [UIView]()
    private var pageVCs = [RecentListViewController]()
    private var currentPage = 1
    private var targetPage = 1
    private let pickerCircleTimes = 4
    private var totalPage = R.Constant.TopicPageMax
    private let downImage = R.Image.ArrowRight
    private let confirmImage = R.Image.Confirm
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        navigationItem.title = R.String.Recent
        
        view.addSubview(contentScrollView)
        view.addSubview(pagePicker)
        let bindings: [String: Any] = [
            "pagePicker": pagePicker,
            "contentScrollView": contentScrollView
            ]
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[contentScrollView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: bindings))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[pagePicker]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: bindings))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[pagePicker][contentScrollView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: bindings))
        
        let closeBtn = UIBarButtonItem(image: R.Image.Close, style: .plain, target: self, action: #selector(closeBtnTapped))
        closeBtn.tintColor = .middleGray
        let pageNumItem: UIBarButtonItem = UIBarButtonItem(customView: pageNumView)
        navigationItem.leftBarButtonItem = pageNumItem
        navigationItem.leftBarButtonItems = [closeBtn, pageNumItem]
        
        let pageSelectBtn = UIBarButtonItem(image: downImage, style: .plain, target: self, action: #selector(pageSelectBtnTapped))
        pageSelectBtn.tintColor = .middleGray
        navigationItem.rightBarButtonItem = pageSelectBtn
        
        pagePicker.scrollingTask = {
            (_) -> Void in
            self.navigationItem.rightBarButtonItem?.isEnabled = false
        }
        pagePicker.endScrollingTask = {
            (_) -> Void in
            self.navigationItem.rightBarButtonItem?.isEnabled = true
        }
        setup()
    }

    private func setup()
    {
        view.layoutIfNeeded()
        var offsetX: CGFloat = 0.0
        for _ in 0..<3
        {
            let topicListVC = RecentListViewController()
            topicListVC.dismissStyle = .none
            addChildViewController(topicListVC)
            topicListVC.didMove(toParentViewController: self)
            pageVCs.append(topicListVC)
            
            let frame = CGRect(x: offsetX, y: 0, width: contentScrollView.bounds.width, height: contentScrollView.bounds.height)
            topicListVC.view.frame = frame
            contentScrollView.addSubview(topicListVC.view)
            views.append(topicListVC.view)
            offsetX += contentScrollView.bounds.width
        }
        contentScrollView.contentSize = CGSize(width: CGFloat(views.count) * view.frame.width, height: 0)
        
        for index in 0..<3
        {
            let pageVC = pageVCs[index]
            pageVC.page = index + 1
            pageVC.initTopLoading()
        }
        pageNumView.setValue(String(currentPage), animated: false)
        pagePicker.setSelectedItem(currentPage - 1 + totalPage * 2, animate: false)
    }
    
    // MARK: - Actions
    @objc
    private func closeBtnTapped()
    {
        dismiss(animated: true, completion: nil)
    }
    
    @objc
    private func pageSelectBtnTapped()
    {
        // always bring picker view to front for safety
        view.bringSubview(toFront: pagePicker)
        if pagePicker.isExpanded
        {
            navigationItem.rightBarButtonItem?.image = downImage
            navigationItem.rightBarButtonItem?.tintColor = .middleGray
            selectPage(targetPage)
        }
        else
        {
            navigationItem.rightBarButtonItem?.image = confirmImage
            navigationItem.rightBarButtonItem?.tintColor = .lightPink
            pagePicker.setSelectedItem(currentPage - 1 + totalPage * 2, animate: false)
            targetPage = (pagePicker.selectedItem! + 1) % totalPage
        }
        
        pagePicker.showOrHide(true, completion: {() -> Void in
            if self.pagePicker.isExpanded == false
            {
                self.pagePicker.setSelectedItem(self.currentPage - 1 + self.totalPage * 2, animate: false)
            }
        })
    }
    
    // MARK: - Private
    private func didShowPage(atIndex index: Int)
    {
        if index != 1, currentPage > 1, currentPage < totalPage
        {
            shiftView(withDistance: index - 1)
            let nextPage = currentPage + index - 1
            let pageVC = pageVCs[index]
            pageVC.page = nextPage
            pageVC.request?.cancel()
            if pageVC.isTopLoadingFail
            {
                pageVC.topLoadingFromFailState()
            }
            else if pageVC.request?.response == nil
            {
                pageVC.isTopLoadingFail = true
                pageVC.topLoadingFromFailState()
            }
            else
            {
                pageVC.enableTopLoading = true
                pageVC.tableView.tableHeaderView = pageVC.tableHeaderView
                pageVC.initTopLoading(shouldResetContent: true)
            }
        }
    }
    
    private func pageCentering()
    {
        let offsetX = contentScrollView.bounds.width
        contentScrollView.setContentOffset(CGPoint(x: offsetX, y: 0.0), animated: false)
    }
    
    private func pageEnding()
    {
        let offsetX = contentScrollView.bounds.width * 2
        contentScrollView.setContentOffset(CGPoint(x: offsetX, y: 0.0), animated: false)
    }
    
    private func pageBegining()
    {
        contentScrollView.setContentOffset(CGPoint(x: 0, y: 0.0), animated: false)
    }
    
    private func shiftView(withDistance distance: Int)
    {
        var offsetX: CGFloat = 0.0
        views = views.shift(withDistance: distance)
        pageVCs = pageVCs.shift(withDistance: distance)
        for view in views
        {
            let frame = CGRect(x: offsetX, y: 0, width: contentScrollView.bounds.width, height: contentScrollView.bounds.height)
            view.frame = frame
            offsetX += contentScrollView.bounds.width
        }
        pageCentering()
        contentScrollView.panGestureRecognizer.isEnabled = true
    }
    
    private func selectPage(_ page: Int)
    {
        guard currentPage != page else{
            return
        }
        
        currentPage = page
        if currentPage == 1
        {
            for index in 0..<3
            {
                let pageVC = pageVCs[index]
                pageVC.page = index + 1
                refresh(pageVC: pageVC)
            }
            pageBegining()
        }
        else if currentPage == totalPage
        {
            for index in 0..<3
            {
                let pageVC = pageVCs[index]
                pageVC.page = currentPage + index - 2
                refresh(pageVC: pageVC)
            }
            pageEnding()
        }
        else
        {
            for index in 0..<3
            {
                let pageVC = pageVCs[index]
                pageVC.page = currentPage + index - 1
                refresh(pageVC: pageVC)
            }
            pageCentering()
        }
        pageNumView.setValue(String(currentPage), animated: true)
    }
    
    private func refresh(pageVC: BaseTableViewController)
    {
        pageVC.request?.cancel()
        if pageVC.isTopLoadingFail
        {
            pageVC.topLoadingFromFailState()
        }
        else if pageVC.request?.response == nil
        {
            pageVC.isTopLoadingFail = true
            pageVC.topLoadingFromFailState()
        }
        else
        {
            pageVC.enableTopLoading = true
            pageVC.tableView.tableHeaderView = pageVC.tableHeaderView
            pageVC.initTopLoading(shouldResetContent: true)
        }
    }
    
    // MARK: - UIScrollViewDelegate
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView)
    {
        let index = Int(max(scrollView.contentOffset.x, 0) / scrollView.frame.width) // the index of three reusable views
        if index == 1
        {
            if currentPage == 1
            {
                currentPage += 1
            }
            else if currentPage == totalPage
            {
                currentPage -= 1
            }
        }
        currentPage += index - 1
        currentPage = min(max(currentPage, 1), totalPage)
        didShowPage(atIndex: index)
        pageNumView.setValue(String(currentPage), animated: true)
        
        if pagePicker.isExpanded
        {
            pagePicker.showOrHide(true, completion: {() -> Void in
                self.pagePicker.setSelectedItem(self.currentPage - 1 + self.totalPage * 2, animate: false)
            })
            navigationItem.rightBarButtonItem?.image = downImage
            navigationItem.rightBarButtonItem?.tintColor = .middleGray
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView)
    {
        if scrollView.isDecelerating, !scrollView.isDragging
        {
            scrollView.panGestureRecognizer.isEnabled = false
        }
    }
    
    // MARK: - DataPickerViewDataSource
    func numberOfItems(inPickerView pickerView: DataPickerView) -> Int
    {
        return totalPage * pickerCircleTimes
    }
    
    func pickerView(_ pickerView: DataPickerView, titleForItemAtIndex index: Int) -> String
    {
        return String(format: R.String.PageNumer, index % totalPage + 1)
    }

    // MARK: - DataPickerViewDelegate
    func pickerView(_ pickerView: DataPickerView, didSelectItemAt index: Int, animate: Bool)
    {
        targetPage = index % totalPage + 1
    }
    
}
