//
//  BaseViewController.swift
//  VeXplore
//
//  Created by Jing Chen on 07/01/2018.
//  Copyright © 2018 Jimmy. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        refreshColorScheme()
        NotificationCenter.default.addObserver(self, selector: #selector(refreshColorScheme), name: NSNotification.Name.Setting.NightModeDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleContentSizeCategoryDidChanged), name: NSNotification.Name.UIContentSizeCategoryDidChange, object: nil)
    }

    @objc
    func refreshColorScheme()
    {
        navigationController?.navigationBar.setupNavigationbar()
        view.backgroundColor = .background
    }

    @objc
    func handleContentSizeCategoryDidChanged()
    {
    }
    
}


class BaseTableViewController: UITableViewController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        refreshColorScheme()
        NotificationCenter.default.addObserver(self, selector: #selector(refreshColorScheme), name: NSNotification.Name.Setting.NightModeDidChange, object: nil)
    }
    
    @objc
    func refreshColorScheme()
    {
        navigationController?.navigationBar.setupNavigationbar()
        view.backgroundColor = .background
    }
    
}


class BaseTableViewCell: UITableViewCell
{
    override init(style: UITableViewCellStyle, reuseIdentifier: String?)
    {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        refreshColorScheme()
        NotificationCenter.default.addObserver(self, selector: #selector(refreshColorScheme), name: NSNotification.Name.Setting.NightModeDidChange, object: nil)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc
    func refreshColorScheme()
    {
        contentView.backgroundColor = .background
        backgroundColor = .background
    }
    
}


class BaseTableViewHeaderFooterView: UITableViewHeaderFooterView
{
    override init(reuseIdentifier: String?)
    {
        super.init(reuseIdentifier: reuseIdentifier)
        refreshColorScheme()
        NotificationCenter.default.addObserver(self, selector: #selector(refreshColorScheme), name: NSNotification.Name.Setting.NightModeDidChange, object: nil)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc
    func refreshColorScheme()
    {
    }
    
}


class BaseView: UIView
{
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        refreshColorScheme()
        NotificationCenter.default.addObserver(self, selector: #selector(refreshColorScheme), name: NSNotification.Name.Setting.NightModeDidChange, object: nil)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc
    func refreshColorScheme()
    {
        backgroundColor = .background
    }
    
}


class BaseCollectionViewCell: UICollectionViewCell
{
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        refreshColorScheme()
        NotificationCenter.default.addObserver(self, selector: #selector(refreshColorScheme), name: NSNotification.Name.Setting.NightModeDidChange, object: nil)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc
    func refreshColorScheme()
    {
    }
    
}


class BaseCollectionReusableView: UICollectionReusableView
{
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        refreshColorScheme()
        NotificationCenter.default.addObserver(self, selector: #selector(refreshColorScheme), name: NSNotification.Name.Setting.NightModeDidChange, object: nil)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc
    func refreshColorScheme()
    {
    }
    
}


class BaseCollectionView: UICollectionView
{
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout)
    {
        super.init(frame: frame, collectionViewLayout: layout)
        refreshColorScheme()
        NotificationCenter.default.addObserver(self, selector: #selector(refreshColorScheme), name: NSNotification.Name.Setting.NightModeDidChange, object: nil)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc
    func refreshColorScheme()
    {
    }
    
}


class BaseTableView: UITableView
{
    override init(frame: CGRect, style: UITableViewStyle)
    {
        super.init(frame: frame, style: style)
        refreshColorScheme()
        NotificationCenter.default.addObserver(self, selector: #selector(refreshColorScheme), name: NSNotification.Name.Setting.NightModeDidChange, object: nil)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc
    func refreshColorScheme()
    {
    }
    
}


class BaseTextView: UITextView
{
    init()
    {
        super.init(frame: .zero, textContainer: nil)
        refreshColorScheme()
        NotificationCenter.default.addObserver(self, selector: #selector(refreshColorScheme), name: NSNotification.Name.Setting.NightModeDidChange, object: nil)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc
    func refreshColorScheme()
    {
        backgroundColor = .background
    }
    
}


class BaseControl: UIControl
{
    init(titles: [String], selectedIndex: Int)
    {
        super.init(frame: .zero)
        refreshColorScheme()
        NotificationCenter.default.addObserver(self, selector: #selector(refreshColorScheme), name: NSNotification.Name.Setting.NightModeDidChange, object: nil)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc
    func refreshColorScheme()
    {
        backgroundColor = .background
    }
    
}

