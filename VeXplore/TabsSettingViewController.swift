//
//  TabsSettingViewController.swift
//  VeXplore
//
//  Copyright © 2016 Jimmy. All rights reserved.
//

import SharedKit

protocol TabsSortingDelegate: class
{
    func saveSortedTabs(_ newTabs: [String])
}

class TabsSettingViewController: UITableViewController, TabsSettingTableViewDelegate, TabsSettingTableViewDataSource
{
    private let defaultShowedTabs = R.Array.AllTabsTitle
    private let defaultHiddenTabs = [String]()
    private var data = [[String]]()
    private var originalShowedTabs = [String]()
    var currentTab: String!
    weak var delegate: TabsSortingDelegate?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        navigationItem.title = R.String.TabsSorting
        navigationController?.navigationBar.setupNavigationbar()

        data = [
            [R.String.ShowedTabsTitle],
            defaultShowedTabs,
            [R.String.HiddenTabsTitle],
            defaultHiddenTabs,
            [SharedR.String.Empty]
        ]
        readTabsSorting()

        tableView = {
            let tableView = TabsSettingTableView(frame: view.bounds, style: .plain)
            tableView.tabsSettingDataSource = self
            tableView.tabsSettingDelegate = self
            tableView.register(TabsSettingHeaderCell.self, forCellReuseIdentifier: String(describing: TabsSettingHeaderCell.self))
            tableView.register(TabsSettingTabCell.self, forCellReuseIdentifier: String(describing: TabsSettingTabCell.self))
            tableView.register(TabsSettingPlaceholderCell.self, forCellReuseIdentifier: String(describing: TabsSettingPlaceholderCell.self))

            return tableView
        }()
        
        let returnBtn = UIBarButtonItem(image: R.Image.Close, style: .plain, target: self, action: #selector(cancelBtnTapped))
        let saveBtn = UIBarButtonItem(image: R.Image.Confirm, style: .plain, target: self, action: #selector(saveBtnTapped))
        saveBtn.tintColor = .highlight
        navigationItem.leftBarButtonItem = returnBtn
        navigationItem.rightBarButtonItem = saveBtn
    }
    
    // MARK: - Actions
    @objc
    private func cancelBtnTapped()
    {
        dismiss(animated: true, completion: nil)
    }
    
    @objc
    private func saveBtnTapped()
    {
        // update sorting if changed
        let showdTabs = data[TabsSettingSection.showedTabsContent.rawValue]
        if showdTabs != originalShowedTabs
        {
            saveTabsSorting()
            delegate?.saveSortedTabs(showdTabs)
        }
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - UITableViewDataSource
    override func numberOfSections(in tableView: UITableView) -> Int
    {
        /**  
         * showed header section,
         * showed tabs section,
         * hidden header section,
         * hidden tabs section,
         * placeholder section
         */
        return 5
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        var numberOfRows = data[section].count
        let tableView = tableView as! TabsSettingTableView
        if let movingIndexPath = tableView.movingIndexPath,
            movingIndexPath.section != tableView.originalIndexPathOfMovingRow.section
        {
            if section == movingIndexPath.section
            {
                numberOfRows = numberOfRows + 1
            }
            else if section == tableView.originalIndexPathOfMovingRow.section
            {
                numberOfRows = numberOfRows - 1
            }
        }
        return numberOfRows
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let tabsSettingSection = TabsSettingSection(rawValue: indexPath.section)!
        switch tabsSettingSection
        {
        case .showedTabsHeader, .hiddenTabsHeader:
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: TabsSettingHeaderCell.self), for: indexPath) as! TabsSettingHeaderCell
            cell.titleLabel.text = data[indexPath.section][indexPath.row]
            cell.descLabel.text = (tabsSettingSection == .showedTabsHeader ? R.String.DragTabToSort : nil)
            return cell
        case .showedTabsContent, .hiddenTabsContent:
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: TabsSettingTabCell.self), for: indexPath) as! TabsSettingTabCell
            if tabsSettingSection == .hiddenTabsContent
            {
                cell.invisibleImageView.isHidden = false
            }
            else if data[indexPath.section].count > indexPath.row, data[indexPath.section][indexPath.row] == currentTab
            {
                cell.lockImageView.isHidden = false
                cell.contentView.alpha = 0.6
            }
            
