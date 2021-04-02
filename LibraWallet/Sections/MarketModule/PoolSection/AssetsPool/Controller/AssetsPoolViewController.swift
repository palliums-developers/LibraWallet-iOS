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
        // 初始化KVO
        self.initKVO()
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        detailView.snp.makeConstraints { (make) in
            make.top.bottom.equalTo(self.view.safeAreaLayoutGuide)
            make.left.right.equalTo(self.view)
        }
    }
    /// 网络请求、数据模型
    lazy var dataModel: AssetsPoolModel = {
        let model = AssetsPoolModel.init()
        return model
    }()
    lazy var viewModel: AssetsPoolViewModel = {
        let model = AssetsPoolViewModel.init()
        model.delegate = self
        return model
    }()
    /// 子View
    lazy var detailView : AssetsPoolView = {
        let view = AssetsPoolView.init()
        view.headerView.delegate = self
        return view
    }()
    /// 数据监听KVO
    var observer: NSKeyValueObservation?
    
    var currentTokens: [MarketMineMainTokensDataModel]?
    
}
extension AssetsPoolViewController: AssetsPoolViewHeaderViewDelegate {
    
    func getPoolLiquidity(inputModuleName: String, outputModuleName: String) {
        self.detailView.toastView?.show(tag: 99)
        self.dataModel.getPoolLiquidity(coinA: inputModuleName,
                                        coinB: outputModuleName)
    }
    
    func addLiquidityConfirm(amountIn: UInt64, amountOut: UInt64, inputModelName: String, outputModelName: String) {
        WalletManager.unlockWallet { [weak self] (result) in
            switch result {
            case let .success(mnemonic):
                self?.detailView.toastView?.show(tag: 99)
                self?.dataModel.sendAddLiquidityViolasTransaction(sendAddress: Wallet.shared.violasAddress ?? "",
                                                                  amounta_desired: amountIn,
                                                                  amountb_desired: amountOut,
                                                                  amounta_min: UInt64(Double(amountIn) * 0.995),
                                                                  amountb_min: UInt64(Double(amountOut) * 0.995),
                                                                  fee: 0,
                                                                  mnemonic: mnemonic,
                                                                  moduleA: inputModelName,
                                                                  moduleB: outputModelName,
                                                                  feeModule: inputModelName)
            case let .failure(error):
                guard error.localizedDescription != "Cancel" else {
                    self?.detailView.toastView?.hide(tag: 99)
                    return
                }
                self?.detailView.makeToast(error.localizedDescription, position: .center)
            }
        }
    }
    func removeLiquidityConfirm(token: Double, amountIn: Double, amountOut: Double, inputModelName: String, outputModelName: String) {
        print("Exchange")
        WalletManager.unlockWallet { [weak self] (result) in
            switch result {
            case let .success(mnemonic):
                self?.detailView.toastView?.show(tag: 99)
                self?.dataModel.sendRemoveLiquidityViolasTransaction(sendAddress: Wallet.shared.violasAddress ?? "",
                                                                     liquidity: token,
                                                                     amounta_min: amountIn,
                                                                     amountb_min: amountOut,
                                                                     fee: 0,
                                                                     mnemonic: mnemonic,
                                                                     moduleA: inputModelName,
                                                                     moduleB: outputModelName,
                                                                     feeModule: inputModelName)
            case let .failure(error):
                guard error.localizedDescription != "Cancel" else {
                    self?.detailView.toastView?.hide(tag: 99)
                    return
                }
                self?.detailView.makeToast(error.localizedDescription, position: .center)
            }
        }
    }
    
    func selectInputToken() {
        if self.detailView.headerView.changeTypeButton.titleLabel?.text == localLanguage(keyString: localLanguage(keyString: "wallet_assets_pool_transfer_in_title")) {
            // 转入
            self.detailView.toastView?.show(tag: 99)
//            self.dataModel.getMarketTokens(address: Wallet.shared.violasAddress ?? "")
            self.viewModel.requestMarketTokens(tag: 10)
        } else {
            // 转出
            self.detailView.makeToastActivity(.center)
//            self.dataModel.getMarketMineTokens(address: Wallet.shared.violasAddress ?? "")
            self.viewModel.requestMineLiquidity()
        }
    }
    func selectOutoutToken() {
        if self.detailView.headerView.changeTypeButton.titleLabel?.text == localLanguage(keyString: localLanguage(keyString: "wallet_assets_pool_transfer_in_title")) {
            // 转入
            self.detailView.toastView?.show(tag: 99)
//            self.dataModel.getMarketTokens(address: Wallet.shared.violasAddress ?? "")
            self.viewModel.requestMarketTokens(tag: 20)
        }
    }
    func swapInputOutputToken() {
        print("Swap")
        
    }
    func changeTrasferInOut() {
        
    }
    func dealTransferOutAmount(amount: Double, coinAModule: String, coinBModule: String) {
        if self.detailView.headerView.changeTypeButton.titleLabel?.text == localLanguage(keyString: localLanguage(keyString: "wallet_assets_pool_transfer_in_title")) {
            // 转入
            self.detailView.toastView?.show(tag: 99)
            self.dataModel.getMarketAssetsPoolTransferInRate(coinA: coinAModule,
                                                             coinB: coinBModule,
                                                             amount: Int64(amount * 1000000))
        } else {
            // 转出
//            self.detailView.toastView?.show(tag: 99)
//            self.dataModel.getMarketAssetsPoolTransferOutRate(address: WalletManager.shared.violasAddress ?? "",
//                                                              coinA: coinAModule,
//                                                              coinB: coinBModule,
//                                                              amount: Int64(amount * 1000000))

        }

    }
    
}

