//
//  LoginViewController.swift
//  VeXplore
//
//  Copyright © 2016 Jimmy. All rights reserved.
//

import SharedKit


class LoginViewController: UIViewController, UITextFieldDelegate
{
    private lazy var backgroundView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleToFill
        view.image = R.Image.LoginBackground
        view.isUserInteractionEnabled = true
        
        return view
    }()
    
    private lazy var usernameContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(usernameContainerViewTapped)))
        
        return view
    }()
    
    private lazy var passwordContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(passwordContainerViewTapped)))

        return view
    }()
    
    private lazy var usernameTextFiled: LoginPageTextField = {
        let textFiled = LoginPageTextField()
        textFiled.translatesAutoresizingMaskIntoConstraints = false
        textFiled.clearButtonMode = .always
        textFiled.textColor = .body
        textFiled.returnKeyType = .next
        textFiled.delegate = self
        textFiled.placeholder = R.String.Username
        
        return textFiled
    }()
    
    private lazy var passwordTextFiled: LoginPageTextField = {
        let textFiled = LoginPageTextField()
        textFiled.translatesAutoresizingMaskIntoConstraints = false
        textFiled.isSecureTextEntry = true
        textFiled.clearButtonMode = .always
        textFiled.textColor = .body
        textFiled.returnKeyType = .done
        textFiled.delegate = self
        textFiled.placeholder = R.String.Password
        
        return textFiled
    }()
    
    private lazy var loginBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(loginBtnTapped), for: .touchUpInside)
        let normalLoginText = NSMutableAttributedString(string: R.String.Login, attributes: [NSFontAttributeName: R.Font.VeryLarge, NSForegroundColorAttributeName: UIColor.body])
        let disabledLoginText = NSMutableAttributedString(string: R.String.Login, attributes: [NSFontAttributeName: R.Font.VeryLarge, NSForegroundColorAttributeName: UIColor.gray])
        btn.setAttributedTitle(normalLoginText, for: .normal)
        btn.setAttributedTitle(disabledLoginText, for: .disabled)
        btn.isEnabled = false
        btn.alpha = 0.0
        btn.layer.borderWidth = 1.0
        btn.layer.cornerRadius = 5.0
        btn.layer.borderColor = UIColor.gray.cgColor
        
        return btn
    }()
    
    private lazy var closeBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setImage(R.Image.Close, for: .normal)
        btn.tintColor = .desc
        btn.addTarget(self, action: #selector(closeBtnTapped), for: .touchUpInside)
        
        return btn
    }()
    
    private lazy var onePasswordBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(R.Image.Onepassword, for: .normal)
        btn.tintColor = .gray
        btn.frame = CGRect(x: 0, y: 0, width: 27, height: 27)
        btn.addTarget(self, action: #selector(searchFromOnePassword(_:)), for: .touchUpInside)
        
        return btn
    }()
    
    private lazy var centerLoadingView: SquaresLoadingView = {
        let view = SquaresLoadingView(loadingStyle: .bottom)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        
        return view
    }()

    private var loginRequest: Request?
    var successHandler: ((String) -> Void)?

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        let bindings = [
            "usernameTextFiled": usernameTextFiled,
            "passwordTextFiled": passwordTextFiled,
            "backgroundView": backgroundView,
            "closeBtn": closeBtn,
            "usernameContainerView": usernameContainerView,
            "passwordContainerView": passwordContainerView,
            "loginBtn": loginBtn,
            ]
        
        usernameContainerView.addSubview(usernameTextFiled)
        passwordContainerView.addSubview(passwordTextFiled)
        usernameContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[usernameTextFiled]|", metrics: nil, views: bindings))
        passwordContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[passwordTextFiled]|", metrics: nil, views: bindings))
        usernameContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-12-[usernameTextFiled(34)]-12-|", metrics: nil, views: bindings))
        passwordContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-12-[passwordTextFiled(34)]-12-|", metrics: nil, views: bindings))

        backgroundView.addSubview(usernameContainerView)
        backgroundView.addSubview(passwordContainerView)
        backgroundView.addSubview(loginBtn)
        backgroundView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-48@999-[usernameContainerView]-48@999-|", metrics: nil, views: bindings))
        usernameContainerView.centerXAnchor.constraint(equalTo: backgroundView.centerXAnchor).isActive = true
        usernameContainerView.leadingAnchor.constraint(equalTo: passwordContainerView.leadingAnchor).isActive = true
        usernameContainerView.trailingAnchor.constraint(equalTo: passwordContainerView.trailingAnchor).isActive = true
        usernameContainerView.widthAnchor.constraint(lessThanOrEqualToConstant: 480.0).isActive = true
        backgroundView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[usernameContainerView][passwordContainerView]-44-[loginBtn(44)]", metrics: nil, views: bindings))
        loginBtn.widthAnchor.constraint(equalToConstant: 112.0).isActive = true
        passwordContainerView.bottomAnchor.constraint(equalTo: backgroundView.centerYAnchor).isActive = true
        loginBtn.centerXAnchor.constraint(equalTo: backgroundView.centerXAnchor).isActive = true
        
        view.addSubview(backgroundView)
        view.addSubview(centerLoadingView)
        view.addSubview(closeBtn)
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[closeBtn(50)]", metrics: nil, views: bindings))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[backgroundView]|", metrics: nil, views: bindings))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[backgroundView]|", metrics: nil, views: bindings))
        closeBtn.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor).isActive = true
        closeBtn.heightAnchor.constraint(equalTo: closeBtn.widthAnchor).isActive = true
        centerLoadingView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        centerLoadingView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        centerLoadingView.widthAnchor.constraint(equalToConstant: R.Constant.LoadingViewHeight).isActive = true
        
        usernameContainerView.transform = CGAffineTransform(translationX: 0, y: 200)
        usernameContainerView.alpha = 0.0
        passwordContainerView.transform = CGAffineTransform(translationX: 0, y: 200)
        passwordContainerView.alpha = 0.0
        
        if OnePasswordExtension.shared().isAppExtensionAvailable()
        {
            passwordTextFiled.rightView = onePasswordBtn
            passwordTextFiled.rightViewMode = .always
        }
        
        view.backgroundColor = .background
        NotificationCenter.default.addObserver(self, selector: #selector(textFieldTextDidChange), name: NSNotification.Name.UITextFieldTextDidChange, object: usernameTextFiled)
        NotificationCenter.default.addObserver(self, selector: #selector(textFieldTextDidChange), name: NSNotification.Name.UITextFieldTextDidChange, object: passwordTextFiled)
        NotificationCenter.default.addObserver(self, selector: #selector(handleContentSizeCategoryDidChanged), name: NSNotification.Name.UIContentSizeCategoryDidChange, object: nil)
    }

    @objc
    private func handleContentSizeCategoryDidChanged()
    {
        usernameTextFiled.font = R.Font.Medium
        passwordTextFiled.font = R.Font.Medium
        let normalLoginText = NSMutableAttributedString(string: R.String.Login, attributes: [NSFontAttributeName: R.Font.VeryLarge, NSForegroundColorAttributeName: UIColor.body])
        let disabledLoginText = NSMutableAttributedString(string: R.String.Login, attributes: [NSFontAttributeName: R.Font.VeryLarge, NSForegroundColorAttributeName: UIColor.gray])
        loginBtn.setAttributedTitle(normalLoginText, for: .normal)
        loginBtn.setAttributedTitle(disabledLoginText, for: .disabled)
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        let duration = 0.4
        UIView.animate(withDuration: duration, animations: {
            self.usernameContainerView.transform = CGAffineTransform.identity
            self.usernameContainerView.alpha = 1.0
            self.passwordContainerView.transform = CGAffineTransform.identity
            self.passwordContainerView.alpha = 1.0
            self.loginBtn.alpha = 1.0
        })
        usernameTextFiled.bendingLine.animateLineUp(withDuration: duration)
        passwordTextFiled.bendingLine.animateLineUp(withDuration: duration)
    }
    
    @objc
    private func usernameContainerViewTapped()
    {
        usernameTextFiled.becomeFirstResponder()
    }
    
    @objc
    private func passwordContainerViewTapped()
    {
        passwordTextFiled.becomeFirstResponder()
    }
    
    @objc
    private func closeBtnTapped()
    {
        loginRequest?.cancel()
        dismiss(animated: true, completion: nil)
    }
    
    @objc
    private func loginBtnTapped()
    {
        let username = usernameTextFiled.text!
        let password = passwordTextFiled.text!
        usernameTextFiled.resignFirstResponder()
        passwordTextFiled.resignFirstResponder()
        backgroundView.alpha = 0.3
        centerLoadingView.isHidden = false
        centerLoadingView.initSquaresNormalPostion()
        centerLoadingView.beginLoading()
        backgroundView.isUserInteractionEnabled = false
        loginRequest = V2Request.Account.Login(withUsername: username, password: password) { (response) in
            self.centerLoadingView.stopLoading(withSuccess: response.success, completion: { (success) in
                if success, let username = response.value, username.isEmpty == false
                {
                    // redeem
                    V2Request.Topic.getTabList { (response) in
                    }
                    NotificationCenter.default.post(name: NSNotification.Name.User.DidLogin, object: nil)
                    User.shared.username = username
                    UserDefaults.standard[R.Key.Username] = username
                    if let handler = self.successHandler
                    {
                        handler(username)
                    }
                    self.dismiss(animated: true, completion: nil)
                }
                else
                {
                    self.backgroundView.alpha = 1.0
                    self.centerLoadingView.isHidden = true
                    self.backgroundView .isUserInteractionEnabled = true
                }
            })
        }
    }
    
    @objc
    private func searchFromOnePassword(_ sender: UIButton)
    {
        OnePasswordExtension.shared().findLogin(forURLString: "v2ex.com", for: self, sender: onePasswordBtn) { (loginDictionary, errpr) -> Void in
            if let loginDictionary = loginDictionary, loginDictionary.count > 0
            {
                self.usernameTextFiled.text = loginDictionary[AppExtensionUsernameKey] as? String
                self.passwordTextFiled.text = loginDictionary[AppExtensionPasswordKey] as? String
                self.loginBtnTapped()
            }
        }
    }
    
    // MARK: - textFieldShouldReturn
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        if textField == usernameTextFiled
        {
            passwordTextFiled.becomeFirstResponder()
        }
        else if textField == passwordTextFiled
        {
            textField.resignFirstResponder()
        }
        return false
    }

    // MARK: - UITextFieldTextDidChangeNotification
    @objc
    private func textFieldTextDidChange()
    {
        if let username = usernameTextFiled.text, username.isEmpty == false,
            let password = passwordTextFiled.text, password.isEmpty == false
        {
            loginBtn.isEnabled = true
        }
        else
        {
            loginBtn.isEnabled = false
        }
    }

}
