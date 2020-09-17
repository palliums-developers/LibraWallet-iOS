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
        tableViewManager.dataModels = self.dataModel.getLocalModel()
    }
    deinit {
        print("RepaymentViewModel销毁了")
    }
    var view: RepaymentView? {
        didSet {
//            view?.headerView.delegate = self
//            view?.headerView.inputAmountTextField.delegate = self
//            view?.headerView.outputAmountTextField.delegate = self
            view?.delegate = self
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
        manager.delegate = self
        return manager
    }()
    /// 数据监听KVO
    var observer: NSKeyValueObservation?
}
extension RepaymentViewModel: RepaymentViewDelegate {
    func confirmRepayment() {
        do {
            let (amount, _) = try handleConfirmCondition()
            WalletManager.unlockWallet(successful: { [weak self] (mnemonic) in
                self?.view?.toastView?.show(tag: 99)
                self?.dataModel.sendRepaymentTransaction(sendAddress: WalletManager.shared.violasAddress!,
                                                         amount: UInt64(amount),
                                                         fee: 10,
                                                         mnemonic: mnemonic,
                                                         module: self?.tableViewManager.model?.token_module ?? "",
                                                         feeModule: self?.tableViewManager.model?.token_module ?? "",
                                                         productID: self?.tableViewManager.model?.product_id ?? "")
            }) { (errorContent) in
                self.view?.makeToast(errorContent, position: .center)
            }
            print(amount)
        } catch {
            self.view?.makeToast(error.localizedDescription, position: .center)
        }
    }
    func handleConfirmCondition() throws -> (UInt64, Bool) {
        // 获取TableViewHeader
        guard let header = self.view?.tableView.headerView(forSection: 0) as? RepaymentTableViewHeaderView else {
            throw LibraWalletError.WalletBankRepayment(reason: .dataInvalid)
        }
        // 获取输入还贷金额
        guard let amountString = header.repaymentAmountTextField.text, amountString.isEmpty == false else {
            throw LibraWalletError.WalletBankRepayment(reason: .amountEmpty)
        }
        // 检查金额是否为纯数字
        guard isPurnDouble(string: amountString) else {
            throw LibraWalletError.WalletBankRepayment(reason: .amountInvalid)
        }
        let amount = NSDecimalNumber.init(string: amountString).multiplying(by: NSDecimalNumber.init(value: 1000000))
        // 检查是否等于0
        guard amount.uint64Value != 0 else {
            throw LibraWalletError.WalletBankRepayment(reason: .amountTooLittle)
        }
        // 检查是否高于贷款金额
        guard amount.uint64Value <= (header.model?.balance ?? 0) else {
            throw LibraWalletError.WalletBankRepayment(reason: .amountTooLarge)
        }
        // 检查是否超过余额
        guard amount.uint64Value < NSDecimalNumber.init(value: header.model?.token_balance ?? 0).uint64Value else {
            throw LibraWalletError.WalletBankRepayment(reason: .balanceInsufficient)
        }
        return (amount.uint64Value, header.model?.token_active_state ?? false)
    }
}
// MARK: - TableViewHeader代理
extension RepaymentViewModel: RepaymentTableViewManagerDelegate {
    func headerDelegate(header: RepaymentTableViewHeaderView) {
        header.delegate = self
        header.repaymentAmountTextField.delegate = self
    }
}
extension RepaymentViewModel: RepaymentTableViewHeaderViewDelegate {
    func selectTotalBalance(header: RepaymentTableViewHeaderView, model: RepaymentMainDataModel) {
        let amount = getDecimalNumber(amount: NSDecimalNumber.init(value: model.balance ?? 0),
                                      scale: 6,
                                      unit: 1000000)
        header.repaymentAmountTextField.text = amount.stringValue
    }
}
// MARK: - TextField逻辑
extension RepaymentViewModel: UITextFieldDelegate {
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
        let amount = NSDecimalNumber.init(string: content).multiplying(by: NSDecimalNumber.init(value: 1000000)).uint64Value
        let repaymentAmount = NSDecimalNumber.init(value: self.tableViewManager.model?.balance ?? 0)
        if amount <= repaymentAmount.uint64Value {
            return true
        } else {
            let amount = getDecimalNumber(amount: repaymentAmount,
                                          scale: 6,
                                          unit: 1000000)
            textField.text = amount.stringValue
            return false
        }
    }
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
            if type == "GetLoanRepaymentDetail" {
                guard let tempData = dataDic.value(forKey: "data") as? RepaymentMainDataModel else {
                    return
                }
                self?.tableViewManager.model = tempData
                self?.tableViewManager.dataModels = self?.dataModel.getLocalModel(model: tempData)
                self?.view?.tableView.reloadData()
                self?.view?.toastView?.hide(tag: 99)
                self?.view?.hideToastActivity()
            } else if type == "SendViolasBankRepaymentTransaction" {
                self?.view?.hideToastActivity()
                self?.view?.toastView?.hide(tag: 99)
                self?.view?.makeToast(localLanguage(keyString: "wallet_bank_repayment_submit_successful"), position: .center)
            }
        })
    }
}
