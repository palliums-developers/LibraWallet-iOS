//
//  TransactionDetailWebViewController.swift
//  LibraWallet
//
//  Created by palliums on 2019/9/17.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit
import WebKit
class TransactionDetailWebViewController: BaseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // 设置标题
//        self.title = localLanguage(keyString: "wallet_setting_help_center_navigationbar_title")
        // 加载子View
        self.view.addSubview(detailView)
        guard let url = self.requestURL else {
            return
        }
        let urlRequest = URLRequest.init(url: URL(string: url)!)
        detailView.webView.load(urlRequest)
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        detailView.snp.makeConstraints { (make) in
            make.top.left.right.bottom.equalTo(self.view)
        }
    }
    //子View
    private lazy var detailView : TransactionDetailWebView = {
        let view = TransactionDetailWebView.init()
        view.webView.navigationDelegate = self
        return view
    }()
    deinit {
        print("TransactionDetailWebViewController销毁了")
    }
    var requestURL: String?
}
extension TransactionDetailWebViewController :WKNavigationDelegate {
    // 页面开始加载时调用
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!){
//        self.view.makeToastActivity(.center)
//        self.detailView.toastView?.show()
    }
    // 当内容开始返回时调用
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!){
        
    }
    // 页面加载完成之后调用
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!){
//        self.view.hideToastActivity()
//        self.detailView.toastView?.hide()
        self.title = webView.title
    }
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
//        print(error)
//        self.detailView.toastView?.hide()
    }
    // 页面加载失败时调用
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        /// 弹出提示框点击确定返回
//        self.view.hideToastActivity()
//        self.detailView.toastView?.hide()
//        let alertView = UIAlertController.init(title: localLanguage(keyString: "wallet_withdraw_address_alert_title"),
//                                               message: HKWalletError.WalletLoadURLError(reason: .loadFailed).localizedDescription,
//                                               preferredStyle: .alert)
//        let okAction = UIAlertAction.init(title:localLanguage(keyString: "wallet_withdraw_address_alert_confirm_button_title"),
//                                          style: .default) { okAction in
//                                            _=self.navigationController?.popViewController(animated: true)
//        }
//        alertView.addAction(okAction)
//        self.present(alertView, animated: true, completion: nil)
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
