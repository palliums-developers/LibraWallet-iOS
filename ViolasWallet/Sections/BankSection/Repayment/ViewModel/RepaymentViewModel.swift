//
//  RepaymentViewModel.swift
//  ViolasWallet
//
//  Created by wangyingdong on 2020/8/25.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit
import Toast

protocol RepaymentViewModelDelegate: NSObjectProtocol {
    func successRepayment()
    func reloadDetailView()
    func showToast(tag: Int)
    func hideToast(tag: Int)
    func requestError(errorMessage: String)
}
protocol RepaymentViewModelInterface  {
    /// 还款信息Model
    var repaymentInfoModel: RepaymentMainDataModel? { get }
    /// 还款信息处理后Model
    var repaymentListmodel: [DepositLocalDataModel]? { get }
}
class RepaymentViewModel: NSObject, RepaymentViewModelInterface {
    
    weak var delegate: RepaymentViewModelDelegate?
    override init() {
        super.init()
        tableViewManager.dataModels = self.dataModel.getLocalModel()
    }
    deinit {
        print("RepaymentViewModel销毁了")
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
    var isRepaymentTotal: Bool = false
    var repaymentListmodel: [DepositLocalDataModel]? {
        return self.dataModel.getLocalModel(model: self.repaymentModel)
    }
    
    var repaymentInfoModel: RepaymentMainDataModel? {
        return self.repaymentModel
    }
    private var repaymentModel: RepaymentMainDataModel? {
        didSet {
            self.delegate?.reloadDetailView()
        }
    }
    private var textFieldText: String?
}
extension RepaymentViewModel {
    func loadOrderDetail(itemID: String, address: String) {
        self.delegate?.showToast(tag: 99)
        self.dataModel.getLoanItemDetailModel(itemID: itemID, address: address) { (result) in
            self.delegate?.hideToast(tag: 99)
            switch result {
            case let .success(model):
                self.repaymentModel = model
            case let .failure(error):
                self.delegate?.requestError(errorMessage: error.localizedDescription)
            }
        }
    }
}
extension RepaymentViewModel: RepaymentViewDelegate {
    func confirmRepayment() {
        do {
            let (amount, _) = try handleConfirmCondition()
            WalletManager.unlockWallet { [weak self] (result) in
                switch result {
                case let .success(mnemonic):
                    self?.delegate?.showToast(tag: 99)
                    self?.dataModel.sendRepaymentTransaction(sendAddress: Wallet.shared.violasAddress!,
                                                             amount: (self?.isRepaymentTotal == false ? UInt64(amount):0),
                                                             fee: 10,
                                                             mnemonic: mnemonic,
                                                             module: self?.tableViewManager.model?.token_module ?? "",
                                                             feeModule: self?.tableViewManager.model?.token_module ?? "",
                                                             productID: self?.tableViewManager.model?.product_id ?? "") { [weak self] (result) in
                        self?.delegate?.hideToast(tag: 99)
                        switch result {
                        case .success(_):
                            self?.delegate?.successRepayment()
                        case let .failure(error):
                            self?.delegate?.requestError(errorMessage: error.localizedDescription)
                        }
                    }
                case let .failure(error):
                    guard error.localizedDescription != "Cancel" else {
                        return
                    }
                    self?.delegate?.requestError(errorMessage: error.localizedDescription)
                }
            }
        } catch {
            self.delegate?.requestError(errorMessage: error.localizedDescription)
        }
    }
    func handleConfirmCondition() throws -> (UInt64, Bool) {
        // 获取输入还贷金额
        guard let amountString = self.textFieldText, amountString.isEmpty == false else {
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
        guard amount.uint64Value <= (self.repaymentModel?.balance ?? 0) else {
            throw LibraWalletError.WalletBankRepayment(reason: .amountTooLarge)
        }
        // 检查是否超过余额
        guard amount.uint64Value <= NSDecimalNumber.init(value: self.repaymentModel?.token_balance ?? 0).uint64Value else {
            throw LibraWalletError.WalletBankRepayment(reason: .balanceInsufficient)
        }
        return (amount.uint64Value, self.repaymentModel?.token_active_state ?? false)
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
        self.textFieldText = amount.stringValue
        self.isRepaymentTotal = true
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
            if amount == repaymentAmount.uint64Value {
                self.isRepaymentTotal = true
            } else {
                self.isRepaymentTotal = false
            }
            return true
        } else {
            let amount = getDecimalNumber(amount: repaymentAmount,
                                          scale: 6,
                                          unit: 1000000)
            textField.text = amount.stringValue
            self.isRepaymentTotal = true
            return false
        }
    }
    func textFieldDidChangeSelection(_ textField: UITextField) {
        self.textFieldText = textField.text
    }
}
