//
//  InvitationRewardViewController.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/11/25.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit
import WebKit
import WKWebViewJavascriptBridge
import Photos

class InvitationRewardViewController: BaseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // 设置标题
        self.title = localLanguage(keyString: "wallet_invitatioin_reward_navigation_title")
        // 加载子View
        self.view.addSubview(detailView)
        
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
    override func back() {
        if self.detailView.webView.canGoBack == true {
            self.detailView.webView.goBack()
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    //子View
    private lazy var detailView : InvitationRewardView = {
        let view = InvitationRewardView.init()
        view.webView.navigationDelegate = self
        return view
    }()
    var needDismissViewController: Bool?
    var bridge: WKWebViewJavascriptBridge!
    private var callClosure: ((Bool)->Void)?
    func addWebListen() {
        bridge = WKWebViewJavascriptBridge.init(webView: detailView.webView)
        bridge.isLogEnable = true
        bridge.register(handlerName: "callNative") { [weak self] (paramters, callback) in
            if paramters!["method"] as? String == "save_picture" {
                if let dataString = (paramters!["params"] as? [String])?.first, dataString.isEmpty == false {
                    if let imageData = Data.init(base64Encoded: dataString, options: Data.Base64DecodingOptions.init(rawValue: 0)) {
                        let image = UIImage.init(data: imageData)
                        self?.loadImage(image: image!)
                        self?.callClosure  = { result in
                            if result == true {
                                callback?("{\"id\":\"\(String(describing: paramters!["id"]!))\",\"result\":\"success\"}")
                            } else {
                                callback?("{\"id\":\"\(String(describing: paramters!["id"]!))\",\"result\":\"failed\"}")
                            }
                        }
                    } else {
                        // 返回失败
                        callback?("{\"id\":\"\(String(describing: paramters!["id"]!))\",\"result\":\"failed\"}")
                    }
                }
            } else if paramters!["method"] as? String == "share_link" {
                if let dataString = (paramters!["params"] as? [String])?.first, dataString.isEmpty == false {
//                    UIPasteboard.general.string = dataString
//                    self?.detailView.makeToast(localLanguage(keyString: "wallet_copy_address_success_title"),
//                                               position: .center)
                    let activityVC = UIActivityViewController(activityItems: [dataString], applicationActivities: nil)
                        // 顯示出我們的 activityVC。
                        self?.present(activityVC, animated: true, completion: nil)
                }
            } else if paramters!["method"] as? String == "mine_invite" {
                // 我的邀请
                let vc = ProfitMainViewController()
                self?.navigationController?.pushViewController(vc, animated: true)
            } 
            print("testiOSCallback called: \(String(describing: paramters))")
//            callback?("{\"id\":\"\(String(describing: paramters!["id"]!))\",\"result\":\"success\"}")
        }
        //        bridge.call(handlerName: "callJavaScript", data: ["foo": "before ready"], callback: nil)
        //                        self?.bridge.call(handlerName: "callJavaScript", data: "{\"id\": \"\(String(describing: paramters!["id"]!))\",\"result\": \"failed\"}", callback: nil)
    }
    func loadImage(image:UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveImage(image:didFinishSavingWithError:contextInfo:)), nil)
    }
    @objc private func saveImage(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: AnyObject) {
        if error != nil {
            print("保存失败")
            if let call = self.callClosure {
                call(false)
            }
        } else {
            print("保存成功")
            if let call = self.callClosure {
                call(true)
            }
        }
    }
    deinit {
        print("InvitationRewardViewController销毁了")
    }
}
extension InvitationRewardViewController :WKNavigationDelegate{
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
