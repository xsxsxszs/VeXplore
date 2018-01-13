//
//  SearchBoxView.swift
//  VeXplore
//
//  Copyright © 2016 Jimmy. All rights reserved.
//

import SharedKit

class SearchBoxView: BaseView
{
    lazy var searchField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.font = SharedR.Font.Small
        textField.textColor = .body
        textField.textAlignment = .left
        textField.clearButtonMode = .always
        textField.tintColor = .highlight
        textField.autocorrectionType = .no
        textField.borderStyle = .roundedRect
        textField.backgroundColor = .background
        
        return textField
    }()
    
    private lazy var searchIcon: UIImageView = {
        let view = UIImageView()
        view.image = R.Image.Search
        view.tintColor = .desc
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFit
        
        return view
    }()
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        
        addSubview(searchField)
        addSubview(searchIcon)
        let bindings: [String : Any] = [
            "searchField": searchField,
            "searchIcon": searchIcon
        ]
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[searchIcon(18)]-10-[searchField]|", metrics: nil, views: bindings))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-4-[searchField]-4-|", metrics: nil, views: bindings))
        searchIcon.centerYAnchor.constraint(equalTo: searchField.centerYAnchor).isActive = true
        searchIcon.heightAnchor.constraint(equalTo: searchIcon.heightAnchor).isActive = true

        isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapped))
        addGestureRecognizer(tap)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc
    override func refreshColorScheme()
    {
        super.refreshColorScheme()
        searchField.textColor = .body
        searchField.tintColor = .highlight
        searchField.backgroundColor = .background
        searchIcon.tintColor = .desc
        backgroundColor = .subBackground
    }
    
    @objc
    private func tapped()
    {
        searchField.becomeFirstResponder()
    }
    
}
