//
//  AnimatableImageView.swift
//  VeXplore
//
//  Copyright © 2016 Jimmy. All rights reserved.
//

import ImageIO
import SharedKit

class AnimatableImageView: UIImageView
{
    private class WeakProxy
    {
        private weak var target: AnimatableImageView?
        
        init(target: AnimatableImageView)
        {
            self.target = target
        }
        
        @objc
        func tick()
        {
            target?.tick()
        }
    }
    
    private var imageSource: CGImageSource?
    private var isDisplayLinkInitialized = false
    private let maxTimeStep: TimeInterval = 1.0
    private var currentFrameIndex = 0
    private var timeSinceLastFrameChange: TimeInterval = 0.0
    private var framesDuration = [TimeInterval]()
    
    private lazy var displayLink: CADisplayLink = {
        self.isDisplayLinkInitialized = true
        let displayLink = CADisplayLink(target: WeakProxy(target: self), selector: #selector(WeakProxy.tick))
        displayLink.add(to: .main, forMode: .commonModes)
        displayLink.isPaused = true
        return displayLink
    }()
    
    var originalData: Data? {
        didSet
        {
            if originalData != oldValue, let data = originalData
            {
                image = UIImage(data: data)
                if let image = image, image.size.width < R.Constant.CommentImageSize, image.size.height < R.Constant.CommentImageSize
                {
                    contentMode = .bottomLeft
                }
                
                if data.isGifFormat
                {
                    let options: NSDictionary = [kCGImageSourceShouldCache as String: true, kCGImageSourceTypeIdentifierHint as String: kUTTypeGIF]
                    if let imageSource = CGImageSourceCreateWithData(data as CFData, options)
                    {
                        self.imageSource = imageSource
                        prepareFramesDuration()
                    }
                    didMove()
                }
            }
        }
    }
    
    override open func didMoveToWindow()
    {
        super.didMoveToWindow()
        didMove()
    }
    
    override open func didMoveToSuperview()
    {
        super.didMoveToSuperview()
        didMove()
    }
    
    private func didMove()
    {
        guard imageSource != nil else {
            return
        }
        if superview != nil, window != nil
        {
            startAnimating()
        }
        else
        {
            stopAnimating()
        }
    }
    
    override open var isAnimating: Bool {
        if isDisplayLinkInitialized
        {
            return !displayLink.isPaused
        }
        return super.isAnimating
    }
    
    override open func startAnimating()
    {
        guard isAnimating == false else {
            return
        }
        displayLink.isPaused = false
    }
    
    override open func stopAnimating()
    {
        if isDisplayLinkInitialized
        {
            displayLink.isPaused = true
        }
    }
    
    private func frameImage(at index: Int) -> CGImage?
    {
        guard let imageSource = imageSource else {
            return nil
        }
        return CGImageSourceCreateImageAtIndex(imageSource, index, nil)
    }
    
    private func prepareFramesDuration()
    {
        guard let imageSource = imageSource else {
            return
        }
        let frameCount = CGImageSourceGetCount(imageSource)
        framesDuration.reserveCapacity(frameCount)
        framesDuration = (0..<frameCount).reduce([]) { $0 + [frameDuration(at: $1)] }
    }
    
    private func frameDuration(at index: Int) -> TimeInterval
    {
        guard let imageSource = imageSource else {
            return 0.0
        }
        let frameDuration = imageSource.gifProperties(at: index).flatMap { gifInfo -> TimeInterval in
            var duration: TimeInterval = 0.100
            if let unclampedDelayTime = gifInfo[kCGImagePropertyGIFUnclampedDelayTime as String] as TimeInterval?
            {
                duration = unclampedDelayTime
            }
            else if let delayTime = gifInfo[kCGImagePropertyGIFDelayTime as String] as TimeInterval?
            {
                duration = delayTime
            }
            return duration > 0.011 ? duration : 0.100
        }
        
        return frameDuration ?? 0.0
    }
    
    override open func display(_ layer: CALayer)
    {
        if currentFrameIndex > 0
        {
            layer.contents = frameImage(at: currentFrameIndex)
        }
        else
        {
            layer.contents = image?.cgImage
        }
    }
    
    private func tick()
    {
        if updateCurrentFrame(duration: displayLink.duration)
        {
            layer.setNeedsDisplay()
        }
    }

    private func updateCurrentFrame(duration: CFTimeInterval) -> Bool
    {
        timeSinceLastFrameChange += min(maxTimeStep, duration)
        guard let frameDuration = framesDuration[safe: currentFrameIndex], frameDuration <= timeSinceLastFrameChange else {
            return false
        }
        timeSinceLastFrameChange -= frameDuration
        currentFrameIndex += 1
        currentFrameIndex = currentFrameIndex % framesDuration.count
        return true
    }
    
    deinit
    {
        if isDisplayLinkInitialized
        {
            displayLink.invalidate()
        }
    }
    
}

extension AnimatableImageView
{
    // retrieve original data from cache, this would be useful to play a gif image
    func setImageOriginalData(with url: URL, placeholder: UIImage? = nil)
    {
        image = placeholder
        WebImage.retrieveImage(with: url, completionHandler: { [weak self] image, originalData, error in
            dispatch_async_safely_to_main_queue {
                guard let weakSelf = self else {
                    return
                }
                weakSelf.originalData = originalData
            }
        })
    }
}

extension CGImageSource
{
    func gifProperties(at index: Int) -> [String: Double]?
    {
        let properties = CGImageSourceCopyPropertiesAtIndex(self, index, nil) as Dictionary?
        return properties?[kCGImagePropertyGIFDictionary] as? [String: Double]
    }
}

extension Array
{
    subscript(safe index: Int) -> Element?
    {
        return indices ~= index ? self[index] : nil
    }
}
