//
//  LoanListViewModel.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/8/24.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit

class LoanListViewModel: NSObject {
    override init() {
        super.init()
    }
    deinit {
        print("LoanListViewModel销毁了")
    }
    var view: LoanListView? {
        didSet {
        }
    }
    /// 网络请求、数据模型
    lazy var dataModel: LoanListModel = {
        let model = LoanListModel.init()
        return model
    }()
    /// 数据监听KVO
    var observer: NSKeyValueObservation?
    ///
    private var firstRequestRate: Bool = true
    /// timer
    private var timer: Timer?
}
// MARK: - 网络请求逻辑处理
extension LoanListViewModel {
    func startAutoRefreshExchangeRate(inputCoinA: MarketSupportTokensDataModel, outputCoinB: MarketSupportTokensDataModel) {
        self.timer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(refreshExchangeRate), userInfo: nil, repeats: true)
        RunLoop.current.add(self.timer!, forMode: .common)
    }
    func stopAutoRefreshExchangeRate() {
        self.timer?.invalidate()
        self.timer = nil
    }
    @objc func refreshExchangeRate() {
        //        self.dataModel.getPoolTotalLiquidity(inputCoinA: (self.view?.headerView.transferInInputTokenA)!, inputCoinB: (self.view?.headerView.transferInInputTokenB)!)
    }
}
// MARK: - 逻辑处理
extension LoanListViewModel {
    #warning("以后启用")
    //    func handleConfirmCondition() throws -> (NSDecimalNumber, NSDecimalNumber, MarketSupportTokensDataModel, MarketSupportTokensDataModel) {
    //        // ModelA不为空
    //        guard let tempInputTokenA = self.view?.headerView.transferInInputTokenA else {
    //            throw LibraWalletError.error(localLanguage(keyString: "wallet_market_exchange_input_token_unselect"))
    //        }
    //        // ModelB不为空
    //        guard let tempInputTokenB = self.view?.headerView.transferInInputTokenB else {
    //            throw LibraWalletError.error(localLanguage(keyString: "wallet_market_exchange_output_token_unselect"))
    //        }
    //        // 付出币激活状态
    //        guard let tokenAActiveState = tempInputTokenA.activeState, tokenAActiveState == true else {
    //            throw LibraWalletError.error(localLanguage(keyString: "wallet_market_exchange_input_token_unactived"))
    //        }
    //        // 金额不为空检查
    //        guard let amountAString = self.view?.headerView.inputAmountTextField.text, amountAString.isEmpty == false else {
    //            throw LibraWalletError.WalletTransfer(reason: .amountEmpty)
    //
    //        }
    //        // 金额是否纯数字检查
    //        guard isPurnDouble(string: amountAString) == true else {
    //            throw LibraWalletError.WalletTransfer(reason: .amountInvalid)
    //        }
    //        // 转换数字
    //        let amountIn = NSDecimalNumber.init(string: amountAString)
    //
    //        // 金额不为空检查
    //        guard let amountBString = self.view?.headerView.outputAmountTextField.text, amountBString.isEmpty == false else {
    //            throw LibraWalletError.WalletTransfer(reason: .amountEmpty)
    //        }
    //        // 金额是否纯数字检查
    //        guard isPurnDouble(string: amountBString) == true else {
    //            throw LibraWalletError.WalletTransfer(reason: .amountInvalid)
    //        }
    //        // 转换数字
    //        let amountOut = NSDecimalNumber.init(string: amountBString)
    //        guard amountIn.int64Value > 0 else {
    //            throw LibraWalletError.WalletTransfer(reason: .amountInvalid)
    //        }
    //        guard amountOut.int64Value > 0 else {
    //            throw LibraWalletError.WalletTransfer(reason: .amountInvalid)
    //        }
    //        // 金额超限检测
    //        guard amountIn.multiplying(by: NSDecimalNumber.init(value: 1000000)).int64Value < (tempInputTokenA.amount ?? 0) else {
    //            throw LibraWalletError.WalletTransfer(reason: .amountOverload)
    //        }
    //        // 金额超限检测
    //        guard amountOut.multiplying(by: NSDecimalNumber.init(value: 1000000)).int64Value < (tempInputTokenB.amount ?? 0) else {
    //            throw LibraWalletError.WalletTransfer(reason: .amountOverload)
    //        }
    //        return (amountIn, amountOut, tempInputTokenA, tempInputTokenB)
    //    }
}
// MARK: - 网络请求
extension LoanListViewModel {
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
                self?.view?.toastView?.hide(tag: 399)
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
                //                self?.view?.headerView.viewState = .Normal
                return
            }
            let type = dataDic.value(forKey: "type") as! String
            if type == "SupportViolasTokens" {
                //                guard let datas = dataDic.value(forKey: "data") as? [MarketSupportTokensDataModel] else {
                //                    return
                //                }
                //                var tempData = datas
                //                if self?.view?.headerView.viewState == .ExchangeSelectAToken {
                //                    if let selectBModel = self?.view?.headerView.transferInInputTokenB {
                //                        if self?.view?.headerView.transferInInputTokenB?.chainType == 0 {
                //                            tempData = tempData.filter {
                //                                $0.chainType != 0
                //                            }
                //                        } else {
                //                            tempData = tempData.filter {
                //                                $0.module != selectBModel.module
                //                            }
                //                        }
                //                    }
                //                } else {
                //                    if let selectBModel = self?.view?.headerView.transferInInputTokenA {
                //                        if self?.view?.headerView.transferInInputTokenA?.chainType == 0 {
                //                            tempData = tempData.filter {
                //                                $0.chainType != 0
                //                            }
                //                        } else {
                //                            tempData = tempData.filter {
                //                                $0.module != selectBModel.module
                //                            }
                //                        }
                //                    }
                //                }
                //                let alert = MappingTokenListAlert.init(data: tempData) { (model) in
                //                    print(model)
                //                    if self?.view?.headerView.viewState == .ExchangeSelectAToken {
                //                        self?.view?.headerView.transferInInputTokenA = model
                //                    } else {
                //                        self?.view?.headerView.transferInInputTokenB = model
                //                    }
                //                    self?.view?.headerView.viewState = .Normal
                //                }
                //                alert.show(tag: 199)
                //                alert.showAnimation()
                //            } else if type == "GetExchangeInfo" {
                //                guard let tempData = dataDic.value(forKey: "data") as? ExchangeInfoModel else {
                //                    return
                //                }
                //                self?.view?.headerView.exchangeModel = tempData
                //            } else if type == "SendViolasTransaction" {
                //                self?.view?.headerView.inputAmountTextField.text = ""
                //                self?.view?.headerView.outputAmountTextField.text = ""
                //                self?.view?.makeToast(localLanguage(keyString: "wallet_market_exchange_submit_exchange_successful"), position: .center)
                //            } else if type == "SendViolasToLibraMappingTransaction" {
                //                self?.view?.headerView.viewState = .Normal
                //                self?.view?.headerView.inputAmountTextField.text = ""
                //                self?.view?.headerView.outputAmountTextField.text = ""
                //                self?.view?.makeToast(localLanguage(keyString: "wallet_market_exchange_submit_exchange_successful"), position: .center)
                //            } else if type == "SendLibraToViolasTransaction" {
                //                self?.view?.headerView.viewState = .Normal
                //                self?.view?.headerView.inputAmountTextField.text = ""
                //                self?.view?.headerView.outputAmountTextField.text = ""
                //                self?.view?.makeToast(localLanguage(keyString: "wallet_market_exchange_submit_exchange_successful"), position: .center)
                //            } else if type == "SendBTCTransaction" {
                //                self?.view?.headerView.viewState = .Normal
                //                self?.view?.headerView.inputAmountTextField.text = ""
                //                self?.view?.headerView.outputAmountTextField.text = ""
                //                self?.view?.makeToast(localLanguage(keyString: "wallet_market_exchange_submit_exchange_successful"), position: .center)
                //            } else if type == "GetPoolTotalLiquidity" {
                //                print("获取流动性成功")
                //                self?.view?.toastView?.hide(tag: 299)
                //                return
            }
            self?.view?.hideToastActivity()
            self?.view?.toastView?.hide(tag: 99)
        })
    }
}
