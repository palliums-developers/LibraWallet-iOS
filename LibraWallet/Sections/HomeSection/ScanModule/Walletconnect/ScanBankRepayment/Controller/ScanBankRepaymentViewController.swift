//
//  ScanBankRepaymentViewController.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/9/14.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit
import Toast

class ScanBankRepaymentViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(detailView)
        self.initKVO()
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
            if let rejectC = self.reject {
                rejectC()
            }
        }
    }
    deinit {
        print("ScanBankRepaymentViewController销毁了")
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.barStyle = .default
    }
    private lazy var detailView : ScanBankRepaymentView = {
        let view = ScanBankRepaymentView.init()
        view.delegate = self
        return view
    }()
    lazy var dataModel: ScanBankRepaymentModel = {
        let model = ScanBankRepaymentModel.init()
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
    var confirm: ((Result<String, NSError>) -> Void)?
    var needReject: Bool? = true
    var submitTransaction: Bool = true
}
extension ScanBankRepaymentViewController {
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
                self?.detailView.toastView.hide(tag: 99)
                self?.detailView.hideToastActivity()
                self?.detailView.makeToast(error.localizedDescription, position: .center)
                return
            }
            if type == "SendViolasBankRepaymentTransaction" {
                self?.detailView.toastView.hide(tag: 99)
                self?.view.makeToast(localLanguage(keyString: "wallet_bank_deposit_submit_successful"), duration: toastDuration, position: .center, title: nil, image: nil, style: ToastManager.shared.style, completion: { (bool) in
                    self?.needReject = false
                    if let confirmAction = self?.confirm {
                        if self?.submitTransaction == true {
                            confirmAction(.success("success"))
                        } else {
                            guard let tempData = dataDic.value(forKey: "data") as? String else {
                                return
                            }
                            confirmAction(.success(tempData))
                        }
                    }
                    self?.dismiss(animated: true, completion: nil)
                })
            }
        })
    }
}

extension ScanBankRepaymentViewController: ScanSendTransactionViewDelegate {
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
            WalletManager.unlockWallet(controller: self) { [weak self] (result) in
                switch result {
                case let .success(mnemonic):
                    self?.detailView.toastView.show(tag: 99)
                    self?.dataModel.sendWithdrawTransaction(model: raw,
                                                            mnemonic: mnemonic,
                                                            submitTransaction: self?.submitTransaction ?? true)
                case let .failure(error):
                    guard error.localizedDescription != "Cancel" else {
                        self?.detailView.toastView.hide(tag: 99)
                        return
                    }
                    self?.view?.makeToast(error.localizedDescription, position: .center)
                }
            }
        } else {
            if let confirmAction = self.confirm {
                let error = NSError.init(domain: "Parameter invalid", code: -32602, userInfo: nil)
                confirmAction(.failure(error))
            }
        }
        self.needReject = false
    }
}
