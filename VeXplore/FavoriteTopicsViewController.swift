//
//  FavoriteTopicsViewController.swift
//  VeXplore
//
//  Copyright © 2016 Jimmy. All rights reserved.
//


class FavoriteTopicsViewController: TopicListViewController
{
    private var currentPage = 1
    private var totalPageNum = 1

    override func viewDidLoad()
    {
        super.viewDidLoad()
        title = R.String.MyFavoriteTopics
        
        enableBottomLoading = false
        let closeBtn = UIBarButtonItem(image: R.Image.Close, style: .plain, target: self, action: #selector(closeBtnTapped))
        navigationItem.leftBarButtonItem = closeBtn
    }
    
    @objc
    private func closeBtnTapped()
    {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Loading request
    override func topLoadingRequest()
    {
        V2Request.Profile.getFavoriteTopics { [weak self] (response) in
            guard let weakSelf = self else {
                return
            }
            
            weakSelf.stopLoading(withLoadingStyle: .top, success: response.success, completion: { (success) -> Void in
                if success, let value = response.value
                {
                    weakSelf.topicList = value.0
                    weakSelf.totalPageNum = value.1
                    weakSelf.currentPage = 2
                    if weakSelf.currentPage > weakSelf.totalPageNum
                    {
                        weakSelf.enableBottomLoading = false
                    }
                    else
                    {
                        weakSelf.tableView.tableFooterView = weakSelf.tableFooterView
                        weakSelf.enableBottomLoading = true
                        weakSelf.bottomLoadingView.initSquaresNormalPostion()
                    }
                    weakSelf.tableView.reloadData()
                    UIView.animate(withDuration: R.Constant.InsetAnimationDuration, delay: 0, options: .beginFromCurrentState, animations: {
                        weakSelf.tableView.contentInset = .zero
                        }, completion: { (_) in
                            weakSelf.tableView.tableHeaderView = nil
                    })
                    weakSelf.isTopLoadingFail = false
                    weakSelf.enableTopLoading = false
                }
                else
                {
                    if response.message.count > 0 && response.message[0] == R.String.NotAuthorizedError
                    {
                        User.shared.logout()
                    }
                    weakSelf.isTopLoadingFail = true
                }
                weakSelf.isTopLoading = false
            })
        }
    }
    
    override func bottomLoadingRequest()
    {
        V2Request.Profile.getFavoriteTopics(withPage: currentPage, completionHandler: { [weak self] (response) in
            guard let weakSelf = self else {
                return
            }
            
            weakSelf.stopLoading(withLoadingStyle: .bottom, success: response.success, completion: { (success) -> Void in
                if success, let value = response.value
                {
                    weakSelf.topicList.append(contentsOf: value.0)
                    weakSelf.currentPage += 1
                    weakSelf.tableView.reloadData()
                    weakSelf.isBottomLoadingFail = false
                    if weakSelf.currentPage > weakSelf.totalPageNum
                    {
                        weakSelf.tableView.tableFooterView = nil
                        weakSelf.enableBottomLoading = false
                    }
                }
                else
                {
                    weakSelf.isBottomLoadingFail = true
                }
                weakSelf.isBottomLoading = false
            })
        })
    }
    
    // MARK: - UITableViewDelegate
    lazy private var heightCell: TopicCell = {
        let cell = TopicCell()
        cell.bounds = self.tableView.bounds
        cell.autoresizingMask = [.flexibleWidth]
        
        return cell
    }()
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        heightCell.prepareForReuse()
        let model = topicList[indexPath.row]
        heightCell.topicTitleLabel.text = model.topicTitle
        heightCell.userNameLabel.text = R.String.Placeholder
        heightCell.lastReplayDateAndUserLabel.text = R.String.Placeholder
        heightCell.setNeedsLayout()
        heightCell.layoutIfNeeded()
        let height = ceil(heightCell.contentView.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height)
        return height
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if let topicId = topicList[indexPath.row].topicId
        {
            let topicVC = TopicViewController(topicId: topicId)
            topicVC.unfavoriteHandler = { [weak self] topicId -> Void in
                guard let weakSelf = self else {
                    return
                }
                weakSelf.removeTopic(withId: topicId)
            }
            DispatchQueue.main.async(execute: {
                self.bouncePresent(navigationVCWith: topicVC, completion: nil)
            })
        }
    }

}
