//
//  ScanSendRawTransactionViewController.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/5/21.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit
import Toast_Swift
class ScanSendRawTransactionViewController: BaseViewController {
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
        print("ScanSendRawTransactionViewController销毁了")
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.barStyle = .default
    }
    private lazy var detailView : ScanSendRawTransactionView = {
        let view = ScanSendRawTransactionView.init()
        view.delegate = self
        return view
    }()
    lazy var dataModel: ScanSendRawTransactionModel = {
        let model = ScanSendRawTransactionModel.init()
        return model
    }()
    var wallet: Token?
    /// 数据监听KVO
    var observer: NSKeyValueObservation?
    var transactionHex: String? {
        didSet {
            self.detailView.model = ViolasManager.derializeTransaction(tx: transactionHex ?? "")
        }
    }
    var reject: (() -> Void)?
    var needReject: Bool? = true
}
extension ScanSendRawTransactionViewController {
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
                self?.detailView.toastView?.hide(tag: 99)
                self?.detailView.hideToastActivity()
                self?.detailView.makeToast(error.localizedDescription, position: .center)
                return
            }
            if type == "SendViolasTransaction" {
                self?.detailView.toastView?.hide(tag: 99)
                self?.view.makeToast(localLanguage(keyString: "wallet_transfer_success_alert"), duration: toastDuration, position: .center, title: nil, image: nil, style: ToastManager.shared.style, completion: { (bool) in
                    self?.needReject = false
                    self?.dismiss(animated: true, completion: nil)
                })
            }
        })
    }
}

extension ScanSendRawTransactionViewController: ScanSendRawTransactionViewDelegate {
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
        if let tx = self.transactionHex, tx.isEmpty == false {
            self.detailView.toastView?.show(tag: 99)
            self.dataModel.sendTransaction(tx: tx)
        } else {
            #warning("报错待处理")
        }
        self.needReject = false
    }
}
