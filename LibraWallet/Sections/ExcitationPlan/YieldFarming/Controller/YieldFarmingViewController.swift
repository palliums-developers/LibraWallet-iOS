//
//  YieldFarmingViewController.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/12/4.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit
import WebKit
import WKWebViewJavascriptBridge

class YieldFarmingViewController: BaseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // 设置标题
//        self.title = localLanguage(keyString: "wallet_private_navigation_title")
        // 加载子View
        self.view.addSubview(detailView)
        
        let request = URLRequest.init(url: URL(string: self.requestURL!)!)
        detailView.webView.load(request)
        self.addWebListen()
        self.initKVO()
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
    deinit {
        print("YieldFarmingViewController销毁了")
    }
    override func back() {
        if needDismissViewController == true {
            self.dismiss(animated: true, completion: nil)
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    /// 子View
    lazy var detailView : YieldFarmingView = {
        let view = YieldFarmingView.init()
        view.webView.navigationDelegate = self
        return view
    }()
    /// 网络请求、数据模型
    private lazy var dataModel: YieldFarmingModel = {
        let model = YieldFarmingModel.init()
        return model
    }()
    var needDismissViewController: Bool?
    var requestURL: String?
    var bridge: WKWebViewJavascriptBridge!
    private var observer: NSKeyValueObservation?
//        = {
//        let bridge = WKWebViewJavascriptBridge.init(webView: detailView.webView)
//        bridge.isLogEnable = true
//        return bridge
//    }()
    var publishClosure: (()->Void)?
    var payTokenClosure: (()->Void)?
    func addWebListen() {
        bridge = WKWebViewJavascriptBridge.init(webView: detailView.webView)
        bridge.isLogEnable = true
        bridge.register(handlerName: "callNative") { [weak self] (paramters, callback) in
            if paramters!["method"] as? String == "checkFarmingRules" {
                // 查看规则
//                if let passwords = paramters!["params"] as? [String], passwords.isEmpty == false {
//                    do {
//                        let tempMenmonic = try WalletManager.getMnemonicFromKeychain(password: passwords[0])
//                        print(tempMenmonic)
//                        callback?("{\"id\":\"\(String(describing: paramters!["id"]!))\",\"result\":\"success\"}")
//                    } catch {
//                        callback?("{\"id\":\"\(String(describing: paramters!["id"]!))\",\"result\":\"failed\"}")
//                    }
//                }
            } else if paramters!["method"] as? String == "getPoolProfit" {
                // 提取资金池挖矿激励
//                if let passwords = paramters!["params"] as? [String], passwords.isEmpty == false {
//                    do {
//                        let tempMenmonic = try WalletManager.getMnemonicFromKeychain(password: passwords[0])
//                        print(tempMenmonic)
////                        self?.detailView.toastView?.show(tag: 99)
////                        self?.dataModel.publishToken(sendAddress: WalletManager.shared.walletAddress ?? "",
////                                                     mnemonic: tempMenmonic,
////                                                     modules: [passwords[1], passwords[2]])
//                        self?.publishClosure = {
//                            callback?("{\"id\":\"\(String(describing: paramters!["id"]!))\",\"result\":\"success\"}")
//                        }
//                    } catch {
//                        callback?("{\"id\":\"\(String(describing: paramters!["id"]!))\",\"result\":\"failed\"}")
//                    }
//                }
            } else if paramters!["method"] as? String == "getBankProfit" {
                // 提取银行挖矿激励
//                if let passwords = paramters!["params"] as? [String], passwords.isEmpty == false {
//                    do {
//                        let tempMenmonic = try WalletManager.getMnemonicFromKeychain(password: passwords[0])
//                        print(tempMenmonic)
////                        self?.detailView.toastView?.show(tag: 99)
////                        self?.dataModel.sendTransaction(sendAddress: WalletManager.shared.walletAddress ?? "",
////                                                        receiveAddress: passwords[1],
////                                                        amount: NSDecimalNumber.init(string: passwords[3]).uint64Value,
////                                                        fee: 1,
////                                                        mnemonic: tempMenmonic,
////                                                        module: passwords[2])
//                        self?.payTokenClosure = {
//                            callback?("{\"id\":\"\(String(describing: paramters!["id"]!))\",\"result\":\"success\"}")
//                        }
//                    } catch {
//                        callback?("{\"id\":\"\(String(describing: paramters!["id"]!))\",\"result\":\"failed\"}")
//                    }
//                }
            } else if paramters!["method"] as? String == "isNewAccount" {
                // 新用户检查
//                if self?.needDismissViewController == true {
//                    self?.dismiss(animated: true, completion: nil)
//                } else {
//                    self?.navigationController?.popViewController(animated: true)
//                }
            } else if paramters!["method"] as? String == "assignmentIP" {
//                if let contents = paramters!["params"] as? [String], contents.isEmpty == false, contents.count == 2 {
//                    guard contents[0].isEmpty == false else {
//                        callback?("{\"id\":\"\(String(describing: paramters!["id"]!))\",\"result\":\"failed\"}")
//                        return
//                    }
//                    guard contents[1].isEmpty == false else {
//                        callback?("{\"id\":\"\(String(describing: paramters!["id"]!))\",\"result\":\"failed\"}")
//                        return
//                    }
////                    let vc = AuthorizedIPViewController()
////                    vc.IPID = contents[0]
////                    vc.moduleName = contents[1]
////                    self?.navigationController?.pushViewController(vc, animated: true)
//                }
            } else if paramters!["method"] as? String == "isNewAccount" {
                // 新用户检查
//                if self?.needDismissViewController == true {
//                    self?.dismiss(animated: true, completion: nil)
//                } else {
//                    self?.navigationController?.popViewController(animated: true)
//                }
            } else if paramters!["method"] as? String == "inviteFriend" {
                // 邀请好友
//                if self?.needDismissViewController == true {
//                    self?.dismiss(animated: true, completion: nil)
//                } else {
//                    self?.navigationController?.popViewController(animated: true)
//                }
            } else if paramters!["method"] as? String == "PoolFarming" {
                // 资金池挖矿
//                if self?.needDismissViewController == true {
//                    self?.dismiss(animated: true, completion: nil)
//                } else {
//                    self?.navigationController?.popViewController(animated: true)
//                }
            } else if paramters!["method"] as? String == "loanFarming" {
                // 借款挖矿
//                if self?.needDismissViewController == true {
//                    self?.dismiss(animated: true, completion: nil)
//                } else {
//                    self?.navigationController?.popViewController(animated: true)
//                }
            } else if paramters!["method"] as? String == "depositFarming" {
                // 存款挖矿
//                if self?.needDismissViewController == true {
//                    self?.dismiss(animated: true, completion: nil)
//                } else {
//                    self?.navigationController?.popViewController(animated: true)
//                }
            } else if paramters!["method"] as? String == "ProfitList" {
                // 收益排行榜
//                if self?.needDismissViewController == true {
//                    self?.dismiss(animated: true, completion: nil)
//                } else {
//                    self?.navigationController?.popViewController(animated: true)
//                }
            }
            print("testiOSCallback called: \(String(describing: paramters))")
            callback?("Response from testiOSCallback")
        }
        //        bridge.call(handlerName: "callJavaScript", data: ["foo": "before ready"], callback: nil)
        //                        self?.bridge.call(handlerName: "callJavaScript", data: "{\"id\": \"\(String(describing: paramters!["id"]!))\",\"result\": \"failed\"}", callback: nil)
    }
}
extension YieldFarmingViewController :WKNavigationDelegate{
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
extension YieldFarmingViewController {
    func initKVO() {
        self.observer = dataModel.observe(\.dataDic, options: [.new], changeHandler: { [weak self](model, change) in
            guard let dataDic = change.newValue, dataDic.count != 0 else {
                self?.detailView.hideToastActivity()
                self?.endLoading()
                return
            }
            if let error = dataDic.value(forKey: "error") as? LibraWalletError {
                if error.localizedDescription == LibraWalletError.WalletRequest(reason: .networkInvalid).localizedDescription {
                    // 网络无法访问
                    print(error.localizedDescription)
                    self?.detailView.makeToast(LibraWalletError.WalletRequest(reason: .networkInvalid).localizedDescription, position: .center)
                } else if error.localizedDescription == LibraWalletError.WalletRequest(reason: .walletVersionExpired).localizedDescription {
                    // 版本太久
                    print(error.localizedDescription)
                    self?.detailView.makeToast("版本太旧,请及时更新版本", position: .center)
                } else if error.localizedDescription == LibraWalletError.WalletRequest(reason: .parseJsonError).localizedDescription {
                    // 解析失败
                    print(error.localizedDescription)
                } else if error.localizedDescription == LibraWalletError.WalletRequest(reason: .dataEmpty).localizedDescription {
                    print(error.localizedDescription)
                    // 数据为空
                    self?.detailView.makeToast(LibraWalletError.WalletRequest(reason: .dataEmpty).localizedDescription, position: .center)
                    self?.detailView.hideToastActivity()
                } else if error.localizedDescription == LibraWalletError.WalletRequest(reason: .noMoreData).localizedDescription {
                    print(error.localizedDescription)
                } else if error.localizedDescription == LibraWalletError.WalletRequest(reason: .dataCodeInvalid).localizedDescription {
                    print(error.localizedDescription)
                    // 数据状态异常
                    self?.detailView.makeToast(LibraWalletError.WalletRequest(reason: .dataCodeInvalid).localizedDescription, position: .center)
                }
                self?.detailView.toastView?.hide(tag: 99)
//                self?.endLoading(animated: true, error: nil, completion: nil)
                return
            }
            let type = dataDic.value(forKey: "type") as! String
            if type == "PublishToken" {
                self?.detailView.toastView?.hide(tag: 99)
                if let action = self?.publishClosure {
                    action()
                }
            } else if type == "SendPayTokenTransaction" {
                self?.detailView.toastView?.hide(tag: 99)
                if let action = self?.payTokenClosure {
                    action()
                }
            }
            self?.detailView.hideToastActivity()
        })
    }
}
