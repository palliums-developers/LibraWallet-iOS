//
//  TokenMappingViewModel.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/8/14.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit

class TokenMappingViewModel: NSObject {
    override init() {
        super.init()
    }
    var view: TokenMappingView? {
        didSet {
            view?.headerView.delegate = self
            view?.headerView.inputAmountTextField.delegate = self
//            view?.headerView.outputAmountTextField.delegate = self
        }
    }
    /// 网络请求、数据模型
    lazy var dataModel: TokenMappingModel = {
        let model = TokenMappingModel.init()
        return model
    }()
    /// 数据监听KVO
    var observer: NSKeyValueObservation?
    typealias checkPublishClosure = (Bool) -> Void
    var actionClosure: checkPublishClosure?
    typealias publishFinishClosure = () -> Void
    var finishClosure: publishFinishClosure?
    var tokens: [Token]?
}
extension TokenMappingViewModel {
    func handleUnlockWallet(inputAmount: NSDecimalNumber, outputAmount: NSDecimalNumber, model: TokenMappingListDataModel, outputModuleActiveState: Bool) {
        WalletManager.unlockWallet(successful: { [weak self](mnemonic) in
            self?.handleRequest(inputAmount: inputAmount,
                                outputAmount: outputAmount,
                                model: model,
                                mnemonic: mnemonic,
                                outputModuleActiveState: true)
        }) { [weak self](error) in
            guard error != "Cancel" else {
                self?.view?.toastView?.hide(tag: 99)
                return
            }
            self?.view?.makeToast(error, position: .center)
        }
    }
    func handleRequest(inputAmount: NSDecimalNumber, outputAmount: NSDecimalNumber, model: TokenMappingListDataModel, mnemonic: [String], outputModuleActiveState: Bool) {
        if model.from_coin?.coin_type?.lowercased() == "violas" && model.to_coin?.coin_type?.lowercased() == "libra" {
            self.dataModel.sendViolasToLibraTransaction(sendAddress: WalletManager.shared.violasAddress ?? "",
                                                        receiveAddress: WalletManager.shared.libraAddress ?? "",
                                                        module: model.from_coin?.assert?.module ?? "",
                                                        amountIn: inputAmount.multiplying(by: NSDecimalNumber.init(value: 1000000)).uint64Value,
                                                        amountOut: outputAmount.multiplying(by: NSDecimalNumber.init(value: 1000000)).uint64Value,
                                                        fee: 0,
                                                        mnemonic: mnemonic,
                                                        type: model.lable ?? "",
                                                        centerAddress: model.receiver_address ?? "",
                                                        outputModuleActiveState: outputModuleActiveState)
        } else if model.from_coin?.coin_type?.lowercased() == "libra" && model.from_coin?.coin_type?.lowercased() == "violas" {
            self.dataModel.sendLibraToViolasTransaction(sendAddress: WalletManager.shared.libraAddress ?? "",
                                                        receiveAddress: WalletManager.shared.violasAddress ?? "",
                                                        module: model.from_coin?.assert?.module ?? "",
                                                        amountIn: inputAmount.multiplying(by: NSDecimalNumber.init(value: 1000000)).uint64Value,
                                                        amountOut: outputAmount.multiplying(by: NSDecimalNumber.init(value: 1000000)).uint64Value,
                                                        fee: 0,
                                                        mnemonic: mnemonic,
                                                        type: model.lable ?? "",
                                                        centerAddress: model.receiver_address ?? "",
                                                        outputModuleActiveState: outputModuleActiveState)
        } else if model.from_coin?.coin_type?.lowercased() == "btc" {
            
        }
    }
}
extension TokenMappingViewModel: TokenMappingHeaderViewDelegate {
    func chooseToken() {
        self.view?.toastView?.show(tag: 99)
        self.dataModel.getMappingTokenList(btcAddress: WalletManager.shared.btcAddress ?? "",
                                           violasAddress: WalletManager.shared.violasAddress ?? "",
                                           libraAddress: WalletManager.shared.libraAddress ?? "")
    }
    
