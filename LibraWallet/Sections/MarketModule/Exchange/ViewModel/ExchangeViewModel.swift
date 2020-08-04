//
//  ExchangeViewModel.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/8/4.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit
protocol ExchangeViewModelDelegate: NSObjectProtocol {
    func getMnemonic()
}
class ExchangeViewModel: NSObject {
    weak var delegate: ExchangeViewModelDelegate?
    override init() {
        super.init()
//        self.initKVO()
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
        self.dataModel.getPoolTotalLiquidity(inputCoinA: (self.view?.headerView.transferInInputTokenA)!, inputCoinB: (self.view?.headerView.transferInInputTokenB)!)
    }
    var view: ExchangeView? {
        didSet {
            view?.headerView.delegate = self
        }
    }
    /// 网络请求、数据模型
    lazy var dataModel: ExchangeModel = {
        let model = ExchangeModel.init()
        return model
    }()
    /// 数据监听KVO
    var observer: NSKeyValueObservation?
    private var firstRequestRate: Bool = true
    private var timer: Timer?
    var controllerClosure: ((UIViewController)->())?
    
    var successV2LMappingClosure: (([MarketSupportMappingTokensDataModel])->())?
    var successL2VMappingClosure: (([MarketSupportMappingTokensDataModel])->())?
    var successB2VMappingClosure: (([MarketSupportMappingTokensDataModel])->())?
    var successB2LMappingClosure: (([MarketSupportMappingTokensDataModel])->())?
    var successV2BMappingClosure: (([MarketSupportMappingTokensDataModel])->())?
    
