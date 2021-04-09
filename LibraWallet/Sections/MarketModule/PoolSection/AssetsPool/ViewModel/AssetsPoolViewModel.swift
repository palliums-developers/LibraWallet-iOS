//
//  AssetsPoolViewModel.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/8/3.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit

protocol AssetsPoolViewModelDelegate: NSObjectProtocol {
    func reloadSelectTokenViewA()
    func reloadSelectTokenViewB()
    func reloadMineLiquidityView()
    func reloadLiquidityRateView()
    func showToast(tag: Int)
    func hideToast(tag: Int)
    func requestError(errorMessage: String)
    func successAddLiquidity()
    func successRemoveLiquidity()
    func refreshBestInput()
    func refreshBestOutput()
    func refreshBestOutLiquidity()
}
protocol AssetsPoolViewModelInterface  {
    /// 付出Token
    var tokenModelA: MarketSupportTokensDataModel? { get }
    /// 付出Token
    var tokenModelB: MarketSupportTokensDataModel? { get }
    /// 我的通证
    var mineLiquidityModel: MarketMineMainTokensDataModel? { get }
    /// 我的所有通证
    var mineLiquiditysModel: [MarketMineMainTokensDataModel]? { get }
    /// 流动性Model
    var modelABLiquidityInfo: AssetsPoolsInfoDataModel? { get }
    /// 输入比例
    var bestInAmount: String? { get }
    /// 输出比例
    var bestOutAmount: String? { get }
    /// 输出比例
    var bestOutLiquidity: AssetsPoolTransferOutInfoDataModel? { get }
}
class AssetsPoolViewModel: NSObject, AssetsPoolViewModelInterface {
    weak var delegate: AssetsPoolViewModelDelegate?

    var tokenModelA: MarketSupportTokensDataModel? {
        return self.modelA
    }
    var tokenModelB: MarketSupportTokensDataModel? {
        return self.modelB
    }
    /// 我的通证
    var mineLiquidityModel: MarketMineMainTokensDataModel? {
        return self.mineLiquidity
    }
    var mineLiquiditysModel: [MarketMineMainTokensDataModel]? {
        return self.mineLiquiditys
    }
    var modelABLiquidityInfo: AssetsPoolsInfoDataModel? {
        return self.modelABLiquidity
    }
    /// 输入比例
    var bestInAmount: String? {
        return self.inputAmountString
    }
    /// 输出比例
    var bestOutAmount: String? {
        return self.outputAmountString
    }
    var bestOutLiquidity: AssetsPoolTransferOutInfoDataModel? {
        return self.outLiquidity
    }
    private var modelA: MarketSupportTokensDataModel? {
        didSet {
            self.delegate?.reloadSelectTokenViewA()
            if let a = modelA, let b = modelB {
                self.getPoolLiquidity(coinA: a.module ?? "", coinB: b.module ?? "")
            }
        }
    }
    private var modelB: MarketSupportTokensDataModel? {
        didSet {
            self.delegate?.reloadSelectTokenViewB()
            if let a = modelA, let b = modelB {
                self.getPoolLiquidity(coinA: a.module ?? "", coinB: b.module ?? "")
            }
        }
    }
    var mineLiquidity: MarketMineMainTokensDataModel?
    
    private var mineLiquiditys: [MarketMineMainTokensDataModel]? {
        didSet {
            self.delegate?.reloadMineLiquidityView()
        }
    }
    private var modelABLiquidity: AssetsPoolsInfoDataModel? {
        didSet {
            self.delegate?.reloadLiquidityRateView()
        }
    }
    /// 付出数量输入框内容
    private var inputAmountString: String?
    /// 兑换数量输入框内容
    private var outputAmountString: String?
    
