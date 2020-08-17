//
//  LibraTransferViewController.swift
//  LibraWallet
//
//  Created by palliums on 2019/9/5.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit

class LibraTransferViewController: BaseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = (self.wallet?.tokenName ?? "") + " " + localLanguage(keyString: "wallet_transfer_navigation_title")
        self.view.backgroundColor = UIColor.init(hex: "F7F7F9")
        
        self.view.addSubview(detailView)
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
        self.navigationController?.navigationBar.barStyle = .default
    }
    deinit {
        print("TransferViewController销毁了")
    }
    /// 子View
    private lazy var detailView : LibraTransferView = {
        let view = LibraTransferView.init()
        view.delegate = self
        return view
    }()
    /// 网络请求、数据模型
    lazy var dataModel: LibraTransferModel = {
        let model = LibraTransferModel.init()
        return model
    }()
    typealias successClosure = () -> Void
    var actionClosure: successClosure?
    var wallet: Token?
    
    var address: String? {
        didSet {
            self.detailView.addressTextField.text = address
        }
    }
    var amount: Int64? {
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
    /// 数据监听KVO
    var observer: NSKeyValueObservation?
}
//MARK: - 子View代理方法列表
extension LibraTransferViewController: LibraTransferViewDelegate {
    func scanAddressQRcode() {
        let vc = ScanViewController()
        vc.actionClosure = { address in
            do {
                let result = try libraWalletTool.scanResultHandle(content: address, contracts: [self.wallet!])
                if result.type == .transfer {
                    switch result.addressType {
                    case .Libra:
                        self.detailView.addressTextField.text = result.address
                        self.amount = result.amount
                    default:
                        //                        self.showScanContent(content: address)
                        self.detailView.addressTextField.text?.removeAll()
                        self.detailView.amountTextField.text?.removeAll()
                        self.view.makeToast(LibraWalletError.WalletScan(reason: LibraWalletError.ScanError.libraAddressInvalid).localizedDescription,
                                            position: .center)
                    }
                } else {
                    self.view.makeToast(LibraWalletError.WalletScan(reason: LibraWalletError.ScanError.libraAddressInvalid).localizedDescription,
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
        vc.addressType = "0"
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func confirmTransfer(amount: Double, address: String, fee: Double) {
        WalletManager.unlockWallet(controller: self, successful: { [weak self] (mnemonic) in
            self?.detailView.toastView?.show(tag: 99)
            self?.dataModel.sendLibraTransaction(sendAddress: self?.wallet?.tokenAddress ?? "",
                                                 receiveAddress: address,
                                                 amount: amount,
                                                 fee: 0.1,
                                                 mnemonic: mnemonic,
                                                 module: self?.wallet?.tokenModule ?? "")
        }) { [weak self] (error) in
            guard error != "Cancel" else {
                self?.detailView.toastView?.hide(tag: 99)
                return
            }
            self?.detailView.makeToast(error,
                                       position: .center)
        }
    }
}
//MARK: - 网络请求数据处理中心
extension LibraTransferViewController {
    //MARK: - KVO
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
            if type == "SendLibraTransaction" {
                self?.detailView.toastView?.hide(tag: 99)
                // 转账成功
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
