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
}
extension ExchangeViewController: ExchangeViewHeaderViewDelegate {
    func dealTransferOutAmount(amount: Int64, inputModule: String, outputModule: String) {
        self.detailView.toastView?.show(tag: 99)
        self.dataModel.getExchangeInfo(amount: amount * 1000000,
                                       inputModule: inputModule,
                                       outputModule: outputModule)
    }
    
    func exchangeConfirm(amountIn: Double, amountOutMin: Double, inputModelName: String, outputModelName: String, path: [UInt8]) {
        print("Exchange")
        
        WalletManager.unlockWallet(controller: self, successful: { [weak self](mnemonic) in
            self?.detailView.toastView?.show(tag: 99)
            self?.dataModel.sendSwapViolasTransaction(sendAddress: "fa279f2615270daed6061313a48360f7",
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
    func selectInputToken() {
//        self.detailView.makeToastActivity(.center)
//        self.dataModel.getMarketSupportTokens()
        self.detailView.toastView?.show(tag: 99)
        self.dataModel.getMarketTokens(address: "fa279f2615270daed6061313a48360f7",
                                       showMineTokens: false)
    }
    func selectOutoutToken() {
        print("selectOutoutToken")
        self.detailView.toastView?.show(tag: 99)
        self.dataModel.getMarketTokens(address: "fa279f2615270daed6061313a48360f7",
                                       showMineTokens: false)
    }
    func swapInputOutputToken() {
        print("Swap")
    }
    
    
}
extension ExchangeViewController {
    func initKVO() {
        self.observer = dataModel.observe(\.dataDic, options: [.new], changeHandler: { [weak self](model, change) in
            guard let dataDic = change.newValue, dataDic.count != 0 else {
                self?.detailView.hideToastActivity()
                return
            }
            #warning("已修改完成，可拷贝执行")
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
            if type == "SupportViolasTokens" {
                guard let tempData = dataDic.value(forKey: "data") as? [MarketSupportTokensDataModel] else {
                    return
                }
                let alert = MappingTokenListAlert.init(data: tempData) { (model) in
                    print(model)
                    if self?.detailView.headerView.selectAToken == true {
                        self?.detailView.headerView.transferInInputTokenA = model
                    } else {
                        self?.detailView.headerView.transferInInputTokenB = model
                    }
                }
                alert.show(tag: 199)
                alert.showAnimation()
            } else if type == "GetExchangeInfo" {
                guard let tempData = dataDic.value(forKey: "data") as? ExchangeInfoDataModel else {
                    return
                }
                self?.detailView.headerView.exchangeModel = tempData
            } else if type == "SendViolasTransaction" {
                self?.detailView.makeToast("发送成功", position: .center)
            }
            self?.detailView.hideToastActivity()
            self?.detailView.toastView?.hide(tag: 99)
        })
    }
}

