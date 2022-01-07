//
//  ExchangeViewController.swift
//  ViolasWallet
//
//  Created by wangyingdong on 2020/7/9.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit
class ExchangeViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        // 加载子View
        self.view.addSubview(detailView)
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        detailView.snp.makeConstraints { (make) in
            make.top.left.right.bottom.equalTo(self.view.safeAreaLayoutGuide)
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.barStyle = .default
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.navigationController?.navigationBar.barStyle = .default
    }
    deinit {
        print("ExchangeViewController销毁了")
    }
    /// 子View
    lazy var detailView : ExchangeView = {
        let view = ExchangeView.init()
        view.headerView.delegate = self
        view.headerView.tokenSelectViewA.inputAmountTextField.delegate = self
        view.headerView.tokenSelectViewB.inputAmountTextField.delegate = self
        return view
    }()
    /// ViewModel
    lazy var viewModel: ExchangeViewModel = {
        let viewModel = ExchangeViewModel.init()
        viewModel.delegate = self
        return viewModel
    }()
}
// MARK: - ViewModel逻辑
extension ExchangeViewController: ExchangeViewModelDelegate {
    func reloadSelectTokenViewA() {
        self.detailView.headerView.tokenSelectViewA.swapTokenModel = self.viewModel.tokenModelA
    }
    func reloadSelectTokenViewB() {
        self.detailView.headerView.tokenSelectViewB.swapTokenModel = self.viewModel.tokenModelB
    }
    func reloadView() {
        self.detailView.headerView.exchangeModel = self.viewModel.swapInfoModel
    }
    func showToast(tag: Int) {
        self.detailView.toastView.show(tag: tag)
    }
    func hideToast(tag: Int) {
        self.detailView.toastView.hide(tag: tag)
    }
    func requestError(errorMessage: String) {
        self.detailView.makeToast(errorMessage, position: .center)
    }
}
// MARK: - ViewDelegate逻辑
extension ExchangeViewController: ExchangeViewHeaderViewDelegate {
    func selectInputToken() {
        self.viewModel.requestSupportTokens(tag: 10) { [weak self] (result) in
            switch result {
            case .success(_):
                print("获取所有Token成功")
            case let .failure(error):
                self?.detailView.makeToast(error.localizedDescription, position: .center)
            }
        }
    }
    func selectOutoutToken() {
        self.viewModel.requestSupportTokens(tag: 20) { [weak self] (result) in
            switch result {
            case .success(_):
                print("获取所有Token成功")
            case let .failure(error):
                self?.detailView.makeToast(error.localizedDescription, position: .center)
            }
        }
    }
    func swapInputOutputToken() {
        print("swapInputOutputToken")
        self.viewModel.swapInputOutputToken()
    }
    func exchangeConfirm() {
        self.viewModel.exchangeConfirm() { [weak self] (result) in
            switch result {
            case .success(_):
                self?.detailView.headerView.tokenSelectViewA.inputAmountTextField.text = ""
                self?.detailView.headerView.clearTokenViewAmount()
                self?.viewModel.fliterBestOutputAmount(content: "")
                self?.viewModel.fliterBestInputAmount(content: "")
                self?.detailView.makeToast(localLanguage(keyString: "wallet_market_exchange_submit_exchange_successful"), position: .center)
            case let .failure(error):
                self?.detailView.makeToast(error.localizedDescription, position: .center)
            }
        }
    }
}
// MARK: - TextField逻辑
extension ExchangeViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let content = textField.text else {
            return true
        }
        let textLength = content.count + string.count - range.length
        if textField.tag == 10 {
            if textLength == 0 {
                self.detailView.headerView.tokenSelectViewA.inputAmountTextField.text = ""
                self.detailView.headerView.tokenSelectViewB.inputAmountTextField.text = ""
                self.detailView.headerView.exchangeRateLabel.text = localLanguage(keyString: "wallet_market_exchange_rate_title") + "---"
                self.detailView.headerView.feeLabel.text = localLanguage(keyString: "wallet_market_exchange_fee_title") + "---"
            }
        } else {
            if textLength == 0 {
                self.detailView.headerView.tokenSelectViewA.inputAmountTextField.text = ""
                self.detailView.headerView.tokenSelectViewB.inputAmountTextField.text = ""
                self.detailView.headerView.exchangeRateLabel.text = localLanguage(keyString: "wallet_market_exchange_rate_title") + "---"
                self.detailView.headerView.feeLabel.text = localLanguage(keyString: "wallet_market_exchange_fee_title") + "---"
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
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        // 转入
        guard self.detailView.headerView.tokenSelectViewA.tokenButton.titleLabel?.text != localLanguage(keyString: "wallet_market_exchange_input_token_button_title") else {
            textField.resignFirstResponder()
            self.view?.makeToast(localLanguage(keyString: "wallet_market_exchange_input_token_unselect"),
                                 position: .center)
            return false
        }
        guard self.detailView.headerView.tokenSelectViewB.tokenButton.titleLabel?.text != localLanguage(keyString: "wallet_market_exchange_output_token_button_title") else {
            textField.resignFirstResponder()
            self.view?.makeToast(localLanguage(keyString: "wallet_market_exchange_output_token_unselect"),
                                 position: .center)
            return false
        }
        return true
    }
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if textField.tag == 10 {
            self.viewModel.fliterBestOutputAmount(content: textField.text ?? "")
        } else {
            self.viewModel.fliterBestInputAmount(content: textField.text ?? "")
        }
    }
    func handleInputAmount(textField: UITextField, content: String) -> Bool {
        let amount = NSDecimalNumber.init(string: content).multiplying(by: NSDecimalNumber.init(value: 1000000)).int64Value
        if textField.tag == 10 {
            if amount <= self.viewModel.tokenModelA?.amount ?? 0 {
                return true
            } else {
                let amount = getDecimalNumber(amount: NSDecimalNumber.init(value: self.viewModel.tokenModelA?.amount ?? 0),
                                              scale: 6,
                                              unit: 1000000)
                textField.text = amount.stringValue
                return false
            }
        } else {
            if amount <= self.viewModel.tokenModelB?.amount ?? 0 {
                return true
            } else {
                return false
            }
        }
    }
}
