//
//  MessageWebDetailViewController.swift
//  LibraWallet
//
//  Created by wangyingdong on 2021/1/12.
//  Copyright © 2021 palliums. All rights reserved.
//

import UIKit
import WebKit

class MessageWebDetailViewController: BaseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // 设置标题
        self.title = localLanguage(keyString: "wallet_notification_system_message_detail_navigation_title")
        // 加载子View
        self.view.addSubview(detailView)
        self.requetData()
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        detailView.snp.makeConstraints { (make) in
            if #available(iOS 11.0, *) {
                make.top.bottom.equalTo(self.view.safeAreaLayoutGuide)
            } else {
                make.top.bottom.equalTo(self.view)
            }
            make.left.right.equalTo(self.view)
        }
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if let action = self.successLoadClosure {
            action()
        }
    }
    deinit {
        print("MessageWebDetailViewController销毁了")
    }
    //子View
    private lazy var detailView : MessageWebDetailView = {
        let view = MessageWebDetailView.init()
        view.webView.navigationDelegate = self
        return view
    }()
    /// 网络请求、数据模型
    lazy var dataModel: MessageWebDetailModel = {
        let model = MessageWebDetailModel.init()
        return model
    }()
    var successLoadClosure: (()->Void)?
    func requetData() {
        self.view.makeToastActivity(.center)
        guard let tempMessageID = messageID, messageID?.isEmpty == false else {
            return
        }
        self.dataModel.getWalletMessageDetail(address: Wallet.shared.violasAddress ?? "", token: getRequestToken(), id: tempMessageID) { [weak self] (result) in
            switch result {
            case let .success(model):
                self?.detailView.model = model
            case let .failure(error):
                self?.detailView.hideToastActivity()
                self?.handleError(requestType: "", error: error)
            }
            self?.endLoading()
        }
    }
    var messageID: String?
}
// MARK: - 网络请求数据处理
extension MessageWebDetailViewController {
    func handleError(requestType: String, error: LibraWalletError) {
        switch error {
        case .WalletRequest(reason: .networkInvalid):
            // 网络无法访问
            print(error.localizedDescription)
        case .WalletRequest(reason: .walletVersionExpired):
            // 版本太久
            print(error.localizedDescription)
        case .WalletRequest(reason: .parseJsonError):
            // 解析失败
            print(error.localizedDescription)
        case .WalletRequest(reason: .dataCodeInvalid):
            // 数据状态异常
            print(error.localizedDescription)
        default:
            // 其他错误
            print(error.localizedDescription)
        }
        self.view?.makeToast(error.localizedDescription, position: .center)
    }
}
extension MessageWebDetailViewController :WKNavigationDelegate{
    // 页面开始加载时调用
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        self.view.makeToastActivity(.center)
    }
    // 当内容开始返回时调用
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        
    }
    // 页面加载完成之后调用
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.view.hideToastActivity()
    }
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print(error)
    }
    // 页面加载失败时调用
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        /// 弹出提示框点击确定返回
        self.view.hideToastActivity()
        guard error.localizedDescription.hasSuffix("code = -999") else {
            return
        }
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
