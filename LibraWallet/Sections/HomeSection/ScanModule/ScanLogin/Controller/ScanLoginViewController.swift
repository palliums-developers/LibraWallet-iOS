//
//  ScanLoginViewController.swift
//  SSO
//
//  Created by wangyingdong on 2020/3/16.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit
import Toast_Swift
class ScanLoginViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(detailView)
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        detailView.snp.makeConstraints { (make) in
            if #available(iOS 11.0, *) {
                make.top.equalTo(self.view.safeAreaLayoutGuide)
            } else {
                make.top.equalTo(self.view)
            }
            make.left.right.bottom.equalTo(self.view)
        }
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if needReject == true {
            if let connect = WalletConnectManager.shared.connect {
                connect(false)
            }
            if let rejectC = self.reject {
                rejectC()
            }
        }
    }
    deinit {
        print("ScanLoginViewController销毁了")
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.barStyle = .default
    }
    private lazy var detailView : ScanLoginView = {
        let view = ScanLoginView.init()
        view.delegate = self
        return view
    }()
    lazy var dataModel: ScanLoginModel = {
        let model = ScanLoginModel.init()
        return model
    }()
    var wallet: Token?
    /// 数据监听KVO
    var observer: NSKeyValueObservation?
    var sessionID: String?
    private var reject: (() -> Void)?
    private var confirm: ((String) -> Void)?
    var needReject: Bool? = true
    var hasLogin: Bool?
}
extension ScanLoginViewController: ScanLoginViewDelegate {
    func openUserAgreement() {
        let vc = ServiceLegalViewController()
        vc.needDismissViewController = true
        let navi = UINavigationController.init(rootViewController: vc)
        self.present(navi, animated: true, completion: nil)
    }
    
    func openPrivateAgreement() {
        let vc = PrivateLegalViewController()
        vc.needDismissViewController = true
        let navi = UINavigationController.init(rootViewController: vc)
        self.present(navi, animated: true, completion: nil)
    }
    
    func cancelLogin() {
        self.dismiss(animated: true, completion:  {
            if let connect = WalletConnectManager.shared.connect {
                connect(false)
            }
            if let rejectC = self.reject {
               rejectC()
            }
        })
        self.needReject = false
    }
    func confirmLogin(password: String) {
        NSLog("Password:\(password)")
        self.detailView.toastView?.show(tag: 99)
        if let connect = WalletConnectManager.shared.connect {
            connect(true)
        }
        self.needReject = false
        WalletConnectManager.shared.didConnectClosure = {
            self.detailView.toastView?.hide(tag: 99)
            self.view.makeToast(localLanguage(keyString: "wallet_scan_login_alert_success_title"), duration: toastDuration, position: .center, title: nil, image: nil, style: ToastManager.shared.style, completion: { (bool) in
                self.dismiss(animated: true, completion: nil)
            })
        }
    }
}
