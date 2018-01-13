//
//  SquaresLoadingView.swift
//  SquaresLoading
//
//  Copyright © 2016 Jimmy. All rights reserved.
//


enum LoadingStyle: Int
{
    case top
    case bottom
}

protocol SquareLoadingViewDelegate: class
{
    func didTriggeredReloading()
}

class SquaresLoadingView: BaseView
{
    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private var size: CGFloat! {
        didSet
        {
            contentViewSize.constant = size
        }
    }
    
    private let squaresLengthSize = 3
    private let duration: Double = 0.8
    private let gapRate: CGFloat = 0.25 // gapSize is gapRate * squareSize
    private var style: LoadingStyle = .top
    private var squareSize: CGFloat!
    private var gapSize: CGFloat!
    private var motionDistance: CGFloat!
    private var contentViewSize: NSLayoutConstraint!
    private var squares = [CALayer]()
    private var squaresOffsetX = [CGFloat]()
    private var squaresOffsetY = [CGFloat]()
    private var squaresOpacity = [Float]()
    private(set) var isLoading = false
    private(set) var isFailed = false
    weak var delegate: SquareLoadingViewDelegate?
    
    convenience init(loadingStyle: LoadingStyle)
    {
        self.init(frame: .zero)
        style = loadingStyle
    }

