//
//  TransferViewModel.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/8/12.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit
protocol TransferViewModelDelegate: NSObjectProtocol {
    func getController()
}
class TransferViewModel: NSObject {
    weak var delegate: TransferViewModelDelegate?
    /// 数据监听KVO
    var observer: NSKeyValueObservation?
    typealias successClosure = () -> Void
    var actionClosure: successClosure?
    var tokens: [Token]?
    /// 网络请求、数据模型
    lazy var dataModel: TransferModel = {
        let model = TransferModel.init()
        return model
    }()
    var view: TransferView? {
        didSet {
            view?.delegate = self
        }
    }
    var controllerClosure: ((UIViewController)->())?
}
//MARK: - 网络请求数据处理中心
extension TransferViewModel {
    //MARK: - KVO
    func initKVO() {
        self.observer = dataModel.observe(\.dataDic, options: [.new], changeHandler: { [weak self](model, change) in
            guard let dataDic = change.newValue, dataDic.count != 0 else {
                self?.view?.hideToastActivity()
                self?.view?.toastView?.hide(tag: 99)
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
                self?.view?.hideToastActivity()
                self?.view?.toastView?.hide(tag: 99)
                self?.view?.makeToast(error.localizedDescription, position: .center)
                return
            }
            if type == "SendLibraTransaction" {
                self?.view?.toastView?.hide(tag: 99)
                // 转账成功
                self?.view?.makeToast(localLanguage(keyString: "wallet_transfer_success_alert"),
                                      position: .center)
//                self?.controllerClosure = { con in
//
//                }
//                self.delegate?.getController()
                //                if let action = self?.actionClosure {
                //                    action()
                //                    self?.navigationController?.popViewController(animated: true)
                //                }
            }
            if type == "SendViolasTransaction" {
                self?.view?.toastView?.hide(tag: 99)
                // 转账成功
                self?.view?.makeToast(localLanguage(keyString: "wallet_transfer_success_alert"),
                                      position: .center)
                //                if let action = self?.actionClosure {
                //                    action()
                //                    self?.navigationController?.popViewController(animated: true)
                //                }
            }
            if type == "SendBTCTransaction" {
                self?.view?.toastView?.hide(tag: 99)
                // 转账成功
                self?.view?.makeToast(localLanguage(keyString: "wallet_transfer_success_alert"),
                                      position: .center)
                //                if let action = self?.actionClosure {
                //                    action()
                //                    self?.navigationController?.popViewController(animated: true)
                //                }
            }
        })
    }
}
extension TransferViewModel: TransferViewDelegate {
    func scanAddressQRcode() {
        self.view?.amountTextField.resignFirstResponder()
        self.view?.addressTextField.resignFirstResponder()
        self.view?.transferFeeSlider.resignFirstResponder()
        self.controllerClosure = { con in
            let vc = ScanViewController()
            vc.actionClosure = { address in
                do {
                    //1.已选币种，扫描；
                    //2.未选币种，扫描；
                    var tempTokens = self.tokens
                    if let token = self.view?.token {
                        tempTokens = [token]
                    }
                    let result = try libraWalletTool.scanResultHandle(content: address, contracts: tempTokens)
                    if result.type == .transfer {
                        switch result.addressType {
                        case .Libra:
                            self.view?.token = result.contract
                            self.view?.addressTextField.text = result.address
                            let amountContent = getDecimalNumberAmount(amount: NSDecimalNumber.init(value: result.amount ?? 0),
                                                                       scale: 6,
                                                                       unit: 1000000)
                            self.view?.amountTextField.text = "\(amountContent)"
                        case .Violas:
                            self.view?.token = result.contract
                            self.view?.addressTextField.text = result.address
                            let amountContent = getDecimalNumberAmount(amount: NSDecimalNumber.init(value: result.amount ?? 0),
                                                                       scale: 6,
                                                                       unit: 1000000)
                            self.view?.amountTextField.text = "\(amountContent)"
                        case .BTC:
                            self.view?.token = result.contract
                            self.view?.addressTextField.text = result.address
                            let amountContent = getDecimalNumberAmount(amount: NSDecimalNumber.init(value: result.amount ?? 0),
                                                                       scale: 8,
                                                                       unit: 100000000)
                            self.view?.amountTextField.text = "\(amountContent)"
                        default:
                            //                        self.showScanContent(content: address)
                            self.view?.addressTextField.text?.removeAll()
                            self.view?.amountTextField.text?.removeAll()
                            self.view?.makeToast(LibraWalletError.WalletScan(reason: LibraWalletError.ScanError.libraAddressInvalid).localizedDescription,
                                                 position: .center)
                        }
                    } else {
                        self.view?.makeToast(LibraWalletError.WalletScan(reason: LibraWalletError.ScanError.libraAddressInvalid).localizedDescription,
                                             position: .center)
                    }
                } catch {
                    self.view?.makeToast(error.localizedDescription, position: .center)
                }
            }
            con.navigationController?.pushViewController(vc, animated: true)
        }
        self.delegate?.getController()
    }
    
