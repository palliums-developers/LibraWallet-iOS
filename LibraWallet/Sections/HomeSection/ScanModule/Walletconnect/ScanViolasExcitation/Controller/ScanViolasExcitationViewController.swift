//
//  ScanViolasExcitationViewController.swift
//  LibraWallet
//
//  Created by wangyingdong on 2021/4/13.
//  Copyright © 2021 palliums. All rights reserved.
//

import UIKit
import Toast_Swift

class ScanViolasExcitationViewController: UIViewController {
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
            if let rejectC = self.reject {
                rejectC()
            }
        }
    }
    deinit {
        print("ScanViolasExcitationViewController销毁了")
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.barStyle = .default
    }
    private lazy var detailView : ScanViolasExcitationView = {
        let view = ScanViolasExcitationView.init()
        view.delegate = self
        return view
    }()
    lazy var dataModel: ScanViolasExcitationModel = {
        let model = ScanViolasExcitationModel.init()
        return model
    }()
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
extension ScanViolasExcitationViewController: ScanSendTransactionViewDelegate {
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
                    self?.request(address: (raw.from ?? ""), mnemonic: mnemonic)
                case let .failure(error):
                    guard error.localizedDescription != "Cancel" else {
                        self?.detailView.toastView.hide(tag: 99)
                        return
                    }
                    self?.detailView.makeToast(error.localizedDescription, position: .center)
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
    func request(address: String, mnemonic: [String]) {
        switch self.model?.payload?.code {
        case ViolasManager.getLocalMoveCode(bundle: "MarketContracts", contract: "withdraw_mine_reward"):
            self.dataModel.sendMarketExtractProfit(sendAddress: address, mnemonic: mnemonic) { [weak self] (result) in
                self?.detailView.toastView.hide(tag: 99)
                switch result {
                case .success(_):
                    self?.view.makeToast(localLanguage(keyString: "wallet_transaction_submit_success_content"), duration: toastDuration, position: .center, title: nil, image: nil, style: ToastManager.shared.style, completion: { (bool) in
                        self?.needReject = false
                        if let confirmAction = self?.confirm {
                            confirmAction(.success("success"))
                        }
                        self?.dismiss(animated: true, completion: nil)
                    })
                case let .failure(error):
                    self?.detailView.makeToast(error.localizedDescription, position: .center)
                }
            }
        case ViolasManager.getLocalMoveCode(bundle: "BankContracts", contract: "claim_incentive"):
            self.dataModel.sendBankExtractProfit(sendAddress: address, mnemonic: mnemonic) { [weak self] (result) in
                self?.detailView.toastView.hide(tag: 99)
                switch result {
                case .success(_):
                    self?.view.makeToast(localLanguage(keyString: "wallet_transaction_submit_success_content"), duration: toastDuration, position: .center, title: nil, image: nil, style: ToastManager.shared.style, completion: { (bool) in
                        self?.needReject = false
                        if let confirmAction = self?.confirm {
                            confirmAction(.success("success"))
                        }
                        self?.dismiss(animated: true, completion: nil)
                    })
                case let .failure(error):
                    self?.detailView.makeToast(error.localizedDescription, position: .center)
                }
            }
        default:
            self.cancelLogin()
        }
    }
}
