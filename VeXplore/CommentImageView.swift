//
//  CommentImageView.swift
//  VeXplore
//
//  Copyright © 2016 Jimmy. All rights reserved.
//


protocol CommentImageTapDelegate: class
{
    func commentImageSingleTap(_ imageView: CommentImageView)
}

class CommentImageView: AnimatableImageView
{
    var imageURL: String?
    weak var delegate: CommentImageTapDelegate?
    
    init()
    {
        super.init(frame: CGRect(x: 0, y: 0, width: R.Constant.CommentImageSize, height: R.Constant.CommentImageSize))
        contentMode = .scaleAspectFill
        clipsToBounds = true
        isUserInteractionEnabled = true
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func willMove(toSuperview newSuperview: UIView?)
    {
        super.willMove(toSuperview: newSuperview)
        guard image == nil else {
            return
        }
        
        if let imageURL = imageURL, let URL = URL(string: imageURL)
        {
            setImageOriginalData(with: URL, placeholder: R.Image.ImagePlaceholder)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        if let touch = touches.first, touch.tapCount == 1
        {
            handleSingleTap()
        }
        next?.touchesCancelled(touches, with: event)
    }
    
    func handleSingleTap()
    {
        delegate?.commentImageSingleTap(self)
    }
    
}
