//
//  LoanViewModel.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/8/26.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit

class LoanViewModel: NSObject {
    override init() {
        super.init()
        tableViewManager.dataModels = self.dataModel.getLocalModel()
    }
    deinit {
        print("LoanViewModel销毁了")
    }
    var view: LoanView? {
        didSet {
            view?.delegate = self
            view?.tableView.delegate = tableViewManager
            view?.tableView.dataSource = tableViewManager
        }
    }
    /// 网络请求、数据模型
    lazy var dataModel: LoanModel = {
        let model = LoanModel.init()
        return model
    }()
    /// tableView管理类
    lazy var tableViewManager: LoanTableViewManager = {
        let manager = LoanTableViewManager()
        manager.delegate = self
        return manager
    }()
    /// 数据监听KVO
    var observer: NSKeyValueObservation?
    var models: [BankDepositMarketDataModel]?
}
// MARK: - 逻辑处理
extension LoanViewModel: LoanViewDelegate {
    func checkLegal() {
        let vc = BankLegalViewController()
        let navi = BaseNavigationViewController.init(rootViewController: vc)
        var rootViewController = UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.rootViewController
        if let navigationController = rootViewController as? UINavigationController {
            rootViewController = navigationController.viewControllers.first
        }
        if let tabBarController = rootViewController as? UITabBarController {
            rootViewController = tabBarController.selectedViewController
        }
        rootViewController?.present(navi, animated: true, completion: nil)
    }
    func loanConfirm() {
        do {
            let (amount, activeState) = try handleConfirmCondition()
            if activeState == false {
                self.unActiveAlert(amount: amount)
            } else {
                WalletManager.unlockWallet(successful: { [weak self] (mnemonic) in
                    self?.view?.toastView?.show(tag: 99)
                    self?.dataModel.sendLoanTransaction(sendAddress: WalletManager.shared.violasAddress!,
                                                        amount: UInt64(amount),
                                                        fee: 0,
                                                        mnemonic: mnemonic,
                                                        module: "",
                                                        feeModule: "",
                                                        activeState: true)
                }) { (errorContent) in
                    self.view?.makeToast(errorContent, position: .center)
                }
            }
            print(amount)
        } catch {
            self.view?.makeToast(error.localizedDescription, position: .center)
        }
    }
    func handleConfirmCondition() throws -> (Int64, Bool) {
        guard let header = self.view?.tableView.headerView(forSection: 0) as? LoanTableViewHeaderView else {
            throw LibraWalletError.error("Unkwon Error")
        }
        guard let amountString = header.loanAmountTextField.text, amountString.isEmpty == false else {
            throw LibraWalletError.error("Amount Invalid")
        }
        guard isPurnDouble(string: amountString) else {
            throw LibraWalletError.error("Amount Invalid")
        }
        let amount = NSDecimalNumber.init(string: amountString).multiplying(by: NSDecimalNumber.init(value: 1000000))
        // 比最少充值金额多
        guard amount.int64Value > (header.productModel?.minimum_amount ?? 0) else {
            throw LibraWalletError.error("Amount Too Least")
        }
        // 比每日限额少
        guard amount.int64Value < (NSDecimalNumber.init(value: header.productModel?.quota_limit ?? 0).subtracting(NSDecimalNumber.init(value: header.productModel?.quota_used ?? 0))).int64Value else {
            throw LibraWalletError.error("Amount over limit")
        }
        // 未同意协议
        guard self.view?.legalButton.imageView?.image != UIImage.init(named: "unselect") else {
            throw LibraWalletError.WalletAddWallet(reason: .notAgreeLegalError)
        }
        return (amount.int64Value, header.productModel?.token_active_state ?? false)
    }
    func unActiveAlert(amount: Int64) {
        let alertContr = UIAlertController(title: localLanguage(keyString: "wallet_alert_delete_address_title"), message: localLanguage(keyString: "wallet_market_exchange_output_token_unactived"), preferredStyle: .alert)
        alertContr.addAction(UIAlertAction(title: localLanguage(keyString: "wallet_alert_delete_address_confirm_button_title"), style: .default){ [weak self] clickHandler in
            WalletManager.unlockWallet(successful: { [weak self] (mnemonic) in
                self?.view?.toastView?.show(tag: 99)
                self?.dataModel.sendLoanTransaction(sendAddress: WalletManager.shared.violasAddress!,
                                                    amount: UInt64(amount),
                                                    fee: 0,
                                                    mnemonic: mnemonic,
                                                    module: "",
                                                    feeModule: "",
                                                    activeState: true)
            }) { (errorContent) in
                self?.view?.makeToast(errorContent, position: .center)
            }
        })
        alertContr.addAction(UIAlertAction(title: localLanguage(keyString: "wallet_alert_delete_address_cancel_button_title"), style: .cancel){ clickHandler in
            NSLog("点击了取消")
        })
        var rootViewController = UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.rootViewController
        if let navigationController = rootViewController as? UINavigationController {
            rootViewController = navigationController.viewControllers.first
        }
        if let tabBarController = rootViewController as? UITabBarController {
            rootViewController = tabBarController.selectedViewController
        }
        rootViewController?.present(alertContr, animated: true, completion: nil)
    }
}
extension LoanViewModel: LoanTableViewManagerDelegate {
    func questionHeaderDelegate(header: LoanQuestionTableViewHeaderView) {
        header.delegate = self
    }
    func describeHeaderDelegate(header: LoanDescribeTableViewHeaderView) {
        header.delegate = self
    }
    func headerDelegate(header: LoanTableViewHeaderView) {
        header.delegate = self
        header.loanAmountTextField.delegate = self
    }
}
extension LoanViewModel: LoanQuestionTableViewHeaderViewDelegate {
    func showQuestions(header: LoanQuestionTableViewHeaderView) {
        self.tableViewManager.showQuestion = self.tableViewManager.showQuestion == true ? false:true
        self.view?.tableView.beginUpdates()
        self.view?.tableView.reloadSections(IndexSet.init(integer: 2), with: UITableView.RowAnimation.fade)
        self.view?.tableView.endUpdates()
    }
}
extension LoanViewModel: LoanDescribeTableViewHeaderViewDelegate {
    func showQuestions(header: LoanDescribeTableViewHeaderView) {
        self.tableViewManager.showIntroduce = self.tableViewManager.showIntroduce == true ? false:true
        self.view?.tableView.beginUpdates()
        self.view?.tableView.reloadSections(IndexSet.init(integer: 1), with: UITableView.RowAnimation.fade)
        self.view?.tableView.endUpdates()
    }
}
extension LoanViewModel: LoanTableViewHeaderViewDelegate {
    func selectTotalBalance(header: LoanTableViewHeaderView, model: BankLoanMarketDataModel) {
        let amount = getDecimalNumber(amount: NSDecimalNumber.init(value: model.quota_limit ?? 0).subtracting(NSDecimalNumber.init(value: model.quota_used ?? 0)),
                                      scale: 6,
                                      unit: 1000000)
        header.loanAmountTextField.text = amount.stringValue
    }
}

