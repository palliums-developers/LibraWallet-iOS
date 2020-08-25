//
//  RepaymentViewModel.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/8/25.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit

class RepaymentViewModel: NSObject {
    override init() {
        super.init()
    }
    deinit {
        print("RepaymentViewModel销毁了")
    }
    var view: RepaymentView? {
        didSet {
//            view?.headerView.delegate = self
//            view?.headerView.inputAmountTextField.delegate = self
//            view?.headerView.outputAmountTextField.delegate = self
            view?.tableView.delegate = tableViewManager
            view?.tableView.dataSource = tableViewManager
        }
    }
    /// 网络请求、数据模型
    lazy var dataModel: RepaymentModel = {
        let model = RepaymentModel.init()
        return model
    }()
    /// tableView管理类
    lazy var tableViewManager: RepaymentTableViewManager = {
        let manager = RepaymentTableViewManager()
        return manager
    }()
    /// 数据监听KVO
    var observer: NSKeyValueObservation?
    ///
    private var firstRequestRate: Bool = true
    /// timer
    private var timer: Timer?
}
// MARK: - 网络请求逻辑处理
extension ExchangeViewModel {
//    func startAutoRefreshExchangeRate(inputCoinA: MarketSupportTokensDataModel, outputCoinB: MarketSupportTokensDataModel) {
//        self.timer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(refreshExchangeRate), userInfo: nil, repeats: true)
//        RunLoop.current.add(self.timer!, forMode: .common)
//    }
//    func stopAutoRefreshExchangeRate() {
//        self.timer?.invalidate()
//        self.timer = nil
//    }
//    @objc func refreshExchangeRate() {
//        self.dataModel.getPoolTotalLiquidity(inputCoinA: (self.view?.headerView.transferInInputTokenA)!, inputCoinB: (self.view?.headerView.transferInInputTokenB)!)
//    }
}
// MARK: - 逻辑处理
extension RepaymentViewModel {
}
// MARK: - TextField逻辑
extension RepaymentViewModel: UITextFieldDelegate {
//    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//        guard let content = textField.text else {
//            return true
//        }
//        let textLength = content.count + string.count - range.length
//        if textField.tag == 10 {
//            if textLength == 0 {
//                self.view?.headerView.inputAmountTextField.text = ""
//                self.view?.headerView.outputAmountTextField.text = ""
//            }
//        } else {
//            if textLength == 0 {
//                self.view?.headerView.inputAmountTextField.text = ""
//                self.view?.headerView.outputAmountTextField.text = ""
//            }
//        }
//        if content.contains(".") {
//            let firstContent = content.split(separator: ".").first?.description ?? "0"
//            if (textLength - firstContent.count) < 8 {
//                return handleInputAmount(textField: textField, content: (content.isEmpty == true ? "0":content) + string)
//            } else {
//                return false
//            }
//        } else {
//            if textLength <= ApplyTokenAmountLengthLimit {
//                return handleInputAmount(textField: textField, content: (content.isEmpty == true ? "0":content) + string)
//            } else {
//                return false
//            }
//        }
//    }
//    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
//        // 转入
//        guard self.view?.headerView.inputTokenButton.titleLabel?.text != localLanguage(keyString: "wallet_market_exchange_input_token_button_title") else {
//            textField.resignFirstResponder()
//            self.view?.makeToast(localLanguage(keyString: "wallet_market_exchange_input_token_unselect"),
//                                 position: .center)
//            return false
//        }
//        guard self.view?.headerView.outputTokenButton.titleLabel?.text != localLanguage(keyString: "wallet_market_exchange_output_token_button_title") else {
//            textField.resignFirstResponder()
//            self.view?.makeToast(localLanguage(keyString: "wallet_market_exchange_output_token_unselect"),
//                                 position: .center)
//            return false
//        }
//        return true
//    }
//    func textFieldDidChangeSelection(_ textField: UITextField) {
//        if textField.tag == 10 {
//            if textField.text?.isEmpty == false {
//                self.view?.headerView.viewState = .handleBestOutputAmount
//                let amount = NSDecimalNumber.init(string: textField.text ?? "0").multiplying(by: NSDecimalNumber.init(value: 1000000)).int64Value
//                self.fliterBestOutputAmount(inputAmount: amount)
//            }
//        } else {
//            if textField.text?.isEmpty == false {
//                self.view?.headerView.viewState = .handleBestInputAmount
//                let amount = NSDecimalNumber.init(string: textField.text ?? "0").multiplying(by: NSDecimalNumber.init(value: 1000000)).int64Value
//                self.fliterBestInputAmount(outputAmount: amount)
//            }
//        }
//        
//    }
//    func handleInputAmount(textField: UITextField, content: String) -> Bool {
//        let amount = NSDecimalNumber.init(string: content).multiplying(by: NSDecimalNumber.init(value: 1000000)).int64Value
//        if textField.tag == 10 {
//            if amount <= self.view?.headerView.transferInInputTokenA?.amount ?? 0 {
//                return true
//            } else {
//                let amount = getDecimalNumber(amount: NSDecimalNumber.init(value: self.view?.headerView.transferInInputTokenA?.amount ?? 0),
//                                              scale: 6,
//                                              unit: 1000000)
//                textField.text = amount.stringValue
//                return false
//            }
//        } else {
//            if amount <= self.view?.headerView.transferInInputTokenB?.amount ?? 0 {
//                return true
//            } else {
//                let amount = getDecimalNumber(amount: NSDecimalNumber.init(value: self.view?.headerView.transferInInputTokenB?.amount ?? 0),
//                                              scale: 6,
//                                              unit: 1000000)
//                textField.text = amount.stringValue
//                return false
//            }
//        }
//    }
}
// MARK: - 网络请求
extension RepaymentViewModel {
    func initKVO() {
        self.observer = dataModel.observe(\.dataDic, options: [.new], changeHandler: { [weak self](model, change) in
            guard let dataDic = change.newValue, dataDic.count != 0 else {
                self?.view?.toastView?.hide(tag: 99)
                self?.view?.toastView?.hide(tag: 299)
                self?.view?.hideToastActivity()
                return
            }
            #warning("已修改完成，可拷贝执行")
            if let error = dataDic.value(forKey: "error") as? LibraWalletError {
                // 隐藏请求指示
                self?.view?.hideToastActivity()
                self?.view?.toastView?.hide(tag: 99)
                self?.view?.toastView?.hide(tag: 299)
                self?.view?.toastView?.hide(tag: 399)
                if error.localizedDescription == LibraWalletError.WalletRequest(reason: .networkInvalid).localizedDescription {
                    // 网络无法访问
                    print(error.localizedDescription)
                    self?.view?.makeToast(error.localizedDescription,
                                          position: .center)
                } else if error.localizedDescription == LibraWalletError.WalletRequest(reason: .walletVersionExpired).localizedDescription {
                    // 版本太久
                    print(error.localizedDescription)
                    self?.view?.makeToast(error.localizedDescription,
                                          position: .center)
                } else if error.localizedDescription == LibraWalletError.WalletRequest(reason: .parseJsonError).localizedDescription {
                    // 解析失败
                    print(error.localizedDescription)
                    self?.view?.makeToast(error.localizedDescription,
                                          position: .center)
                } else if error.localizedDescription == LibraWalletError.WalletRequest(reason: .dataCodeInvalid).localizedDescription {
                    print(error.localizedDescription)
                    // 数据状态异常
                    self?.view?.makeToast(error.localizedDescription,
                                          position: .center)
                } else if error.localizedDescription == LibraWalletError.WalletRequest(reason: .dataEmpty).localizedDescription {
                    print(error.localizedDescription)
                    // 下拉刷新请求数据为空
                    self?.view?.makeToast(error.localizedDescription,
                                          position: .center)
                } else if error.localizedDescription == LibraWalletError.WalletRequest(reason: .noMoreData).localizedDescription {
                    // 上拉请求更多数据为空
                    print(error.localizedDescription)
                } else {
                    self?.view?.makeToast(error.localizedDescription,
                                          position: .center)
                }
//                self?.view?.headerView.viewState = .Normal
                return
            }
            let type = dataDic.value(forKey: "type") as! String
            if type == "SupportViolasTokens" {
                
            }
            self?.view?.hideToastActivity()
            self?.view?.toastView?.hide(tag: 99)
        })
    }
}