    func confirmTransfer() {
        guard let model = self.view?.headerView.inputModel else {
            return
        }
        self.view?.headerView.inputAmountTextField.resignFirstResponder()
        guard let inputAmountString = self.view?.headerView.inputAmountTextField.text, inputAmountString.isEmpty == false else {
            self.view?.makeToast(LibraWalletError.WalletMarket(reason: .payAmountEmpty).localizedDescription, position: .center)
            return
        }
        guard isPurnDouble(string: inputAmountString) == true else {
            self.view?.makeToast(LibraWalletError.WalletMarket(reason: .payAmountInvalid).localizedDescription, position: .center)
            return
        }
        let inputAmount = NSDecimalNumber.init(string: inputAmountString)
        guard inputAmount.doubleValue != 0 else {
            self.view?.makeToast(localLanguage(keyString: "wallet_market_pay_amount_least_title") + "\(transferViolasLeast)", position: .center)
            return
        }
        guard let outputAmountString = self.view?.headerView.outputAmountTextField.text, outputAmountString.isEmpty == false else {
            self.view?.makeToast(LibraWalletError.WalletMarket(reason: .exchangeAmountEmpty).localizedDescription, position: .center)
            return
        }
        guard isPurnDouble(string: outputAmountString) == true else {
            self.view?.makeToast(LibraWalletError.WalletMarket(reason: .exchangeAmountInvalid).localizedDescription, position: .center)
            return
        }
        let outputAmount = NSDecimalNumber.init(string: outputAmountString)
        guard outputAmount.doubleValue != 0 else {
            self.view?.makeToast(localLanguage(keyString: "wallet_market_exchange_amount_least_title") + "\(transferViolasLeast)", position: .center)
            return
        }
        // 判断余额是否充足
        var unit = 1000000
        if model.from_coin?.coin_type == "btc" {
            unit = 100000000
        }
        guard inputAmount.multiplying(by: NSDecimalNumber.init(value: unit)).int64Value <= (model.from_coin?.assert?.amount ?? 0) else {
            self.view?.makeToast(LibraWalletError.WalletMarket(reason: .payAmountMaxLimit).localizedDescription, position: .center)
            return
        }
        self.handleUnlockWallet(inputAmount: inputAmount, outputAmount: outputAmount, model: model, outputModuleActiveState: model.from_coin?.assert?.active_state ?? false)
    }
    
