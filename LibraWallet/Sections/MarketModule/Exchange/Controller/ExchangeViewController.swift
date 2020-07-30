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
        self.initKVO()
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        detailView.snp.makeConstraints { (make) in
            if #available(iOS 11.0, *) {
                make.top.bottom.equalTo(self.view.safeAreaLayoutGuide)
            } else {
                make.top.bottom.equalTo(self.view)
            }
            make.left.right.equalTo(self.view)
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
    /// 网络请求、数据模型
    lazy var dataModel: ExchangeModel = {
        let model = ExchangeModel.init()
        return model
    }()
    /// 子View
    lazy var detailView : ExchangeView = {
        let view = ExchangeView.init()
        view.headerView.delegate = self
        return view
    }()
    /// 数据监听KVO
    var observer: NSKeyValueObservation?
    
    var marketSupportModels: [MarketSupportMappingTokensDataModel]?
    
    var successV2LMappingClosure: (([MarketSupportMappingTokensDataModel])->())?
    var successL2VMappingClosure: (([MarketSupportMappingTokensDataModel])->())?
    var successB2VMappingClosure: (([MarketSupportMappingTokensDataModel])->())?
    var successB2LMappingClosure: (([MarketSupportMappingTokensDataModel])->())?
    func startAutoRefreshExchangeRate(inputCoinA: MarketSupportTokensDataModel, outputCoinB: MarketSupportTokensDataModel) {
        self.timer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(refreshExchangeRate), userInfo: nil, repeats: true)
        RunLoop.current.add(self.timer!, forMode: .common)
    }
    func stopAutoRefreshExchangeRate() {
        self.timer?.invalidate()
        self.timer = nil
    }
    @objc func refreshExchangeRate() {
        self.dataModel.getPoolTotalLiquidity(inputCoinA: self.detailView.headerView.transferInInputTokenA!, inputCoinB: self.detailView.headerView.transferInInputTokenB!)
    }
    private var timer: Timer?
    private var firstRequestRate: Bool = true
    private var handleOutputAmountClosure: (()->())?
    private var handleInputAmountClosure: (()->())?
//    private var pathAToB: Bool = true
}
extension ExchangeViewController: ExchangeViewHeaderViewDelegate {
    func fliterBestOutputAmount(inputAmount: Int64) {
        self.dataModel.fliterBestOutput(inputAAmount: inputAmount,
                                        inputCoinA: (self.detailView.headerView.transferInInputTokenA?.index)!,
                                        paths: self.dataModel.shortPath)
    }
    func fliterBestInputAmount(outputAmount: Int64) {
        self.dataModel.fliterBestInput(outputAAmount: outputAmount,
                                       outputCoinA: (self.detailView.headerView.transferInInputTokenB?.index)!,
                                       pathModel: self.detailView.headerView.exchangeModel!.models,
                                       path:self.detailView.headerView.exchangeModel!.path)
        
    }
    
    func dealTransferOutAmount(inputModule: MarketSupportTokensDataModel, outputModule: MarketSupportTokensDataModel) {
        if self.dataModel.shortPath.isEmpty == true {
            self.detailView.toastView?.show(tag: 299)
            if firstRequestRate == true {
                self.refreshExchangeRate()
                firstRequestRate = false
            }
            self.startAutoRefreshExchangeRate(inputCoinA: inputModule, outputCoinB: outputModule)
        } else {
            if let amountString = self.detailView.headerView.inputAmountTextField.text, amountString.isEmpty == false {
                let amount = NSDecimalNumber.init(string: amountString).multiplying(by: NSDecimalNumber.init(value: 1000000)).int64Value
                self.dataModel.fliterBestOutput(inputAAmount: amount,
                                               inputCoinA: inputModule.index!,
                                               paths: self.dataModel.shortPath)
            }
        }
    }
    
