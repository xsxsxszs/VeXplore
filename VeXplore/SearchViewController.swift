//
//  SearchViewController.swift
//  VeXplore
//
//  Copyright © 2016 Jimmy. All rights reserved.
//

import SharedKit

class SearchViewController: BaseViewController, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate
{
    lazy var searchBox: SearchBoxView = {
        let view = SearchBoxView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.searchField.delegate = self
        view.searchField.addTarget(self, action: #selector(searchFieldDidChange(_:)), for: .editingChanged)
        
        return view
    }()
    
    private lazy var line: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .border
        
        return view
    }()
    
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: CGRect.zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = .background
        tableView.sectionIndexBackgroundColor = .background
        tableView.sectionIndexColor = .href
        tableView.register(SectionHeaderView.self, forHeaderFooterViewReuseIdentifier: String(describing: SectionHeaderView.self))

        return tableView
    }()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        view.addSubview(searchBox)
        view.addSubview(line)
        view.addSubview(tableView)
        let bindings = [
            "searchBox": searchBox,
            "line": line,
            "tableView": tableView
        ]
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-12-[searchBox]-12-|", metrics: nil, views: bindings))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[line]|", metrics: nil, views: bindings))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[tableView]|", metrics: nil, views: bindings))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-4-[searchBox]-4-[line(0.5)][tableView]|", metrics: nil, views: bindings))
    }
    
    @objc
    override func refreshColorScheme()
    {
        super.refreshColorScheme()
        line.backgroundColor = .border
        tableView.backgroundColor = .background
        tableView.sectionIndexBackgroundColor = .background
        tableView.sectionIndexColor = .href
        view.backgroundColor = .subBackground
    }
    
    @objc
    override func handleContentSizeCategoryDidChanged()
    {
        super.handleContentSizeCategoryDidChanged()
        searchBox.searchField.font = SharedR.Font.Small
    }

    // override this method in subclass
    @objc
    func searchFieldDidChange(_ textField: UITextField) {}
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = UITableViewCell()
        return cell
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        // override this method in subclass
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView)
    {
        // override this method in subclass
    }

    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView)
    {
        searchBox.searchField.resignFirstResponder()
    }

}
