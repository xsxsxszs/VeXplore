//
//  NodesViewController.swift
//  VeXplore
//
//  Copyright © 2016 Jimmy. All rights reserved.
//


class NodesViewController: BaseCenterLoadingViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, AnimatedSearchButtonDelegate
{
    lazy var searchButton: AnimatedSearchButton = {
        let button = AnimatedSearchButton(frame: CGRect(x: 0, y: 0, width: 22, height: 22))
        button.delegate = self
        
        return button
    }()
    
    let layout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsetsMake(8, 12, 8, 12)
        
        return layout
    }()

    lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: CGRect.zero, collectionViewLayout: self.layout)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.showsVerticalScrollIndicator = false
        view.showsHorizontalScrollIndicator = false
        view.backgroundColor = .background
        view.dataSource = self
        view.delegate = self
        view.allowsMultipleSelection = false
        view.register(NodeCollectionViewCell.self, forCellWithReuseIdentifier: String(describing: NodeCollectionViewCell.self))
        view.register(NodeCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: String(describing: NodeCollectionReusableView.self))
        
        return view
    }()
    
    private var nodeGroupArray = [NodeGroupModel]()
    var searchVC = NodeSearchViewController()

    override func viewDidLoad()
    {
        super.viewDidLoad()
        navigationItem.title = R.String.Nodes

        view.addSubview(collectionView)
        let bindings = ["collectionView": collectionView]
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[collectionView]|", metrics: nil, views: bindings))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[collectionView]|", metrics: nil, views: bindings))
        view.bringSubview(toFront: centerLoadingView)
        
        let searchBtn = UIBarButtonItem(customView: searchButton)
        navigationItem.rightBarButtonItem = searchBtn
        
        refreshColorScheme()
        
        NotificationCenter.default.addObserver(self, selector: #selector(refreshColorScheme), name: NSNotification.Name.Setting.NightModeDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleContentSizeCategoryDidChanged), name: NSNotification.Name.UIContentSizeCategoryDidChange, object: nil)
        
        searchVC.getAllNodesIfNeed()
    }
    
    init()
    {
        super.init(nibName: nil, bundle: nil)
        dismissStyle = .none
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc
    private func refreshColorScheme()
    {
        navigationController?.navigationBar.setupNavigationbar()
        collectionView.backgroundColor = .background
    }
    
    @objc
    private func handleContentSizeCategoryDidChanged()
    {
        collectionView.reloadData()
    }
    
    // MARK: - AnimatedSearchButtonDelegate
    func searchButtonTouchUpInside()
    {
        if searchButton.isSearchView
        {
            dismissContentModalViewController(searchVC, animated: true, completion: nil)
        }
        else
        {
            presentContentModalViewController(searchVC, animated: true, completion: nil)
        }
    }
    
    override func loadingRequest()
    {
        if let diskCachePath = cachePathString(withFilename: classForCoder.description()),
            let nodeGroupArray = NSKeyedUnarchiver.unarchiveObject(withFile: diskCachePath) as? [NodeGroupModel]
        {
            self.nodeGroupArray = nodeGroupArray
            if nodeGroupArray.count > 0
            {
                collectionView.reloadData()
                centerLoadingView.removeFromSuperview()
            }
        }
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        V2Request.Node.getDefaultNodes(completion: { [weak self] (response) -> Void in
            guard let weakSelf = self else {
                return
            }
            
            weakSelf.stopLoading(withSuccesse: response.success, completion: { (success) in
                if success, let value = response.value
                {
                    if let diskCachePath = cachePathString(withFilename: weakSelf.classForCoder.description())
                    {
                        NSKeyedArchiver.archiveRootObject(value, toFile: diskCachePath)
                    }
                    // if new data is equal to old data, collectionView will not reload data
                    var needsReloadData = false
                    if weakSelf.nodeGroupArray.count == value.count
                    {
                        for i in 0..<weakSelf.nodeGroupArray.count
                        {
                            if weakSelf.nodeGroupArray[i].isEqual(value[i]) == false
                            {
                                needsReloadData = true
                                break
                            }
                        }
                    }
                    else
                    {
                        needsReloadData = true
                    }
                    
                    weakSelf.nodeGroupArray = value
                    if needsReloadData
                    {
                        weakSelf.collectionView.reloadData()
                    }
                    weakSelf.centerLoadingView.removeFromSuperview()
                }
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            })
        })
    }
    
    // MARK: - UICollectionViewDataSource
    func numberOfSections(in collectionView: UICollectionView) -> Int
    {
        return nodeGroupArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return self.nodeGroupArray[section].childNodes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let nodeModel = nodeGroupArray[indexPath.section].childNodes[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: NodeCollectionViewCell.self), for: indexPath) as! NodeCollectionViewCell
        cell.nodeNameLabel.text = nodeModel.nodeName
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView
    {
        let nodeGroupNameView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: String(describing: NodeCollectionReusableView.self), for: indexPath) as! NodeCollectionReusableView
        nodeGroupNameView.nodeGroupNameLabel.text = nodeGroupArray[indexPath.section].groupName
        return nodeGroupNameView
    }

    // MARK: - UICollectionViewDelegateFlowLayout
    private let heightCell = NodeCollectionViewCell()
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        let nodeModel = nodeGroupArray[indexPath.section].childNodes[indexPath.row]
        heightCell.nodeNameLabel.text = nodeModel.nodeName
        heightCell.nodeNameLabel.font = R.Font.Small
        let size = heightCell.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
        return size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat
    {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize
    {
        guard let groupName = nodeGroupArray[section].groupName else {
            return .zero
        }
        let rect = groupName.boundingRect(
            with: CGSize(width: collectionView.frame.width, height: collectionView.frame.height),
            options: .usesLineFragmentOrigin,
            attributes: [NSFontAttributeName:R.Font.Medium],
            context: nil)
        return CGSize(width: collectionView.bounds.width, height: rect.height + 16)
    }

    // MARK: - UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        let nodeModel = nodeGroupArray[indexPath.section].childNodes[indexPath.row]
        let nodeTopicListVC = NodeTopicListViewController()
        nodeTopicListVC.node = nodeModel
        nodeTopicListVC.title = nodeModel.nodeName
        DispatchQueue.main.async {
            self.bouncePresent(navigationVCWith: nodeTopicListVC, completion: { 
                nodeTopicListVC.startLoading()
            })
        }
    }
    
    // MARK: - Double tap tabar item
    func doubleTapTabarItem()
    {
        if collectionView.contentOffset.y > 0
        {
            collectionView.setContentOffset(.zero, animated: true)
        }
    }

}


