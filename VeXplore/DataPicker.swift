//
//  DataPicker.swift
//  VeXplore
//
//  Copyright © 2016 Jimmy. All rights reserved.
//

import SharedKit

protocol DataPickerViewDataSource: class
{
    func numberOfItems(inPickerView pickerView: DataPickerView) -> Int
    func pickerView(_ pickerView: DataPickerView, titleForItemAtIndex index: Int) -> String
}

protocol DataPickerViewDelegate: class
{
    func pickerView(_ pickerView: DataPickerView, didSelectItemAt index: Int, animate: Bool)
}

class DataPickerView: BaseView, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
{
    private lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: DataPickerCollectionViewLayout())
        view.translatesAutoresizingMaskIntoConstraints = false
        view.showsVerticalScrollIndicator = false
        view.showsHorizontalScrollIndicator = false
        view.backgroundColor = .background
        view.register(DataPickerCollectionViewCell.self, forCellWithReuseIdentifier: String(describing: DataPickerCollectionViewCell.self))
        view.dataSource = self
        view.delegate = self
        view.allowsMultipleSelection = false
        
        view.layer.mask = {
            let maskLayer = CAGradientLayer()
            maskLayer.frame = view.bounds
            maskLayer.colors = [
                UIColor.clear.cgColor,
                UIColor.black.cgColor,
                UIColor.black.cgColor,
                UIColor.clear.cgColor
            ]
            maskLayer.locations = [0.0, 0.3, 0.7, 1.0]
            maskLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
            maskLayer.endPoint = CGPoint(x: 0.0, y: 1.0)
            
            return maskLayer
            }()
        
        return view
    }()
    
    private lazy var bottomLine: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .border
        
        return view
    }()
    
    private lazy var pickerContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        
        return view
    }()
    
    private lazy var bendingLine: BendingLine = {
        let view = BendingLine()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .border
        
        return view
    }()
    
    private var pickerContainerHeight: NSLayoutConstraint!
    private var isAniamting = false
    var selectedItem: Int?
    var isExpanded = false
    var scrollingTask: (() -> Void)?
    var endScrollingTask: (() -> Void)?
    weak var dataSource: DataPickerViewDataSource?
    weak var delegate: DataPickerViewDelegate?
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        
        pickerContainerView.addSubview(collectionView)
        addSubview(pickerContainerView)
        addSubview(bendingLine)
        let bindings = [
            "collectionView": collectionView,
            "bendingLine": bendingLine,
            "pickerContainerView": pickerContainerView
        ]
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[collectionView]|", metrics: nil, views: bindings))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[pickerContainerView]|", metrics: nil, views: bindings))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[pickerContainerView]|", metrics: nil, views: bindings))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[bendingLine]|", metrics: nil, views: bindings))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[bendingLine(8)]|", metrics: nil, views: bindings))
        collectionView.topAnchor.constraint(equalTo: pickerContainerView.topAnchor).isActive = true
        collectionView.heightAnchor.constraint(equalToConstant: R.Constant.DataPickerHeight).isActive = true
        pickerContainerHeight = NSLayoutConstraint(item: pickerContainerView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 1.0)
        pickerContainerHeight.isActive = true
        
        clipsToBounds = false
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc
    override func refreshColorScheme()
    {
        super.refreshColorScheme()
        collectionView.backgroundColor = .background
        bottomLine.backgroundColor = .border
        bendingLine.backgroundColor = .border
    }
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        collectionView.layer.mask?.frame = collectionView.bounds
    }
    
    //MARK: - Public
    func showOrHide(_ animated: Bool, completion: (() -> Void)?)
    {
        guard isAniamting == false else{
            return
        }
        
        isAniamting = true
        let duration = 0.5
        layoutIfNeeded()
        var superView = superview
        while (superView != nil)
        {
            superView?.layoutIfNeeded()
            superView = superView?.superview
        }
        
        UIView.animate(withDuration: duration, delay: 0.0, options: .curveEaseInOut, animations: {
            if self.isExpanded
            {
                self.pickerContainerHeight.constant = 1
            }
            else
            {
                self.pickerContainerHeight.constant = R.Constant.DataPickerHeight
            }
            self.layoutIfNeeded()
            var superView = self.superview
            while (superView != nil)
            {
                superView?.layoutIfNeeded()
                superView = superView?.superview
            }
        }) { (_) in
            self.isExpanded = !self.isExpanded
            self.isAniamting = false
            completion?()
        }
        
        if (isExpanded)
        {
            bendingLine.animateLineUp(withDuration: duration)
        }
        else
        {
            bendingLine.animateLineDown(withDuration: duration)
        }
    }

    func reloadData()
    {
        collectionView.reloadData()
        if let selectedItem = selectedItem,
            let dataSource = dataSource,
            dataSource.numberOfItems(inPickerView: self) > 0,
            dataSource.numberOfItems(inPickerView: self) > selectedItem
        {
            setSelectedItem(selectedItem, animate: false)
        }
    }
    
    func setSelectedItem(_ item: Int, animate: Bool)
    {
        collectionView.selectItem(at: IndexPath(item: item, section: 0), animated: animate, scrollPosition: .centeredVertically)
        scrollToItem(item, animate: animate)
        selectedItem = item
    }
    
    // MARK: - Private
    private func offsetForItem(at index: Int) -> CGFloat
    {
        guard index < collectionView.numberOfItems(inSection: 0) else {
            fatalError("item out of range")
        }
        
        var offset: CGFloat = 0.0
        for index in 0 ..< index
        {
            let indexPath = IndexPath(item: index, section: 0)
            let cellSize = collectionView(collectionView, layout: collectionView.collectionViewLayout, sizeForItemAt: indexPath)
            offset += cellSize.height
        }
        return offset
    }
    
    private func selectItem(_ item: Int, animate: Bool)
    {
        setSelectedItem(item, animate: animate)
        delegate?.pickerView(self, didSelectItemAt: item, animate: animate)
    }
    
    private func scrollToItem(_ item: Int, animate: Bool)
    {
        collectionView.setContentOffset(CGPoint(x: collectionView.contentOffset.x, y: offsetForItem(at: item)), animated: animate)
    }
    
    //MARK: - UICollectionViewDataSource
    func numberOfSections(in collectionView: UICollectionView) -> Int
    {
        if let dataSource = dataSource, dataSource.numberOfItems(inPickerView: self) > 0
        {
            return 1
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return dataSource?.numberOfItems(inPickerView: self) ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: DataPickerCollectionViewCell.self), for: indexPath) as! DataPickerCollectionViewCell
        if let dataSource = dataSource
        {
            let title = dataSource.pickerView(self, titleForItemAtIndex: indexPath.item)
            cell.label.text = title
            cell.label.bounds = cell.bounds
        }
        return cell
    }
    
    //MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        return CGSize(width: collectionView.bounds.width, height: R.Constant.DataPickerCellHeight)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets
    {
        let number = self.collectionView(collectionView, numberOfItemsInSection: section)
        let firstIndexPath = IndexPath(item: 0, section: section)
        let firstSize = self.collectionView(collectionView, layout: collectionViewLayout, sizeForItemAt: firstIndexPath)
        let lastIndexPath = IndexPath(item: number - 1, section: section)
        let lastSize = self.collectionView(collectionView, layout: collectionViewLayout, sizeForItemAt: lastIndexPath)
        
        return UIEdgeInsetsMake((collectionView.bounds.height - firstSize.height) * 0.5,
                                0,
                                (collectionView.bounds.height - lastSize.height) * 0.5,
                                0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat
    {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat
    {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        selectItem(indexPath.item, animate: true)
    }
    
    //MARK: - UIScrollViewDelegate
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>)
    {
        if let dataSource = dataSource, dataSource.numberOfItems(inPickerView: self) > 0
        {
            let item = Int(targetContentOffset.pointee.y / R.Constant.DataPickerCellHeight)
            targetContentOffset.pointee.y = offsetForItem(at: item)
            collectionView.deselectItem(at: IndexPath(item: selectedItem!, section: 0), animated: true)
            selectedItem = item
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView)
    {
        if let selectedItem = selectedItem
        {
            collectionView.selectItem(at: IndexPath(item: selectedItem, section: 0), animated: true, scrollPosition: UICollectionViewScrollPosition())
            delegate?.pickerView(self, didSelectItemAt: selectedItem, animate: true)
        }
        endScrollingTask?()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView)
    {
        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
        collectionView.layer.mask?.frame = collectionView.bounds
        CATransaction.commit()
        if scrollView.isDragging || scrollView.isDecelerating
        {
            scrollingTask?()
        }
    }

    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView)
    {
        if let endScrollingTask = endScrollingTask
        {
            endScrollingTask()
        }
    }
    
}


class DataPickerCollectionViewCell: UICollectionViewCell
{
    fileprivate lazy var label: UILabel = {
        let label = UILabel(frame: self.contentView.bounds)
        label.textColor = .body
        label.textAlignment = .center
        label.highlightedTextColor = .highlight
        label.font = SharedR.Font.StaticMedium
        label.lineBreakMode = .byTruncatingTail
        label.autoresizingMask = [
            .flexibleTopMargin,
            .flexibleRightMargin,
            .flexibleBottomMargin,
            .flexibleLeftMargin
        ]
        
        return label
    }()
    
    //jctodo: bug: somethimes not highlighted
    override var isSelected: Bool{
        didSet
        {
            if oldValue != isSelected
            {
                let transition = CATransition()
                transition.type = kCATransitionFade
                transition.duration = 0.5
                label.layer.add(transition, forKey: nil)
            }
        }
    }
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        layer.isDoubleSided = false
        contentView.addSubview(label)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }

}


