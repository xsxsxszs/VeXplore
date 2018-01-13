//
//  LoginPageTextField.swift
//  VeXplore
//
//  Copyright © 2016 Jimmy. All rights reserved.
//

//import SharedKit
//
//class LoginPageTextField: UITextField
//{
//    lazy var bendingLine: BendingLine = {
//        let view = BendingLine()
//        view.translatesAutoresizingMaskIntoConstraints = false
//        view.backgroundColor = .clear
//        view.lineColor = .desc
//        
//        return view
//    }()
//    
//    override init(frame: CGRect)
//    {
//        super.init(frame: frame)
//        
//        addSubview(bendingLine)
//        let bindings = ["bendingLine": bendingLine]
//        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[bendingLine]|", metrics: nil, views: bindings))
//        bendingLine.topAnchor.constraint(equalTo: bottomAnchor).isActive = true
//        bendingLine.heightAnchor.constraint(equalToConstant: 8.0).isActive = true
//        
//        font = SharedR.Font.Medium
//        clipsToBounds = false
//        autocorrectionType = .no
//        autocapitalizationType = .none
//    }
//    
//    required init?(coder aDecoder: NSCoder)
//    {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//}

