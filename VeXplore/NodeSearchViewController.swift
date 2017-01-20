//
//  NodeSearchViewController.swift
//  VeXplore
//
//  Copyright © 2016 Jimmy. All rights reserved.
//


class SortedNodeGroupModel: NSObject
{
    var initial: String?
    var nodes = [NodeModel]()
    
    func encodeWithCoder(_ aCoder: NSCoder)
    {
        aCoder.encode(initial, forKey: "initial")
        aCoder.encode(nodes, forKey: "nodes")
    }
    
    required convenience init?(coder aDecoder: NSCoder)
    {
        self.init()
        initial = aDecoder.decodeObject(forKey: "initial") as? String
        nodes = aDecoder.decodeObject(forKey: "nodes") as! [NodeModel]
    }
    
}


class NodeSearchCell: UITableViewCell
{
    lazy var contentLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = R.Font.Medium
        label.textColor = UIColor.darkGray
        
        return label
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?)
    {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(contentLabel)
        let bindings = ["contentLabel": contentLabel]
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-18-[contentLabel]-18-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: bindings))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[contentLabel]-10-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: bindings))
        
        contentView.backgroundColor = .white
        preservesSuperviewLayoutMargins = false
        layoutMargins = .zero
        selectionStyle = .none
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse()
    {
        super.prepareForReuse()
        contentLabel.font = R.Font.Medium
    }
    
}


class NodeSearchViewController: SearchViewController
{
    private var nodes: [NodeModel] = [] {
        didSet
        {
            groupedNodes.removeAll()
            for _ in 0 ..< collation.sectionTitles.count
            {
                groupedNodes.append(SortedNodeGroupModel())
            }
            let sortedObjects = collation.sortedArray(from: nodes, collationStringSelector: #selector(getter: NodeModel.allLetter))
            for object in sortedObjects
            {
                let sectionNumber = collation.section(for: object, collationStringSelector: #selector(getter: NodeModel.initialLetter))
                groupedNodes[sectionNumber].nodes.append(object as! NodeModel)
                groupedNodes[sectionNumber].initial = collation.sectionTitles[sectionNumber]
            }
            tableView.reloadData()
            if let diskCachePath = cachePathString(withFilename: NodeSearchViewController.description())
            {
                NSKeyedArchiver.archiveRootObject(groupedNodes, toFile: diskCachePath)
            }
        }
    }
    
    private var isLoading = false
    private let collation = UILocalizedIndexedCollation.current()
    var isSearching = false
    var groupedNodes = [SortedNodeGroupModel]()
    var searchResultNodes = [SortedNodeGroupModel]()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        searchBox.searchField.returnKeyType = .done
        refreshAllNodes()
        tableView.sectionIndexColor = .hrefColor
        tableView.sectionIndexBackgroundColor = .clear
        tableView.estimatedSectionHeaderHeight = R.Constant.EstimatedSectionHeaderHeight
        tableView.estimatedRowHeight = R.Constant.EstimatedRowHeight
        tableView.sectionHeaderHeight = UITableViewAutomaticDimension
        tableView.register(NodeSearchCell.self, forCellReuseIdentifier: String(describing: NodeSearchCell.self))
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        guard groupedNodes.count > 0 else{
            getAllNodesIfNeed()
            return
        }
    }
    
    func getAllNodesIfNeed()
    {
        if let diskCachePath = cachePathString(withFilename: NodeSearchViewController.description()),
            let groupedNodes = NSKeyedUnarchiver.unarchiveObject(withFile: diskCachePath) as? [SortedNodeGroupModel]
        {
            self.groupedNodes = groupedNodes
            tableView.reloadData()
        }
        else
        {
            refreshAllNodes()
        }
    }
    
    private func refreshAllNodes()
    {
        guard isLoading == false else{
            return
        }
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        isLoading = true
        V2Request.Node.getAllNodes(completion: { [weak self] (response) in
            guard let weakSelf = self else {
                return
            }
            
            if response.success, let value = response.value, value.count > weakSelf.nodes.count
            {
                dispatch_async_to_background_queue {
                    // this method will cost a lot of time, it should not be called in main queue
                    weakSelf.dealData(withNodesArray: value)
                    DispatchQueue.main.async(execute: { 
                        weakSelf.nodes = value
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                        weakSelf.isLoading = false
                    })
                }
            }
            else
            {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                weakSelf.isLoading = false
            }
        })
    }

    private func getSearchKey(fromString str: String) -> SearchKey // (initial, all)
    {
        var result = SearchKey(initialLetter: R.String.Empty, allLetter: R.String.Empty)
        let latinString = str.getUppercaseLatinString()
        result.allLetter = latinString
        if let index = latinString.characters.index(latinString.startIndex, offsetBy: 1, limitedBy: latinString.endIndex)
        {
            result.initialLetter = latinString.substring(to: index)
        }
        return result
    }
    
    private func dealData(withNodesArray nodesArray: [NodeModel])
    {
        for node in nodesArray
        {
            if let nodeName = node.nodeName
            {
                let result = getSearchKey(fromString: nodeName)
                node.initialLetter = result.initialLetter
                node.allLetter = result.allLetter
                node.allLetterWithoutSpace = result.allLetter.removeWhitespace()
            }
        }
    }
    
    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true
    }
    
