//
//  TabsSettingTableView.swift
//  VeXplore
//
//  Copyright © 2016 Jimmy. All rights reserved.
//


enum TabsSettingSection: Int
{
    case showedTabsHeader = 0
    case showedTabsContent
    case hiddenTabsHeader
    case hiddenTabsContent
    case paddingPlaceholder
}

protocol TabsSettingTableViewDataSource: class
{
    func tabsSettingTableView(_ tableView: TabsSettingTableView, canMoveRowAt indexPath: IndexPath) -> Bool
    func tabsSettingTableView(_ tableView: TabsSettingTableView, canMoveToRowAt indexPath: IndexPath) -> Bool
}

protocol TabsSettingTableViewDelegate: class
{
    func tabsSettingTableView(_ tableView: TabsSettingTableView, moveRowAt indexPath: IndexPath, to newIndexPath: IndexPath)
}

class TabsSettingTableView: UITableView, UIGestureRecognizerDelegate
{
    var moveGesture: UILongPressGestureRecognizer!
    weak var tabsSettingDataSource: TabsSettingTableViewDataSource?
    weak var tabsSettingDelegate: TabsSettingTableViewDelegate?
    var originalIndexPathOfMovingRow: IndexPath!
    var movingIndexPath: IndexPath!
    var lastTouchPoint: CGPoint!
    var snapshotOfMovingCell: UIView!
    var touchOffsetYInMovingCell: CGFloat = 0.0
    var autoScrollingThreshold: CGFloat = 0.0
    var autoScrollingDistance: CGFloat!
    var autoScrollTimer: Timer?
    var isAutoScrolling = false
    
    override init(frame: CGRect, style: UITableViewStyle)
    {
        super.init(frame: frame, style: style)
        
        moveGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        moveGesture.delegate = self
        addGestureRecognizer(moveGesture)
        backgroundColor = .offWhite
        separatorStyle = .none
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Handle gesture
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool
    {
        var shouldBegin = true
        if gestureRecognizer == moveGesture
        {
            let touchPoint = gestureRecognizer.location(in: self)
            if let touchIndexPath = indexPathForRow(at: touchPoint)
            {
                shouldBegin = canMoveRow(at: touchIndexPath)
            }
            else
            {
                shouldBegin = false
            }
        }
        return shouldBegin
    }
    
    @objc
    private func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer)
    {
        switch gestureRecognizer.state
        {
        case .began:
            let touchPoint = gestureRecognizer.location(in: self)
            prepareForMovingRow(at: touchPoint)
            lastTouchPoint = touchPoint
            break
        case .changed:
            let touchPoint = gestureRecognizer.location(in: self)
            moveSnapshot(to: touchPoint)
            setupAutoScrollingWith(currentTouchPoint: touchPoint)
            if !isAutoScrolling
            {
                moveRow(to: touchPoint)
            }
            lastTouchPoint = touchPoint
            break
        case .ended:
            finishMovingRow()
            break
        default:
            cancelMovingRowIfNeeded()
            break
        }
    }
    
    private func prepareForMovingRow(at touchPoint: CGPoint)
    {
        let touchIndexPath = indexPathForRow(at: touchPoint)
        originalIndexPathOfMovingRow = touchIndexPath
        movingIndexPath = touchIndexPath
        snapshotOfMovingCell = snapshotForRow(at: movingIndexPath)
        addSubview(snapshotOfMovingCell)
        touchOffsetYInMovingCell = snapshotOfMovingCell.center.y - touchPoint.y
        autoScrollingThreshold = snapshotOfMovingCell.frame.height * 0.6
        autoScrollingDistance = 0.0
    }
    
    private func finishMovingRow()
    {
        stopAutoScrolling()
        let finalFrame = rectForRow(at: movingIndexPath)
        if finalFrame.equalTo(CGRect.zero)
        {
            return
        }
        
        UIView.animate(withDuration: 0.2, animations: {
            self.snapshotOfMovingCell.frame = finalFrame
            self.snapshotOfMovingCell.alpha = 1.0
            self.snapshotOfMovingCell.transform = CGAffineTransform.identity
            self.snapshotOfMovingCell.backgroundColor = .white
            }, completion: { (finished) in
                if finished
                {
                    self.resetSnapshot()
                    if self.originalIndexPathOfMovingRow.compare(self.movingIndexPath) != .orderedSame
                    {
                        self.tabsSettingDelegate?.tabsSettingTableView(self,  moveRowAt: self.originalIndexPathOfMovingRow, to: self.movingIndexPath)
                    }
                    self.resetMovingRow()
                    self.reloadData()
                }
        })
    }
    
    private func cancelMovingRowIfNeeded()
    {
        stopAutoScrolling()
        resetSnapshot()
        resetMovingRow()
    }
    
    private func resetMovingRow()
    {
        movingIndexPath = nil
        originalIndexPathOfMovingRow = nil
    }
    
    private func moveRow(to location: CGPoint)
    {
        if var newIndexPath = indexPathForRow(at: location)
        {
            // edge case, there is no cell in hidden section
            if newIndexPath.section == TabsSettingSection.paddingPlaceholder.rawValue, numberOfRows(inSection: TabsSettingSection.hiddenTabsContent.rawValue) == 0
            {
                newIndexPath = IndexPath(row: 0, section: newIndexPath.section - 1)
            }
            if canMoveRow(to: newIndexPath)
            {
                beginUpdates()
                deleteRows(at: [movingIndexPath], with: .fade)
                insertRows(at: [newIndexPath], with: .fade)
                movingIndexPath = newIndexPath
                endUpdates()
            }
        }
    }
    