    func chooseAddress() {
        self.view?.amountTextField.resignFirstResponder()
        self.view?.addressTextField.resignFirstResponder()
        self.view?.transferFeeSlider.resignFirstResponder()
        
        self.controllerClosure = { con in
            let vc = AddressManagerViewController()
            vc.actionClosure = { address in
                self.view?.addressTextField.text = address
            }
            if let tempToken = self.view?.token {
                switch tempToken.tokenType {
                case .Libra:
                   vc.addressType = "0"
                case .Violas:
                    vc.addressType = "1"
                case .BTC:
                    vc.addressType = "2"
                }
            } else {
                vc.addressType = ""
            }
            vc.hidesBottomBarWhenPushed = true
            con.navigationController?.pushViewController(vc, animated: true)
        }
        self.delegate?.getController()
    }
    func confirmTransfer() {
        guard let token = self.view?.token else {
            self.view?.makeToast(LibraWalletError.WalletTransfer(reason: .tokenInvalid).localizedDescription,
                                 position: .center)
            return
        }
        // 金额不为空检查
        guard let amountString = self.view?.amountTextField.text, amountString.isEmpty == false else {
            self.view?.makeToast(LibraWalletError.WalletTransfer(reason: .amountEmpty).localizedDescription,
                                 position: .center)
            return
        }
        // 金额是否纯数字检查
        guard isPurnDouble(string: amountString) == true else {
            self.view?.makeToast(LibraWalletError.WalletTransfer(reason: .amountInvalid).localizedDescription,
                                 position: .center)
            return
        }
        var unit = 1000000
        if token.tokenType == .BTC {
            unit = 100000000
        }
        // 转换数字
        let amount = NSDecimalNumber.init(string: amountString).multiplying(by: NSDecimalNumber.init(value: unit))
        guard amount.int64Value != 0 else {
            self.view?.makeToast(LibraWalletError.WalletTransfer(reason: .libraAmountLeast).localizedDescription,
                                 position: .center)
            return
        }
        // 手续费转换
        let feeString = self.view?.transferFeeLabel.text
        let fee = NSDecimalNumber.init(string: "\(feeString?.split(separator: " ").first ?? "0")").multiplying(by: NSDecimalNumber.init(value: unit))
        // 金额大于我的金额
        guard amount.int64Value <= token.tokenBalance else {
            self.view?.makeToast(LibraWalletError.WalletTransfer(reason: .amountOverload).localizedDescription,
                                 position: .center)
            return
        }
        // 地址是否为空
        guard let address = self.view?.addressTextField.text, address.isEmpty == false else {
            self.view?.makeToast(LibraWalletError.WalletTransfer(reason: .addressEmpty).localizedDescription,
                                 position: .center)
            return
        }
        // 是否有效地址
        guard LibraManager.isValidLibraAddress(address: address) else {
            self.view?.makeToast(LibraWalletError.WalletTransfer(reason: .addressInvalid).localizedDescription,
                                 position: .center)
            return
        }
        // 检查是否向自己转账
        guard address != token.tokenAddress else {
            self.view?.makeToast(LibraWalletError.WalletTransfer(reason: .transferToSelf).localizedDescription,
                                 position: .center)
            return
        }
        
        self.view?.amountTextField.resignFirstResponder()
        self.view?.addressTextField.resignFirstResponder()
        self.view?.transferFeeSlider.resignFirstResponder()
        
        WalletManager.unlockWallet(successful: { [weak self] (mnemonic) in
            self?.view?.toastView?.show(tag: 99)
            
            switch token.tokenType {
            case .Violas:
                print("Send Violas Transaction")
                self?.dataModel.sendViolasTransaction(sendAddress: token.tokenAddress,
                                                      receiveAddress: address,
                                                      amount: amount.uint64Value,
                                                      fee: fee.uint64Value,
                                                      mnemonic: mnemonic,
                                                      module: token.tokenModule)
            case .Libra:
                print("Send Libra Transaction")
                self?.dataModel.sendLibraTransaction(sendAddress: token.tokenAddress,
                                                     receiveAddress: address,
                                                     amount: amount.uint64Value,
                                                     fee: fee.uint64Value,
                                                     mnemonic: mnemonic,
                                                     module: token.tokenModule)
            case .BTC:
                print("Send BTC Transaction")
                let wallet = try! BTCManager().getWallet(mnemonic: mnemonic)
                self?.dataModel.makeTransaction(wallet: wallet,
                                                amount: amount.uint64Value,
                                                fee: fee.uint64Value,
                                                toAddress: address)
            }
        }) { [weak self] (error) in
            guard error != "Cancel" else {
                self?.view?.toastView?.hide(tag: 99)
                return
            }
            self?.view?.makeToast(error, position: .center)
        }
    }
    func chooseCoin() {
        self.view?.amountTextField.resignFirstResponder()
        self.view?.addressTextField.resignFirstResponder()
        self.view?.transferFeeSlider.resignFirstResponder()
        guard let tempTokens = self.tokens, tempTokens.isEmpty == false else {
            return
        }
        let alert = TransferTokensAlert.init(data: tempTokens) { (model) in
            print(model)
            self.view?.token = model
        }
        if self.view?.coinSelectButton.titleLabel?.text != localLanguage(keyString: "wallet_transfer_token_default_title") {
            let index = tempTokens.firstIndex {
                $0.tokenName == (self.view?.coinSelectButton.titleLabel?.text ?? "")
            }
            alert.pickerRow = index
        }
        alert.show(tag: 199)
        alert.showAnimation()
    }
}
