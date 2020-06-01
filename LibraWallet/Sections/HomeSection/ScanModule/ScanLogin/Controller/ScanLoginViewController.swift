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
                make.top.bottom.equalTo(self.view.safeAreaLayoutGuide)
            } else {
                make.top.bottom.equalTo(self.view)
            }
            make.left.right.equalTo(self.view)
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
    var wallet: LibraWalletManager?
    var vtokenModel: ViolasTokenModel?
    /// 数据监听KVO
    var observer: NSKeyValueObservation?
    var sessionID: String?
    private var reject: (() -> Void)?
    private var confirm: ((String) -> Void)?
    var needReject: Bool? = true
    var hasLogin: Bool?
}
extension ScanLoginViewController {
    func initKVO() {
        self.observer = dataModel.observe(\.dataDic, options: [.new], changeHandler: { [weak self](model, change) in
            guard let dataDic = change.newValue, dataDic.count != 0 else {
                self?.detailView.hideToastActivity()
//                self?.endLoading()
                return
            }
            let type = dataDic.value(forKey: "type") as! String
            if let error = dataDic.value(forKey: "error") as? LibraWalletError {
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
                } else if error.localizedDescription == LibraWalletError.WalletRequest(reason: .dataCodeInvalid).localizedDescription {
                    print(error.localizedDescription)
                    // 数据返回状态异常
                }
                self?.detailView.hideToastActivity()
//                self?.detailView.toastView?.hide(tag: 199)
                self?.detailView.makeToast(error.localizedDescription, position: .center)
                return
            }
            if type == "ScanLogin" {
//                self?.detailView.toastView?.hide(tag: 199)
                self?.view.makeToast(localLanguage(keyString: "wallet_scan_login_alert_success_title"), duration: toastDuration, position: .center, title: nil, image: nil, style: ToastManager.shared.style, completion: { (bool) in
                    self?.dismiss(animated: true, completion: nil)
                })
            }
        })
    }
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
        self.detailView.toastView?.show()
        if let connect = WalletConnectManager.shared.connect {
            connect(true)
        }
        WalletConnectManager.shared.didConnectClosure = {
            self.detailView.toastView?.hide()
            self.view.makeToast(localLanguage(keyString: "wallet_scan_login_alert_success_title"), duration: toastDuration, position: .center, title: nil, image: nil, style: ToastManager.shared.style, completion: { (bool) in
                self.dismiss(animated: true, completion: nil)
            })
        }
    }
}