    func handleRequest(inputAmount: NSDecimalNumber, outputAmount: NSDecimalNumber, inputModule: MarketSupportTokensDataModel, outputModule: MarketSupportTokensDataModel, mnemonic: [String]) {
        switch self.view?.headerView.viewState {
        case .ViolasToLibraSwap:
            print("ViolasToLibraSwap")
            self.successV2LMappingClosure = { tokens in
                let tempModel = tokens.filter {
                    $0.to_coin?.assets?.module == outputModule.module
                }
                self.view?.toastView?.show(tag: 99)
                self.dataModel.sendSwapViolasToLibraTransaction(sendAddress: WalletManager.shared.violasAddress ?? "",
                                                                amountIn: inputAmount.doubleValue,
                                                                AmountOut: outputAmount.doubleValue,
                                                                fee: 0,
                                                                mnemonic: mnemonic,
                                                                moduleInput: inputModule.module ?? "",
                                                                feeModule: outputModule.module ?? "",
                                                                exchangeCenterAddress: tempModel.first?.receiver_address ?? "",
                                                                receiveAddress: WalletManager.shared.libraAddress ?? "",
                                                                type: tempModel.first?.lable ?? "")
            }
        case .ViolasToBTCSwap:
            print("ViolasToBTCSwap")
            self.successV2BMappingClosure = { tokens in
                let tempModel = tokens.filter {
                    $0.to_coin?.assets?.module == outputModule.module
                }
                self.view?.toastView?.show(tag: 99)
                self.dataModel.sendSwapViolasToLibraTransaction(sendAddress: WalletManager.shared.violasAddress ?? "",
                                                                amountIn: inputAmount.doubleValue,
                                                                AmountOut: outputAmount.doubleValue,
                                                                fee: 0,
                                                                mnemonic: mnemonic,
                                                                moduleInput: inputModule.module ?? "",
                                                                feeModule: inputModule.module ?? "",
                                                                exchangeCenterAddress: tempModel.first?.receiver_address ?? "",
                                                                receiveAddress: WalletManager.shared.libraAddress ?? "",
                                                                type: tempModel.first?.lable ?? "")
            }
        case .ViolasToViolasSwap:
            print("ViolasToViolasSwap")
            self.view?.toastView?.show(tag: 99)
            self.dataModel.sendSwapViolasTransaction(sendAddress: WalletManager.shared.violasAddress ?? "",
                                                     amountIn: inputAmount.doubleValue,
                                                     AmountOutMin: outputAmount.doubleValue,
                                                     path: (self.view?.headerView.exchangeModel?.path)!,
                                                     fee: 0,
                                                     mnemonic: mnemonic,
                                                     moduleA: inputModule.module ?? "",
                                                     moduleB: outputModule.module ?? "",
                                                     feeModule: inputModule.module ?? "")
        case .LibraToViolasSwap:
            print("LibraToViolasSwap")
            self.successL2VMappingClosure = { tokens in
                let tempModel = tokens.filter {
                    $0.to_coin?.assets?.module == outputModule.module
                }
                self.view?.toastView?.show(tag: 99)
                self.dataModel.sendLibraToViolasMappingTransaction(sendAddress: WalletManager.shared.libraAddress ?? "",
                                                                   module: inputModule.module ?? "",
                                                                   amountIn: inputAmount.doubleValue,
                                                                   amountOut: outputAmount.doubleValue,
                                                                   fee: 0,
                                                                   mnemonic: mnemonic,
                                                                   exchangeCenterAddress: tempModel.first?.receiver_address ?? "",
                                                                   violasReceiveAddress: WalletManager.shared.violasAddress ?? "",
                                                                   feeModule: inputModule.module ?? "",
                                                                   type: tempModel.first?.lable ?? "")
                
            }
        case .LibraToLibraSwap:
            print("LibraToLibraSwap暂不支持")
        case .LibraToBTCSwap:
            print("LibraToBTCSwap暂不支持")
        case .BTCToLibraSwap:
            print("BTCToLibraSwap")
            self.successB2LMappingClosure = { tokens in
                let tempModel = tokens.filter {
                    $0.to_coin?.assets?.module == outputModule.module && $0.input_coin_type == "btc"
                }
                self.view?.toastView?.show(tag: 99)
                let wallet = try! BTCManager().getWallet(mnemonic: mnemonic)
                self.dataModel.makeTransaction(wallet: wallet,
                                               amountIn: inputAmount.doubleValue,
                                               amountOut: outputAmount.doubleValue,
                                               fee: 0.0003,
                                               toAddress: tempModel.first?.receiver_address ?? "",
                                               mappingContract: tempModel.first?.to_coin?.assets?.address ?? "",
                                               mappingReceiveAddress: WalletManager.shared.violasAddress ?? "",
                                               type: tempModel.first?.lable ?? "")
            }
        case .BTCToViolasSwap:
            print("BTCToLibraSwap")
            self.successB2VMappingClosure = { tokens in
                let tempModel = tokens.filter {
                    $0.to_coin?.assets?.module == outputModule.module && $0.input_coin_type == "btc"
                }
                self.view?.toastView?.show(tag: 99)
                let wallet = try! BTCManager().getWallet(mnemonic: mnemonic)
                self.dataModel.makeTransaction(wallet: wallet,
                                               amountIn: inputAmount.doubleValue,
                                               amountOut: outputAmount.doubleValue,
                                               fee: 0.0003,
                                               toAddress: tempModel.first?.receiver_address ?? "",
                                               mappingContract: tempModel.first?.to_coin?.assets?.address ?? "",
                                               mappingReceiveAddress: WalletManager.shared.libraAddress ?? "",
                                               type: tempModel.first?.lable ?? "")
            }
        default:
            print("123")
        }
    }
}
extension ExchangeViewModel: ExchangeViewHeaderViewDelegate {
    func exchangeConfirm() {
        // ModelA不为空
        guard let tempInputTokenA = self.view?.headerView.transferInInputTokenA else {
            self.view?.makeToast(localLanguage(keyString: "wallet_market_exchange_input_token_unselect"),
                                 position: .center)
            return
        }
        // ModelB不为空
        guard let tempInputTokenB = self.view?.headerView.transferInInputTokenB else {
            self.view?.makeToast(localLanguage(keyString: "wallet_market_exchange_output_token_unselect"),
                                 position: .center)
            return
        }
        // 金额不为空检查
        guard let amountAString = self.view?.headerView.inputAmountTextField.text, amountAString.isEmpty == false else {
            self.view?.makeToast(LibraWalletError.WalletTransfer(reason: .amountEmpty).localizedDescription,
                                 position: .center)
            return
        }
        // 金额是否纯数字检查
        guard isPurnDouble(string: amountAString) == true else {
            self.view?.makeToast(LibraWalletError.WalletTransfer(reason: .amountInvalid).localizedDescription,
                                 position: .center)
            return
        }
        // 转换数字
        let amountIn = NSDecimalNumber.init(string: amountAString)
        
        // 金额不为空检查
        guard let amountBString = self.view?.headerView.outputAmountTextField.text, amountBString.isEmpty == false else {
            self.view?.makeToast(LibraWalletError.WalletTransfer(reason: .amountEmpty).localizedDescription,
                                 position: .center)
            return
        }
        // 金额是否纯数字检查
        guard isPurnDouble(string: amountBString) == true else {
            self.view?.makeToast(LibraWalletError.WalletTransfer(reason: .amountInvalid).localizedDescription,
                                 position: .center)
            return
        }
        // 转换数字
        let amountOut = NSDecimalNumber.init(string: amountBString)
        if tempInputTokenA.chainType == 1 && tempInputTokenB.chainType == 1 {
            self.view?.headerView.viewState = .ViolasToViolasSwap
        } else if tempInputTokenA.chainType == 1 && tempInputTokenB.chainType == 0 {
            self.view?.headerView.viewState = .ViolasToLibraSwap
        } else if tempInputTokenA.chainType == 1 && tempInputTokenB.chainType == 2 {
            self.view?.headerView.viewState = .ViolasToBTCSwap
        } else if tempInputTokenA.chainType == 0 && tempInputTokenB.chainType == 1 {
            self.view?.headerView.viewState = .LibraToViolasSwap
        } else if tempInputTokenA.chainType == 0 && tempInputTokenB.chainType == 2 {
            self.view?.headerView.viewState = .LibraToBTCSwap
        } else if tempInputTokenA.chainType == 2 && tempInputTokenB.chainType == 0 {
            self.view?.headerView.viewState = .BTCToLibraSwap
        } else if tempInputTokenA.chainType == 2 && tempInputTokenB.chainType == 1 {
            self.view?.headerView.viewState = .BTCToViolasSwap
        }
        self.delegate?.getMnemonic()
        self.controllerClosure = { [weak self] controller in
            WalletManager.unlockWallet(controller: controller, successful: { [weak self](mnemonic) in
                self?.handleRequest(inputAmount: amountIn,
                                    outputAmount: amountOut,
                                    inputModule: tempInputTokenA,
                                    outputModule: tempInputTokenB,
                                    mnemonic: mnemonic)
            }) { [weak self](error) in
                guard error != "Cancel" else {
                    self?.view?.toastView?.hide(tag: 99)
                    return
                }
                self?.view?.makeToast(error, position: .center)
            }
        }
    }
    func MappingBTCToViolasConfirm(amountIn: Double, amountOut: Double, inputModel: MarketSupportTokensDataModel, outputModel: MarketSupportTokensDataModel) {
        self.view?.headerView.inputAmountTextField.resignFirstResponder()
        self.view?.headerView.outputAmountTextField.resignFirstResponder()
    }
    
