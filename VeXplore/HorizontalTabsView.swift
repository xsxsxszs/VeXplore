//
//  HorizontalTabsView.swift
//  VeXplore
//
//  Copyright © 2016 Jimmy. All rights reserved.
//

import SharedKit

protocol HorizontalTabsViewDelegate: class
{
    func numberOfTabs(in horizontalTabsView: HorizontalTabsView) -> Int
    func titleOfTabs(in horizontalTabsView: HorizontalTabsView, forIndex index: Int) -> String
    func horizontalTabsView(_ horizontalTabsView: HorizontalTabsView, didSelectItemAt index: Int)
}

class HorizontalTabCell: BaseCollectionViewCell
{
    fileprivate lazy var label: UILabel = {
        let label = UILabel(frame: self.contentView.bounds)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.textColor = .body
        label.font = SharedR.Font.StaticMedium
        label.highlightedTextColor = .highlight
        
        return label
    }()
    
    private lazy var bottomLine: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .body
        view.isHidden = true
        
        return view
    }()
    
    private lazy var leftLine: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .border
        view.isHidden = true

        return view
    }()
    
    private lazy var rightLine: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .border
        view.isHidden = true

        return view
    }()
    
    private var bottomLineWidth: NSLayoutConstraint!
    override var isSelected: Bool {
        didSet
        {
            guard isSelected != oldValue else {
                return
            }
            
            label.isHighlighted = isSelected
            if isSelected
            {
                bottomLine.isHidden = false
                contentView.layoutIfNeeded()
                UIView.animate(withDuration: 0.25, animations: {
                    self.contentView.backgroundColor = .background
                    self.bottomLineWidth.isActive = false
                    self.bottomLineWidth = self.bottomLine.widthAnchor.constraint(equalTo: self.contentView.widthAnchor)
                    self.bottomLineWidth.isActive = true
                    self.contentView.layoutIfNeeded()
                    }, completion: { (_) in
                        self.leftLine.isHidden = false
                        self.rightLine.isHidden = false
                })
            }
            else
            {
                contentView.layoutIfNeeded()
                UIView.animate(withDuration: 0.25, animations: {
                    self.contentView.backgroundColor = .subBackground
                    self.bottomLineWidth.isActive = false
                    self.bottomLineWidth = self.bottomLine.widthAnchor.constraint(equalToConstant: 0.0)
                    self.bottomLineWidth.isActive = true
                    self.contentView.layoutIfNeeded()
                    }, completion: { (_) in
                        self.leftLine.isHidden = true
                        self.rightLine.isHidden = true
                })
            }
        }
    }
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        
        contentView.addSubview(label)
        contentView.addSubview(bottomLine)
        contentView.addSubview(leftLine)
        contentView.addSubview(rightLine)
        let bindings = [
            "label": label,
            "bottomLine": bottomLine,
            "leftLine": leftLine,
            "rightLine": rightLine
        ]
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[label]|", metrics: nil, views: bindings))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[bottomLine(2)]|", metrics: nil, views: bindings))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[leftLine(0.5)]", metrics: nil, views: bindings))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[leftLine]|", metrics: nil, views: bindings))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[rightLine(0.5)]|", metrics: nil, views: bindings))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[rightLine]|", metrics: nil, views: bindings))
        label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        bottomLine.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        bottomLineWidth = bottomLine.widthAnchor.constraint(equalToConstant: 0.0)
        bottomLineWidth.isActive = true
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse()
    {
        super.prepareForReuse()
        leftLine.isHidden = true
        rightLine.isHidden = true
        bottomLine.isHidden = true
        contentView.backgroundColor = .subBackground
        label.isHighlighted = false
    }
    
    @objc
    override func refreshColorScheme()
    {
        super.refreshColorScheme()
        label.textColor = .body
        label.highlightedTextColor = .highlight
        bottomLine.backgroundColor = .body
        leftLine.backgroundColor = .border
        rightLine.backgroundColor = .border
        contentView.backgroundColor = .subBackground
    }
}


class HorizontalTabsView: BaseCollectionView, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
{
    private let cellWidth: CGFloat =  66.0
    weak var tabsDelegate: HorizontalTabsViewDelegate?
    
    convenience init()
    {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        self.init(frame: .zero, collectionViewLayout: layout)
    }
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout)
    {
        super.init(frame: frame, collectionViewLayout: layout)
        translatesAutoresizingMaskIntoConstraints = false
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        register(HorizontalTabCell.self, forCellWithReuseIdentifier: String(describing: HorizontalTabCell.self))
        dataSource = self
        delegate = self
        allowsMultipleSelection = false
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        let leftInset = max((frame.width - contentSize.width) * 0.5, 0)
        var newContentInset = contentInset
        newContentInset.left = leftInset
        contentInset = newContentInset
    }
    
    @objc
    override func refreshColorScheme()
    {
        super.refreshColorScheme()
        backgroundColor = .subBackground
    }
    
    // MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return tabsDelegate?.numberOfTabs(in: self) ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: HorizontalTabCell.self), for: indexPath) as! HorizontalTabCell
        cell.label.text = tabsDelegate?.titleOfTabs(in: self, forIndex: indexPath.row)
        return cell
    }
    
    // MARK: - UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath)
    {
        if let selectedIndexPaths = collectionView.indexPathsForSelectedItems, selectedIndexPaths.count > 0
        {
            cell.isSelected = (selectedIndexPaths[0].compare(indexPath) == .orderedSame)
        }
    }

    // MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        return CGSize(width: cellWidth, height: collectionView.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        tabsDelegate?.horizontalTabsView(self, didSelectItemAt: indexPath.row)
    }

}