class NodeCollectionViewCell: UICollectionViewCell
{
    lazy var nodeNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = R.Font.Small
        label.textColor = .desc
        
        return label
    }()
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        
        contentView.addSubview(nodeNameLabel)
        let bindings = ["nodeNameLabel": nodeNameLabel]
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-6-[nodeNameLabel]-6-|", metrics: nil, views: bindings))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-3-[nodeNameLabel]-3-|", metrics: nil, views: bindings))
        
        layer.borderWidth = 1
        layer.cornerRadius = 5
        
        refreshColorScheme()
        
        NotificationCenter.default.addObserver(self, selector: #selector(refreshColorScheme), name: NSNotification.Name.Setting.NightModeDidChange, object: nil)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse()
    {
        super.prepareForReuse()
        nodeNameLabel.font = R.Font.Small
    }
    
    @objc
    private func refreshColorScheme()
    {
        nodeNameLabel.textColor = .desc
        layer.borderColor = UIColor.border.cgColor
    }
    
}


class NodeCollectionReusableView: UICollectionReusableView
{
    lazy var nodeGroupNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = R.Font.Medium
        label.textColor = .body
        
        return label
    }()
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        
        addSubview(nodeGroupNameLabel)
        let bindings = ["nodeGroupNameLabel": nodeGroupNameLabel,]
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-12-[nodeGroupNameLabel]-12-|", metrics: nil, views: bindings))
        nodeGroupNameLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        refreshColorScheme()
        
        NotificationCenter.default.addObserver(self, selector: #selector(refreshColorScheme), name: NSNotification.Name.Setting.NightModeDidChange, object: nil)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse()
    {
        super.prepareForReuse()
        nodeGroupNameLabel.font = R.Font.Medium
    }
    
    @objc
    private func refreshColorScheme()
    {
        nodeGroupNameLabel.textColor = .body
        backgroundColor = .subBackground
    }
    
}
