//
//  ExchangeViewController.swift
//  LibraWallet
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
extension ExchangeViewController: ExchangeViewModelDelegate {
    func reloadSelectTokenViewA() {
        self.detailView.headerView.tokenSelectViewA.swapTokenModel = self.viewModel.tokenModelA
        self.detailView.toastView.hide(tag: 99)
    }
    func reloadSelectTokenViewB() {
        self.detailView.headerView.tokenSelectViewB.swapTokenModel = self.viewModel.tokenModelB
        self.detailView.toastView.hide(tag: 99)
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
extension ExchangeViewController: ExchangeViewHeaderViewDelegate {
    func selectInputToken() {
        self.detailView.toastView.show(tag: 99)
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
        self.detailView.toastView.show(tag: 99)
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
        self.detailView.toastView.show(tag: 99)
        self.viewModel.exchangeConfirm() { [weak self] (result) in
            self?.detailView.toastView.hide(tag: 99)
            switch result {
            case .success(_):
                self?.detailView.headerView.tokenSelectViewA.inputAmountTextField.text = ""
                self?.detailView.headerView.clearTokenViewAmount()
                self?.filterBestOutput(content: "")
                self?.filterBestIntput(content: "")
                self?.detailView.makeToast(localLanguage(keyString: "wallet_market_exchange_submit_exchange_successful"), position: .center)
            case let .failure(error):
                self?.detailView.makeToast(error.localizedDescription, position: .center)
            }
        }
    }
    func filterBestOutput(content: String) {
        self.viewModel.fliterBestOutputAmount(content: content)
    }
    func filterBestIntput(content: String) {
        self.viewModel.fliterBestInputAmount(content: content)
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
            }
        } else {
            if textLength == 0 {
                self.detailView.headerView.tokenSelectViewA.inputAmountTextField.text = ""
                self.detailView.headerView.tokenSelectViewB.inputAmountTextField.text = ""
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
            self.viewModel.fliterBestInputAmount(content: textField.text ?? "0.0")
            if (self.viewModel.swapInfoModel?.input ?? 0) < (self.viewModel.tokenModelA?.amount ?? 0) {
                return true
            } else {
                let amount = getDecimalNumber(amount: NSDecimalNumber.init(value: self.viewModel.swapInfoModel?.output ?? 0),
                                              scale: 6,
                                              unit: 1000000)
                textField.text = amount.stringValue
                return false
            }
//            if amount <= self.viewModel.tokenModelB?.amount ?? 0 {
//                return true
//            } else {
//                let amount = getDecimalNumber(amount: NSDecimalNumber.init(value: self.viewModel.tokenModelB?.amount ?? 0),
//                                              scale: 6,
//                                              unit: 1000000)
//                textField.text = amount.stringValue
//                return false
//            }
        }
    }
}
