//
//  DepositViewModel.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/8/26.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit

class DepositViewModel: NSObject {
    override init() {
        super.init()
        tableViewManager.dataModels = self.dataModel.getLocalModel()
    }
    deinit {
        print("DepositView销毁了")
    }
    var view: DepositView? {
        didSet {
            view?.delegate = self
            view?.tableView.delegate = tableViewManager
            view?.tableView.dataSource = tableViewManager
        }
    }
    /// 网络请求、数据模型
    lazy var dataModel: DepositModel = {
        let model = DepositModel.init()
        return model
    }()
    /// tableView管理类
    lazy var tableViewManager: DepositTableViewManager = {
        let manager = DepositTableViewManager()
        manager.delegate = self
        return manager
    }()
    /// 数据监听KVO
    var observer: NSKeyValueObservation?
    ///
    private var models: [BankDepositMarketDataModel]?
    var selectIndexPath: IndexPath?
}
// MARK: - 逻辑处理
extension DepositViewModel: DepositTableViewManagerDelegate {
    func headerDelegate(header: DepositTableViewHeaderView) {
        header.delegate = self
        header.depositAmountTextField.delegate = self
    }
}
extension DepositViewModel: DepositTableViewHeaderViewDelegate {
    func selectDepositToken(header: DepositTableViewHeaderView) {
        guard let tempData = models else {
            return
        }
        let alert = DepositTokensAlert.init(data: tempData) { (model) in
            print(model)
            self.tableViewManager.model = model
            self.tableViewManager.dataModels = self.dataModel.getLocalModel(model: model)
            self.view?.tableView.reloadData()
        }
        if header.depositTokenSelectButton.titleLabel?.text != localLanguage(keyString: "wallet_bank_deposit_select_token_button_title") {
            let index = tempData.firstIndex {
                $0.product_token_show_name == header.depositTokenSelectButton.titleLabel?.text
            }
            alert.pickerRow = index
        }
        alert.show(tag: 199)
        alert.showAnimation()
    }
    func selectTotalBalance(header: DepositTableViewHeaderView, model: BankDepositMarketDataModel) {
        if (model.token_balance ?? 0) > (model.product_amount_limit_least ?? 0) {
            let amount = getDecimalNumber(amount: NSDecimalNumber.init(value: model.product_amount_limit_least ?? 0),
                                          scale: 6,
                                          unit: 1000000)
            header.depositAmountTextField.text = amount.stringValue
        } else {
            let amount = getDecimalNumber(amount: NSDecimalNumber.init(value: model.token_balance ?? 0),
                                          scale: 6,
                                          unit: 1000000)
            header.depositAmountTextField.text = amount.stringValue
        }
    }
}
// MARK: - TextField逻辑
extension DepositViewModel: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let content = textField.text else {
            return true
        }
        let textLength = content.count + string.count - range.length
        if textField.tag == 10 {
            if textLength == 0 {
                textField.text = ""
            }
        }
        if content.contains(".") {
            let firstContent = content.split(separator: ".").first?.description ?? "0"
            if (textLength - firstContent.count) < 8 {
                return handleInputAmount(textField: textField, content: (content.isEmpty == true ? "0":content) + string)
            } else {
                return false
            }
        } else {
            if textLength <= ApplyTokenAmountLengthLimit {
                return handleInputAmount(textField: textField, content: (content.isEmpty == true ? "0":content) + string)
            } else {
                return false
            }
        }
    }
    private func handleInputAmount(textField: UITextField, content: String) -> Bool {
        let amount = NSDecimalNumber.init(string: content).multiplying(by: NSDecimalNumber.init(value: 1000000)).int64Value
        if amount <= self.models?[(selectIndexPath?.row ?? 0)].product_amount_limit_least ?? 0 && amount <= self.models?[(selectIndexPath?.row ?? 0)].token_balance ?? 0 {
            return true
        } else {
            if (self.models?[(selectIndexPath?.row ?? 0)].token_balance ?? 0) > (self.models?[(selectIndexPath?.row ?? 0)].product_amount_limit_least ?? 0) {
                let amount = getDecimalNumber(amount: NSDecimalNumber.init(value: self.models?[(selectIndexPath?.row ?? 0)].product_amount_limit_least ?? 0),
                                              scale: 6,
                                              unit: 1000000)
                textField.text = amount.stringValue
            } else {
                let amount = getDecimalNumber(amount: NSDecimalNumber.init(value: self.models?[(selectIndexPath?.row ?? 0)].token_balance ?? 0),
                                              scale: 6,
                                              unit: 1000000)
                textField.text = amount.stringValue
            }
            return false
        }
    }
}
extension DepositViewModel: DepositViewDelegate {
    func confirmDeposit() {
        do {
            let amount = try handleConfirmCondition()
            
        } catch {
            self.view?.makeToast(error.localizedDescription, position: .center)
        }
    }
    func handleConfirmCondition() throws -> Int64 {
        
        guard let header = self.view?.tableView.headerView(forSection: 0) as? DepositTableViewHeaderView else {
            return
        }
        guard self.tableViewManager.model?.token_active_state == true else {
            throw LibraWalletError.error("UnActive Token")
        }
        guard let balance = self.tableViewManager.model?.token_balance, balance > 0 else {
            throw LibraWalletError.error("Account Balance Empty")
        }
        guard let amountString = header.depositAmountTextField.text, amountString.isEmpty == false else {
            throw LibraWalletError.error("Amount Invalid")
        }
        guard isPurnDouble(string: amountString) else {
            throw LibraWalletError.error("Amount Invalid")
        }
        let amount = NSDecimalNumber.init(string: amountString).multiplying(by: NSDecimalNumber.init(value: 1000000))
        // 比余额多
        guard amount.int64Value < (header.productModel?.token_balance ?? 0) else {
            throw LibraWalletError.error("Amount Too big")
        }
        // 比最少充值金额多
        guard amount.int64Value > (header.productModel?.product_input_token_least ?? 0) else {
            throw LibraWalletError.error("Amount Too Least")
        }
        // 比每日限额少
        guard amount.int64Value < (header.productModel?.product_amount_limit ?? 0) else {
            throw LibraWalletError.error("Amount over limit")
        }
        return amount.int64Value
    }
}
// MARK: - 网络请求
extension DepositViewModel {
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
            if type == "GetBankTokens" {
                guard let tempData = dataDic.value(forKey: "data") as? [BankDepositMarketDataModel] else {
                    return
                }
                self?.models = tempData
                self?.tableViewManager.model = tempData[(self?.selectIndexPath?.row ?? 0)]
                self?.tableViewManager.dataModels = self?.dataModel.getLocalModel(model: tempData[(self?.selectIndexPath?.row ?? 0)])
                self?.view?.tableView.reloadData()
            }
            self?.view?.hideToastActivity()
            self?.view?.toastView?.hide(tag: 99)
        })
    }
}
