//
//  BaseCenterLoadingViewController.swift
//  VeXplore
//
//  Copyright © 2016 Jimmy. All rights reserved.
//


class BaseCenterLoadingViewController: SwipeTransitionViewController, SquareLoadingViewDelegate, UITableViewDelegate, UITableViewDataSource
{
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: self.view.bounds, style: .plain)
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.isHidden = true
        tableView.backgroundColor = .background
        
        return tableView
    }()
    
    lazy var centerLoadingView: SquaresLoadingView = {
        let view = SquaresLoadingView(loadingStyle: LoadingStyle.bottom)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.delegate = self
        
        return view
    }()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        navigationController?.navigationBar.setupNavigationbar()

        view.addSubview(tableView)
        view.addSubview(centerLoadingView)
        centerLoadingView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        centerLoadingView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        centerLoadingView.widthAnchor.constraint(equalToConstant: R.Constant.LoadingViewHeight).isActive = true
        centerLoadingView.initSquaresPosition()
        beginLoading()
    }
    
    private func beginLoading()
    {
        centerLoadingView.beginLoading()
        loadingRequest()
    }
    
    // MARK: - Public
    func loadingRequest()
    {
        // override this method in subclass
    }
    
    func stopLoading(withSuccesse success: Bool, completion: CompletionTask?)
    {
        centerLoadingView.stopLoading(withSuccess: success, completion: completion)
    }
    
    // MARK: - SquareLoadingViewDelegate
    func didTriggeredReloading()
    {
        beginLoading()
    }
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        // override this method in subclass
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        // override this method in subclass
        return UITableViewCell()
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        // override this method in subclass
    }
    
}