    func MappingBTCToLibraConfirm(amountIn: Double, amountOut: Double, inputModel: MarketSupportTokensDataModel, outputModel: MarketSupportTokensDataModel) {
        
    }
    
    func MappingViolasToViolasConfirm(amountIn: Double, amountOutMin: Double, inputModelName: String, outputModelName: String, path: [UInt8]) {
        
    }
    
    func MappingViolasToLibraConfirm(amountIn: Double, amountOut: Double, inputModel: MarketSupportTokensDataModel, outputModel: MarketSupportTokensDataModel) {
        
    }
    
    func MappingViolasToBTCConfirm(amountIn: Double, amountOut: Double, inputModel: MarketSupportTokensDataModel, outputModel: MarketSupportTokensDataModel) {
        
    }
    
    func MappingLibraToViolasConfirm(amountIn: Double, amountOut: Double, inputModel: MarketSupportTokensDataModel, outputModel: MarketSupportTokensDataModel) {
        
    }
    
    func MappingLibraToBTCConfirm(amountIn: Double, amountOut: Double, inputModel: MarketSupportTokensDataModel, outputModel: MarketSupportTokensDataModel) {
        
    }
    
    func selectInputToken() {
        self.view?.toastView?.show(tag: 99)
        self.dataModel.getMarketTokens(btcAddress: WalletManager.shared.btcAddress ?? "",
                                       violasAddress: WalletManager.shared.violasAddress ?? "",
                                       libraAddress: WalletManager.shared.libraAddress ?? "")
    }
    
    func selectOutoutToken() {
        print("selectOutoutToken")
        self.view?.toastView?.show(tag: 99)
        self.dataModel.getMarketTokens(btcAddress: WalletManager.shared.btcAddress ?? "",
                                       violasAddress: WalletManager.shared.violasAddress ?? "",
                                       libraAddress: WalletManager.shared.libraAddress ?? "")
    }
    
    func swapInputOutputToken() {
        
    }
    
    func dealTransferOutAmount(inputModule: MarketSupportTokensDataModel, outputModule: MarketSupportTokensDataModel) {
        if self.dataModel.shortPath.isEmpty == true {
            self.view?.toastView?.show(tag: 299)
            if firstRequestRate == true {
                self.refreshExchangeRate()
                firstRequestRate = false
            }
            self.startAutoRefreshExchangeRate(inputCoinA: inputModule, outputCoinB: outputModule)
        } else {
            if let amountString = self.view?.headerView.inputAmountTextField.text, amountString.isEmpty == false {
                let amount = NSDecimalNumber.init(string: amountString).multiplying(by: NSDecimalNumber.init(value: 1000000)).int64Value
                self.dataModel.fliterBestOutput(inputAAmount: amount,
                                                inputCoinA: inputModule.index!,
                                                paths: self.dataModel.shortPath)
            }
        }
    }
    
