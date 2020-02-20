//
//  HelpCenterViewController.swift
//  HKWallet
//
//  Created by palliums on 2019/8/9.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit
import WebKit
class HelpCenterViewController: BaseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // 初始化本地配置
//        self.setBaseControlllerConfig()
        // 设置标题
        self.title = localLanguage(keyString: "wallet_feedback_navigation_title")
        // 加载子View
        self.view.addSubview(detailView)
        // 添加NavigationRightBar
        self.addNavigationRightBar()
        // 初始化KVO
        initKVO()
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        detailView.snp.makeConstraints { (make) in
            make.top.left.right.bottom.equalTo(self.view)
        }
    }
    func addNavigationRightBar() {
        // 自定义导航栏的UIBarButtonItem类型的按钮
        let backView = UIBarButtonItem(customView: feedbackButton)
        // 重要方法，用来调整自定义返回view距离左边的距离
        let barButtonItem = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        barButtonItem.width = 5
        // 返回按钮设置成功
        self.navigationItem.rightBarButtonItems = [barButtonItem, backView]
    }
    //网络请求、数据模型
    lazy var dataModel: HelpCenterModel = {
        let model = HelpCenterModel.init()
        return model
    }()
    //子View
    private lazy var detailView : HelpCenterView = {
        let view = HelpCenterView.init()
        view.webView.navigationDelegate = self
        return view
    }()
    lazy var feedbackButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle(localLanguage(keyString: "wallet_about_us_navigation_right_bar_title"), for: .normal)
        button.setTitleColor(UIColor.init(hex: "492AC5"), for: UIControl.State.normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 16), weight: UIFont.Weight.regular)
        button.addTarget(self, action: #selector(feedback), for: .touchUpInside)
        return button
    }()
    deinit {
        print("HelpCenterViewController销毁了")
    }
    var alert: FeedbackAlert?
    @objc func feedback() {
        alert = FeedbackAlert.init { (content, contact) in
//            self.dataModel.feedback(uid: WalletData.wallet.walletUID!, content: content, contact: contact)
        }
        alert?.show()
    }
    var myContext = 0
}
extension HelpCenterViewController {
    //MARK: - KVO
    func initKVO() {
        dataModel.addObserver(self, forKeyPath: "dataDic", options: NSKeyValueObservingOptions.new, context: &myContext)
    }
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?)  {
        guard context == &myContext else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }
        guard (change?[NSKeyValueChangeKey.newKey]) != nil else {
            return
        }
        guard let jsonData = (object! as AnyObject).value(forKey: "dataDic") as? NSDictionary else {
            return
        }
        if let error = jsonData.value(forKey: "error") as? LibraWalletError {
            if error.localizedDescription == LibraWalletError.WalletRequest(reason: .networkInvalid).localizedDescription {
                // 网络无法访问
                print(error.localizedDescription)
            } else if error.localizedDescription == LibraWalletError.WalletRequest(reason: .walletVersionExpired).localizedDescription {
                // 版本太久
                print(error.localizedDescription)
            } else if error.localizedDescription == LibraWalletError.WalletRequest(reason: .parseJsonError).localizedDescription {
                // 解析失败
                print(error.localizedDescription)
            } else if error.localizedDescription == LibraWalletError.WalletRequest(reason: .dataEmpty).localizedDescription {
                print(error.localizedDescription)
                // 数据为空
            }
            //wallet_pay_failed_title = "付款失败"
            alert?.hideToastActivity()
            alert?.makeToast(error.localizedDescription, position: .center)
            return
        }
        let type = jsonData.value(forKey: "type") as! String
        if type == "Feedback" {
            alert?.hideToastActivity()
            alert?.hide()
            self.navigationController?.popViewController(animated: true)
        }
        self.view.hideToastActivity()
    }
}
extension HelpCenterViewController :WKNavigationDelegate{
    // 页面开始加载时调用
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!){
        self.view.makeToastActivity(.center)
    }
    // 当内容开始返回时调用
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!){
        
    }
    // 页面加载完成之后调用
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!){
        self.view.hideToastActivity()
        
    }
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print(error)
    }
    // 页面加载失败时调用
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        /// 弹出提示框点击确定返回
        self.view.hideToastActivity()
        let alertView = UIAlertController.init(title: localLanguage(keyString: "wallet_service_legal_loaded_error_title"),
                                               message: nil,
                                               preferredStyle: .alert)
        let okAction = UIAlertAction.init(title:localLanguage(keyString: "wallet_service_legal_loaded_error_cancel_button_title"),
                                          style: .default) { okAction in
            _=self.navigationController?.popViewController(animated: true)
        }
        alertView.addAction(okAction)
        self.present(alertView, animated: true, completion: nil)
    }
    
    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if(challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust) {
            let cred = URLCredential(trust: challenge.protectionSpace.serverTrust!)
            completionHandler(.useCredential, cred)
        } else {
            completionHandler(.performDefaultHandling, nil)
        }
    }
}

