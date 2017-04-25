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
        let bindings: [String: Any] = [
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
        
        refreshColorScheme()
        
        NotificationCenter.default.addObserver(self, selector: #selector(refreshColorScheme), name: NSNotification.Name.Setting.NightModeDidChange, object: nil)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc
    private func refreshColorScheme()
    {
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
