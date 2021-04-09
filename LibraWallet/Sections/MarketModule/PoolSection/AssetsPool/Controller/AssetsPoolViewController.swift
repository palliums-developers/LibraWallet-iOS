//
//  AssetsPoolViewController.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/7/1.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit
import MJRefresh
class AssetsPoolViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        // 加载子View
        self.view.addSubview(detailView)
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        detailView.snp.makeConstraints { (make) in
            make.top.bottom.left.right.equalTo(self.view.safeAreaLayoutGuide)
        }
    }
    private lazy var viewModel: AssetsPoolViewModel = {
        let model = AssetsPoolViewModel.init()
        model.delegate = self
        return model
    }()
    /// 子View
    lazy var detailView : AssetsPoolView = {
        let view = AssetsPoolView.init()
        view.headerView.delegate = self
        view.headerView.tokenSelectViewB.inputAmountTextField.delegate = self
        view.headerView.tokenSelectViewA.inputAmountTextField.delegate = self
        return view
    }()
    
    var currentTokens: [MarketMineMainTokensDataModel]?
    
}
extension AssetsPoolViewController: AssetsPoolViewHeaderViewDelegate {
    func addLiquidityConfirm() {
        self.viewModel.confirmAddLiquidity()
    }
    func getPoolLiquidity(inputModuleName: String, outputModuleName: String) {
//        self.viewModel.getPoolLiquidity(coinA: inputModuleName,
//                                        coinB: outputModuleName)
    }
    func removeLiquidityConfirm() {
        self.viewModel.confirmRemoveLiquidity()
    }
    func selectInputToken() {
        if self.detailView.headerView.changeTypeButton.titleLabel?.text == localLanguage(keyString: localLanguage(keyString: "wallet_assets_pool_transfer_in_title")) {
            // 转入
            self.viewModel.requestMarketTokens(tag: 10)
        } else {
            // 转出
            self.detailView.makeToastActivity(.center)
            self.viewModel.requestMineLiquidity()
        }
    }
    func selectOutoutToken() {
        if self.detailView.headerView.changeTypeButton.titleLabel?.text == localLanguage(keyString: localLanguage(keyString: "wallet_assets_pool_transfer_in_title")) {
            // 转入
            self.viewModel.requestMarketTokens(tag: 20)
        }
    }
    func changeTrasferInOut() {
        
    }
}
extension AssetsPoolViewController: DropperDelegate {
    func DropperSelectedRow(_ path: IndexPath, contents: String) {
        self.detailView.headerView.tokenSelectViewA.liquidityTokenModel = self.currentTokens?[path.row]
        self.viewModel.mineLiquidity = self.currentTokens?[0]

        self.viewModel.getPoolLiquidity(coinA: self.currentTokens?[path.row].coin_a?.module ?? "",
                                        coinB: self.currentTokens?[path.row].coin_b?.module ?? "")
    }
}
extension AssetsPoolViewController: AssetsPoolViewModelDelegate {
    func refreshBestOutLiquidity() {
        self.detailView.headerView.tokenRemoveLiquidityView.transferOutModel = self.viewModel.bestOutLiquidity
    }
    func reloadSelectTokenViewA() {
        self.detailView.toastView.hide(tag: 99)
        self.detailView.headerView.tokenSelectViewA.swapTokenModel = self.viewModel.tokenModelA
    }
    func reloadSelectTokenViewB() {
        self.detailView.toastView.hide(tag: 99)
        self.detailView.headerView.tokenSelectViewB.swapTokenModel = self.viewModel.tokenModelB
    }
    func reloadMineLiquidityView() {
        self.detailView.hideToastActivity()
        var tempDropperData = [String]()
        guard let model = self.viewModel.mineLiquiditysModel, model.isEmpty == false else {
            
            self.detailView.makeToast(LibraWalletError.WalletRequest(reason: .dataEmpty).localizedDescription, position: .center)
            return
        }
        for item in self.viewModel.mineLiquiditysModel! {
            let tokenNameString = (item.coin_a?.show_name ?? "---") + "/" + (item.coin_b?.show_name ?? "---")
            tempDropperData.append(tokenNameString)
        }
        self.currentTokens = self.viewModel.mineLiquiditysModel!
        let realHeight = CGFloat((self.viewModel.mineLiquiditysModel?.count ?? 34) * 34)
        let height = realHeight > 34*6 ? 34*6:realHeight
        let dropper = Dropper.init(width: 120, height: height, button: (self.detailView.headerView.tokenSelectViewA.tokenButton))
        dropper.items = tempDropperData
        dropper.cornerRadius = 8
        dropper.theme = .black(UIColor.init(hex: "F1EEFB"))
        dropper.cellTextFont = UIFont.systemFont(ofSize: 12, weight: UIFont.Weight.regular)
        dropper.cellColor = UIColor.init(hex: "333333")
        dropper.spacing = 12
        dropper.delegate = self
        if self.detailView.headerView.tokenSelectViewA.tokenButton.titleLabel?.text != localLanguage(keyString: "wallet_market_exchange_input_token_button_title") {
            let index = tempDropperData.firstIndex(of: self.detailView.headerView.tokenSelectViewA.tokenButton.titleLabel?.text ?? "")
            dropper.defaultSelectRow = index
        }
        dropper.isInvisableBackground = true
        dropper.show(Dropper.Alignment.center, button: (self.detailView.headerView.tokenSelectViewA.tokenButton))
    }
    func reloadLiquidityRateView() {
        self.detailView.toastView.hide(tag: 99)
        self.detailView.headerView.modelABLiquidityInfo = self.viewModel.modelABLiquidityInfo
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
    func successAddLiquidity() {
        self.detailView.headerView.tokenSelectViewA.inputAmountTextField.text = ""
        self.detailView.headerView.tokenSelectViewB.inputAmountTextField.text = ""
        self.detailView.makeToast(localLanguage(keyString: "wallet_transfer_success_alert"), position: .center)
    }
    func successRemoveLiquidity() {
        self.detailView.headerView.tokenSelectViewA.inputAmountTextField.text = ""
        self.detailView.headerView.tokenSelectViewB.inputAmountTextField.text = ""
        self.detailView.headerView.tokenRemoveLiquidityView.outputCoinAAmountLabel.text = "---"
        self.detailView.headerView.tokenRemoveLiquidityView.outputCoinBAmountLabel.text = "---"
        self.detailView.makeToast(localLanguage(keyString: "wallet_transfer_success_alert"), position: .center)
    }
    func refreshBestInput() {
        self.detailView.headerView.tokenSelectViewA.inputAmountTextField.text = self.viewModel.bestInAmount
    }
    func refreshBestOutput() {
        self.detailView.headerView.tokenSelectViewB.inputAmountTextField.text = self.viewModel.bestOutAmount
    }
}
extension AssetsPoolViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let content = textField.text else {
            return true
        }
        let textLength = content.count + string.count - range.length
        if textField.tag == 10 {
            if textLength == 0 {
                self.detailView.headerView.tokenSelectViewA.inputAmountTextField.text = ""
            }
        } else {
            if textLength == 0 {
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
        if self.detailView.headerView.changeTypeButton.titleLabel?.text == localLanguage(keyString: localLanguage(keyString: "wallet_assets_pool_transfer_in_title")) {
            // 转入
            guard self.detailView.headerView.tokenSelectViewA.tokenButton.titleLabel?.text != localLanguage(keyString: "wallet_market_exchange_input_token_button_title") else {
                textField.resignFirstResponder()
                self.detailView.makeToast(localLanguage(keyString: "wallet_assets_pool_add_liquidity_unselect_first_deposit_token_content"), position: .center)
                return false
            }
            guard self.detailView.headerView.tokenSelectViewB.tokenButton.titleLabel?.text != localLanguage(keyString: "wallet_market_exchange_output_token_button_title") else {
                textField.resignFirstResponder()
                self.detailView.makeToast(localLanguage(keyString: "wallet_assets_pool_add_liquidity_unselect_second_deposit_token_content"), position: .center)
                return false
            }
            
        } else {
            // 转出
            guard self.detailView.headerView.tokenSelectViewA.tokenButton.titleLabel?.text != localLanguage(keyString: "wallet_market_exchange_input_token_button_title") else {
                textField.resignFirstResponder()
                self.detailView.makeToast(localLanguage(keyString: "wallet_assets_pool_remove_liquidity_unselect_token"), position: .center)
                return false
            }
        }
        return true
    }
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if textField.tag == 10 {
            if self.detailView.headerView.changeTypeButton.titleLabel?.text == localLanguage(keyString: localLanguage(keyString: "wallet_assets_pool_transfer_in_title")) {
                // 资金池添加流动性
                if let text = textField.text, text.isEmpty == true {
                    self.detailView.headerView.tokenSelectViewA.inputAmountTextField.text = ""
                    self.detailView.headerView.tokenSelectViewB.inputAmountTextField.text = ""
                }
                self.viewModel.fliterBestOutputAmount(content: textField.text ?? "")

            } else {
                // 资金池移除流动性
                if let text = textField.text, text.isEmpty == true {
                    self.detailView.headerView.tokenSelectViewB.balanceAmountLabel.text = "---"
                    self.detailView.headerView.tokenSelectViewB.balanceAmountLabel.text = "---"
                }
                self.viewModel.fliterBestOutputLiquidity(content: textField.text ?? "")
            }
        } else {
            guard self.detailView.headerView.tokenSelectViewB.tokenButton.titleLabel?.text != localLanguage(keyString: "wallet_market_exchange_output_token_button_title") else {
                return
            }
//            guard self.detailView.headerView.autoCalculateMode == true else {
//                return
//            }
            if self.detailView.headerView.changeTypeButton.titleLabel?.text == localLanguage(keyString: localLanguage(keyString: "wallet_assets_pool_transfer_in_title")) {
                // 转入
                if let text = textField.text, text.isEmpty == true {
                    self.detailView.headerView.tokenSelectViewA.inputAmountTextField.text = ""
                    self.detailView.headerView.tokenSelectViewB.inputAmountTextField.text = ""
                }
                self.viewModel.fliterBestInputAmount(content: textField.text ?? "")
            }
        }
    }
    func handleInputAmount(textField: UITextField, content: String) -> Bool {
        let amount = NSDecimalNumber.init(string: content).multiplying(by: NSDecimalNumber.init(value: 1000000)).int64Value
        if textField.tag == 10 {
            if self.detailView.headerView.changeTypeButton.titleLabel?.text == localLanguage(keyString: localLanguage(keyString: "wallet_assets_pool_transfer_in_title")) {
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
                if amount <= self.detailView.headerView.tokenSelectViewA.liquidityTokenModel?.token ?? 0 {
                    return true
                } else {
                    let amount = getDecimalNumber(amount: NSDecimalNumber.init(value: self.detailView.headerView.tokenSelectViewA.liquidityTokenModel?.token ?? 0),
                                                  scale: 6,
                                                  unit: 1000000)
                    textField.text = amount.stringValue
                    return false
                }
            }

        } else {
            if amount <= self.viewModel.tokenModelB?.amount ?? 0 {
                return true
            } else {
                let amount = getDecimalNumber(amount: NSDecimalNumber.init(value: self.viewModel.tokenModelB?.amount ?? 0),
                                              scale: 6,
                                              unit: 1000000)
                textField.text = amount.stringValue
                return false
            }
        }
    }
}