    func MappingBTCToViolasConfirm(amountIn: Double, amountOut: Double, inputModel: MarketSupportTokensDataModel, outputModel: MarketSupportTokensDataModel) {
        self.detailView.toastView?.show(tag: 99)
        self.dataModel.getMappingTokenList()
        self.successB2VMappingClosure = { tokens in
            let tempModel = tokens.filter {
                $0.to_coin?.assets?.module == outputModel.module && $0.input_coin_type == "btc"
            }
            WalletManager.unlockWallet(controller: self, successful: { [weak self](mnemonic) in
                self?.detailView.toastView?.show(tag: 99)
                let wallet = try! BTCManager().getWallet(mnemonic: mnemonic)
                self?.dataModel.makeTransaction(wallet: wallet,
                                                amountIn: amountIn,
                                                amountOut: amountOut,
                                                fee: 0.0003,
                                                toAddress: tempModel.first?.receiver_address ?? "",
                                                mappingContract: tempModel.first?.to_coin?.assets?.address ?? "",
                                                mappingReceiveAddress: WalletManager.shared.violasAddress ?? "",
                                                type: tempModel.first?.lable ?? "")
            }) { [weak self](error) in
                guard error != "Cancel" else {
                    self?.detailView.toastView?.hide(tag: 99)
                    return
                }
                self?.detailView.makeToast(error,
                                           position: .center)
            }
        }
    }
    func MappingBTCToLibraConfirm(amountIn: Double, amountOut: Double, inputModel: MarketSupportTokensDataModel, outputModel: MarketSupportTokensDataModel) {
        self.detailView.toastView?.show(tag: 99)
        self.dataModel.getMappingTokenList()
        self.successB2VMappingClosure = { tokens in
            let tempModel = tokens.filter {
                $0.to_coin?.assets?.module == outputModel.module && $0.input_coin_type == "btc"
            }
            WalletManager.unlockWallet(controller: self, successful: { [weak self](mnemonic) in
                self?.detailView.toastView?.show(tag: 99)
                let wallet = try! BTCManager().getWallet(mnemonic: mnemonic)
                self?.dataModel.makeTransaction(wallet: wallet,
                                                amountIn: amountIn,
                                                amountOut: amountOut,
                                                fee: 0.0003,
                                                toAddress: tempModel.first?.receiver_address ?? "",
                                                mappingContract: tempModel.first?.to_coin?.assets?.address ?? "",
                                                mappingReceiveAddress: WalletManager.shared.libraAddress ?? "",
                                                type: tempModel.first?.lable ?? "")
            }) { [weak self](error) in
                guard error != "Cancel" else {
                    self?.detailView.toastView?.hide(tag: 99)
                    return
                }
                self?.detailView.makeToast(error,
                                           position: .center)
            }
        }
    }
    func MappingViolasToViolasConfirm(amountIn: Double, amountOutMin: Double, inputModelName: String, outputModelName: String, path: [UInt8]) {
        print("Exchange")
        WalletManager.unlockWallet(controller: self, successful: { [weak self](mnemonic) in
            self?.detailView.toastView?.show(tag: 99)
            self?.dataModel.sendSwapViolasTransaction(sendAddress: WalletManager.shared.libraAddress ?? "",
                                                      amountIn: amountIn,
                                                      AmountOutMin: amountOutMin,
                                                      path: path,
                                                      fee: 0,
                                                      mnemonic: mnemonic,
                                                      moduleA: inputModelName,
                                                      moduleB: outputModelName,
                                                      feeModule: inputModelName)
        }) { [weak self](error) in
            guard error != "Cancel" else {
                self?.detailView.toastView?.hide(tag: 99)
                return
            }
            self?.detailView.makeToast(error,
                                       position: .center)
        }
    }
    func MappingViolasToLibraConfirm(amountIn: Double, amountOut: Double, inputModel: MarketSupportTokensDataModel, outputModel: MarketSupportTokensDataModel) {
        self.detailView.toastView?.show(tag: 99)
        self.dataModel.getMappingTokenList()
        self.successV2LMappingClosure = { tokens in
            let tempModel = tokens.filter {
                $0.to_coin?.assets?.module == outputModel.module
            }
            WalletManager.unlockWallet(controller: self, successful: { [weak self](mnemonic) in
                self?.detailView.toastView?.show(tag: 99)
                self?.dataModel.sendSwapViolasToLibraTransaction(sendAddress: WalletManager.shared.violasAddress ?? "",
                                                                 amountIn: amountIn,
                                                                 AmountOut: amountOut,
                                                                 fee: 0,
                                                                 mnemonic: mnemonic,
                                                                 moduleInput: inputModel.module ?? "",
                                                                 feeModule: inputModel.module ?? "",
                                                                 exchangeCenterAddress: tempModel.first?.receiver_address ?? "",
                                                                 receiveAddress: WalletManager.shared.libraAddress ?? "",
                                                                 type: tempModel.first?.lable ?? "")
            }) { [weak self](error) in
                guard error != "Cancel" else {
                    self?.detailView.toastView?.hide(tag: 99)
                    return
                }
                self?.detailView.makeToast(error,
                                           position: .center)
            }
        }
    }
    func MappingViolasToBTCConfirm(amountIn: Double, amountOut: Double, inputModel: MarketSupportTokensDataModel, outputModel: MarketSupportTokensDataModel) {
        
    }
    
