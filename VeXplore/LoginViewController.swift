//
//  LoginViewController.swift
//  VeXplore
//
//  Copyright © 2016 Jimmy. All rights reserved.
//

import SharedKit

class LoginViewController: SwipeTransitionViewController, UIWebViewDelegate
{
    lazy var contentWebView: UIWebView = {
        let webView = UIWebView()
        webView.allowsLinkPreview = true // enable link 3D touch
        webView.delegate = self
        
        return webView
    }()
    
    var successHandler: ((String) -> Void)?
 
    override func viewDidLoad()
    {
        super.viewDidLoad()
        navigationItem.title = R.String.Login

        view = contentWebView
        let closeBtn = UIBarButtonItem(image: R.Image.Close, style: .plain, target: self, action: #selector(closeBtnTapped))
        navigationItem.leftBarButtonItem = closeBtn
        
        let onePasswordBtn = UIBarButtonItem(image: R.Image.Onepassword, style: .plain, target: self, action: #selector(searchFromOnePassword(_:)))
        navigationItem.rightBarButtonItem = onePasswordBtn

        let loginURLString = R.String.BaseUrl + "/signin"
        if let loginURL = try? loginURLString.toURL()
        {
            let request = URLRequest(url: loginURL)
            contentWebView.loadRequest(request)
        }
    }
    
    @objc
    private func closeBtnTapped()
    {
        contentWebView.stopLoading()
        dismiss(animated: true, completion: nil)
    }
    
    @objc
    private func searchFromOnePassword(_ sender: UIButton)
    {
        OnePasswordExtension.shared().fillItem(intoWebView: contentWebView, for: self, sender: sender, showOnlyLogins: true, completion: nil)
    }
    
    // MARK: - UIWebViewDelegate
    func webViewDidFinishLoad(_ webView: UIWebView)
    {
        notifyUser()
        recognizeCaptcha()
        verifyLoginStatus()
    }
    
    private func notifyUser()
    {
        let replaceScript = isPad ? "document.querySelector('#Main > div.box > div.cell > form > table > tbody > tr:nth-child(3) > td:nth-child(1)').innerHTML='若验证码识别不准确，可摇一摇重新识别'" : "document.querySelector('#Wrapper > div > div:nth-child(1) > div.cell > form > table > tbody > tr:nth-child(4) > td:nth-child(1)').innerHTML='若验证码识别不准确，可摇一摇重新识别'"
        contentWebView.stringByEvaluatingJavaScript(from: replaceScript)
    }
    
    private func recognizeCaptcha()
    {
        let captchaScript = isPad ? "document.querySelector('#Main > div.box > div.cell > form > table > tbody > tr:nth-child(3) > td:nth-child(2) > div:nth-child(1)').style.backgroundImage.slice(4, -1)" : "document.querySelector('#Wrapper > div > div:nth-child(1) > div.cell > form > table > tbody > tr:nth-child(3) > td > div').style.backgroundImage.slice(4, -1)"
        if let captchaURLString = contentWebView.stringByEvaluatingJavaScript(from: captchaScript),
            captchaURLString.contains("/_captcha?once=")
        {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            V2Request.OCR.recognize(captchaURLString: captchaURLString, completion: { (success, captcha) in
                if success
                {
                    let fillCaptchaScript = String(format: isPad ? "document.querySelector('#Main > div.box > div.cell > form > table > tbody > tr:nth-child(3) > td:nth-child(2) > input').value='%@'" : "document.querySelector('#Wrapper > div > div:nth-child(1) > div.cell > form > table > tbody > tr:nth-child(4) > td:nth-child(2) > input').value='%@'", captcha)
                    self.contentWebView.stringByEvaluatingJavaScript(from: fillCaptchaScript)
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
                else
                {
                    self.recognizeCaptcha()
                }
            })
        }
    }
    
    private func verifyLoginStatus()
    {
        let notificationsSript = "document.querySelectorAll(\"a[href^='/settings']\").length>0"
        let usernamesSript = "document.querySelectorAll(\"a[href^='/member/']\")[0].href.split('/').pop()"
        if let isLogin = contentWebView.stringByEvaluatingJavaScript(from: notificationsSript)?.boolValue,
            isLogin == true,
            let username = contentWebView.stringByEvaluatingJavaScript(from: usernamesSript),
            username.count > 0
        {
            // daily redeem
            V2Request.Topic.getTabList { (response) in
            }
            NotificationCenter.default.post(name: NSNotification.Name.User.DidLogin, object: nil)
            User.shared.username = username
            UserDefaults.standard[R.Key.Username] = username
            self.successHandler?(username)
            self.dismiss(animated: true, completion: nil)
        }
    }

    // MARK: - Shake
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?)
    {
        recognizeCaptcha()
    }
    
}
