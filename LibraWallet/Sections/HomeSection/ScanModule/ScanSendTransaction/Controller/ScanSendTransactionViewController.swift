//
//  ScanSendTransactionViewController.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/5/21.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit
import Toast_Swift
class ScanSendTransactionViewController: BaseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(detailView)
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
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if needReject == true {
            if let rejectC = self.reject {
                rejectC()
            }
        }
    }
    deinit {
        print("ScanSendTransactionViewController销毁了")
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.barStyle = .default
    }
    private lazy var detailView : ScanSendTransactionView = {
        let view = ScanSendTransactionView.init()
        view.delegate = self
        return view
    }()
    lazy var dataModel: ScanSendTransactionModel = {
        let model = ScanSendTransactionModel.init()
        return model
    }()
    /// 数据监听KVO
    var observer: NSKeyValueObservation?
    var model: WCRawTransaction? {
        didSet {
            self.detailView.model = model
        }
    }
    var reject: (() -> Void)?
    var needReject: Bool? = true
}
extension ScanSendTransactionViewController {
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
                self?.detailView.toastView?.hide()
                self?.detailView.hideToastActivity()
                self?.detailView.makeToast(error.localizedDescription, position: .center)
                return
            }
            if type == "SendViolasTransaction" {
                self?.detailView.toastView?.hide()
                self?.view.makeToast(localLanguage(keyString: "wallet_scan_login_alert_success_title"), duration: toastDuration, position: .center, title: nil, image: nil, style: ToastManager.shared.style, completion: { (bool) in
                    self?.needReject = false
                    self?.dismiss(animated: true, completion: nil)
                })
            }
        })
    }
}

extension ScanSendTransactionViewController: ScanSendTransactionViewDelegate {
    func cancelLogin() {
        self.dismiss(animated: true, completion: {
            if let rejectC = self.reject {
                rejectC()
            }
        })
        self.needReject = false
    }
    func confirmLogin(password: String) {
        NSLog("Password:\(password)")
        if let raw = self.model {
//            if LibraWalletManager.shared.walletBiometricLock == true {
//                KeychainManager().getPasswordWithBiometric(walletAddress: "Violas_" + (raw.from ?? "")) { [weak self](result, error) in
//                    if result.isEmpty == false {
//                        do {
//                            let mnemonic = try LibraWalletManager.shared.getMnemonicFromKeychain(password: result, walletRootAddress: LibraWalletManager.shared.walletRootAddress ?? "")
//                            self?.detailView.toastView?.show()
//                            self?   .dataModel.sendViolasTransaction(model: raw, mnemonic: mnemonic)
//                        } catch {
//                            self?.detailView.makeToast(error.localizedDescription, position: .center)
//                        }
//                        
//                    } else {
//                        self?.detailView.makeToast(error, position: .center)
//                    }
//                }
//            } else {
//                let alert = passowordAlert(rootAddress: "Violas_" + (raw.from ?? ""), mnemonic: { [weak self] (mnemonic) in
//                    self?.detailView.toastView?.show()
//                    self?.dataModel.sendViolasTransaction(model: raw, mnemonic: mnemonic)
//                }) { [weak self] (errorContent) in
//                    guard errorContent != "Cancel" else {
//                        self?.detailView.toastView?.hide()
//                        return
//                    }
//                    self?.view.makeToast(errorContent, position: .center)
//                }
//                self.present(alert, animated: true, completion: nil)
//
//            }
        } else {
            #warning("报错待处理")
        }
    }
}
