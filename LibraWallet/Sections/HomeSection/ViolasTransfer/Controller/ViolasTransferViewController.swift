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
        self.title = (self.wallet?.tokenName ?? "") + " " + localLanguage(keyString: "wallet_transfer_navigation_title")

        self.view.addSubview(detailView)
//        self.detailView.sendViolasTokenState = self.sendViolasTokenState
        self.detailView.wallet = self.wallet
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
    var wallet: Token?
    
//    var sendViolasTokenState: Bool?
//    var vtokenModel: ViolasTokenModel?
    /// 数据监听KVO
    private var observer: NSKeyValueObservation?
    var address: String? {
        didSet {
           self.detailView.addressTextField.text = address
        }
    }
    var amount: UInt64? {
        didSet {
            guard let tempAmount = amount else {
                return
            }
            let amountContent = getDecimalNumberAmount(amount: NSDecimalNumber.init(value: tempAmount),
                                                       scale: 6,
                                                       unit: 1000000)
            self.detailView.amountTextField.text = "\(amountContent)"
        }
    }
}
extension ViolasTransferViewController: ViolasTransferViewDelegate {
    func scanAddressQRcode() {
        let vc = ScanViewController()
        vc.actionClosure = { address in
            do {
                let result = try ScanHandleManager.scanResultHandle(content: address, contracts: [self.wallet!])
                print(result)
                if result.type == .transfer {
                    switch result.addressType {
                    case .Violas:
                        self.detailView.addressTextField.text = result.address
                        self.amount = result.amount
                    default:
                        self.detailView.addressTextField.text?.removeAll()
                        self.detailView.amountTextField.text?.removeAll()
                        self.view.makeToast(LibraWalletError.WalletScan(reason: LibraWalletError.ScanError.violasAddressInvalid).localizedDescription,
                                            position: .center)
                    }
                } else {
                    self.view.makeToast(LibraWalletError.WalletScan(reason: LibraWalletError.ScanError.violasAddressInvalid).localizedDescription,
                                        position: .center)
                }
            } catch {
                self.view.makeToast(error.localizedDescription, position: .center)
            }
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func chooseAddress() {
        let vc = AddressManagerViewController()
        vc.actionClosure = { address in
            self.detailView.addressTextField.text = address
        }
        vc.addressType = "1"
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func confirmTransfer(amount: UInt64, address: String, fee: UInt64) {
        WalletManager.unlockWallet { [weak self] (result) in
            switch result {
            case let .success(mnemonic):
                self?.detailView.toastView?.show(tag: 99)
                self?.dataModel.sendViolasTransaction(sendAddress: self?.wallet?.tokenAddress ?? "",
                                                      receiveAddress: address,
                                                      amount: amount,
                                                      fee: fee,
                                                      mnemonic: mnemonic,
                                                      module: self?.wallet?.tokenModule ?? "")
            case let .failure(error):
                guard error.localizedDescription != "Cancel" else {
                    self?.detailView.toastView?.hide(tag: 99)
                    return
                }
                self?.detailView.makeToast(error.localizedDescription, position: .center)
            }
        }
    }
}
extension ViolasTransferViewController {
    func initKVO() {
        self.observer = dataModel.observe(\.dataDic, options: [.new], changeHandler: { [weak self](model, change) in
            guard let dataDic = change.newValue, dataDic.count != 0 else {
                self?.detailView.hideToastActivity()
                self?.detailView.toastView?.hide(tag: 99)
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
                self?.detailView.toastView?.hide(tag: 99)
                self?.view.makeToast(error.localizedDescription, position: .center)
                return
            }
            if type == "SendViolasTransaction" {
                self?.detailView.toastView?.hide(tag: 99)
                self?.view.makeToast(localLanguage(keyString: "wallet_transfer_success_alert"),
                                     position: .center)
                if let action = self?.actionClosure {
                    action()
                    self?.navigationController?.popViewController(animated: true)
                }
            }
        })
    }
}
