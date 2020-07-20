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
            if #available(iOS 11.0, *) {
                make.top.bottom.equalTo(self.view.safeAreaLayoutGuide)
            } else {
                make.top.bottom.equalTo(self.view)
            }
            make.left.right.equalTo(self.view)
        }
    }
    /// 网络请求、数据模型
    lazy var dataModel: AssetsPoolModel = {
        let model = AssetsPoolModel.init()
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
    func addLiquidityConfirm(amountIn: Double, amountOut: Double, inputModelName: String, outputModelName: String) {
        WalletManager.unlockWallet(controller: self, successful: { [weak self](mnemonic) in
            self?.detailView.toastView?.show(tag: 99)
            self?.dataModel.sendAddLiquidityViolasTransaction(sendAddress: "fa279f2615270daed6061313a48360f7",
                                                              amounta_desired: Double(amountIn),
                                                              amountb_desired: Double(amountOut),
                                                              amounta_min: Double(amountIn) * 0.995,
                                                              amountb_min: Double(amountOut) * 0.995,
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
    func removeLiquidityConfirm(token: Double, amountIn: Double, amountOut: Double, inputModelName: String, outputModelName: String) {
        print("Exchange")
        
        WalletManager.unlockWallet(controller: self, successful: { [weak self](mnemonic) in
            self?.detailView.toastView?.show(tag: 99)
            self?.dataModel.sendRemoveLiquidityViolasTransaction(sendAddress: "fa279f2615270daed6061313a48360f7",
                                                                 liquidity: token,
                                                                 amounta_min: amountIn,
                                                                 amountb_min: amountOut,
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
    
    func selectInputToken() {
        if self.detailView.headerView.changeTypeButton.titleLabel?.text == localLanguage(keyString: localLanguage(keyString: "wallet_assets_pool_transfer_in_title")) {
            // 转入
            self.detailView.toastView?.show(tag: 99)
            self.dataModel.getMarketTokens(address: "fa279f2615270daed6061313a48360f7")
        } else {
            // 转出
            self.detailView.makeToastActivity(.center)
            self.dataModel.getMarketMineTokens(address: "fa279f2615270daed6061313a48360f7")
        }
    }
    func selectOutoutToken() {
        if self.detailView.headerView.changeTypeButton.titleLabel?.text == localLanguage(keyString: localLanguage(keyString: "wallet_assets_pool_transfer_in_title")) {
            // 转入
            self.detailView.toastView?.show(tag: 99)
            self.dataModel.getMarketTokens(address: "fa279f2615270daed6061313a48360f7")
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
            self.detailView.toastView?.show(tag: 99)
            self.dataModel.getMarketAssetsPoolTransferOutRate(address: "fa279f2615270daed6061313a48360f7",
                                                              coinA: coinAModule,
                                                              coinB: coinBModule,
                                                              amount: Int64(amount * 1000000))
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
                    let tokenNameString = (item.coin_a_name ?? "---") + "/" + (item.coin_b_name ?? "---")
                    tempDropperData.append(tokenNameString)
                }
                self?.currentTokens = tempData.balance
                let dropper = Dropper.init(width: 120, height: CGFloat((tempData.balance?.count ?? 34) * 34))
                dropper.items = tempDropperData
                dropper.cornerRadius = 8
                dropper.theme = .black(UIColor.init(hex: "F1EEFB"))
                dropper.cellTextFont = UIFont.systemFont(ofSize: 12, weight: UIFont.Weight.regular)
                dropper.cellColor = UIColor.init(hex: "333333")
                dropper.spacing = 12
                dropper.show(Dropper.Alignment.center, button: (self?.detailView.headerView.inputTokenButton)!)
                dropper.delegate = self
            } else if type == "GetAssetsPoolTransferOutInfo" {
                guard let tempData = dataDic.value(forKey: "data") as? AssetsPoolTransferOutInfoDataModel else {
                    return
                }
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
                    self?.detailView.makeToast("发送成功", position: .center)
                } else {
                    print("资金池转出成功")
                    self?.detailView.makeToast("发送成功", position: .center)
                }
                self?.detailView.headerView.viewState = .Normal
            } else if type == "GetAssetsPoolTransferInInfo" {
                guard let tempData = dataDic.value(forKey: "data") as? Int64 else {
                    return
                }
                if self?.detailView.headerView.viewState == .AssetsPoolTransferInBaseOnInputARequestRate {
                    self?.detailView.headerView.outputAmountTextField.text = getDecimalNumber(amount: NSDecimalNumber.init(value: tempData ?? 0),
                                                                                              scale: 4,
                                                                                              unit: 1000000).stringValue
                    
                } else {
                    self?.detailView.headerView.inputAmountTextField.text = getDecimalNumber(amount: NSDecimalNumber.init(value: tempData ?? 0),
                                                                                             scale: 4,
                                                                                             unit: 1000000).stringValue
                }
                self?.detailView.headerView.viewState = .Normal
            }
            self?.detailView.hideToastActivity()
            self?.detailView.toastView?.hide(tag: 99)
        })
    }
}
extension AssetsPoolViewController: DropperDelegate {
    func DropperSelectedRow(_ path: IndexPath, contents: String) {
        self.detailView.headerView.tokenModel = self.currentTokens?[path.row]
    }
}