class DataPickerCollectionViewLayout: UICollectionViewFlowLayout
{
    private var midY: CGFloat = 0.0
    private var height: CGFloat = 0.0
    
    override init()
    {
        super.init()
        scrollDirection = .vertical
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepare()
    {
        super.prepare()
        let visibleRect = CGRect(origin: collectionView!.contentOffset, size: collectionView!.bounds.size)
        midY = visibleRect.midY
        height = visibleRect.height * 0.5
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool
    {
        return true
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes?
    {
        if let attributes = super.layoutAttributesForItem(at: indexPath)
        {
            let distance = attributes.frame.midY - midY
            let currentAngle = distance / height
            var transform = CATransform3DIdentity
            transform = CATransform3DTranslate(transform, 0, -distance, -height)
            transform = CATransform3DRotate(transform, currentAngle, -1, 0, 0)
            transform = CATransform3DTranslate(transform, 0, 0, height)
            attributes.transform3D = transform
            attributes.alpha = abs(Double(currentAngle)) < .pi/2 ? 1.0 : 0.0
            return attributes
        }
        return nil
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]?
    {
        let attributesInRect = super.layoutAttributesForElements(in: rect)
        var attributes = [UICollectionViewLayoutAttributes]()
        for cellAttributes in attributesInRect!
        {
            let layoutAttributes = layoutAttributesForItem(at: cellAttributes.indexPath)
            attributes.append(layoutAttributes!)
        }
        return attributes
    }
    
}