    override func searchFieldDidChange(_ textField: UITextField)
    {
        if let searchKey = textField.text?.uppercased(), searchKey.isEmpty == false
        {
            isSearching = true
            searchResultNodes.removeAll()
            for sortedNodeGroupModel in groupedNodes
            {
                let filteredNodes = sortedNodeGroupModel.nodes.filter { (nodeModel) -> Bool in
                    if let allLetterWithoutSpace = nodeModel.allLetterWithoutSpace,
                        let allLetter = nodeModel.allLetter,
                        let nodeName = nodeModel.nodeName
                    {
                        return allLetterWithoutSpace.contains(searchKey) || allLetter.contains(searchKey) || nodeName.contains(searchKey)
                    }
                    return false
                }
                if filteredNodes.count > 0
                {
                    let filteredNodeGroupModel = SortedNodeGroupModel()
                    filteredNodeGroupModel.initial = sortedNodeGroupModel.initial
                    filteredNodeGroupModel.nodes = filteredNodes
                    searchResultNodes.append(filteredNodeGroupModel)
                }
            }
        }
        else
        {
            isSearching = false
        }
        self.tableView.reloadData()

    }
    
    // MARK: - UITableViewDataSource
    func numberOfSectionsInTableView(_ tableView: UITableView) -> Int
    {
        return isSearching ? searchResultNodes.count : groupedNodes.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return isSearching ? searchResultNodes[section].nodes.count : groupedNodes[section].nodes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: NodeSearchCell.self), for: indexPath) as! NodeSearchCell
        let node = isSearching ? searchResultNodes[indexPath.section].nodes[indexPath.row] : groupedNodes[indexPath.section].nodes[indexPath.row]
        cell.contentLabel.text = node.nodeName
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        let sectionTitle = isSearching ? searchResultNodes[section].initial : groupedNodes[section].initial
        let headerView: SectionHeaderView! = tableView.dequeueReusableHeaderFooterView(withIdentifier: String(describing: SectionHeaderView.self)) as? SectionHeaderView ?? SectionHeaderView()
        headerView.contentLabel.text = sectionTitle ?? R.String.HashKey
        return headerView
    }
    
    func sectionIndexTitlesForTableView(_ tableView: UITableView) -> [String]
    {
        return isSearching ? [] : collation.sectionIndexTitles
    }
    
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int
    {
        return collation.section(forSectionIndexTitle: index)
    }
    
    // MARK: - UITableViewDelegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let nodeModel = isSearching ? searchResultNodes[indexPath.section].nodes[indexPath.row] : groupedNodes[indexPath.section].nodes[indexPath.row]
        let nodeTopicListVC = NodeTopicListViewController()
        nodeTopicListVC.node = nodeModel
        nodeTopicListVC.title = nodeModel.nodeName
        DispatchQueue.main.async {
            self.bouncePresent(navigationVCWith: nodeTopicListVC, completion: {
                nodeTopicListVC.startLoading()
            })
        }
    }
    
    
    private struct SearchKey
    {
        var initialLetter: String
        var allLetter: String
    }
    
}