    func MappingLibraToViolasConfirm(amountIn: Double, amountOut: Double, inputModel: MarketSupportTokensDataModel, outputModel: MarketSupportTokensDataModel) {
        self.detailView.toastView?.show(tag: 99)
        self.dataModel.getMappingTokenList()
        self.successL2VMappingClosure = { tokens in
            let tempModel = tokens.filter {
                $0.to_coin?.assets?.module == outputModel.module
            }
            WalletManager.unlockWallet(controller: self, successful: { [weak self](mnemonic) in
                self?.detailView.toastView?.show(tag: 99)
                self?.dataModel.sendLibraToViolasMappingTransaction(sendAddress: WalletManager.shared.libraAddress ?? "",
                                                                    module: inputModel.module ?? "",
                                                                    amountIn: amountIn,
                                                                    amountOut: amountOut,
                                                                    fee: 0,
                                                                    mnemonic: mnemonic,
                                                                    exchangeCenterAddress: tempModel.first?.receiver_address ?? "",
                                                                    violasReceiveAddress: WalletManager.shared.violasAddress ?? "",
                                                                    feeModule: inputModel.module ?? "",
                                                                    type: tempModel.first?.lable ?? "")
            }) { [weak self](error) in
                guard error != "Cancel" else {
                    self?.detailView.toastView?.hide(tag: 99)
                    return
                }
                self?.detailView.makeToast(error,
                                           position: .center)
            }
                    
        }
    }
    
    func MappingLibraToBTCConfirm(amountIn: Double, amountOut: Double, inputModel: MarketSupportTokensDataModel, outputModel: MarketSupportTokensDataModel) {
        
    }

