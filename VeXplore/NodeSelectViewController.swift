//
//  NodeSelectViewController.swift
//  VeXplore
//
//  Copyright © 2016 Jimmy. All rights reserved.
//


protocol NodeSelectDelegate: class
{
    func didSelectNode(_ node: NodeModel)
}

class NodeSelectViewController: NodeSearchViewController
{
    weak var delegate: NodeSelectDelegate?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        title = R.String.NodeChoose
        
        let closeBtn = UIBarButtonItem(image: R.Image.Close, style: .plain, target: self, action: #selector(closeBtnTapped))
        closeBtn.tintColor = .middleGray
        navigationItem.leftBarButtonItem = closeBtn
    }
    
    @objc
    private func closeBtnTapped()
    {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - UITableViewDelegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let nodeModel = isSearching ? searchResultNodes[indexPath.section].nodes[indexPath.row] : groupedNodes[indexPath.section].nodes[indexPath.row]
        DispatchQueue.main.async {
            self.delegate?.didSelectNode(nodeModel)
            self.dismiss(animated: true, completion: nil)
        }
    }
    
}
