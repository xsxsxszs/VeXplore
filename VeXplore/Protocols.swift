//
//  Protocols.swift
//  VeXplore
//
//  Copyright © 2016 Jimmy. All rights reserved.
//

protocol AvatarTappedDelegate: class
{
    func avatarTapped(withUsername username: String)
}


protocol TopicCellDelegate: AvatarTappedDelegate
{
    func nodeTapped(withNodeId nodeId: String, nodeName: String?)
}


protocol TopicDetailDelegate: TopicCellDelegate
{
    func favoriteBtnTapped()
}


protocol SwipeCellDelegate: class
{
    func cellWillBeginSwipe(at indexPath: IndexPath)
    func cellShouldBeginSwpipe() -> Bool
}
// optional func in SwipeCellDelegate
extension SwipeCellDelegate
{
    func cellShouldBeginSwpipe() -> Bool
    {
        return true
    }
}


protocol NotificationCellDelegate: AvatarTappedDelegate, SwipeCellDelegate
{
    func deleteNotification(withId notificationId: String)
}


protocol CommentCellDelegate: AvatarTappedDelegate, SwipeCellDelegate
{
    func thankBtnTapped(withReplyId replyId: String, indexPath: IndexPath)
    func ignoreBtnTapped(withReplyId replyId: String)
    func replyBtnTapped(withUsername username: String)
    func longPress(at indexPath: IndexPath)
}
