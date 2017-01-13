//
//  ImageViewingController.swift
//  VeXplore
//
//  Copyright © 2016 Jimmy. All rights reserved.
//


class ImageViewingController: UIViewController, UIScrollViewDelegate, UIGestureRecognizerDelegate
{
    private lazy var scrollView: UIScrollView = {
        let view = UIScrollView(frame: self.view.bounds)
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.delegate = self
        view.showsHorizontalScrollIndicator = false
        view.zoomScale = 1.0
        view.maximumZoomScale = 8.0
        view.isScrollEnabled = false
        
        return view
    }()
    
    private let duration = 0.3
    private let zoomScale: CGFloat = 3.0
    private let dismissDistance: CGFloat = 100.0
    private var image: UIImage!
    private var imageView: AnimatableImageView!
    private var imageInfo: ImageInfo!
    private var startFrame: CGRect!
    private var snapshotView: UIView!
    private var originalScrollViewCenter: CGPoint = .zero
    private var singleTapGestureRecognizer: UITapGestureRecognizer!
    private var panGestureRecognizer: UIPanGestureRecognizer!
    private var longPressGestureRecognizer: UILongPressGestureRecognizer!
    private var doubleTapGestureRecognizer: UITapGestureRecognizer!
    
    init(imageInfo: ImageInfo)
    {
        super.init(nibName: nil, bundle: nil)
        self.imageInfo = imageInfo
        image = imageInfo.image
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        view.addSubview(scrollView)
        let referenceFrameCurrentView = imageInfo.referenceView.convert(imageInfo.referenceRect, to: view)
        imageView = AnimatableImageView(frame: referenceFrameCurrentView)
        imageView.isUserInteractionEnabled = true
        imageView.image = image
        imageView.originalData = imageInfo.originalData // used for gif image
        imageView.contentMode = .scaleAspectFill // reset content mode
        imageView.backgroundColor = .clear
        setupGestureRecognizers()
        view.backgroundColor = .black
    }
    
    func presented(by viewController: UIViewController)
    {
        view.isUserInteractionEnabled = false
        snapshotView = snapshotParentmostViewController(of: viewController)
        snapshotView.alpha = 0.1
        view.insertSubview(snapshotView, at: 0)
        let referenceFrameInWindow = imageInfo.referenceView.convert(imageInfo.referenceRect, to: nil)
        view.addSubview(imageView) // will move to scroll view after transition finishes
        viewController.present(self, animated: false) {
            self.imageView.frame = referenceFrameInWindow
            self.startFrame = referenceFrameInWindow
            UIView.animate(withDuration: self.duration, delay: 0, options: .beginFromCurrentState, animations: {
                self.imageView.frame = self.resizedFrame(forImageSize: self.image.size)
                self.imageView.center = CGPoint(x: self.view.bounds.width / 2.0, y: self.view.bounds.height / 2.0)
                }, completion: { (_) in
                    self.scrollView.addSubview(self.imageView)
                    self.updateScrollViewAndImageView()
                    self.view.isUserInteractionEnabled = true
            })
        }
    }
    
    private func dismiss()
    {
        view.isUserInteractionEnabled = false
        let imageFrame = view.convert(imageView.frame, from: scrollView)
        imageView.removeFromSuperview()
        imageView.frame = imageFrame
        view.addSubview(imageView)
        scrollView.removeFromSuperview()
        UIView.animate(withDuration: duration, delay: 0, options: .beginFromCurrentState, animations: {
            self.imageView.frame = self.startFrame
        }) { (_) in
            self.dismiss(animated: false, completion: nil)
        }
    }
    