    func showMappingTokenList() {
        
    }
    
}
//MARK: - 网络请求数据处理中心
extension TokenMappingViewModel {
    func initKVO() {
        self.observer = dataModel.observe(\.dataDic, options: [.new], changeHandler: { [weak self](model, change) in
            guard let dataDic = change.newValue, dataDic.count != 0 else {
                self?.view?.hideToastActivity()
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
                    if type == "MappingTokenList" {
                        self?.showMappingDataEmptyFunctionAlert()
                        return
                    }
                } else if error.localizedDescription == LibraWalletError.WalletRequest(reason: .dataCodeInvalid).localizedDescription {
                    print(error.localizedDescription)
                    // 数据返回状态异常
                } else {
                    if type == "MappingInfo" {
                        self?.showMappingFunctionAlert()
                        return
                    }
                }
                self?.view?.toastView?.hide(tag: 99)
                self?.view?.makeToast(error.localizedDescription, position: .center)
                return
            }
            if type == "MappingInfo" {
                self?.view?.toastView?.hide(tag: 99)
                if let tempData = dataDic.value(forKey: "data") as? [TokenMappingListDataModel] {
                    self?.view?.headerView.models = tempData
                    let alert = MappingTokensAlert.init(data: tempData) { (model) in
                        print(model)
                        self?.view?.headerView.inputModel = model
                    }
                    if self?.view?.headerView.coinSelectButton.titleLabel?.text != localLanguage(keyString: "wallet_transfer_token_default_title") {
                        let index = tempData.firstIndex {
                            $0.from_coin?.assert?.show_name == (self?.view?.headerView.coinSelectButton.titleLabel?.text ?? "")
                        }
                        alert.pickerRow = index
                    }
                    alert.show(tag: 199)
                    alert.showAnimation()
                }
            } else if type == "SendBTCTransaction" {
                self?.view?.toastView?.hide(tag: 99)
                self?.view?.makeToast(localLanguage(keyString: "wallet_transfer_success_alert"), position: .center)
            } else if type == "SendLibraTransaction" {
                self?.view?.toastView?.hide(tag: 99)
                self?.view?.makeToast(localLanguage(keyString: "wallet_transfer_success_alert"), position: .center)
            } else if type == "SendVBTCTransaction" {
                self?.view?.toastView?.hide(tag: 99)
                self?.view?.makeToast(localLanguage(keyString: "wallet_transfer_success_alert"), position: .center)
            } else if type == "SendVLibraTransaction" {
                self?.view?.toastView?.hide(tag: 99)
                self?.view?.makeToast(localLanguage(keyString: "wallet_transfer_success_alert"), position: .center)
            } else if type == "GetWalletEnableCoin" {
                if let tempData = dataDic.value(forKey: "data") as? Bool {
                    print(tempData)
                    if let action = self?.actionClosure {
                        action(tempData)
                    }
                }
            } else if type == "SendPublishTransaction" {
                if let action = self?.finishClosure {
                    action()
                }
            } else if type == "MappingTokenList" {
//                if let tempData = dataDic.value(forKey: "data") as? [TokenMappingListDataModel] {
//                    print(tempData)
//                    self?.detailView.toastView?.hide(tag: 99)
//                    let alert = MappingTokenListAlert.init(data: tempData) { (model) in
//                        print(model)
//                        self?.detailView.headerView.reverseModel = model
//                    }
//                    alert.show(tag: 99)
//                    alert.showAnimation()
//                }
            }
        })
//        if wallet?.tokenType == .BTC || wallet?.tokenType == .Libra {
//            self.view?.toastView?.show(tag: 99)
//            self.dataModel.getMappingInfo()
//        } else {
//            // 获取当前钱包已映射稳定币列表
//            self.dataModel.getMappingTokenList(walletAddress: "b45d3e7e8079eb16cd7111b676f0c32294135e4190261240e3fd7b96fe1b9b89")
//        }
    }
    private func showMappingFunctionAlert() {
//        let alertContr = UIAlertController(title: localLanguage(keyString: "wallet_mapping_info_alert_title"), message: LibraWalletError.WalletMapping(reason: .mappingFounctionInvalid).localizedDescription, preferredStyle: .alert)
//        alertContr.addAction(UIAlertAction(title: localLanguage(keyString: "wallet_mapping_info_alert_confirm_button_title"), style: .default){ [weak self] clickHandler in
//            self?.view?.toastView?.hide(tag: 99)
//            self?.navigationController?.popViewController(animated: true)
//        })
//        self.present(alertContr, animated: true, completion: nil)
    }
    private func showMappingDataEmptyFunctionAlert() {
//        let alertContr = UIAlertController(title: localLanguage(keyString: "wallet_mapping_info_alert_title"), message: LibraWalletError.WalletMapping(reason: .mappingCoinDataEmpty).localizedDescription, preferredStyle: .alert)
//        alertContr.addAction(UIAlertAction(title: localLanguage(keyString: "wallet_mapping_info_alert_confirm_button_title"), style: .default){ [weak self] clickHandler in
//            self?.detailView.toastView?.hide(tag: 99)
//            self?.navigationController?.popViewController(animated: true)
//        })
//        self.present(alertContr, animated: true, completion: nil)
    }
}
extension TokenMappingViewModel: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let content = textField.text else {
            return true
        }
        let textLength = content.count + string.count - range.length
        if textField.tag == 10 {
            if textLength == 0 {
                self.view?.headerView.inputAmountTextField.text = ""
            }
        } else {
            if textLength == 0 {
                self.view?.headerView.outputAmountTextField.text = "0"
            }
        }
        if content.contains(".") {
            let firstContent = content.split(separator: ".").first?.description ?? "0"
            if (textLength - firstContent.count) < 8 {
                return true
            } else {
                return false
            }
        } else {
            return textLength <= ApplyTokenAmountLengthLimit
        }
        
    }
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if self.view?.headerView.coinSelectButton.titleLabel?.text != localLanguage(keyString: "wallet_transfer_token_default_title") {
            return true
        } else {
            self.view?.makeToast(localLanguage(keyString: "wallet_market_exchange_input_token_unselect"),
                                 position: .center)
            return false
        }
    }
    func textFieldDidChangeSelection(_ textField: UITextField) {
         if textField.tag == 10 {
             if textField.text?.isEmpty == false {
                guard let model = self.view?.headerView.inputModel else {
                    return
                }
                let numberConfig = NSDecimalNumberHandler.init(roundingMode: .down,
                                                               scale: 6,
                                                               raiseOnExactness: false,
                                                               raiseOnOverflow: false,
                                                               raiseOnUnderflow: false,
                                                               raiseOnDivideByZero: false)
                let amount = NSDecimalNumber.init(string: textField.text ?? "0").multiplying(by: NSDecimalNumber.init(value: model.mapping_rate ?? 1.0), withBehavior: numberConfig)
                self.view?.headerView.outputAmountTextField.text = amount.stringValue
             } else {
                self.view?.headerView.outputAmountTextField.text = "0"
            }
        }
     }
}
