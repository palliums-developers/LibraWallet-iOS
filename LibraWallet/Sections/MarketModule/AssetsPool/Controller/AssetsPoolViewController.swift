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
    func exchangeConfirm(amountIn: Int64, amountOut: Int64, inputModelName: String, outputModelName: String) {
        print("Exchange")
        
        WalletManager.unlockWallet(controller: self, successful: { [weak self](mnemonic) in
//            self?.dataModel.sendAddLiquidityViolasTransaction(sendAddress: "fa279f2615270daed6061313a48360f7",
//                                                              amounta_desired: amountIn,
//                                                              amountb_desired: amountOut,
//                                                              amounta_min: 0,
//                                                              amountb_min: 0,
//                                                              fee: 0,
//                                                              mnemonic: mnemonic,
//                                                              moduleA: inputModelName,
//                                                              moduleB: outputModelName,
//                                                              feeModule: "LBR")
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
        } else {
            // 转出
            self.detailView.makeToastActivity(.center)
            self.dataModel.getMarketMineTokens(address: "fa279f2615270daed6061313a48360f7")
        }
    }
    func selectOutoutToken() {
        print("selectOutoutToken")
    }
    func swapInputOutputToken() {
        print("Swap")
    }
    func changeTrasferInOut() {
        
    }
    func dealTransferOutAmount(amount: Int64) {
        self.detailView.toastView?.show(tag: 99)
        self.dataModel.getMarketAssetsPoolTransferOutRate(address: "fa279f2615270daed6061313a48360f7", coinA: "VLSUSD", coinB: "VLSEUR", amount: amount * 1000000)
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
                
            }
            self?.detailView.hideToastActivity()
            self?.detailView.toastView?.hide(tag: 99)
        })
    }
}
extension AssetsPoolViewController: DropperDelegate {
    func DropperSelectedRow(_ path: IndexPath, contents: String) {
        self.detailView.headerView.inputTokenButton.setTitle(contents, for: UIControl.State.normal)
        self.detailView.headerView.tokenModel = self.currentTokens?[path.row]
    }
}