// MARK: - TextField逻辑
extension LoanViewModel: UITextFieldDelegate {
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
        if amount <= self.tableViewManager.model?.minimum_amount ?? 0 {
            return true
        } else {
            let amount = getDecimalNumber(amount: NSDecimalNumber.init(value: self.tableViewManager.model?.quota_limit ?? 0).subtracting(NSDecimalNumber.init(value: self.tableViewManager.model?.quota_used ?? 0)),
                                          scale: 6,
                                          unit: 1000000)
            textField.text = amount.stringValue
            return false
        }
    }
}
// MARK: - 网络请求
extension LoanViewModel {
    func initKVO() {
        self.observer = dataModel.observe(\.dataDic, options: [.new], changeHandler: { [weak self](model, change) in
            guard let dataDic = change.newValue, dataDic.count != 0 else {
                self?.view?.toastView?.hide(tag: 99)
                self?.view?.toastView?.hide(tag: 299)
                self?.view?.hideToastActivity()
                return
            }
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
            if type == "GetLoanItemDetail" {
                guard let tempData = dataDic.value(forKey: "data") as? BankLoanMarketDataModel else {
                    return
                }
                self?.tableViewManager.model = tempData
                self?.tableViewManager.dataModels = self?.dataModel.getLocalModel(model: tempData)
                self?.view?.tableView.reloadData()
            }
            self?.view?.hideToastActivity()
            self?.view?.toastView?.hide(tag: 99)
        })
    }
}