    // MARK: - Index path utils
    func isMovingIndexPath(_ indexPath: IndexPath) -> Bool
    {
        if movingIndexPath != nil
        {
            return indexPath.compare(movingIndexPath) == .orderedSame
        }
        return false
    }
    
    private func canMoveRow(at indexPath: IndexPath) -> Bool
    {
        if let dataSource = tabsSettingDataSource
        {
            return dataSource.tabsSettingTableView(self, canMoveRowAt: indexPath)
        }
        return false
    }
    
    private func canMoveRow(to indexPath: IndexPath) -> Bool
    {
        if indexPath.compare(movingIndexPath) == .orderedSame
        {
            return false
        }
        if let dataSource = tabsSettingDataSource
        {
            return dataSource.tabsSettingTableView(self, canMoveToRowAt: indexPath)
        }
        return false
    }
    
    // MARK: - Snapshot
    private func snapshotForRow(at indexPath: IndexPath) -> UIView
    {
        let touchCell = cellForRow(at: indexPath) as! TabsSettingTabCell
        touchCell.isSelected = false
        touchCell.isHighlighted = false
        
        let snapshot = touchCell.contentView.snapshotView(afterScreenUpdates: true)!
        snapshot.frame = touchCell.frame
        UIView.animate(withDuration: 0.15, animations: {
            snapshot.alpha = 0.9
            snapshot.transform = CGAffineTransform(scaleX: 1, y: 1.05)
            snapshot.layer.shadowOpacity = 0.7
            snapshot.layer.shadowOffset = CGSize.zero
            snapshot.layer.shadowPath = UIBezierPath(rect: snapshot.layer.bounds).cgPath
            }, completion: { (_) in
                touchCell.prepareForMove()
        })
        
        return snapshot
    }
    
    private func moveSnapshot(to touchPoint: CGPoint)
    {
        snapshotOfMovingCell.center = CGPoint(x: snapshotOfMovingCell.center.x, y: touchPoint.y + touchOffsetYInMovingCell)
    }
    
    private func resetSnapshot()
    {
        snapshotOfMovingCell.removeFromSuperview()
        snapshotOfMovingCell = nil
    }
    
    // Auto scrolling
    private func setupAutoScrollingWith(currentTouchPoint touchPoint: CGPoint)
    {
        setupautoScrollingDistanceForSnapShot()
        var shouldAutoScroll = false
        
        // move down and scroll down
        if touchPoint.y - lastTouchPoint.y > 0, autoScrollingDistance > 0
        {
            shouldAutoScroll = true
        }
        // move up and scroll up
        if touchPoint.y - lastTouchPoint.y < 0, autoScrollingDistance < 0
        {
            shouldAutoScroll = true
        }
        if !shouldAutoScroll
        {
            autoScrollTimer?.invalidate()
            autoScrollTimer = nil
        }
        else if (autoScrollTimer == nil)
        {
            autoScrollTimer = Timer.scheduledTimer(timeInterval: (1.0 / 60.0), target: self, selector: #selector(autoScrollingTimerFired(_:)), userInfo: nil, repeats: true)
        }
        isAutoScrolling = shouldAutoScroll
    }
    
    private func setupautoScrollingDistanceForSnapShot()
    {
        autoScrollingDistance = 0.0
        let canScroll = frame.height < contentSize.height
        if canScroll, snapshotOfMovingCell.frame.intersects(bounds)
        {
            var touchPoint = moveGesture.location(in: self)
            touchPoint.y += touchOffsetYInMovingCell
            let distanceToTopEdge = touchPoint.y - bounds.minY
            let distanceToBottomEdge = bounds.maxY - touchPoint.y
            
            if distanceToTopEdge < autoScrollingThreshold
            {
                autoScrollingDistance =  -autoScrollingDistance(withDistanceToEdge: distanceToTopEdge)
            }
            else if distanceToBottomEdge < autoScrollingThreshold
            {
                autoScrollingDistance =  autoScrollingDistance(withDistanceToEdge: distanceToBottomEdge)
            }
        }
    }
    
    private func autoScrollingDistance(withDistanceToEdge distanceToEdge:CGFloat) -> CGFloat
    {
        return (autoScrollingThreshold - distanceToEdge) / 5.0
    }
    
    @objc
    private func autoScrollingTimerFired(_ timer: Timer)
    {
        legalizeAutoscrollDistance()
        var newContentOffset = contentOffset
        newContentOffset.y += autoScrollingDistance
        contentOffset = newContentOffset
        
        var frame = snapshotOfMovingCell.frame
        frame.origin.y += autoScrollingDistance
        snapshotOfMovingCell.frame = frame
        
        let touchPoint = moveGesture.location(in: self)
        moveRow(to: touchPoint)
    }
    
    private func legalizeAutoscrollDistance()
    {
        let minimumLegalDistance = -contentOffset.y
        let maximumLegalDistance = contentSize.height - (frame.height + contentOffset.y)
        autoScrollingDistance = max(autoScrollingDistance, minimumLegalDistance)
        autoScrollingDistance = min(autoScrollingDistance, maximumLegalDistance)
    }
    
    private func stopAutoScrolling()
    {
        autoScrollingDistance = 0.0
        autoScrollTimer?.invalidate()
        autoScrollTimer = nil
    }
    
}