extension AssetsPoolViewController {
    func initKVO() {
        self.observer = dataModel.observe(\.dataDic, options: [.new], changeHandler: { [weak self](model, change) in
            guard let dataDic = change.newValue, dataDic.count != 0 else {
                self?.detailView.hideToastActivity()
                return
            }
            if let error = dataDic.value(forKey: "error") as? LibraWalletError {
                // 隐藏请求指示
                self?.detailView.hideToastActivity()
                self?.detailView.toastView?.hide(tag: 99)
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
                } else if error.localizedDescription == "CalculateRateFailed" {
                    self?.detailView.makeToast("资金池中尚未有此交易对，请谨慎设置注入比例，以防造成较大损失",
                                               position: .center)
                    self?.detailView.headerView.autoCalculateMode = false
                } else {
                    self?.detailView.makeToast(error.localizedDescription,
                                               position: .center)
                }
                return
            }
            let type = dataDic.value(forKey: "type") as! String
            if type == "GetMarketMineTokens" {
                guard let tempData = dataDic.value(forKey: "data") as? MarketMineMainDataModel else {
                    return
                }
                var tempDropperData = [String]()
                for item in tempData.balance! {
                    let tokenNameString = (item.coin_a?.show_name ?? "---") + "/" + (item.coin_b?.show_name ?? "---")
                    tempDropperData.append(tokenNameString)
                }
                self?.currentTokens = tempData.balance
                let realHeight = CGFloat((tempData.balance?.count ?? 34) * 34)
                let height = realHeight > 34*6 ? 34*6:realHeight
                let dropper = Dropper.init(width: 120, height: height)
                dropper.items = tempDropperData
                dropper.cornerRadius = 8
                dropper.theme = .black(UIColor.init(hex: "F1EEFB"))
                dropper.cellTextFont = UIFont.systemFont(ofSize: 12, weight: UIFont.Weight.regular)
                dropper.cellColor = UIColor.init(hex: "333333")
                dropper.spacing = 12
                dropper.delegate = self
                if self?.detailView.headerView.inputTokenButton.titleLabel?.text != localLanguage(keyString: "wallet_market_exchange_input_token_button_title") {
                    let index = tempDropperData.firstIndex(of: self?.detailView.headerView.inputTokenButton.titleLabel?.text ?? "")
                    dropper.defaultSelectRow = index
                }
                dropper.show(Dropper.Alignment.center, button: (self?.detailView.headerView.inputTokenButton)!)
            } else if type == "GetAssetsPoolTransferOutInfo" {
                guard let tempData = dataDic.value(forKey: "data") as? AssetsPoolTransferOutInfoDataModel else {
                    return
                }
//                self?.detailView.headerView.transferOutModel = tempData
                self?.detailView.headerView.transferOutModel = tempData

                
            } else if type == "SupportViolasTokens" {
                guard let datas = dataDic.value(forKey: "data") as? [MarketSupportTokensDataModel] else {
                    return
                }
                var tempData = datas
                if self?.detailView.headerView.viewState == .AssetsPoolTransferInSelectAToken {
                    if let selectBModel = self?.detailView.headerView.transferInInputTokenB {
                        tempData = tempData.filter {
                            $0.module != selectBModel.module
                        }
                    }
                } else {
                    if let selectBModel = self?.detailView.headerView.transferInInputTokenA {
                        tempData = tempData.filter {
                            $0.module != selectBModel.module
                        }
                    }
                }
                let alert = MappingTokenListAlert.init(data: tempData) { (model) in
                    if self?.detailView.headerView.viewState == .AssetsPoolTransferInSelectAToken {
                        self?.detailView.headerView.transferInInputTokenA = model
                    } else {
                        self?.detailView.headerView.transferInInputTokenB = model
                    }
                }
                alert.show(tag: 199)
                alert.showAnimation()
            } else if type == "SendViolasTransaction" {
                if self?.detailView.headerView.viewState == .AssetsPoolTransferInConfirm {
                    print("资金池转入成功")
                    self?.detailView.headerView.inputAmountTextField.text = ""
                    self?.detailView.headerView.outputAmountTextField.text = ""
                    self?.detailView.makeToast(localLanguage(keyString: "wallet_transfer_success_alert"), position: .center)
                } else {
                    print("资金池转出成功")
                    self?.detailView.headerView.inputAmountTextField.text = ""
                    self?.detailView.headerView.outputAmountTextField.text = ""
                    self?.detailView.headerView.outputCoinAAmountLabel.text = "---"
                    self?.detailView.headerView.outputCoinBAmountLabel.text = "---"
                    self?.detailView.makeToast(localLanguage(keyString: "wallet_transfer_success_alert"), position: .center)
                }
                self?.detailView.headerView.viewState = .Normal
            } else if type == "GetAssetsPoolTransferInInfo" {
                guard let tempData = dataDic.value(forKey: "data") as? Int64 else {
                    return
                }
                self?.detailView.headerView.autoCalculateMode = true
                if self?.detailView.headerView.viewState == .AssetsPoolTransferInBaseOnInputARequestRate {
                    self?.detailView.headerView.outputAmountTextField.text = getDecimalNumber(amount: NSDecimalNumber.init(value: tempData),
                                                                                              scale: 6,
                                                                                              unit: 1000000).stringValue
                } else {
                    self?.detailView.headerView.inputAmountTextField.text = getDecimalNumber(amount: NSDecimalNumber.init(value: tempData),
                                                                                             scale: 6,
                                                                                             unit: 1000000).stringValue
                }
                self?.detailView.headerView.viewState = .Normal
            } else if type == "GetPoolTokenInfo" {
                guard let tempData = dataDic.value(forKey: "data") as? AssetsPoolsInfoDataModel else {
                    return
                }
                self?.detailView.headerView.liquidityInfoModel = tempData
            }
            self?.detailView.hideToastActivity()
            self?.detailView.toastView?.hide(tag: 99)
        })
    }
}
extension AssetsPoolViewController: DropperDelegate {
    func DropperSelectedRow(_ path: IndexPath, contents: String) {
        self.detailView.headerView.tokenModel = self.currentTokens?[path.row]
        self.detailView.toastView?.show(tag: 99)
        self.dataModel.getPoolLiquidity(coinA: self.currentTokens?[path.row].coin_a?.module ?? "",
                                        coinB: self.currentTokens?[path.row].coin_b?.module ?? "")
    }
}
extension AssetsPoolViewController: AssetsPoolViewModelDelegate {
    func reloadSelectTokenViewA() {
        self.detailView.toastView?.hide(tag: 99)
        self.detailView.headerView.transferInInputTokenA = self.viewModel.tokenModelA
    }
    
