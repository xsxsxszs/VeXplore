//
//  BendingLine.swift
//  VeXplore
//
//  Copyright © 2016 Jimmy. All rights reserved.
//


class BendingLine: UIView
{
    private var shapeLayer = CAShapeLayer()
    private var lineLayer = CAShapeLayer()
    var upAnimationFillColor: UIColor = .clear
    var lineColor: UIColor = .border
    
    // MARK - Public
    func animateLineUp(withDuration duration: Double)
    {
        updateLayers()
        
        let upShapeAnimation: CAKeyframeAnimation = {
            let animation = CAKeyframeAnimation(keyPath: "path")
            animation.repeatCount = 1.0
            animation.values = [
                normalShapePathRef(),
                upShapePathRef(),
                normalShapePathRef()
            ]
            animation.keyTimes = [0, 0.7, 1]
            animation.calculationMode = kCAAnimationCubic
            animation.timingFunctions = [CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)]
            animation.duration = duration
            
            return animation
        }()
        
        let upLineAnimation: CAKeyframeAnimation = {
            let animation = CAKeyframeAnimation(keyPath: "path")
            animation.repeatCount = 1.0
            animation.values = [
                normalLinePathRef(),
                upLinePathRef(),
                normalLinePathRef()
            ]
            animation.keyTimes = [0, 0.7, 1]
            animation.calculationMode = kCAAnimationCubic
            animation.timingFunctions = [CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)]
            animation.duration = duration
            