    private var outLiquidity: AssetsPoolTransferOutInfoDataModel?
    /// 网络请求、数据模型
    lazy var dataModel: AssetsPoolModel = {
        let model = AssetsPoolModel.init()
        return model
    }()
    deinit {
        print("AssetsPoolViewModel销毁了")
    }
}
extension AssetsPoolViewModel {
    func fliterBestOutputAmount(content: String) {
        self.inputAmountString = content
        let amount = NSDecimalNumber.init(string: content)
        if amount.doubleValue > 0 {
            let number = amount.multiplying(by: NSDecimalNumber.init(value: 1000000))
            let coinAValue = NSDecimalNumber.init(value: self.modelABLiquidityInfo?.coina?.value ?? 0)
            let rate = number.dividing(by: coinAValue)
            let amountB = getDecimalNumber(amount: NSDecimalNumber.init(value: self.modelABLiquidityInfo?.coinb?.value ?? 0).multiplying(by: rate),
                                           scale: 6,
                                           unit: 1000000)
            self.outputAmountString = amountB.stringValue
        } else {
            self.outputAmountString = ""
        }
        self.delegate?.refreshBestOutput()
    }
    func fliterBestInputAmount(content: String) {
        self.outputAmountString = content
        let amount = NSDecimalNumber.init(string: content)
        if amount.doubleValue > 0 {
            let amount = NSDecimalNumber.init(string: content).multiplying(by: NSDecimalNumber.init(value: 1000000))
            let coinBValue = NSDecimalNumber.init(value: self.modelABLiquidityInfo?.coinb?.value ?? 0)
            let rate = amount.dividing(by: coinBValue)
            let amountA = getDecimalNumber(amount: NSDecimalNumber.init(value: self.modelABLiquidityInfo?.coina?.value ?? 0).multiplying(by: rate),
                                           scale: 6,
                                           unit: 1000000)
            self.inputAmountString = amountA.stringValue
        } else {
            self.inputAmountString = ""
        }
        self.delegate?.refreshBestInput()
    }
    func fliterBestOutputLiquidity(content: String) {
        self.inputAmountString = content
        let amount = NSDecimalNumber.init(string: content)
        if amount.doubleValue > 0 {
            let totalToken = NSDecimalNumber.init(value: self.modelABLiquidity?.liquidity_total_supply ?? 0)
            let aaa = amount.multiplying(by: NSDecimalNumber.init(value: 1000000))
            let rate = aaa.dividing(by: totalToken)
            let numberConfig = NSDecimalNumberHandler.init(roundingMode: .down,
                                                           scale: 6,
                                                           raiseOnExactness: false,
                                                           raiseOnOverflow: false,
                                                           raiseOnUnderflow: false,
                                                           raiseOnDivideByZero: false)
            let amountA = NSDecimalNumber.init(value: self.modelABLiquidity?.coina?.value ?? 0).multiplying(by: rate, withBehavior: numberConfig)
            
            let amountB = NSDecimalNumber.init(value: self.modelABLiquidity?.coinb?.value ?? 0).multiplying(by: rate, withBehavior: numberConfig)
            self.outLiquidity = AssetsPoolTransferOutInfoDataModel.init(coin_a_value: amountA.uint64Value,
                                                                        coin_b_value: amountB.uint64Value,
                                                                        coin_a_name: self.modelABLiquidity?.coina?.name,
                                                                        coin_b_name: self.modelABLiquidity?.coinb?.name)
        } else {
            self.outLiquidity = AssetsPoolTransferOutInfoDataModel.init(coin_a_value: 0,
                                                                        coin_b_value: 0,
                                                                        coin_a_name: self.modelABLiquidity?.coina?.name,
                                                                        coin_b_name: self.modelABLiquidity?.coinb?.name)
        }
        self.delegate?.refreshBestOutLiquidity()
    }
    func handleAddLiquidityCondition() throws -> (NSDecimalNumber, NSDecimalNumber, MarketSupportTokensDataModel, MarketSupportTokensDataModel) {
        // ModelA不为空
        guard let tempInputTokenA = self.modelA else {
            throw LibraWalletError.error(localLanguage(keyString: "wallet_market_exchange_input_token_unselect"))
        }
        // ModelB不为空
        guard let tempInputTokenB = self.modelB else {
            throw LibraWalletError.error(localLanguage(keyString: "wallet_market_exchange_output_token_unselect"))
        }
        // 付出币A激活状态
        guard let tokenAActiveState = tempInputTokenA.activeState, tokenAActiveState == true else {
            throw LibraWalletError.error(localLanguage(keyString: "wallet_assets_pool_add_liquidity_token_unpublish_content"))
        }
        // 付出币B激活状态
        guard let tokenBActiveState = tempInputTokenB.activeState, tokenBActiveState == true else {
            throw LibraWalletError.error(localLanguage(keyString: "wallet_assets_pool_add_liquidity_token_unpublish_content"))
        }
        // 金额A不为空检查
        guard let amountAString = self.inputAmountString, amountAString.isEmpty == false else {
            throw LibraWalletError.WalletTransfer(reason: .amountEmpty)
        }
        // 金额B不为空检查
        guard let amountBString = self.outputAmountString, amountBString.isEmpty == false else {
            throw LibraWalletError.WalletTransfer(reason: .amountEmpty)
        }
        // 金额A是否纯数字检查
        guard isPurnDouble(string: amountAString) == true else {
            throw LibraWalletError.WalletTransfer(reason: .amountInvalid)
        }
        // 金额B是否纯数字检查
        guard isPurnDouble(string: amountBString) == true else {
            throw LibraWalletError.WalletTransfer(reason: .amountInvalid)
        }
        // A转换数字
        let amountIn = NSDecimalNumber.init(string: amountAString)
        guard amountIn.doubleValue > 0 else {
            throw LibraWalletError.WalletTransfer(reason: .amountInvalid)
        }
        // B转换数字
        let amountOut = NSDecimalNumber.init(string: amountBString)
        guard amountOut.doubleValue > 0 else {
            throw LibraWalletError.WalletTransfer(reason: .amountInvalid)
        }
        // 金额A超限检测
        guard amountIn.multiplying(by: NSDecimalNumber.init(value: 1000000)).int64Value <= (tempInputTokenA.amount ?? 0) else {
            throw LibraWalletError.WalletTransfer(reason: .amountOverload)
        }
        // 金额B超限检测
        guard amountOut.multiplying(by: NSDecimalNumber.init(value: 1000000)).int64Value <= (tempInputTokenB.amount ?? 0) else {
            throw LibraWalletError.WalletTransfer(reason: .amountOverload)
        }
        if (tempInputTokenA.index ?? 0) > (tempInputTokenB.index ?? 0) {
            return (amountOut.multiplying(by: NSDecimalNumber.init(value: 1000000)),
                    amountIn.multiplying(by: NSDecimalNumber.init(value: 1000000)),
                    tempInputTokenB,
                    tempInputTokenA)
        } else {
            return (amountIn.multiplying(by: NSDecimalNumber.init(value: 1000000)),
                    amountOut.multiplying(by: NSDecimalNumber.init(value: 1000000)),
                    tempInputTokenA,
                    tempInputTokenB)
        }
    }
    func handleRemoveLiquidityCondition() throws -> (UInt64, UInt64, String, String) {
        // Liquidity不为空
        guard let liquidity = self.mineLiquidity else {
            throw LibraWalletError.error(localLanguage(keyString: "wallet_assets_pool_remove_liquidity_unselect_token"))
        }
        guard let totalToken = liquidity.token, totalToken > 0 else {
            throw LibraWalletError.error(localLanguage(keyString: "wallet_assets_pool_remove_liquidity_not_enough_token"))
        }
        // 金额A不为空检查
        guard let amountAString = self.inputAmountString, amountAString.isEmpty == false else {
            throw LibraWalletError.WalletTransfer(reason: .amountEmpty)
        }
        // 金额A是否纯数字检查
        guard isPurnDouble(string: amountAString) == true else {
            throw LibraWalletError.WalletTransfer(reason: .amountInvalid)
        }
        // A转换数字
        let amountIn = NSDecimalNumber.init(string: amountAString)
        guard amountIn.doubleValue > 0 else {
            throw LibraWalletError.WalletTransfer(reason: .amountInvalid)
        }
        return ((self.outLiquidity?.coin_a_value)!, (self.outLiquidity?.coin_b_value)!, (self.outLiquidity?.coin_a_name)!, (self.outLiquidity?.coin_b_name)!)
    }

}
//extension AssetsPoolViewModel: UITextFieldDelegate {
//    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//        guard let content = textField.text else {
//            return true
//        }
//        let textLength = content.count + string.count - range.length
//        if textField.tag == 10 {
//            if textLength == 0 {
//                tokenSelectViewA.inputAmountTextField.text = ""
//            }
//        } else {
//            if textLength == 0 {
//                outputAmountTextField.text = ""
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
//        if changeTypeButton.titleLabel?.text == localLanguage(keyString: localLanguage(keyString: "wallet_assets_pool_transfer_in_title")) {
//            // 转入
//            guard tokenSelectViewA.tokenButton.titleLabel?.text != localLanguage(keyString: "wallet_market_exchange_input_token_button_title") else {
//                textField.resignFirstResponder()
//                self.makeToast(localLanguage(keyString: "wallet_assets_pool_add_liquidity_unselect_first_deposit_token_content"),
//                               position: .center)
//                return false
//            }
//            guard outputTokenButton.titleLabel?.text != localLanguage(keyString: "wallet_market_exchange_output_token_button_title") else {
//                textField.resignFirstResponder()
//                self.makeToast(localLanguage(keyString: "wallet_assets_pool_add_liquidity_unselect_second_deposit_token_content"),
//                               position: .center)
//                return false
//            }
//
//        } else {
//            // 转出
//            guard tokenSelectViewA.tokenButton.titleLabel?.text != localLanguage(keyString: "wallet_market_exchange_input_token_button_title") else {
//                textField.resignFirstResponder()
//                self.makeToast(localLanguage(keyString: "wallet_assets_pool_remove_liquidity_unselect_token"),
//                               position: .center)
//                return false
//            }
//        }
//        return true
//    }
//    func textFieldDidChangeSelection(_ textField: UITextField) {
//        if textField.tag == 10 {
//            guard let model = liquidityInfoModel else {
//                return
//            }
//            if self.changeTypeButton.titleLabel?.text == localLanguage(keyString: localLanguage(keyString: "wallet_assets_pool_transfer_in_title")) {
//                // 资金池添加流动性
//                guard let text = textField.text, text.isEmpty == false else {
//                    self.tokenSelectViewA.inputAmountTextField.text = ""
//                    self.outputAmountTextField.text = ""
//                    return
//                }
//                self.viewState = .AssetsPoolTransferInBaseOnInputARequestRate
//                let amount = NSDecimalNumber.init(string: text).multiplying(by: NSDecimalNumber.init(value: 1000000))
//                let coinAValue = NSDecimalNumber.init(value: model.coina?.value ?? 0)
//                let rate = amount.dividing(by: coinAValue)
//                let amountB = getDecimalNumber(amount: NSDecimalNumber.init(value: model.coinb?.value ?? 0).multiplying(by: rate),
//                                               scale: 6,
//                                               unit: 1000000)
//                outputAmountTextField.text = amountB.stringValue
//                self.viewState = .Normal
//            } else {
//                // 资金池移除流动性
//                guard let text = textField.text, text.isEmpty == false else {
//                    self.outputCoinAAmountLabel.text = "---"
//                    self.outputCoinBAmountLabel.text = "---"
//                    return
//                }
//                self.viewState = .AssetsPoolTransferInBaseOnInputBRequestRate
//                let totalToken = NSDecimalNumber.init(value: model.liquidity_total_supply ?? 0)
//                let amount = NSDecimalNumber.init(string: text).multiplying(by: NSDecimalNumber.init(value: 1000000))
//                let rate = amount.dividing(by: totalToken)
//                let amountA = getDecimalNumber(amount: NSDecimalNumber.init(value: model.coina?.value ?? 0).multiplying(by: rate),
//                                               scale: 6,
//                                               unit: 1000000)
//                outputCoinAAmountLabel.text = amountA.stringValue + (model.coina?.name ?? "---")
//                let amountB = getDecimalNumber(amount: NSDecimalNumber.init(value: model.coinb?.value ?? 0).multiplying(by: rate),
//                                               scale: 6,
//                                               unit: 1000000)
//                outputCoinBAmountLabel.text = amountB.stringValue + (model.coinb?.name ?? "---")
//                self.viewState = .Normal
//            }
//        } else {
//            guard outputTokenButton.titleLabel?.text != localLanguage(keyString: "wallet_market_exchange_output_token_button_title") else {
//                return
//            }
//            guard autoCalculateMode == true else {
//                return
//            }
//            guard let model = liquidityInfoModel else {
//                return
//            }
//            if self.changeTypeButton.titleLabel?.text == localLanguage(keyString: localLanguage(keyString: "wallet_assets_pool_transfer_in_title")) {
//                // 转入
//                self.viewState = .AssetsPoolTransferInBaseOnInputBRequestRate
//                guard let text = textField.text, text.isEmpty == false else {
//                    self.tokenSelectViewA.inputAmountTextField.text = ""
//                    self.outputAmountTextField.text = ""
//                    return
//                }
//                self.viewState = .AssetsPoolTransferInBaseOnInputARequestRate
//                let amount = NSDecimalNumber.init(string: text).multiplying(by: NSDecimalNumber.init(value: 1000000))
//                let coinBValue = NSDecimalNumber.init(value: model.coinb?.value ?? 0)
//                let rate = amount.dividing(by: coinBValue)
//                let amountA = getDecimalNumber(amount: NSDecimalNumber.init(value: model.coina?.value ?? 0).multiplying(by: rate),
//                                               scale: 6,
//                                               unit: 1000000)
//                tokenSelectViewA.inputAmountTextField.text = amountA.stringValue
//                self.viewState = .Normal
//            }
//        }
//    }
//    func handleInputAmount(textField: UITextField, content: String) -> Bool {
//        let amount = NSDecimalNumber.init(string: content).multiplying(by: NSDecimalNumber.init(value: 1000000)).int64Value
//        if textField.tag == 10 {
//            if self.changeTypeButton.titleLabel?.text == localLanguage(keyString: localLanguage(keyString: "wallet_assets_pool_transfer_in_title")) {
//                if amount <= transferInInputTokenA?.amount ?? 0 {
//                    return true
//                } else {
//                    let amount = getDecimalNumber(amount: NSDecimalNumber.init(value: transferInInputTokenA?.amount ?? 0),
//                                                  scale: 6,
//                                                  unit: 1000000)
//                    textField.text = amount.stringValue
//                    return false
//                }
//            } else {
//                if amount <= tokenModel?.token ?? 0 {
//                    return true
//                } else {
//                    let amount = getDecimalNumber(amount: NSDecimalNumber.init(value: tokenModel?.token ?? 0),
//                                                  scale: 6,
//                                                  unit: 1000000)
//                    textField.text = amount.stringValue
//                    return false
//                }
//            }
//
//        } else {
//            if amount <= transferInInputTokenB?.amount ?? 0 {
//                return true
//            } else {
//                let amount = getDecimalNumber(amount: NSDecimalNumber.init(value: transferInInputTokenB?.amount ?? 0),
//                                              scale: 6,
//                                              unit: 1000000)
//                textField.text = amount.stringValue
//                return false
//            }
//        }
//    }
//}