    func reloadSelectTokenViewB() {
        self.detailView.toastView?.hide(tag: 99)
        self.detailView.headerView.transferInInputTokenB = self.viewModel.tokenModelB
    }
    
    func reloadLiquidityView() {
        self.detailView.hideToastActivity()
        var tempDropperData = [String]()
        guard let model = self.viewModel.liquidityModel, model.isEmpty == false else {
            
            self.detailView.makeToast(LibraWalletError.WalletRequest(reason: .dataEmpty).localizedDescription, position: .center)
            return
        }
        for item in self.viewModel.liquidityModel! {
            let tokenNameString = (item.coin_a?.show_name ?? "---") + "/" + (item.coin_b?.show_name ?? "---")
            tempDropperData.append(tokenNameString)
        }
        self.currentTokens = self.viewModel.liquidityModel!
        let realHeight = CGFloat((self.viewModel.liquidityModel?.count ?? 34) * 34)
        let height = realHeight > 34*6 ? 34*6:realHeight
        let dropper = Dropper.init(width: 120, height: height)
        dropper.items = tempDropperData
        dropper.cornerRadius = 8
        dropper.theme = .black(UIColor.init(hex: "F1EEFB"))
        dropper.cellTextFont = UIFont.systemFont(ofSize: 12, weight: UIFont.Weight.regular)
        dropper.cellColor = UIColor.init(hex: "333333")
        dropper.spacing = 12
        dropper.delegate = self
        if self.detailView.headerView.inputTokenButton.titleLabel?.text != localLanguage(keyString: "wallet_market_exchange_input_token_button_title") {
            let index = tempDropperData.firstIndex(of: self.detailView.headerView.inputTokenButton.titleLabel?.text ?? "")
            dropper.defaultSelectRow = index
        }
        dropper.show(Dropper.Alignment.center, button: (self.detailView.headerView.inputTokenButton))
    }
    
    func showToast(tag: Int) {
        self.detailView.toastView?.show(tag: tag)
    }
    
    func hideToast(tag: Int) {
        self.detailView.toastView?.hide(tag: tag)
    }
    
    func requestError(errorMessage: String) {
        print("")
    }    
}