            let tableView = tableView as! TabsSettingTableView
            if tableView.isMovingIndexPath(indexPath)
            {
                cell.prepareForMove()
            }
            else
            {
                cell.titleLabel.text = data[indexPath.section][indexPath.row]
            }
            cell.longLine.isHidden = (indexPath.row != tableView.numberOfRows(inSection: indexPath.section) - 1)
            return cell
        case .paddingPlaceholder:
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: TabsSettingPlaceholderCell.self), for: indexPath) as! TabsSettingPlaceholderCell
            return cell
        }
    }
    
    // MARK: - UITableViewDelegate
    lazy private var headerHeightCell: TabsSettingHeaderCell = {
        let cell = TabsSettingHeaderCell()
        cell.bounds = self.tableView.bounds
        cell.autoresizingMask = [.flexibleWidth]
        
        return cell
    }()
    lazy private var contentHeightCell: TabsSettingTabCell = {
        let cell = TabsSettingTabCell()
        cell.bounds = self.tableView.bounds
        cell.autoresizingMask = [.flexibleWidth]
        
        return cell
    }()
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        let tabsSettingSection = TabsSettingSection(rawValue: indexPath.section)!
        switch tabsSettingSection
        {
        case .showedTabsHeader, .hiddenTabsHeader:
            headerHeightCell.prepareForReuse()
            headerHeightCell.titleLabel.text = R.String.Placeholder
            headerHeightCell.descLabel.text = (tabsSettingSection == .showedTabsHeader ? R.String.Placeholder : nil)
            headerHeightCell.setNeedsLayout()
            headerHeightCell.layoutIfNeeded()
            let height = ceil(headerHeightCell.contentView.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height)
            return height
        case .showedTabsContent, .hiddenTabsContent, .paddingPlaceholder:
            contentHeightCell.prepareForReuse()
            contentHeightCell.titleLabel.text = R.String.Placeholder
            headerHeightCell.setNeedsLayout()
            headerHeightCell.layoutIfNeeded()
            let height = ceil(contentHeightCell.contentView.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height)
            return height
        }
    }
    
    // MARK: - MoveSortTableViewDataSource
    func tabsSettingTableView(_ tableView: TabsSettingTableView, canMoveRowAt indexPath: IndexPath) -> Bool
    {
        let tabsSettingSection = TabsSettingSection(rawValue: indexPath.section)!
        switch tabsSettingSection
        {
        case .showedTabsContent, .hiddenTabsContent:
            return data[indexPath.section][indexPath.row] != currentTab
        default:
            return false
        }
    }
    
    func tabsSettingTableView(_ tableView: TabsSettingTableView, canMoveToRowAt indexPath: IndexPath) -> Bool
    {
        let tabsSettingSection = TabsSettingSection(rawValue: indexPath.section)!
        switch tabsSettingSection
        {
        case .showedTabsContent, .hiddenTabsContent:
            return true
        default:
            return false
        }
    }
    
    // MARK: - MoveSortTableViewDelegate
    func tabsSettingTableView(_ tableView: TabsSettingTableView, moveRowAt indexPath: IndexPath, to newIndexPath: IndexPath)
    {
        var fromData = data[indexPath.section]
        let fromItem = fromData[indexPath.row]
        fromData.remove(at: indexPath.row)
        data[indexPath.section] = fromData
        var toData = data[newIndexPath.section]
        toData.insert(fromItem, at: newIndexPath.row)
        data[newIndexPath.section] = toData
    }
    
    // MARK: - Data Persistence
    private func saveTabsSorting()
    {
        let userDefaults = UserDefaults.standard
        userDefaults.set(data[TabsSettingSection.showedTabsContent.rawValue], forKey: R.Key.ShowedTabs)
        userDefaults.set(data[TabsSettingSection.hiddenTabsContent.rawValue], forKey: R.Key.HiddenTabs)
    }
    
    private func readTabsSorting()
    {
        let userDefaults = UserDefaults.standard
        if let showedTabsSaved = userDefaults.array(forKey: R.Key.ShowedTabs) as? [String]
        {
            data[TabsSettingSection.showedTabsContent.rawValue] = showedTabsSaved
            originalShowedTabs = showedTabsSaved
        }
        else
        {
            userDefaults.set(defaultShowedTabs, forKey: R.Key.ShowedTabs)
            originalShowedTabs = defaultShowedTabs
        }
        
        if let hiddenTabs = userDefaults.array(forKey: R.Key.HiddenTabs) as? [String]
        {
            data[TabsSettingSection.hiddenTabsContent.rawValue] = hiddenTabs
        }
        else
        {
            userDefaults.set(defaultHiddenTabs, forKey: R.Key.HiddenTabs)
        }
    }
    
}