    func fliterBestOutputAmount(inputAmount: Int64) {
        self.dataModel.fliterBestOutput(inputAAmount: inputAmount,
                                        inputCoinA: (self.view?.headerView.transferInInputTokenA?.index)!,
                                        paths: self.dataModel.shortPath)
    }
    
    func fliterBestInputAmount(outputAmount: Int64) {
        self.view?.toastView?.show(tag: 99)
        self.dataModel.getMarketTokens(btcAddress: WalletManager.shared.btcAddress ?? "",
                                       violasAddress: WalletManager.shared.violasAddress ?? "",
                                       libraAddress: WalletManager.shared.libraAddress ?? "")
    }
}
extension ExchangeViewModel {
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
                self?.view?.headerView.viewState = .Normal
                return
            }
            let type = dataDic.value(forKey: "type") as! String
            if type == "SupportViolasTokens" {
                guard let datas = dataDic.value(forKey: "data") as? [MarketSupportTokensDataModel] else {
                    return
                }
                var tempData = datas
                if self?.view?.headerView.viewState == .ExchangeSelectAToken {
                    if let selectBModel = self?.view?.headerView.transferInInputTokenB {
                        if self?.view?.headerView.transferInInputTokenB?.chainType == 0 {
                            tempData = tempData.filter {
                                $0.chainType != 0
                            }
                        } else {
                            tempData = tempData.filter {
                                $0.module != selectBModel.module
                            }
                        }
                        
                    }
                } else {
                    if let selectBModel = self?.view?.headerView.transferInInputTokenA {
                        if self?.view?.headerView.transferInInputTokenA?.chainType == 0 {
                            tempData = tempData.filter {
                                $0.chainType != 0
                            }
                        } else {
                            tempData = tempData.filter {
                                $0.module != selectBModel.module
                            }
                        }
                    }
                }
                let alert = MappingTokenListAlert.init(data: tempData) { (model) in
                    print(model)
                    if self?.view?.headerView.viewState == .ExchangeSelectAToken {
                        self?.view?.headerView.transferInInputTokenA = model
                    } else {
                        self?.view?.headerView.transferInInputTokenB = model
                    }
                    self?.view?.headerView.viewState = .Normal
                }
                alert.show(tag: 199)
                alert.showAnimation()
            } else if type == "GetExchangeInfo" {
                guard let tempData = dataDic.value(forKey: "data") as? ExchangeInfoModel else {
                    return
                }
                self?.view?.headerView.exchangeModel = tempData
            } else if type == "SendViolasTransaction" {
                self?.view?.headerView.inputAmountTextField.text = ""
                self?.view?.headerView.outputAmountTextField.text = ""
                self?.view?.makeToast("发送成功", position: .center)
            } else if type == "GetMappingTokenList" {
                guard let tempData = dataDic.value(forKey: "data") as? [MarketSupportMappingTokensDataModel] else {
                    return
                }
                if self?.view?.headerView.viewState == .ViolasToLibraSwap {
                    if let action = self?.successV2LMappingClosure {
                        action(tempData)
                    }
                } else if self?.view?.headerView.viewState == .LibraToViolasSwap {
                    if let action = self?.successL2VMappingClosure {
                        action(tempData)
                    }
                } else if self?.view?.headerView.viewState == .BTCToViolasSwap {
                    if let action = self?.successB2VMappingClosure {
                        action(tempData)
                    }
                } else if self?.view?.headerView.viewState == .BTCToLibraSwap {
                    if let action = self?.successB2LMappingClosure {
                        action(tempData)
                    }
                } else if self?.view?.headerView.viewState == .ViolasToBTCSwap {
                    if let action = self?.successV2BMappingClosure {
                        action(tempData)
                    }
                }
            } else if type == "SendViolasToLibraMappingTransaction" {
                self?.view?.headerView.viewState = .Normal
                self?.view?.headerView.inputAmountTextField.text = ""
                self?.view?.headerView.outputAmountTextField.text = ""
                self?.view?.makeToast("发送成功", position: .center)
            } else if type == "SendLibraToViolasTransaction" {
                self?.view?.headerView.viewState = .Normal
                self?.view?.headerView.inputAmountTextField.text = ""
                self?.view?.headerView.outputAmountTextField.text = ""
                self?.view?.makeToast("发送成功", position: .center)
            } else if type == "SendBTCTransaction" {
                self?.view?.headerView.viewState = .Normal
                self?.view?.headerView.inputAmountTextField.text = ""
                self?.view?.headerView.outputAmountTextField.text = ""
                self?.view?.makeToast("发送成功", position: .center)
            } else if type == "GetPoolTotalLiquidity" {
                print("获取流动性成功")
                self?.view?.toastView?.hide(tag: 299)
                return
            }
            self?.view?.hideToastActivity()
            self?.view?.toastView?.hide(tag: 99)
        })
    }
}
