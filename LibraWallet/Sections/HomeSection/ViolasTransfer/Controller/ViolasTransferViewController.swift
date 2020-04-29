//
//  ViolasTransferViewController.swift
//  LibraWallet
//
//  Created by palliums on 2019/11/14.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit

class ViolasTransferViewController: BaseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = (self.wallet?.walletType?.description ?? "") + " " + localLanguage(keyString: "wallet_transfer_navigation_title")

        self.view.addSubview(detailView)
        self.detailView.sendViolasTokenState = self.sendViolasTokenState
        if self.sendViolasTokenState == false {
            self.detailView.wallet = self.wallet
        } else {
            self.detailView.vtoken = self.vtokenModel
        }
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
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNavigationBarTitleColorDefault()
        self.navigationController?.navigationBar.barStyle = .default
    }
    private lazy var detailView : ViolasTransferView = {
        let view = ViolasTransferView.init()
        view.delegate = self
        return view
    }()
    lazy var dataModel: ViolasTransferModel = {
        let model = ViolasTransferModel.init()
        return model
    }()
    typealias successClosure = () -> Void
    var actionClosure: successClosure?
    var wallet: LibraWalletManager?
    
    var sendViolasTokenState: Bool?
    var vtokenModel: ViolasTokenModel?
    /// 数据监听KVO
    private var observer: NSKeyValueObservation?
    var address: String? {
        didSet {
           self.detailView.addressTextField.text = address
        }
    }
}
extension ViolasTransferViewController: ViolasTransferViewDelegate {
    func scanAddressQRcode() {
        let vc = ScanViewController()
        vc.actionClosure = { address in
            do {
                let tempAddressModel = try handleScanContent(content: address)
                self.detailView.addressTextField.text = tempAddressModel.address
            } catch {
                self.detailView.makeToast(error.localizedDescription, position: .center)
            }
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func chooseAddress() {
        let vc = AddressManagerViewController()
        vc.actionClosure = { address in
            self.detailView.addressTextField.text = address
        }
        vc.addressType = "Violas"
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func confirmTransfer(amount: Double, address: String, fee: Double) {
        let alert = passowordAlert(rootAddress: (self.wallet?.walletRootAddress)!, mnemonic: { [weak self] (mnemonic) in
            self?.detailView.toastView?.show()
            if self?.sendViolasTokenState == false {
                self?.dataModel.sendViolasTransaction(sendAddress: (self?.wallet?.walletAddress)!,
                                                      receiveAddress: address,
                                                      amount: amount,
                                                      fee: fee,
                                                      mnemonic: mnemonic)
            } else {
                self?.dataModel.sendViolasTokenTransaction(sendAddress: (self?.wallet?.walletAddress)!,
                                                           receiveAddress: address,
                                                           amount: amount,
                                                           fee: fee,
                                                           mnemonic: mnemonic,
                                                           tokenIndex: "\(self?.vtokenModel?.id ?? 9999)")
            }
        }) { [weak self] (errorContent) in
            guard errorContent != "Cancel" else {
                self?.detailView.toastView?.hide()
                return
            }
            self?.view.makeToast(errorContent, position: .center)
        }
        self.present(alert, animated: true, completion: nil)
    }
}
extension ViolasTransferViewController {
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
                self?.view.makeToast(error.localizedDescription, position: .center)
                return
            }
            if type == "SendViolasTransaction" {
                self?.detailView.toastView?.hide()
                self?.view.makeToast(localLanguage(keyString: "wallet_transfer_success_alert"), position: .center)
                if let action = self?.actionClosure {
                    action()
                    self?.navigationController?.popViewController(animated: true)
                }
            }
        })
    }
}