// MARK: - 获取资金池中个人流动性
extension AssetsPoolViewModel {
    func requestMineLiquidity() {
        self.dataModel.getMarketMineTokens(address: Wallet.shared.violasAddress ?? "") { [weak self] (result) in
            switch result {
            case let .success(model):
                self?.mineLiquiditys = model.balance
            case let .failure(error):
                self?.delegate?.requestError(errorMessage: error.localizedDescription)
            }
        }
    }
}
// MARK: - 获取交易所支持币种
extension AssetsPoolViewModel {
    func requestMarketTokens(tag: Int) {
        self.delegate?.showToast(tag: 99)
        self.dataModel.getMarketTokens(address: Wallet.shared.violasAddress ?? "") { [weak self] (result) in
            self?.delegate?.hideToast(tag: 99)
            switch result {
            case let .success(models):
                guard models.isEmpty == false else {
                    self?.delegate?.requestError(errorMessage: LibraWalletError.WalletMarket(reason: .marketOffline).localizedDescription)
                    return
                }
                let tempData = models.filter {
                    $0.module != (tag == 10 ? self?.modelB:self?.modelA)?.module
                }
                let alert = MappingTokenListAlert.init(data: tempData) { (model) in
                    print(model)
                    if tag == 10 {
                        self?.modelA = model
                    } else {
                        self?.modelB = model
                    }
                }
                alert.show(tag: 199)
                alert.showAnimation()
            case let .failure(error):
                self?.delegate?.requestError(errorMessage: error.localizedDescription)
            }
        }
    }
}
// MARK: - 获取交易所流动性
extension AssetsPoolViewModel {
    func getPoolLiquidity(coinA: String, coinB: String) {
        self.delegate?.showToast(tag: 99)
        self.dataModel.getPoolLiquidity(coinA: coinA, coinB: coinB) { (result) in
            switch result {
            case let .success(model):
                self.modelABLiquidity = model
            case let .failure(error):
                self.delegate?.requestError(errorMessage: error.localizedDescription)
            }
        }
    }
}
// MARK: - 添加交易所流动性
extension AssetsPoolViewModel {
    func confirmAddLiquidity() {
        do {
            let (amountIn, amountOut, inputModel, outputModel) = try handleAddLiquidityCondition()
            WalletManager.unlockWallet { [weak self] (result) in
                switch result {
                case let .success(mnemonic):
                    self?.delegate?.showToast(tag: 99)
                    self?.dataModel.sendAddLiquidityViolasTransaction(sendAddress: Wallet.shared.violasAddress ?? "", amounta_desired: amountIn.uint64Value, amountb_desired: amountOut.uint64Value, amounta_min: UInt64(Double(amountIn.uint64Value) * 0.995), amountb_min: UInt64(Double(amountOut.uint64Value) * 0.995), fee: 0, mnemonic: mnemonic, moduleA: inputModel.module ?? "", moduleB: outputModel.module ?? "", feeModule: inputModel.module ?? "") { [weak self] (result) in
                        self?.delegate?.hideToast(tag: 99)
                        switch result {
                        case .success(_):
                            self?.delegate?.successAddLiquidity()
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
}
// MARK: - 移除交易所流动性
extension AssetsPoolViewModel {
    func confirmRemoveLiquidity() {
        do {
            let (amountOutA, amountOutB, inputModelName, outputModelName) = try handleRemoveLiquidityCondition()
            WalletManager.unlockWallet { [weak self] (result) in
                switch result {
                case let .success(mnemonic):
                    self?.delegate?.showToast(tag: 99)
                    let liquidityAmount = NSDecimalNumber.init(string: self?.inputAmountString).multiplying(by: NSDecimalNumber.init(value: 1000000)).uint64Value
                    self?.dataModel.sendRemoveLiquidityViolasTransaction(sendAddress: Wallet.shared.violasAddress ?? "", liquidity: liquidityAmount, amounta_min: amountOutA, amountb_min: amountOutB, fee: 0, mnemonic: mnemonic, moduleA: inputModelName, moduleB: outputModelName, feeModule: inputModelName) { [weak self] (result) in
                        self?.delegate?.hideToast(tag: 99)
                        switch result {
                        case .success(_):
                            self?.delegate?.successRemoveLiquidity()
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
}