            return animation
        }()
        
        let upLineStrokeColorAnimation: CAKeyframeAnimation = {
            let animation = CAKeyframeAnimation(keyPath: "strokeColor")
            animation.repeatCount = 1.0
            animation.values = [
                UIColor.highlight.cgColor,
                lineColor.cgColor
            ]
            animation.calculationMode = kCAAnimationCubic
            animation.timingFunctions = [CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)]
            animation.isRemovedOnCompletion = false
            animation.fillMode = kCAFillModeForwards
            animation.duration = duration
            
            return animation
        }()
        
        shapeLayer.add(upShapeAnimation, forKey: nil)
        lineLayer.add(upLineAnimation, forKey: nil)
        lineLayer.add(upLineStrokeColorAnimation, forKey: nil)
    }
    
    func animateLineDown(withDuration duration: Double)
    {
        updateLayers()
        
        let downShapeAnimation: CAKeyframeAnimation = {
            let animation = CAKeyframeAnimation(keyPath: "path")
            animation.repeatCount = 1.0
            animation.values = [
                normalShapePathRef(),
                downShapePathRef(),
                normalShapePathRef()
            ]
            animation.keyTimes = [0, 0.7, 1]
            animation.calculationMode = kCAAnimationCubic
            animation.timingFunctions = [CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)]
            animation.duration = duration
            
            return animation
        }()
        
        let downLineAnimation: CAKeyframeAnimation = {
            let animation = CAKeyframeAnimation(keyPath: "path")
            animation.repeatCount = 1.0
            animation.values = [
                normalLinePathRef(),
                downLinePathRef(),
                normalLinePathRef()
            ]
            animation.keyTimes = [0, 0.7, 1]
            animation.calculationMode = kCAAnimationCubic
            animation.timingFunctions = [CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)]
            animation.duration = duration
            
            return animation
        }()
        
        let downLineStrokeColorAnimation: CAKeyframeAnimation = {
            let animation = CAKeyframeAnimation(keyPath: "strokeColor")
            animation.repeatCount = 1.0
            animation.values = [
                lineColor.cgColor,
                UIColor.highlight.cgColor
            ]
            animation.calculationMode = kCAAnimationCubic
            animation.timingFunctions = [CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)]
            animation.isRemovedOnCompletion = false
            animation.fillMode = kCAFillModeForwards
            animation.duration = duration
            
            return animation
        }()
        
        shapeLayer.add(downShapeAnimation, forKey: nil)
        lineLayer.add(downLineAnimation, forKey: nil)
        lineLayer.add(downLineStrokeColorAnimation, forKey: nil)
    }
    
    // MARK: - Private
    private func updateLayers()
    {
        shapeLayer.removeFromSuperlayer()
        shapeLayer = {
            let shapeLayer = CAShapeLayer()
            shapeLayer.frame = bounds
            shapeLayer.strokeColor = UIColor.clear.cgColor
            shapeLayer.fillColor = UIColor.clear.cgColor
            shapeLayer.path = normalShapePathRef()
            
            return shapeLayer
        }()
        layer.addSublayer(shapeLayer)
        
        lineLayer.removeFromSuperlayer()
        lineLayer = {
            let shapeLayer = CAShapeLayer()
            shapeLayer.frame = bounds
            shapeLayer.lineWidth = 1
            shapeLayer.strokeColor = UIColor.highlight.cgColor
            shapeLayer.fillColor = UIColor.clear.cgColor
            shapeLayer.path = normalLinePathRef()
            
            return shapeLayer
        }()
        layer.addSublayer(lineLayer)
        backgroundColor = upAnimationFillColor
    }
    
    private func normalLinePathRef() -> CGPath
    {
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: 999.5, y: 49.5))
        bezierPath.addLine(to: CGPoint(x: 999.5, y: 49.5))
        bezierPath.addLine(to: CGPoint(x: 0.5, y: 49.5))
        bezierPath.lineWidth = 0
        return scalePath(bezierPath)
    }
    
    private func upLinePathRef() -> CGPath
    {
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: 999.5, y: 60))
        bezierPath.addCurve(to: CGPoint(x: 500.5, y: 10), controlPoint1: CGPoint(x: 999.5, y: 60), controlPoint2: CGPoint(x: 750.25, y: 10))
        bezierPath.addCurve(to: CGPoint(x: 0.5, y: 60), controlPoint1: CGPoint(x: 250.75, y: 10), controlPoint2: CGPoint(x: 0.5, y: 60))
        bezierPath.lineWidth = 0
        return scalePath(bezierPath)
    }
    
    private func downLinePathRef() -> CGPath
    {
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: 999.5, y: 39.5))
        bezierPath.addCurve(to: CGPoint(x: 500.5, y: 90), controlPoint1: CGPoint(x: 999.5, y: 39.5), controlPoint2: CGPoint(x: 750.25, y: 90))
        bezierPath.addCurve(to: CGPoint(x: 0.5, y: 39.5), controlPoint1: CGPoint(x: 250.75, y: 90), controlPoint2: CGPoint(x: 0.5, y: 39.5))
        bezierPath.lineWidth = 0
        return scalePath(bezierPath)
    }
    
    private func normalShapePathRef() -> CGPath
    {
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: 0.5, y: 0.5))
        bezierPath.addLine(to: CGPoint(x: 999.5, y: 0.5))
        bezierPath.addLine(to: CGPoint(x: 999.5, y: 49.5))
        bezierPath.addLine(to: CGPoint(x: 499.5, y: 49.5))
        bezierPath.addLine(to: CGPoint(x: 0.5, y: 49.5))
        bezierPath.addLine(to: CGPoint(x: 0.5, y: 0.5))
        bezierPath.close()
        bezierPath.lineWidth = 0
        return scalePath(bezierPath)
    }
    
    private func upShapePathRef() -> CGPath
    {
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: 0.5, y: 0.5))
        bezierPath.addLine(to: CGPoint(x: 999.5, y: 0.5))
        bezierPath.addLine(to: CGPoint(x: 999.5, y: 60))
        bezierPath.addCurve(to: CGPoint(x: 500.5, y: 10), controlPoint1: CGPoint(x: 999.5, y: 60), controlPoint2: CGPoint(x: 750.25, y: 10))
        bezierPath.addCurve(to: CGPoint(x: 0.5, y: 60), controlPoint1: CGPoint(x: 250.75, y: 10), controlPoint2: CGPoint(x: 0.5, y: 60))
        bezierPath.addLine(to: CGPoint(x: 0.5, y: 0.5))
        bezierPath.close()
        bezierPath.lineWidth = 0
        return scalePath(bezierPath)
    }
    
    private func downShapePathRef() -> CGPath
    {
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: 0.5, y: 0.5))
        bezierPath.addLine(to: CGPoint(x: 999.5, y: 0.5))
        bezierPath.addLine(to: CGPoint(x: 999.5, y: 39.5))
        bezierPath.addCurve(to: CGPoint(x: 500.5, y: 90), controlPoint1: CGPoint(x: 999.5, y: 39.5), controlPoint2: CGPoint(x: 750.25, y: 90))
        bezierPath.addCurve(to: CGPoint(x: 0.5, y: 39.5), controlPoint1: CGPoint(x: 250.75, y: 90), controlPoint2: CGPoint(x: 0.5, y: 39.5))
        bezierPath.addLine(to: CGPoint(x: 0.5, y: 0.5))
        bezierPath.close()
        bezierPath.lineWidth = 0
        return scalePath(bezierPath)
    }
    
    private func scalePath(_ path: UIBezierPath) -> CGPath
    {
        let transform = CGAffineTransform(scaleX: bounds.width / 1000.0, y: bounds.height / 50.0)
        path.apply(transform)
        return path.cgPath
    }
    
}