    func selectInputToken() {
        self.detailView.toastView?.show(tag: 99)
        self.dataModel.getMarketTokens(btcAddress: WalletManager.shared.btcAddress ?? "",
                                       violasAddress: WalletManager.shared.violasAddress ?? "",
                                       libraAddress: WalletManager.shared.libraAddress ?? "")
    }
    func selectOutoutToken() {
        print("selectOutoutToken")
        self.detailView.toastView?.show(tag: 99)
        self.dataModel.getMarketTokens(btcAddress: WalletManager.shared.btcAddress ?? "",
                                       violasAddress: WalletManager.shared.violasAddress ?? "",
                                       libraAddress: WalletManager.shared.libraAddress ?? "")
    }
    func swapInputOutputToken() {
        print("Swap")
    }
}
extension ExchangeViewController {
    func initKVO() {
        self.observer = dataModel.observe(\.dataDic, options: [.new], changeHandler: { [weak self](model, change) in
            guard let dataDic = change.newValue, dataDic.count != 0 else {
                self?.detailView.toastView?.hide(tag: 99)
                self?.detailView.toastView?.hide(tag: 299)
                self?.detailView.hideToastActivity()
                return
            }
            #warning("已修改完成，可拷贝执行")
            if let error = dataDic.value(forKey: "error") as? LibraWalletError {
                // 隐藏请求指示
                self?.detailView.hideToastActivity()
                self?.detailView.toastView?.hide(tag: 99)
                self?.detailView.toastView?.hide(tag: 299)
                if error.localizedDescription == LibraWalletError.WalletRequest(reason: .networkInvalid).localizedDescription {
                    // 网络无法访问
                    print(error.localizedDescription)
                    self?.detailView.makeToast(error.localizedDescription,
                                               position: .center)
                } else if error.localizedDescription == LibraWalletError.WalletRequest(reason: .walletVersionExpired).localizedDescription {
                    // 版本太久
                    print(error.localizedDescription)
                    self?.detailView.makeToast(error.localizedDescription,
                                               position: .center)
                } else if error.localizedDescription == LibraWalletError.WalletRequest(reason: .parseJsonError).localizedDescription {
                    // 解析失败
                    print(error.localizedDescription)
                    self?.detailView.makeToast(error.localizedDescription,
                                               position: .center)
                } else if error.localizedDescription == LibraWalletError.WalletRequest(reason: .dataCodeInvalid).localizedDescription {
                    print(error.localizedDescription)
                    // 数据状态异常
                    self?.detailView.makeToast(error.localizedDescription,
                                               position: .center)
                } else if error.localizedDescription == LibraWalletError.WalletRequest(reason: .dataEmpty).localizedDescription {
                    print(error.localizedDescription)
                    // 下拉刷新请求数据为空
                    self?.detailView.makeToast(error.localizedDescription,
                                               position: .center)
                } else if error.localizedDescription == LibraWalletError.WalletRequest(reason: .noMoreData).localizedDescription {
                    // 上拉请求更多数据为空
                    print(error.localizedDescription)
                } else {
                    self?.detailView.makeToast(error.localizedDescription,
                                               position: .center)
                }
                self?.detailView.headerView.viewState = .Normal
                return
            }
            let type = dataDic.value(forKey: "type") as! String
            if type == "SupportViolasTokens" {
                guard let datas = dataDic.value(forKey: "data") as? [MarketSupportTokensDataModel] else {
                    return
                }
                var tempData = datas
                if self?.detailView.headerView.viewState == .ExchangeSelectAToken {
                    if let selectBModel = self?.detailView.headerView.transferInInputTokenB {
                        if self?.detailView.headerView.transferInInputTokenB?.chainType == 0 {
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
                    if let selectBModel = self?.detailView.headerView.transferInInputTokenA {
                        if self?.detailView.headerView.transferInInputTokenA?.chainType == 0 {
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
                    if self?.detailView.headerView.viewState == .ExchangeSelectAToken {
                        self?.detailView.headerView.transferInInputTokenA = model
                    } else {
                        self?.detailView.headerView.transferInInputTokenB = model
                    }
                    self?.detailView.headerView.viewState = .Normal
                }
                alert.show(tag: 199)
                alert.showAnimation()
            } else if type == "GetExchangeInfo" {
                guard let tempData = dataDic.value(forKey: "data") as? ExchangeInfoModel else {
                    return
                }
                self?.detailView.headerView.exchangeModel = tempData
            } else if type == "SendViolasTransaction" {
                self?.detailView.headerView.inputAmountTextField.text = ""
                self?.detailView.headerView.outputAmountTextField.text = ""
                self?.detailView.makeToast("发送成功", position: .center)
            } else if type == "GetMappingTokenList" {
                guard let tempData = dataDic.value(forKey: "data") as? [MarketSupportMappingTokensDataModel] else {
                    return
                }
                if self?.detailView.headerView.viewState == .ViolasToLibraSwap {
                    if let action = self?.successV2LMappingClosure {
                        action(tempData)
                    }
                } else if self?.detailView.headerView.viewState == .LibraToViolasSwap {
                    if let action = self?.successL2VMappingClosure {
                        action(tempData)
                    }
                } else if self?.detailView.headerView.viewState == .BTCToViolasSwap {
                    if let action = self?.successB2VMappingClosure {
                        action(tempData)
                    }
                } else if self?.detailView.headerView.viewState == .BTCToLibraSwap {
                    if let action = self?.successB2LMappingClosure {
                        action(tempData)
                    }
                }
            } else if type == "SendViolasToLibraMappingTransaction" {
                self?.detailView.headerView.viewState = .Normal
                self?.detailView.headerView.inputAmountTextField.text = ""
                self?.detailView.headerView.outputAmountTextField.text = ""
                self?.detailView.makeToast("发送成功", position: .center)
            } else if type == "SendLibraToViolasTransaction" {
                self?.detailView.headerView.viewState = .Normal
                self?.detailView.headerView.inputAmountTextField.text = ""
                self?.detailView.headerView.outputAmountTextField.text = ""
                self?.detailView.makeToast("发送成功", position: .center)
            } else if type == "SendBTCTransaction" {
                self?.detailView.headerView.viewState = .Normal
                self?.detailView.headerView.inputAmountTextField.text = ""
                self?.detailView.headerView.outputAmountTextField.text = ""
                self?.detailView.makeToast("发送成功", position: .center)
            } else if type == "GetPoolTotalLiquidity" {
                print("获取流动性成功")
                self?.detailView.toastView?.hide(tag: 299)
                return
            }
            self?.detailView.hideToastActivity()
            self?.detailView.toastView?.hide(tag: 99)
        })
    }
}

