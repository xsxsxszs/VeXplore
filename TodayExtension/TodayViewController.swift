//
//  TodayViewController.swift
//  TodayExtension
//
//  Copyright © 2017 Jimmy. All rights reserved.
//

import NotificationCenter
import SharedKit

// Due to Swift module, NSExtensionPrincipalClass should be $(PRODUCT_NAME).TodayViewController
// Or you can use TodayViewController as NSExtensionPrincipalClass, and rename the class expose to Objc by using: 
// @objc (TodayViewController)
class TodayViewController: UIViewController, NCWidgetProviding, UITableViewDataSource, UITableViewDelegate
{
    private let rowHeight: CGFloat = 37.0
    
    lazy private var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = self.rowHeight
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: String(describing: UITableViewCell.self))

        return tableView
    }()
    
    private var data = [TopicItem]()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        extensionContext?.widgetLargestAvailableDisplayMode = .expanded
        view.addSubview(tableView)
        let bindings: [String: Any] = ["tableView": tableView]
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[tableView]|", metrics: nil, views: bindings))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[tableView]|", metrics: nil, views: bindings))
    }

    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        loadData()
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void))
    {
        loadData()
        completionHandler(NCUpdateResult.newData)
    }
    
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize)
    {
        if activeDisplayMode == .expanded
        {
            preferredContentSize = CGSize(width: 0, height: rowHeight * CGFloat(data.count))
        }
    }
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: UITableViewCell.self), for: indexPath)
        cell.textLabel?.font = UIFont.systemFont(ofSize: 14.0)
        cell.textLabel?.text = data[indexPath.row].title
        return cell
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let topicId = data[indexPath.row].id
        if let url = URL(string: "todayExtension://?\(topicId)")
        {
            extensionContext?.open(url, completionHandler: nil)
        }
    }
    
    
    private func loadData()
    {
        let url = "https://www.v2ex.com/api/topics/hot.json"
        var topics = [TopicItem]()
        Networking.request(url, headers: SharedR.Dict.MobileClientHeaders).responseJSON { (response) in
            if response.result.isSuccess, let value = response.result.value
            {
                let json = JSON(object: value)
                for (_, subJson) in json
                {
                    if let topicId = subJson["id"].string, let topicTitle = subJson["title"].string
                    {
                        let topicItem = TopicItem(id: topicId, title: topicTitle)
                        topics.append(topicItem)
                    }
                }
                self.data = topics
                self.tableView.reloadData()
            }
        }
    }
    
    private struct TopicItem
    {
        let id: String
        let title: String
    }
}
