//
//  MemberTopicCell.swift
//  VeXplore
//
//  Copyright © 2016 Jimmy. All rights reserved.
//


class MemberTopicCell: TopicCell
{
    var memberTopicItemModel: MemberTopicItemModel?

    override init(style: UITableViewCellStyle, reuseIdentifier: String?)
    {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        avatarSize.constant = 0.0
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Action
    override func nodeTapped()
    {
        if let nodeId = memberTopicItemModel?.nodeId
        {
            delegate?.nodeTapped(withNodeId: nodeId, nodeName: memberTopicItemModel?.nodeName)
        }
    }
}
