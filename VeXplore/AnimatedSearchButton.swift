//
//  AnimatedSearchButton.swift
//  VeXplore
//
//  Copyright © 2016 Jimmy. All rights reserved.
//


protocol AnimatedSearchButtonDelegate: class
{
    func searchButtonTouchUpInside()
}

class AnimatedSearchButton: UIButton, CAAnimationDelegate
{
    // search to close path
    private let searchNormalPath: UIBezierPath = {
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: 68.16, y: 68.16))
        bezierPath.addLine(to: CGPoint(x: 94, y: 94))
        bezierPath.move(to: CGPoint(x: 68.26, y: 68.32))
        bezierPath.addCurve(to: CGPoint(x: 45.26, y: 77.76), controlPoint1: CGPoint(x: 68.26, y: 68.32), controlPoint2: CGPoint(x: 58.83, y: 77.76))
        bezierPath.addCurve(to: CGPoint(x: 22.27, y: 68.32), controlPoint1: CGPoint(x: 31.7, y: 77.76), controlPoint2: CGPoint(x: 22.27, y: 68.32))
        bezierPath.addCurve(to: CGPoint(x: 12.83, y: 45.3), controlPoint1: CGPoint(x: 22.26, y: 68.32), controlPoint2: CGPoint(x: 12.54, y: 58.58))
        bezierPath.addCurve(to: CGPoint(x: 22.27, y: 22.28), controlPoint1: CGPoint(x: 12.83, y: 31.72), controlPoint2: CGPoint(x: 22.26, y: 22.27))
        bezierPath.addCurve(to: CGPoint(x: 45.26, y: 12.83), controlPoint1: CGPoint(x: 22.27, y: 22.28), controlPoint2: CGPoint(x: 32, y: 12.54))
        bezierPath.addCurve(to: CGPoint(x: 68.26, y: 22.28), controlPoint1: CGPoint(x: 58.53, y: 12.54), controlPoint2: CGPoint(x: 68.26, y: 22.27))
        bezierPath.addCurve(to: CGPoint(x: 77.7, y: 45.3), controlPoint1: CGPoint(x: 68.26, y: 22.28), controlPoint2: CGPoint(x: 77.7, y: 31.72))
        bezierPath.addCurve(to: CGPoint(x: 68.26, y: 68.32), controlPoint1: CGPoint(x: 77.99, y: 58.58), controlPoint2: CGPoint(x: 68.26, y: 68.32))
        
        return bezierPath
    }()
    
    private let searchTouchDownPath: UIBezierPath = {
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: 63.92, y: 63.92))
        bezierPath.addLine(to: CGPoint(x: 83, y: 83))
        bezierPath.move(to: CGPoint(x: 20.59, y: 46.02))
        bezierPath.addCurve(to: CGPoint(x: 27.89, y: 27.9), controlPoint1: CGPoint(x: 20.59, y: 35.21), controlPoint2: CGPoint(x: 27.88, y: 27.89))
        bezierPath.addCurve(to: CGPoint(x: 45.99, y: 20.59), controlPoint1: CGPoint(x: 27.89, y: 27.9), controlPoint2: CGPoint(x: 35.48, y: 20.3))
        bezierPath.addCurve(to: CGPoint(x: 63.79, y: 27.9), controlPoint1: CGPoint(x: 56.2, y: 20.3), controlPoint2: CGPoint(x: 63.8, y: 27.89))
        bezierPath.addCurve(to: CGPoint(x: 71.09, y: 46.02), controlPoint1: CGPoint(x: 63.79, y: 27.9), controlPoint2: CGPoint(x: 71.09, y: 35.21))
        bezierPath.addCurve(to: CGPoint(x: 63.79, y: 63.86), controlPoint1: CGPoint(x: 71.38, y: 56.26), controlPoint2: CGPoint(x: 63.8, y: 63.85))
        bezierPath.addCurve(to: CGPoint(x: 45.99, y: 71.17), controlPoint1: CGPoint(x: 63.79, y: 63.86), controlPoint2: CGPoint(x: 56.5, y: 71.17))
        bezierPath.addCurve(to: CGPoint(x: 27.89, y: 63.86), controlPoint1: CGPoint(x: 35.18, y: 71.17), controlPoint2: CGPoint(x: 27.89, y: 63.86))
        bezierPath.addCurve(to: CGPoint(x: 20.59, y: 46.02), controlPoint1: CGPoint(x: 27.88, y: 63.85), controlPoint2: CGPoint(x: 20.3, y: 56.26))
        
        return bezierPath
    }()
    
    private let searchToClosePathA: UIBezierPath = {
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: 70.17, y: 69.97))
        bezierPath.addLine(to: CGPoint(x: 96.7, y: 96.64))
        bezierPath.move(to: CGPoint(x: 11.99, y: 14.16))
        bezierPath.addCurve(to: CGPoint(x: 3.89, y: 3.54), controlPoint1: CGPoint(x: 11.5, y: 14.5), controlPoint2: CGPoint(x: 2.29, y: 4.68))
        bezierPath.addCurve(to: CGPoint(x: 13.9, y: 11.94), controlPoint1: CGPoint(x: 5.55, y: 2.35), controlPoint2: CGPoint(x: 13.5, y: 11.5))
        bezierPath.addCurve(to: CGPoint(x: 36.42, y: 35.69), controlPoint1: CGPoint(x: 13.5, y: 11.5), controlPoint2: CGPoint(x: 36.42, y: 35.69))
        bezierPath.addCurve(to: CGPoint(x: 60.26, y: 59.43), controlPoint1: CGPoint(x: 36.42, y: 35.69), controlPoint2: CGPoint(x: 49.62, y: 49.83))
        bezierPath.addCurve(to: CGPoint(x: 70.13, y: 69.6), controlPoint1: CGPoint(x: 70.92, y: 69.03), controlPoint2: CGPoint(x: 71.83, y: 67.62))
        bezierPath.addCurve(to: CGPoint(x: 59.53, y: 60.91), controlPoint1: CGPoint(x: 68.5, y: 71.5), controlPoint2: CGPoint(x: 68.94, y: 71.09))
        bezierPath.addCurve(to: CGPoint(x: 35.98, y: 37.31), controlPoint1: CGPoint(x: 49.86, y: 50.45), controlPoint2: CGPoint(x: 35.98, y: 37.31))
        bezierPath.addCurve(to: CGPoint(x: 11.99, y: 14.16), controlPoint1: CGPoint(x: 35.98, y: 37.31), controlPoint2: CGPoint(x: 11.5, y: 14.5))
        
        return bezierPath
    }()
    
    private let searchToClosePathB: UIBezierPath = {
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: 3.7, y: 6))
        bezierPath.addCurve(to: CGPoint(x: 40.79, y: 41.66), controlPoint1: CGPoint(x: 16.46, y: 13.66), controlPoint2: CGPoint(x: 16.46, y: 13.66))
        bezierPath.addLine(to: CGPoint(x: 55.03, y: 58.75))
        bezierPath.addCurve(to: CGPoint(x: 93.9, y: 89.1), controlPoint1: CGPoint(x: 81.14, y: 87.33), controlPoint2: CGPoint(x: 81.14, y: 87.33))
        bezierPath.move(to: CGPoint(x: 98.8, y: 7.3))
        bezierPath.addCurve(to: CGPoint(x: 58.23, y: 39.63), controlPoint1: CGPoint(x: 77.05, y: 17.38), controlPoint2: CGPoint(x: 77.05, y: 17.38))
        bezierPath.addLine(to: CGPoint(x: 37.36, y: 61.87))
        bezierPath.addCurve(to: CGPoint(x: 1.2, y: 93.9), controlPoint1: CGPoint(x: 17.37, y: 85.3), controlPoint2: CGPoint(x: 17.37, y: 85.3))
        
        return bezierPath
    }()
    
    private let searchToClosePathC: UIBezierPath = {
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: 10, y: 2.2))
        bezierPath.addCurve(to: CGPoint(x: 30.64, y: 33.94), controlPoint1: CGPoint(x: 11.47, y: 11.9), controlPoint2: CGPoint(x: 11.47, y: 11.9))
        bezierPath.addLine(to: CGPoint(x: 55.41, y: 58.34))
        bezierPath.addCurve(to: CGPoint(x: 82.53, y: 98.6), controlPoint1: CGPoint(x: 84.89, y: 87.43), controlPoint2: CGPoint(x: 84.89, y: 87.43))
        bezierPath.move(to: CGPoint(x: 90.65, y: 1))
        bezierPath.addCurve(to: CGPoint(x: 59.14, y: 38.84), controlPoint1: CGPoint(x: 89.47, y: 10.97), controlPoint2: CGPoint(x: 89.47, y: 10.97))
        bezierPath.addLine(to: CGPoint(x: 35.29, y: 61.13))
        bezierPath.addCurve(to: CGPoint(x: 11.15, y: 99.85), controlPoint1: CGPoint(x: 12.33, y: 84.89), controlPoint2: CGPoint(x: 12.33, y: 84.89))
        
        return bezierPath
    }()
    
    private let searchToClosePathD: UIBezierPath = {
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: 4.85, y: 19.74))
        bezierPath.addCurve(to: CGPoint(x: 31.67, y: 36.96), controlPoint1: CGPoint(x: 13.06, y: 18.35), controlPoint2: CGPoint(x: 13.06, y: 18.35))
        bezierPath.addLine(to: CGPoint(x: 56.42, y: 58.57))
        bezierPath.addCurve(to: CGPoint(x: 87.95, y: 80.75), controlPoint1: CGPoint(x: 76.4, y: 79.54), controlPoint2: CGPoint(x: 76.4, y: 79.54))
        bezierPath.move(to: CGPoint(x: 96.3, y: 18))
        bezierPath.addCurve(to: CGPoint(x: 61.17, y: 38.85), controlPoint1: CGPoint(x: 80.3, y: 20.72), controlPoint2: CGPoint(x: 80.3, y: 20.72))
        bezierPath.addLine(to: CGPoint(x: 36.37, y: 61.46))
        bezierPath.addCurve(to: CGPoint(x: 3.6, y: 81.72), controlPoint1: CGPoint(x: 13.34, y: 82.31), controlPoint2: CGPoint(x: 13.34, y: 82.31))
        
        return bezierPath
    }()
    
    // close to search path
    private let closeNormalPath: UIBezierPath = {
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: 12.05, y: 13.25))
        bezierPath.addCurve(to: CGPoint(x: 32.49, y: 33.04), controlPoint1: CGPoint(x: 22.27, y: 23.145), controlPoint2: CGPoint(x: 22.27, y: 23.145))
        bezierPath.addLine(to: CGPoint(x: 70.94, y: 70.28))
        bezierPath.addCurve(to: CGPoint(x: 87.9, y: 86.7), controlPoint1: CGPoint(x: 78.21, y: 78.49), controlPoint2: CGPoint(x: 79.42, y: 78.49))
        bezierPath.move(to: CGPoint(x: 87.85, y: 13.25))
        bezierPath.addCurve(to: CGPoint(x: 68.57, y: 31.92), controlPoint1: CGPoint(x: 78.21, y: 22.585), controlPoint2: CGPoint(x: 78.21, y: 22.585))
        bezierPath.addLine(to: CGPoint(x: 29.1, y: 70.14))
        bezierPath.addCurve(to: CGPoint(x: 12, y: 86.7), controlPoint1: CGPoint(x: 20.55, y: 78.42), controlPoint2: CGPoint(x: 20.55, y: 78.42))
        
        return bezierPath
    }()
    
    private let closeTouchDownPath: UIBezierPath = {
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: 20.55, y: 21.1))
        bezierPath.addLine(to: CGPoint(x: 79.6, y: 78.85))
        bezierPath.move(to: CGPoint(x: 79.55, y: 21.1))
        bezierPath.addCurve(to: CGPoint(x: 49.5, y: 49.95), controlPoint1: CGPoint(x: 64.525, y: 35.525), controlPoint2: CGPoint(x: 64.525, y: 35.525))
        bezierPath.move(to: CGPoint(x: 49.5, y: 49.95))
        bezierPath.addCurve(to: CGPoint(x: 20.5, y: 78.85), controlPoint1: CGPoint(x: 35, y: 64.4), controlPoint2: CGPoint(x: 35, y: 64.4))
        
        return bezierPath
    }()
    
    private let closeToSearchPathA: UIBezierPath = {
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: 18, y: 19.8))
        bezierPath.addLine(to: CGPoint(x: 81.95, y: 82.45))
        bezierPath.move(to: CGPoint(x: 63.61, y: 15))
        bezierPath.addCurve(to: CGPoint(x: 48.15, y: 49.8), controlPoint1: CGPoint(x: 64.47, y: 32.1), controlPoint2: CGPoint(x: 64.47, y: 32.1))
        bezierPath.move(to: CGPoint(x: 49.3, y: 48.7))
        bezierPath.addCurve(to: CGPoint(x: 33.53, y: 84.8), controlPoint1: CGPoint(x: 29.38, y: 63.78), controlPoint2: CGPoint(x: 29.38, y: 63.78))
        
        return bezierPath
    }()
    
    private let closeToSearchPathB: UIBezierPath = {
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: 15, y: 16.25))
        bezierPath.addLine(to: CGPoint(x: 84.9, y: 83.8))
        bezierPath.move(to: CGPoint(x: 48.18, y: 6.6))
        bezierPath.addCurve(to: CGPoint(x: 46.35, y: 46.4), controlPoint1: CGPoint(x: 65.16, y: 25.56), controlPoint2: CGPoint(x: 65.16, y: 25.56))
        bezierPath.move(to: CGPoint(x: 46.55, y: 46.4))
        bezierPath.addCurve(to: CGPoint(x: 48.7, y: 93.35), controlPoint1: CGPoint(x: 31.55, y: 68), controlPoint2: CGPoint(x: 31.55, y: 68))
        
        return bezierPath
    }()
    
    private let closeToSearchPathC: UIBezierPath = {
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: 12, y: 12.75))
        bezierPath.addLine(to: CGPoint(x: 87.85, y: 87.2))
        bezierPath.move(to: CGPoint(x: 22.8, y: 12.7))
        bezierPath.addCurve(to: CGPoint(x: 46.85, y: 46.35), controlPoint1: CGPoint(x: 41.16, y: 16.99), controlPoint2: CGPoint(x: 41.16, y: 16.99))
        bezierPath.move(to: CGPoint(x: 49.4, y: 49.95))
        bezierPath.addCurve(to: CGPoint(x: 75.75, y: 87.3), controlPoint1: CGPoint(x: 57.56, y: 76.95), controlPoint2: CGPoint(x: 57.56, y: 76.95))
        
        return bezierPath
    }()
    
    private let closeToSearchPathD: UIBezierPath = {
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: 80.93, y: 73.5))
        bezierPath.addCurve(to: CGPoint(x: 85.16, y: 93.39), controlPoint1: CGPoint(x: 85.21, y: 81.87), controlPoint2: CGPoint(x: 87.33, y: 79.26))
        bezierPath.move(to: CGPoint(x: 80.93, y: 73.5))
        bezierPath.addCurve(to: CGPoint(x: 70.33, y: 64.51), controlPoint1: CGPoint(x: 79.74, y: 74.69), controlPoint2: CGPoint(x: 79.74, y: 74.69))
        bezierPath.addCurve(to: CGPoint(x: 46.78, y: 40.91), controlPoint1: CGPoint(x: 60.92, y: 54.32), controlPoint2: CGPoint(x: 46.78, y: 40.91))
        bezierPath.addCurve(to: CGPoint(x: 22.79, y: 17.76), controlPoint1: CGPoint(x: 46.78, y: 40.91), controlPoint2: CGPoint(x: 32.64, y: 27.5))
        bezierPath.addCurve(to: CGPoint(x: 14.69, y: 7.14), controlPoint1: CGPoint(x: 12.93, y: 8.02), controlPoint2: CGPoint(x: 12.93, y: 8.02))
        bezierPath.addCurve(to: CGPoint(x: 24.7, y: 15.54), controlPoint1: CGPoint(x: 15.31, y: 5.95), controlPoint2: CGPoint(x: 15.31, y: 5.95))
        bezierPath.addCurve(to: CGPoint(x: 47.22, y: 39.29), controlPoint1: CGPoint(x: 34.02, y: 25.15), controlPoint2: CGPoint(x: 47.22, y: 39.29))
        bezierPath.addCurve(to: CGPoint(x: 71.06, y: 63.03), controlPoint1: CGPoint(x: 47.22, y: 39.29), controlPoint2: CGPoint(x: 60.42, y: 53.43))
        bezierPath.addCurve(to: CGPoint(x: 80.93, y: 73.5), controlPoint1: CGPoint(x: 81.77, y: 72.63), controlPoint2: CGPoint(x: 81.77, y: 72.63))
        
        return bezierPath
    }()
    
    private let closeToSearchPathE: UIBezierPath = {
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: 64.81, y: 72.87))
        bezierPath.addCurve(to: CGPoint(x: 94.61, y: 84.92), controlPoint1: CGPoint(x: 74.32, y: 82.61), controlPoint2: CGPoint(x: 74.32, y: 82.61))
        bezierPath.move(to: CGPoint(x: 64.81, y: 72.87))
        bezierPath.addCurve(to: CGPoint(x: 43.41, y: 82.34), controlPoint1: CGPoint(x: 64.81, y: 72.87), controlPoint2: CGPoint(x: 59.36, y: 78.53))
        bezierPath.addCurve(to: CGPoint(x: 16.44, y: 79.41), controlPoint1: CGPoint(x: 27.46, y: 86.16), controlPoint2: CGPoint(x: 16.44, y: 79.41))
        bezierPath.addCurve(to: CGPoint(x: 5.42, y: 59.16), controlPoint1: CGPoint(x: 16.44, y: 79.41), controlPoint2: CGPoint(x: 5.13, y: 72.37))
        bezierPath.addCurve(to: CGPoint(x: 16.44, y: 33.63), controlPoint1: CGPoint(x: 5.42, y: 45.66), controlPoint2: CGPoint(x: 16.44, y: 33.63))
        bezierPath.addCurve(to: CGPoint(x: 43.41, y: 17.79), controlPoint1: CGPoint(x: 16.44, y: 33.63), controlPoint2: CGPoint(x: 27.75, y: 21.31))
        bezierPath.addCurve(to: CGPoint(x: 70.38, y: 20.72), controlPoint1: CGPoint(x: 59.07, y: 13.68), controlPoint2: CGPoint(x: 70.38, y: 20.72))
        bezierPath.addCurve(to: CGPoint(x: 81.4, y: 40.97), controlPoint1: CGPoint(x: 70.38, y: 20.72), controlPoint2: CGPoint(x: 81.4, y: 27.47))
        bezierPath.addCurve(to: CGPoint(x: 64.81, y: 72.87), controlPoint1: CGPoint(x: 81.69, y: 53.88), controlPoint2: CGPoint(x: 64.81, y: 72.87))
        
        return bezierPath
    }()
    
    private let closeToSearchPathF: UIBezierPath = {
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: 69.2, y: 66.24))
        bezierPath.addCurve(to: CGPoint(x: 83.75, y: 89.14), controlPoint1: CGPoint(x: 83.11, y: 75.59), controlPoint2: CGPoint(x: 83.11, y: 75.59))
        bezierPath.move(to: CGPoint(x: 69.2, y: 66.24))
        bezierPath.addCurve(to: CGPoint(x: 40.5, y: 72.73), controlPoint1: CGPoint(x: 69.2, y: 66.24), controlPoint2: CGPoint(x: 51.99, y: 77.14))
        bezierPath.addCurve(to: CGPoint(x: 22.22, y: 56.87), controlPoint1: CGPoint(x: 28.41, y: 68.33), controlPoint2: CGPoint(x: 22.22, y: 56.87))
        bezierPath.addCurve(to: CGPoint(x: 17.51, y: 33.07), controlPoint1: CGPoint(x: 22.22, y: 56.87), controlPoint2: CGPoint(x: 15.44, y: 45.11))
        bezierPath.addCurve(to: CGPoint(x: 29.59, y: 15.15), controlPoint1: CGPoint(x: 19.86, y: 20.44), controlPoint2: CGPoint(x: 29.59, y: 15.15))
        bezierPath.addCurve(to: CGPoint(x: 51.11, y: 13.97), controlPoint1: CGPoint(x: 29.59, y: 15.15), controlPoint2: CGPoint(x: 39.02, y: 9.56))
        bezierPath.addCurve(to: CGPoint(x: 69.39, y: 29.54), controlPoint1: CGPoint(x: 62.61, y: 17.79), controlPoint2: CGPoint(x: 69.36, y: 29.54))
        bezierPath.addCurve(to: CGPoint(x: 74.1, y: 53.64), controlPoint1: CGPoint(x: 69.36, y: 29.54), controlPoint2: CGPoint(x: 76.17, y: 41))
        bezierPath.addCurve(to: CGPoint(x: 69.2, y: 66.24), controlPoint1: CGPoint(x: 71.74, y: 65.68), controlPoint2: CGPoint(x: 69.2, y: 66.24))
        
        return bezierPath
    }()
    
    override var frame: CGRect {
        didSet
        {
            updateShapeLayer()
        }
    }
    
    override var contentEdgeInsets: UIEdgeInsets {
        didSet
        {
            updateShapeLayer()
        }
    }
    
    private let normalColor: UIColor = .middleGray
    private let highlightColor: UIColor = .lightPink
    private var shapeLayer = CAShapeLayer()
    private var sequenceOfAnimations = [CAAnimation]()
    private let durantion = 0.4
    var isSearchView = false
    weak var delegate: AnimatedSearchButtonDelegate?
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        updateShapeLayer()
        addTarget(self, action: #selector(buttonTouchDown), for: .touchDown)
        addTarget(self, action: #selector(buttonTouchCancel), for: .touchDragOutside)
        addTarget(self, action: #selector(buttonTouchUpInside), for: .touchUpInside)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Touch Actions
    @objc
    private func buttonTouchDown()
    {
        shapeLayer.strokeColor = highlightColor.cgColor
        var transform = CGAffineTransform(scaleX: shapeLayer.frame.width/100.0, y: shapeLayer.frame.height/100.0)
        let tempPath = isSearchView ? closeTouchDownPath.cgPath.copy(using: &transform) : searchTouchDownPath.cgPath.copy(using: &transform)
        shapeLayer.path = tempPath
    }
    
    @objc
    private func buttonTouchCancel()
    {
        shapeLayer.strokeColor = normalColor.cgColor
        var transform = CGAffineTransform(scaleX: shapeLayer.frame.width/100.0, y: shapeLayer.frame.height/100.0)
        let tempPath = isSearchView ? closeNormalPath.cgPath.copy(using: &transform) : searchNormalPath.cgPath.copy(using: &transform)
        shapeLayer.path = tempPath
    }
    
    @objc
    private func buttonTouchUpInside()
    {
        isUserInteractionEnabled = false
        var transform = CGAffineTransform(scaleX: shapeLayer.frame.width/100.0, y: shapeLayer.frame.height/100.0)
        delegate?.searchButtonTouchUpInside()
        
        if isSearchView
        {
            ///////////////////////////////////////
            ////// Search To Close Animation //////
            ///////////////////////////////////////
            
            let closeTouchDownPathransformed = closeTouchDownPath.cgPath.copy(using: &transform)
            let closeToSearchPathATransformed = closeToSearchPathA.cgPath.copy(using: &transform)
            let closeToSearchPathBTransformed = closeToSearchPathB.cgPath.copy(using: &transform)
            let closeToSearchPathCTransformed = closeToSearchPathC.cgPath.copy(using: &transform)
            let closeToSearchPathDTransformed = closeToSearchPathD.cgPath.copy(using: &transform)
            let closeToSearchPathETransformed = closeToSearchPathE.cgPath.copy(using: &transform)
            let closeToSearchPathFTransformed = closeToSearchPathF.cgPath.copy(using: &transform)
            let searchNormalPathTransformed = searchNormalPath.cgPath.copy(using: &transform)

            // animation 1
            let pathAnimation1 = CAKeyframeAnimation(keyPath: "path")
            pathAnimation1.values = [
                closeTouchDownPathransformed!,
                closeToSearchPathATransformed!,
                closeToSearchPathBTransformed!,
                closeToSearchPathCTransformed!
            ]
            
            let strokeColorAnimation1 = CABasicAnimation(keyPath: "strokeColor")
            strokeColorAnimation1.repeatCount = 1.0
            strokeColorAnimation1.fromValue = highlightColor.cgColor
            strokeColorAnimation1.toValue = normalColor.cgColor
            strokeColorAnimation1.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)

            let groupAnimation1 = CAAnimationGroup()
            groupAnimation1.animations = [
                pathAnimation1,
                strokeColorAnimation1
            ]
            groupAnimation1.fillMode = kCAFillModeForwards
            groupAnimation1.isRemovedOnCompletion = false
            groupAnimation1.duration = durantion * 1.0/5.0
            groupAnimation1.delegate = self
            
            // animation 2
            let animation2 = CAKeyframeAnimation(keyPath: "path")
            animation2.values = [
                closeToSearchPathCTransformed!,
                closeToSearchPathDTransformed!
            ]
            animation2.isRemovedOnCompletion = false
            animation2.fillMode = kCAFillModeForwards
            animation2.duration = durantion * 1.0/5.0
            animation2.delegate = self
            
            // animation 3
            let animation3 = CAKeyframeAnimation(keyPath: "path")
            animation3.values = [
                closeToSearchPathDTransformed!,
                closeToSearchPathETransformed!,
                closeToSearchPathFTransformed!,
                searchNormalPathTransformed!
            ]
            animation3.isRemovedOnCompletion = false
            animation3.fillMode = kCAFillModeForwards
            animation3.duration = durantion * 3.0/5.0
            animation3.delegate = self
            
            // apply animation
            sequenceOfAnimations = [
                groupAnimation1,
                animation2,
                animation3
            ]
            applyNextAnimation()
            var transform = CGAffineTransform(scaleX: shapeLayer.frame.width/100.0, y: shapeLayer.frame.height/100.0)
            let tempPath = searchNormalPath.cgPath.copy(using: &transform)
            shapeLayer.path = tempPath
            shapeLayer.strokeColor = normalColor.cgColor
        }
        else
        {
            ///////////////////////////////////////
            ////// Close To Search Animation //////
            ///////////////////////////////////////
            
            let searchTouchDownPathTransformed = searchTouchDownPath.cgPath.copy(using: &transform)
            let searchToClosePathATransformed = searchToClosePathA.cgPath.copy(using: &transform)
            let searchToClosePathBTransformed = searchToClosePathB.cgPath.copy(using: &transform)
            let searchToClosePathCTransformed = searchToClosePathC.cgPath.copy(using: &transform)
            let searchToClosePathDTransformed = searchToClosePathD.cgPath.copy(using: &transform)
            let closeNormalPathTransformed = closeNormalPath.cgPath.copy(using: &transform)
            
            // animation 1
            let pathAnimation1 = CAKeyframeAnimation(keyPath: "path")
            pathAnimation1.values = [
                searchTouchDownPathTransformed!,
                searchToClosePathATransformed!
            ]
            
            let strokeColorAnimation1 = CABasicAnimation(keyPath: "strokeColor")
            strokeColorAnimation1.repeatCount = 1.0
            strokeColorAnimation1.fromValue = highlightColor.cgColor
            strokeColorAnimation1.toValue = normalColor.cgColor
            strokeColorAnimation1.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            
            let groupAnimation1 = CAAnimationGroup()
            groupAnimation1.animations = [
                pathAnimation1,
                strokeColorAnimation1
            ]
            groupAnimation1.isRemovedOnCompletion = false
            groupAnimation1.fillMode = kCAFillModeForwards
            groupAnimation1.duration = durantion * 1.0/5.0
            groupAnimation1.delegate = self
            
            // animation 2
            let animation2 = CAKeyframeAnimation(keyPath: "path")
            animation2.values = [
                searchToClosePathATransformed!,
                searchToClosePathBTransformed!
            ]
            animation2.isRemovedOnCompletion = false
            animation2.fillMode = kCAFillModeForwards
            animation2.duration = durantion * 1.0/5.0
            animation2.delegate = self
            
            // animation 3
            let animation3 = CAKeyframeAnimation(keyPath: "path")
            animation3.values = [
                searchToClosePathBTransformed!,
                searchToClosePathCTransformed!
            ]
            animation3.isRemovedOnCompletion = false
            animation3.fillMode = kCAFillModeForwards
            animation3.duration = durantion * 1.0/5.0
            animation3.delegate = self
            
            // animation 4
            let animation4 = CAKeyframeAnimation(keyPath: "path")
            animation4.values = [
                searchToClosePathCTransformed!,
                searchToClosePathDTransformed!
            ]
            animation4.isRemovedOnCompletion = false
            animation4.fillMode = kCAFillModeForwards
            animation4.duration = durantion * 1.0/5.0
            animation4.delegate = self
            
            // animation 5
            let animation5 = CAKeyframeAnimation(keyPath: "path")
            animation5.values = [
                searchToClosePathCTransformed!,
                closeNormalPathTransformed!
            ]
            animation5.isRemovedOnCompletion = false
            animation5.fillMode = kCAFillModeForwards
            animation5.duration = durantion * 1.0/5.0
            animation5.delegate = self
            
            // apply animation
            sequenceOfAnimations = [
                groupAnimation1,
                animation2,
                animation3,
                animation4,
                animation5
            ]
            applyNextAnimation()
            var transform = CGAffineTransform(scaleX: shapeLayer.frame.width/100.0, y: shapeLayer.frame.height/100.0)
            let tempPath = closeNormalPath.cgPath.copy(using: &transform);
            shapeLayer.path = tempPath
            shapeLayer.strokeColor = normalColor.cgColor
        }
        isSearchView = !isSearchView
    }
    
    // MARK: - Private
    private func updateShapeLayer()
    {
        shapeLayer.removeFromSuperlayer()
        
        let contentSize = CGSize(width: bounds.width - contentEdgeInsets.left - contentEdgeInsets.right, height: bounds.height - contentEdgeInsets.top - contentEdgeInsets.bottom)
        let dimension = min(contentSize.width, contentSize.height)
        let layerFrame = CGRect(x: (bounds.width - dimension)/2.0, y: (bounds.height - dimension)/2.0, width: dimension, height: dimension)
        shapeLayer = {
            let shapeLayer = CAShapeLayer()
            shapeLayer.frame = layerFrame
            shapeLayer.strokeColor = normalColor.cgColor
            shapeLayer.fillColor = UIColor.clear.cgColor
            var transform = CGAffineTransform(scaleX: shapeLayer.frame.width/100.0, y: shapeLayer.frame.height/100.0)
            let tempPath = isSearchView ? closeNormalPath.cgPath.copy(using: &transform) : searchNormalPath.cgPath.copy(using: &transform)
            shapeLayer.path = tempPath
            
            return shapeLayer
        }()
        layer.addSublayer(shapeLayer)
    }
    
    // MARK: - CAAnimationDelegate
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool)
    {
        applyNextAnimation()
    }
    
    private func applyNextAnimation()
    {
        if sequenceOfAnimations.count == 0
        {
            shapeLayer.removeAllAnimations()
            isUserInteractionEnabled = true
            return
        }
        let nextAnimation = sequenceOfAnimations.first
        sequenceOfAnimations.removeFirst()
        shapeLayer.add(nextAnimation!, forKey: nil)
    }

}
