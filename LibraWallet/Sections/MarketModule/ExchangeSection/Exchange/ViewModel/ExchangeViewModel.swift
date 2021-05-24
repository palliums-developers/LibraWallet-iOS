//
//  ExchangeViewModel.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/8/4.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit

protocol ExchangeViewModelDelegate: NSObjectProtocol {
    func reloadSelectTokenViewA()
    func reloadSelectTokenViewB()
    func reloadView()
    func showToast(tag: Int)
    func hideToast(tag: Int)
    func requestError(errorMessage: String)
}
protocol ExchangeViewModelInterface  {
    /// 付出Token
    var tokenModelA: MarketSupportTokensDataModel? { get }
    /// 兑换Token
    var tokenModelB: MarketSupportTokensDataModel? { get }
    /// 兑换比例Model
    var swapInfoModel: ExchangeInfoModel? { get }
    /// 交换付出兑换方法
    func swapInputOutputToken()
}
class ExchangeViewModel: NSObject, ExchangeViewModelInterface {
    weak var delegate: ExchangeViewModelDelegate?
    /// 付出Token（只读）
    var tokenModelA: MarketSupportTokensDataModel? {
        return self.modelA
    }
    /// 兑换Token（只读）
    var tokenModelB: MarketSupportTokensDataModel? {
        return self.modelB
    }
    /// 交换比例Model（只读）
    var swapInfoModel: ExchangeInfoModel? {
        return self.exchangeModel
    }
    /// 交换付出兑换Token方法
    func swapInputOutputToken() {
        guard let tempTokenA = self.modelA else {
            return
        }
        guard let tempTokenB = self.modelB else {
            return
        }
        self.modelA = tempTokenB
        self.modelB = tempTokenA
    }
    /// 网络请求、数据模型
    private lazy var dataModel: ExchangeModel = {
        let model = ExchangeModel.init()
        return model
    }()
    /// 首次获取兑换率
    private var isFirstRequestRate: Bool = true
    /// 刷新Timer
    private var timer: Timer?
    /// 付出Token（内部访问）
    private var modelA: MarketSupportTokensDataModel? {
        didSet {
            self.delegate?.reloadSelectTokenViewA()
            if let _ = modelA, let _ = modelB {
                self.dealTransferOutAmount()
            }
        }
    }
    /// 兑换Token（内部访问）
    private var modelB: MarketSupportTokensDataModel? {
        didSet {
            self.delegate?.reloadSelectTokenViewB()
            if let _ = modelA, let _ = modelB {
                self.dealTransferOutAmount()
            }
        }
    }
    /// 兑换比例（内部访问）
    private var exchangeModel: ExchangeInfoModel? {
        didSet {
            self.delegate?.reloadView()
        }
    }
    /// 付出数量输入框内容
    private var inputAmountString: String?
    /// 兑换数量输入框内容
    private var outputAmountString: String?
}
// MARK: - 兑换逻辑
extension ExchangeViewModel {
    func exchangeConfirm(completion: @escaping (Result<Bool, LibraWalletError>) -> Void) {
        do {
            let (amountIn, amountOut, tempInputTokenA, tempInputTokenB) = try handleConfirmCondition()
            var leastModuleA = tempInputTokenA
            var otherModuleB = tempInputTokenB
            // 序号小在前
            if (tempInputTokenA.index ?? 0) > (tempInputTokenB.index ?? 0) {
                leastModuleA = tempInputTokenB
                otherModuleB = tempInputTokenA
            }
            if let tokenBActiveState = tempInputTokenB.activeState, tokenBActiveState == true {
                // 已激活
                self.handleUnlockWallet() { [weak self] (result) in
                    switch result {
                    case let .success(mnemonic):
                        self?.delegate?.showToast(tag: 99)
                        self?.handleRequest(inputAmount: amountIn.multiplying(by: NSDecimalNumber.init(value: 1000000)),
                                            outputAmount: amountOut.multiplying(by: NSDecimalNumber.init(value: 1000000)),
                                            inputModule: leastModuleA,
                                            outputModule: otherModuleB,
                                            mnemonic: mnemonic,
                                            outputModuleActiveState: true,
                                            completion: completion)
                    case let .failure(error):
                        completion(.failure(error))
                    }
                }
            } else {
                // 未激活
                let alertContr = UIAlertController(title: localLanguage(keyString: "wallet_alert_delete_address_title"), message: localLanguage(keyString: "wallet_market_exchange_output_token_unactived"), preferredStyle: .alert)
                alertContr.addAction(UIAlertAction(title: localLanguage(keyString: "wallet_alert_delete_address_confirm_button_title"), style: .default){ [weak self] clickHandler in
                    self?.handleUnlockWallet() { (result) in
                        switch result {
                        case let .success(mnemonic):
                            self?.delegate?.showToast(tag: 99)
                            self?.handleRequest(inputAmount: amountIn.multiplying(by: NSDecimalNumber.init(value: 1000000)),
                                                outputAmount: amountOut.multiplying(by: NSDecimalNumber.init(value: 1000000)),
                                                inputModule: leastModuleA,
                                                outputModule: otherModuleB,
                                                mnemonic: mnemonic,
                                                outputModuleActiveState: false,
                                                completion: completion)
                        case let .failure(error):
                            completion(.failure(error))
                        }
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
        } catch {
            completion(.failure(error as! LibraWalletError))
        }
    }
    
    func handleUnlockWallet(completion: @escaping (Result<[String], LibraWalletError>) -> Void) {
        WalletManager.unlockWallet { (result) in
            switch result {
            case let .success(mnemonic):
                completion(.success(mnemonic))
            case let .failure(error):
                guard error.localizedDescription != "Cancel" else {
                    return
                }
                completion(.failure(LibraWalletError.error(error.localizedDescription)))
            }
        }
    }
    func handleRequest(inputAmount: NSDecimalNumber, outputAmount: NSDecimalNumber, inputModule: MarketSupportTokensDataModel, outputModule: MarketSupportTokensDataModel, mnemonic: [String], outputModuleActiveState: Bool, completion: @escaping (Result<Bool, LibraWalletError>) -> Void) {
        print("ViolasToViolasSwap")
        self.dataModel.sendSwapViolasTransaction(sendAddress: Wallet.shared.violasAddress ?? "",
                                                 amountIn: inputAmount.uint64Value,
                                                 AmountOutMin: outputAmount.multiplying(by: NSDecimalNumber.init(value: 0.99)).uint64Value,
                                                 path: (self.exchangeModel?.path)!,
                                                 fee: 1,
                                                 mnemonic: mnemonic,
                                                 moduleA: inputModule.module ?? "",
                                                 moduleB: outputModule.module ?? "",
                                                 feeModule: inputModule.module ?? "",
                                                 outputModuleActiveState: outputModuleActiveState) { [weak self] (result) in
            self?.delegate?.hideToast(tag: 99)
            switch result {
            case let .success(state):
                completion(.success(state))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
    func handleConfirmCondition() throws -> (NSDecimalNumber, NSDecimalNumber, MarketSupportTokensDataModel, MarketSupportTokensDataModel) {
        // ModelA不为空
        guard let tempInputTokenA = self.modelA else {
            throw LibraWalletError.error(localLanguage(keyString: "wallet_market_exchange_input_token_unselect"))
        }
        // ModelB不为空
        guard let tempInputTokenB = self.modelB else {
            throw LibraWalletError.error(localLanguage(keyString: "wallet_market_exchange_output_token_unselect"))
        }
        // 付出币激活状态
        guard let tokenAActiveState = tempInputTokenA.activeState, tokenAActiveState == true else {
            throw LibraWalletError.error(localLanguage(keyString: "wallet_market_exchange_input_token_unactived"))
        }
        // 金额不为空检查
        guard let amountAString = self.inputAmountString, amountAString.isEmpty == false else {
            throw LibraWalletError.WalletTransfer(reason: .amountEmpty)
        }
        // 金额是否纯数字检查
        guard isPurnDouble(string: amountAString) == true else {
            throw LibraWalletError.WalletTransfer(reason: .amountInvalid)
        }
        // 转换数字
        let amountIn = NSDecimalNumber.init(string: amountAString)
        
        // 金额不为空检查
        guard let amountBString = self.outputAmountString, amountBString.isEmpty == false else {
            throw LibraWalletError.WalletTransfer(reason: .amountEmpty)
        }
        // 金额是否纯数字检查
        guard isPurnDouble(string: amountBString) == true else {
            throw LibraWalletError.WalletTransfer(reason: .amountInvalid)
        }
        // 转换数字
        let amountOut = NSDecimalNumber.init(string: amountBString)
        guard amountIn.doubleValue > 0 else {
            throw LibraWalletError.WalletTransfer(reason: .amountInvalid)
        }
        guard amountOut.doubleValue > 0 else {
            throw LibraWalletError.WalletTransfer(reason: .amountInvalid)
        }
        // 金额超限检测
        guard amountIn.multiplying(by: NSDecimalNumber.init(value: 1000000)).int64Value <= (tempInputTokenA.amount ?? 0) else {
            throw LibraWalletError.WalletTransfer(reason: .amountOverload)
        }
        return (amountIn, amountOut, tempInputTokenA, tempInputTokenB)
    }
}
// MARK: - 获取交易所支持币种
extension ExchangeViewModel {
    func requestSupportTokens(tag: Int, completion: @escaping (Result<Bool, LibraWalletError>) -> Void) {
        self.delegate?.showToast(tag: 99)
        self.dataModel.getMarketTokens(btcAddress: Wallet.shared.btcAddress ?? "", violasAddress: Wallet.shared.violasAddress ?? "", libraAddress: Wallet.shared.libraAddress ?? "") { [weak self] (result) in
            self?.delegate?.hideToast(tag: 99)
            switch result {
            case let .success(models):
                guard models.isEmpty == false else {
                    completion(.failure(LibraWalletError.WalletMarket(reason: .marketOffline)))
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
                    completion(.success(true))
                }
                alert.show(tag: 199)
                alert.showAnimation()
            case let .failure(error):
                print(error.localizedDescription)
                completion(.failure(error))
            }
        }
    }
    //    func handleError(requestType: String, error: LibraWalletError) {
    //        switch error {
    //        case .WalletRequest(reason: .networkInvalid):
    //            // 网络无法访问
    //            print(error.localizedDescription)
    //        case .WalletRequest(reason: .walletVersionExpired):
    //            // 版本太久
    //            print(error.localizedDescription)
    //        case .WalletRequest(reason: .parseJsonError):
    //            // 解析失败
    //            print(error.localizedDescription)
    //        case .WalletRequest(reason: .dataCodeInvalid):
    //            // 数据状态异常
    //            print(error.localizedDescription)
    //        default:
    //            // 其他错误
    //            print(error.localizedDescription)
    //        }
    //    }
    func fliterBestOutputAmount(content: String) {
        self.inputAmountString = content
        let amount = NSDecimalNumber.init(string: content)
        guard amount.doubleValue > 0 else {
            return
        }
        let inputAmount = amount.multiplying(by: NSDecimalNumber.init(value: 1000000)).int64Value
        let result = self.dataModel.fliterBestOutput(inputAAmount: inputAmount,
                                                     inputCoinA: (self.tokenModelA?.index)!,
                                                     paths: self.dataModel.shortPath)
        self.exchangeModel = result
        self.outputAmountString = NSDecimalNumber.init(value: result.output).dividing(by: NSDecimalNumber.init(value: 1000000)).stringValue
    }
    
    func fliterBestInputAmount(content: String) {
        self.outputAmountString = content
        let amount = NSDecimalNumber.init(string: content)
        guard amount.doubleValue > 0 else {
            return
        }
        let outputAmount = amount.multiplying(by: NSDecimalNumber.init(value: 1000000)).int64Value
        let result = self.dataModel.fliterBestInput(outputAAmount: outputAmount,
                                                    outputCoinA: (self.tokenModelB?.index)!,
                                                    paths: self.dataModel.shortPath)
        self.exchangeModel = result
        self.inputAmountString = NSDecimalNumber.init(value: result.input).dividing(by: NSDecimalNumber.init(value: 1000000)).stringValue
    }
}
// MARK: - 实时刷新路径、兑换比例模块
extension ExchangeViewModel {
    func dealTransferOutAmount() {
        if self.dataModel.shortPath.isEmpty == true {
            self.delegate?.showToast(tag: 299)
            if isFirstRequestRate == true {
                self.refreshExchangeRate()
                isFirstRequestRate = false
            }
            self.startAutoRefreshExchangeRate(inputCoinA: self.modelA!, outputCoinB: self.modelB!)
        } else {
            if let amountString = self.inputAmountString, amountString.isEmpty == false {
                guard NSDecimalNumber.init(string: amountString).intValue > 0 else {
                    return
                }
                let amount = NSDecimalNumber.init(string: amountString).multiplying(by: NSDecimalNumber.init(value: 1000000)).int64Value
                let result = self.dataModel.fliterBestOutput(inputAAmount: amount,
                                                             inputCoinA: (self.modelA?.index)!,
                                                             paths: self.dataModel.shortPath)
                self.exchangeModel = result
            }
        }
    }
    func startAutoRefreshExchangeRate(inputCoinA: MarketSupportTokensDataModel, outputCoinB: MarketSupportTokensDataModel) {
        self.timer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(refreshExchangeRate), userInfo: nil, repeats: true)
        RunLoop.current.add(self.timer!, forMode: .common)
    }
    func stopAutoRefreshExchangeRate() {
        self.timer?.invalidate()
        self.timer = nil
    }
    @objc func refreshExchangeRate() {
        self.dataModel.getPoolTotalLiquidity(inputCoinA: self.tokenModelA!, inputCoinB: self.tokenModelB!) {
            [weak self] (result) in
            self?.delegate?.hideToast(tag: 299)
            switch result {
            case .success(_):
                print("获取兑换率成功")
            case let .failure(error):
                switch error {
                case .WalletRequest(reason: .dataEmpty):
                    self?.stopAutoRefreshExchangeRate()
                    self?.delegate?.requestError(errorMessage: LibraWalletError.WalletMarket(reason: .marketWithoutLiquidity).localizedDescription)
                default:
                    print(error.localizedDescription)
                }
            }
        }
    }
}