    override init(frame: CGRect)
    {
        super.init(frame: frame)
        addSubview(contentView)
        contentView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        contentView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        contentView.widthAnchor.constraint(equalTo: contentView.heightAnchor).isActive = true
        contentViewSize = NSLayoutConstraint.init(item: contentView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 0.0)
        addConstraint(contentViewSize)
        
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc
    override func refreshColorScheme()
    {
        super.refreshColorScheme()
        for square in squares
        {
            square.backgroundColor = UIColor.body.cgColor
        }
    }
    
    private func commonInit()
    {
        for _ in -1..<squaresLengthSize * squaresLengthSize
        {
            let square = CALayer()
            square.backgroundColor = UIColor.body.cgColor
            squares.append(square)
            contentView.layer.addSublayer(square)
        }
        let tap = UITapGestureRecognizer(target: self, action: #selector(reloading))
        addGestureRecognizer(tap)
    }
    
    // MARK: - Public
    func initSquaresPosition()
    {
        initSquaresNormalPostion()
        initSquares(withOffset: size)
    }
    
    func initSquaresNormalPostion()
    {
        for square in squares
        {
            square.removeFromSuperlayer()
        }
        squares.removeAll()
        for _ in -1..<squaresLengthSize * squaresLengthSize
        {
            let square = CALayer()
            square.backgroundColor = UIColor.body.cgColor
            squares.append(square)
            contentView.layer.addSublayer(square)
        }
        
        isLoading = false
        size = min(frame.width, frame.height)
        size = size > 0 ? size : R.Constant.LoadingViewHeight
        
        /**
         * For squaresLengthSize = 3, there are 4 gaps and 2 square placeholder in both sides.
         * So there are 5 suqares and 4 gaps in total.
         *
         * |square placeholder|-gap-|square|-gap-|square|-gap-|square|-gap-|square placeholder|
         *
         * -------
         * |S    |
         * | SSS |
         * | SSS |
         * | SSS |
         * |   S |
         * -------
         */
        squareSize = size / (CGFloat(squaresLengthSize) + 2 + CGFloat(squaresLengthSize + 1) * gapRate)
        gapSize = gapRate * squareSize
        motionDistance = squareSize + gapSize
        squaresOffsetX.removeAll()
        squaresOffsetY.removeAll()
        squaresOpacity.removeAll()
        
        for row in 0..<squaresLengthSize
        {
            for column in 0..<squaresLengthSize
            {
                var offsetX: CGFloat!
                var offsetY: CGFloat!
                if row&1 == 1 // even line
                {
                    offsetX = motionDistance + motionDistance * CGFloat(squaresLengthSize - 1 - column)
                }
                else
                {
                    offsetX = motionDistance + motionDistance * CGFloat(column)
                }
                offsetY = motionDistance * CGFloat(row + 1)
                squaresOffsetX.append(offsetX)
                squaresOffsetY.append(offsetY)
                let indexFloat = Float(squaresLengthSize * row + column + 1)
                squaresOpacity.append(indexFloat / Float(squaresLengthSize * squaresLengthSize))
            }
        }
        
        for position in -1..<squaresLengthSize * squaresLengthSize
        {
            let square = squares[position + 1]
            square.isHidden = false
            square.setAffineTransform(.identity)
            if position == -1
            {
                square.frame = CGRect(x: motionDistance, y: 0, width: squareSize, height: squareSize)
                square.opacity = 0
            }
            else
            {
                square.frame = CGRect(x: squaresOffsetX[position], y: squaresOffsetY[position], width: CGFloat(squareSize), height: CGFloat(squareSize))
                square.opacity = squaresOpacity[position]
            }
        }
        setNeedsLayout()
        layoutIfNeeded()    
    }
    
    func beginLoading()
    {
        if isLoading
        {
            return
        }
        for position in -1..<squaresLengthSize * squaresLengthSize
        {
            addSquareAnimation(positionIndex: position)
        }
        isLoading = true
    }
    
    func showLoadingView(withOffset offset: CGFloat)
    {
        let height = frame.height
        for row in 0..<squaresLengthSize
        {
            for column in 0..<squaresLengthSize
            {
                let index = squaresLengthSize * row + column
                let square = squares[index + 1]
                let squareCount = squaresLengthSize * squaresLengthSize
                let startPoint = motionDistance + squareSize
                let startThreshold = CGFloat(squareCount - index - 1) / CGFloat(squareCount)
                let endThreshold = CGFloat(squareCount - index) / CGFloat(squareCount)
                let relativeOffset = (offset - startPoint) / (height - startPoint)
                if relativeOffset > startThreshold
                {
                    square.isHidden = false
                    if relativeOffset >= endThreshold
                    {
                        square.setAffineTransform(.identity)
                    }
                    else
                    {
                        let realOffset = size * (endThreshold - relativeOffset) / (endThreshold - startThreshold)
                        if (row&1) == 0 // odd line, e.g., first line, third line
                        {
                            square.setAffineTransform(CGAffineTransform(translationX: -realOffset, y: 0))
                        }
                        else
                        {
                            square.setAffineTransform(CGAffineTransform(translationX: realOffset, y: 0))
                        }
                    }
                }
                else
                {
                    square.isHidden = true
                }
            }
        }
    }
    
    func stopLoading(withSuccess success: Bool, completion: CompletionTask?)
    {
        for position in -1..<squaresLengthSize * squaresLengthSize
        {
            let square: CALayer = squares[position + 1]
            square.removeAllAnimations()
            square.opacity = 0
            square.isHidden = true
        }
        
        var path = [Int]()
        var desiredPoints = [CGPoint]()
        let distance = motionDistance / sqrt(2.0)
        var centerSquare: CALayer!
        if success
        {
           centerSquare = squares[8]
            path = [2, 3, 5]
            desiredPoints = [
                CGPoint(x: centerSquare.position.x + 2 * distance, y: centerSquare.position.y - 2 * distance),
                CGPoint(x: centerSquare.position.x + distance, y: centerSquare.position.y - distance),
                CGPoint(x: centerSquare.position.x - distance, y: centerSquare.position.y - distance)
            ]
        }
        else
        {
            centerSquare = squares[5]
            path = [0, 2, 6, 8]
            desiredPoints = [
                CGPoint(x: centerSquare.position.x - distance, y: centerSquare.position.y - distance),
                CGPoint(x: centerSquare.position.x + distance, y: centerSquare.position.y - distance),
                CGPoint(x: centerSquare.position.x - distance, y: centerSquare.position.y + distance),
                CGPoint(x: centerSquare.position.x + distance, y: centerSquare.position.y + distance)
            ]
        }
        centerSquare.opacity = 1
        centerSquare.isHidden = false
        centerSquare.setAffineTransform(CGAffineTransform(rotationAngle: .pi/4))
        
        CATransaction.begin()
        CATransaction.setAnimationDuration(0.5)
        CATransaction.setCompletionBlock {
            self.isLoading = false
            self.isFailed = !success
            completion?(success)
        }
        
        // this code block should be called after CATransaction.setCompletionBlock
        for i in 0..<path.count
        {
            let square = squares[path[i] + 1]
            square.opacity = 1
            square.isHidden = false
            let desiredPoint = desiredPoints[i]
            var transform = CGAffineTransform(translationX: desiredPoint.x - square.position.x, y: desiredPoint.y - square.position.y)
            transform = transform.rotated(by: .pi/4)
            square.setAffineTransform(transform)
        }
        
        CATransaction.commit()
    }
    
    @objc
    private func reloading()
    {
        if isFailed
        {
            initSquaresPosition()
            isFailed = false
            delegate?.didTriggeredReloading()
        }
    }
    
    // MARK: - Private
    private func initSquares(withOffset offset: CGFloat)
    {
        if style == .top
        {
            for row in 0..<squaresLengthSize
            {
                for column in 0..<squaresLengthSize
                {
                    let index = squaresLengthSize * row + column
                    let square = squares[index + 1]
                    if (row&1) == 0 // odd line, go left
                    {
                        square.setAffineTransform(CGAffineTransform(translationX: -offset, y: 0))
                    }
                    else
                    {
                        square.setAffineTransform(CGAffineTransform(translationX: offset, y: 0))
                    }
                    square.isHidden = true
                }
            }
        }
    }
    
    private func addSquareAnimation(positionIndex position: Int)
    {
        let square: CALayer = squares[position + 1]
        square.isHidden = false
        
        let squareCount = squaresLengthSize * squaresLengthSize
        let squareCountDouble = Double(squareCount)
        let keyTimes = [
            0.0,
            1.0 / squareCountDouble,
            (squareCountDouble - 1.0) / squareCountDouble,
            (squareCountDouble - 1.0) / squareCountDouble,
            1.0
        ]
        let startAlpha = (position == -1) ? 0.0 : squaresOpacity[position]
        let endAlpha = (position == squareCount - 1) ? 0.0 : squaresOpacity[position + 1]
        let alphas = [
            startAlpha,
            endAlpha,
            endAlpha,
            0,
            0
        ]
        
        let isFirstOrLastSquare = (position == -1 || position == squareCount - 1)
        let tx: CGFloat = isFirstOrLastSquare ? 0.0 : squaresOffsetX[position + 1] - squaresOffsetX[position]
        let ty: CGFloat = isFirstOrLastSquare ? motionDistance : squaresOffsetY[position + 1] - squaresOffsetY[position]
        let path = CGMutablePath()
        path.move(to: CGPoint(x: square.position.x, y: square.position.y))
        path.addLine(to: CGPoint(x: square.position.x + tx, y: square.position.y + ty))
        path.addLine(to: CGPoint(x: square.position.x + tx, y: square.position.y + ty))
        path.addLine(to: CGPoint(x: square.position.x + tx, y: square.position.y + ty))
        path.addLine(to: CGPoint(x: square.position.x + tx, y: square.position.y + ty))
        
        let positionAnimation: CAKeyframeAnimation = {
            let animation = CAKeyframeAnimation(keyPath: "position")
            animation.isRemovedOnCompletion = false
            animation.duration = duration
            animation.keyTimes = keyTimes as [NSNumber]?
            animation.path = path
            return animation
        }()
        
        let alphaAnimation: CAKeyframeAnimation = {
            let animation = CAKeyframeAnimation(keyPath: "opacity")
            animation.isRemovedOnCompletion = false
            animation.duration = duration
            animation.keyTimes = keyTimes as [NSNumber]?
            animation.values = alphas
            return animation
        }()
        
        let motionTime = duration / squareCountDouble
        let beginTime = motionTime * (squareCountDouble - 1.0 - Double(position))
        let groupAnimation: CAAnimationGroup = {
            let animation = CAAnimationGroup()
            animation.animations = [
                positionAnimation,
                alphaAnimation
            ]
            animation.beginTime = CACurrentMediaTime() + beginTime
            animation.repeatCount = HUGE
            animation.isRemovedOnCompletion = false
            animation.duration = duration
            
            return animation
        }()
        
        square.add(groupAnimation, forKey: nil)
    }
    
}
