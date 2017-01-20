//
//  SearchViewController.swift
//  VeXplore
//
//  Copyright © 2016 Jimmy. All rights reserved.
//


class SearchViewController: UIViewController, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate
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
        view.backgroundColor = .lightGray
        
        return view
    }()
    
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: CGRect.zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.register(SectionHeaderView.self, forHeaderFooterViewReuseIdentifier: String(describing: SectionHeaderView.self))

        return tableView
    }()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        navigationController?.navigationBar.isTranslucent = false

        view.addSubview(searchBox)
        view.addSubview(line)
        view.addSubview(tableView)
        let bindings = [
            "searchBox": searchBox,
            "line": line,
            "tableView": tableView
        ]
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-12-[searchBox]-12-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: bindings))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[line]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: bindings))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[tableView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: bindings))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-4-[searchBox]-4-[line(0.5)][tableView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: bindings))

        view.backgroundColor = .offWhite
        NotificationCenter.default.addObserver(self, selector: #selector(handleContentSizeCategoryDidChanged), name: NSNotification.Name.UIContentSizeCategoryDidChange, object: nil)
    }
    
    @objc
    private func handleContentSizeCategoryDidChanged()
    {
        searchBox.searchField.font = R.Font.Small
    }

    // override this method in subclass
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
