//
//  SearchBoxView.swift
//  VeXplore
//
//  Copyright © 2016 Jimmy. All rights reserved.
//


class SearchBoxView: UIView
{
    lazy var searchField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.font = R.Font.Small
        textField.textColor = .darkGray
        textField.textAlignment = .left
        textField.clearButtonMode = .always
        textField.tintColor = .lightPink
        textField.autocorrectionType = .no
        textField.borderStyle = .roundedRect
        
        return textField
    }()
    
    private lazy var searchIcon: UIImageView = {
        let view = UIImageView()
        view.image = R.Image.Search
        view.tintColor = .middleGray
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFit
        
        return view
    }()
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        
        addSubview(searchField)
        addSubview(searchIcon)
        let bindings: [String: Any] = [
            "searchField": searchField,
            "searchIcon": searchIcon
        ]
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[searchIcon(18)]-10-[searchField]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: bindings))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-4-[searchField]-4-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: bindings))
        searchIcon.centerYAnchor.constraint(equalTo: searchField.centerYAnchor).isActive = true
        searchIcon.heightAnchor.constraint(equalTo: searchIcon.heightAnchor).isActive = true

        isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapped))
        addGestureRecognizer(tap)
    
        backgroundColor = .offWhite
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc
    private func tapped()
    {
        searchField.becomeFirstResponder()
    }
    
}
