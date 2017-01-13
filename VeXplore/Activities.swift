//
//  IgnoreActivity.swift
//  VeXplore
//
//  Copyright © 2016 Jimmy. All rights reserved.
//


////////////////////////////
////// Reply Activity //////
////////////////////////////
protocol ReplyActivityDelegate: class
{
    func replyActivityTapped()
}

class ReplyActivity: UIActivity
{
    weak var delegate: ReplyActivityDelegate?
    
    override var activityTitle : String?
    {
        return R.String.ReplyTopic
    }
    
    override var activityImage : UIImage?
    {
        return R.Image.ReplyArrow
    }
    
    override class var activityCategory : UIActivityCategory
    {
        return .action
    }
    
    
    override func canPerform(withActivityItems activityItems: [Any]) -> Bool
    {
        return true
    }
    
    override func prepare(withActivityItems activityItems: [Any])
    {
        delegate?.replyActivityTapped()
    }
    
}


////////////////////////////
////// Favorite Activity //////
////////////////////////////
protocol FavoriteActivityDelegate: class
{
    func favoriteActivityTapped()
}

class FavoriteActivity: UIActivity
{
    weak var delegate: FavoriteActivityDelegate?
    
    override var activityTitle : String?
    {
        return R.String.FavoriteTopic
    }
    
    override var activityImage : UIImage?
    {
        return R.Image.FavoriteActivity
    }
    
    override class var activityCategory : UIActivityCategory
    {
        return .action
    }
    
    
    override func canPerform(withActivityItems activityItems: [Any]) -> Bool
    {
        return true
    }
    
    override func prepare(withActivityItems activityItems: [Any])
    {
        delegate?.favoriteActivityTapped()
    }
    
}


/////////////////////////////////
////// Owner View Activity //////
/////////////////////////////////
protocol OwnerViewActivityDelegate: class
{
    func ownerViewActivityTapped()
}

class OwnerViewActivity: UIActivity
{
    weak var delegate: OwnerViewActivityDelegate?
    var isOwnerView = false
    
    override var activityTitle : String?
    {
        return R.String.OwnerViewSwitch
    }
    
    override var activityImage : UIImage?
    {
        return R.Image.Eye
    }
    
    override class var activityCategory : UIActivityCategory
    {
        return .action
    }
    
    override func canPerform(withActivityItems activityItems: [Any]) -> Bool
    {
        return true
    }
    
    override func prepare(withActivityItems activityItems: [Any])
    {
        delegate?.ownerViewActivityTapped()
    }
    
}


/////////////////////////////
////// Ignore Activity //////
/////////////////////////////
protocol IgnoreActivityDelegate: class
{
    func ignoreActivityTapped()
}

class IgnoreActivity: UIActivity
{
    weak var delegate: IgnoreActivityDelegate?

    override var activityTitle: String?
    {
        return R.String.IgnoreTopic
    }
    
    override var activityImage: UIImage?
    {
        return R.Image.Trash
    }
    
    override class var activityCategory: UIActivityCategory
    {
        return .action
    }
    
    override func canPerform(withActivityItems activityItems: [Any]) -> Bool
    {
        return true
    }
    
    override func prepare(withActivityItems activityItems: [Any])
    {
        delegate?.ignoreActivityTapped()
    }

}


/////////////////////////////
////// Report Activity //////
/////////////////////////////
protocol ReportActivityDelegate: class
{
    func reportActivityTapped()
}

class ReportActivity: UIActivity
{
    weak var delegate: ReportActivityDelegate?
    
    override var activityTitle : String?
    {
        return R.String.ReportTopic
    }
    
    override var activityImage : UIImage?
    {
        return R.Image.ThumbDown
    }
    
    override class var activityCategory : UIActivityCategory
    {
        return .action
    }
    
    override func canPerform(withActivityItems activityItems: [Any]) -> Bool
    {
        return true
    }
    
    override func prepare(withActivityItems activityItems: [Any])
    {
        delegate?.reportActivityTapped()
    }
    
}


/////////////////////////////////////
////// Open In Safari Activity //////
/////////////////////////////////////
protocol OpenInSafariActivityDelegate: class
{
    func openInSafariActivityTapped()
}

class OpenInSafariActivity: UIActivity
{
    weak var delegate: OpenInSafariActivityDelegate?
    
    override var activityTitle : String?
    {
        return R.String.OpenInSafari
    }
    
    override var activityImage : UIImage?
    {
        return R.Image.Safari
    }
    
    override class var activityCategory : UIActivityCategory
    {
        return .action
    }
    
    override func canPerform(withActivityItems activityItems: [Any]) -> Bool
    {
        return true
    }
    
    override func prepare(withActivityItems activityItems: [Any])
    {
        delegate?.openInSafariActivityTapped()
    }
    
}