    // MARK: - Private
    private func cancelImageDragging()
    {
        UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: [.allowUserInteraction, .beginFromCurrentState], animations: {
            self.imageView.center = CGPoint(x: self.scrollView.contentSize.width / 2.0, y: self.scrollView.contentSize.height / 2.0)
            self.updateScrollViewAndImageView()
            self.snapshotView.alpha = 0.1
            }, completion: nil)
    }

    private func setupGestureRecognizers()
    {
        doubleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(doubleTap(_:)))
        doubleTapGestureRecognizer.numberOfTapsRequired = 2
        doubleTapGestureRecognizer.delegate = self
        longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPress))
        longPressGestureRecognizer.delegate = self
        singleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(singleTap))
        singleTapGestureRecognizer.require(toFail: doubleTapGestureRecognizer)
        singleTapGestureRecognizer.require(toFail: longPressGestureRecognizer)
        singleTapGestureRecognizer.delegate = self

        view.addGestureRecognizer(singleTapGestureRecognizer)
        view.addGestureRecognizer(longPressGestureRecognizer)
        view.addGestureRecognizer(doubleTapGestureRecognizer)
        
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(pan(_:)))
        panGestureRecognizer.maximumNumberOfTouches = 1
        panGestureRecognizer.delegate = self
        scrollView.addGestureRecognizer(panGestureRecognizer)
    }
    
    private func snapshotParentmostViewController(of viewController: UIViewController) -> UIView
    {
        var snapshot = viewController.view
        if var presentingViewController = viewController.view.window!.rootViewController
        {
            while presentingViewController.presentedViewController != nil
            {
                presentingViewController = presentingViewController.presentedViewController!
            }
            snapshot = presentingViewController.view.snapshotView(afterScreenUpdates: true)
        }
        return snapshot ?? UIView()
    }
    
    private func updateScrollViewAndImageView()
    {
        scrollView.frame = view.bounds
        imageView.frame = resizedFrame(forImageSize: image.size)
        scrollView.contentSize = imageView.frame.size
        scrollView.contentInset = contentInsetForScrollView(withZoomScale: scrollView.zoomScale)
    }
    
    private func contentInsetForScrollView(withZoomScale zoomScale: CGFloat) -> UIEdgeInsets
    {
        let boundsWidth = scrollView.bounds.width
        let boundsHeight = scrollView.bounds.height
        let contentWidth =  image.size.width
        let contentHeight = image.size.height
        var minContentHeight: CGFloat!
        var minContentWidth: CGFloat!
        if (contentHeight / contentWidth) < (boundsHeight / boundsWidth)
        {
            minContentWidth = boundsWidth
            minContentHeight = minContentWidth * (contentHeight / contentWidth)
        }
        else
        {
            minContentHeight = boundsHeight
            minContentWidth = minContentHeight * (contentWidth / contentHeight)
        }
        minContentWidth = minContentWidth * zoomScale
        minContentHeight =  minContentHeight * zoomScale
        let hDiff = max(boundsWidth - minContentWidth, 0)
        let vDiff = max(boundsHeight - minContentHeight, 0)
        let inset = UIEdgeInsets(top: vDiff / 2.0, left: hDiff / 2.0, bottom: vDiff / 2.0, right: hDiff / 2.0)
        return inset
    }
    
    private func resizedFrame(forImageSize size: CGSize) -> CGRect
    {
        guard size.width > 0, size.height > 0 else {
            return .zero
        }
        
        var frame = view.bounds
        let nativeWidth = size.width
        let nativeHeight = size.height
        var targetWidth = frame.width * scrollView.zoomScale
        var targetHeight = frame.height * scrollView.zoomScale
        if (targetHeight / targetWidth) < (nativeHeight / nativeWidth)
        {
            targetWidth = targetHeight * (nativeWidth / nativeHeight)
        }
        else
        {
            targetHeight = targetWidth * (nativeHeight / nativeWidth)
        }
        frame = CGRect(x: 0, y: 0, width: targetWidth, height: targetHeight)
        return frame
    }
    
    // MARK: - Gesture Recognizer Actions
    @objc
    private func singleTap()
    {
        dismiss()
    }
    
    @objc
    private func pan(_ sender: UIPanGestureRecognizer)
    {
        let translation = sender.translation(in: sender.view)
        let translationDistance = sqrt(pow(translation.x, 2) + pow(translation.y, 2))
        switch sender.state
        {
        case .began:
            originalScrollViewCenter = scrollView.center
        case .changed:
            scrollView.center = CGPoint(x: originalScrollViewCenter.x + translation.x, y: originalScrollViewCenter.y + translation.y)
            snapshotView.alpha = min(max(translationDistance / dismissDistance * 0.5, 0.1), 0.6)
        default:
            if translationDistance > dismissDistance
            {
                dismiss()
            }
            else
            {
                cancelImageDragging()
            }
        }
    }
    
    @objc
    private func longPress()
    {
        let activityViewController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        present(activityViewController, animated: true, completion: nil)
    }
    
    @objc
    private func doubleTap(_ sender: UITapGestureRecognizer)
    {
        let rawLocation = sender.location(in: sender.view)
        let point = scrollView.convert(rawLocation, from: sender.view)
        var targetZoomRect: CGRect
        var targetInsets: UIEdgeInsets
        if scrollView.zoomScale == 1.0
        {
            let zoomWidth = view.bounds.width / zoomScale
            let zoomHeight = view.bounds.height / zoomScale
            targetZoomRect = CGRect(x: point.x - zoomWidth * 0.5, y: point.y - zoomHeight * 0.5, width: zoomWidth, height: zoomHeight)
            targetInsets = contentInsetForScrollView(withZoomScale: zoomScale)
        }
        else
        {
            let zoomWidth = view.bounds.width * scrollView.zoomScale
            let zoomHeight = view.bounds.height * scrollView.zoomScale
            targetZoomRect = CGRect(x: point.x - zoomWidth * 0.5, y: point.y - zoomHeight * 0.5, width: zoomWidth, height: zoomHeight)
            targetInsets = contentInsetForScrollView(withZoomScale: 1.0)
        }
        view.isUserInteractionEnabled = false
        CATransaction.begin()
        CATransaction.setCompletionBlock {
            self.scrollView.contentInset = targetInsets
            self.view.isUserInteractionEnabled = true
        }
        scrollView.zoom(to: targetZoomRect, animated: true)
        CATransaction.commit()
    }
    
    // MARK: - UIGestureRecognizerDelegate
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool
    {
        if gestureRecognizer == panGestureRecognizer, scrollView.zoomScale != 1.0
        {
            return false
        }
        return true
    }
    
    // MARK: - UIScrollViewDelegate
    func viewForZooming(in scrollView: UIScrollView) -> UIView?
    {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView)
    {
        scrollView.contentInset = contentInsetForScrollView(withZoomScale: scrollView.zoomScale)
        scrollView.isScrollEnabled = true
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat)
    {
        scrollView.isScrollEnabled = (scale > 1)
        scrollView.contentInset = contentInsetForScrollView(withZoomScale: scale)
    }
    
}


struct ImageInfo
{
    var image: UIImage!
    var originalData: Data?
    var referenceRect: CGRect!
    var referenceView: UIView!
}
