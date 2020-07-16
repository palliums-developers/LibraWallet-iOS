//
//  AssetsPoolModel.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/7/1.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit
import Moya
struct AssetsPoolTransferOutInfoDataModel: Codable {
    /// 输入数量
    var coin_a_value: Int64?
    /// 兑换数量
    var coin_b_value: Int64?
    /// 输入币名
    var coin_a_name: String?
    /// 兑换币名
    var coin_b_name: String?
}
struct AssetsPoolTransferOutInfoMainModel: Codable {
    var code: Int?
    var message: String?
    var data: AssetsPoolTransferOutInfoDataModel?
}
struct AssetsPoolTransactionsDataModel: Codable {
    /// 输入数量
    var amounta: Int64?
    /// 兑换数量
    var amountb: Int64?
    /// 输入币名
    var coina: String?
    /// 兑换币名
    var coinb: String?
    /// 日期
    var date: Int?
    /// 状态（同链上状态）
    var status: Int?
    ///
    var token: Int64?
    /// 交易状态
    var transaction_type: String?
    /// 交易唯一ID
    var version: Int?
}
struct AssetsPoolTransactionsMainModel: Codable {
    var code: Int?
    var message: String?
    var data: [AssetsPoolTransactionsDataModel]?
}
class AssetsPoolModel: NSObject {
    private var requests: [Cancellable] = []
    @objc dynamic var dataDic: NSMutableDictionary = [:]
    private var sequenceNumber: Int?
    func getAssetsPoolTransactions(address: String, page: Int, pageSize: Int, requestStatus: Int) {
        let type = requestStatus == 0 ? "AssetsPoolTransactionsOrigin":"AssetsPoolTransactionsMore"
        let request = mainProvide.request(.AssetsPoolTransactions(address, page, pageSize)) {[weak self](result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(AssetsPoolTransactionsMainModel.self)
                    if json.code == 2000 {
                        guard json.data?.isEmpty == false else {
                            if requestStatus == 0 {
                                let data = setKVOData(error: LibraWalletError.WalletRequest(reason: .dataEmpty), type: type)
                                self?.setValue(data, forKey: "dataDic")
                            } else {
                                let data = setKVOData(error: LibraWalletError.WalletRequest(reason: .noMoreData), type: type)
                                self?.setValue(data, forKey: "dataDic")
                            }
                            return
                        }
                        let data = setKVOData(type: type, data: json.data)
                        self?.setValue(data, forKey: "dataDic")
                    } else {
                        print("\(type)_状态异常")
                        if let message = json.message, message.isEmpty == false {
                            let data = setKVOData(error: LibraWalletError.error(message), type: type)
                            self?.setValue(data, forKey: "dataDic")
                        } else {
                            let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.dataCodeInvalid), type: type)
                            self?.setValue(data, forKey: "dataDic")
                        }
                    }
                } catch {
                    print("\(type)解析异常\(error.localizedDescription)")
                    let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.parseJsonError), type: type)
                    self?.setValue(data, forKey: "dataDic")
                }
            case let .failure(error):
                guard error.errorCode != -999 else {
                    print("网络请求已取消")
                    return
                }
                print("\(type)网络异常\(error.localizedDescription)")
                let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.networkInvalid), type: type)
                self?.setValue(data, forKey: "dataDic")
            }
        }
        self.requests.append(request)
    }
    func sendAddLiquidityViolasTransaction(sendAddress: String, amounta_desired: Double, amountb_desired: Double, amounta_min: Double, amountb_min: Double, fee: Double, mnemonic: [String], moduleA: String, moduleB: String, feeModule: String) {
        let semaphore = DispatchSemaphore.init(value: 1)
        let queue = DispatchQueue.init(label: "SendQueue")
        queue.async {
            semaphore.wait()
            self.getViolasSequenceNumber(sendAddress: sendAddress, semaphore: semaphore)
        }
        queue.async {
            semaphore.wait()
            do {
                let signature = try ViolasManager.getMarketAddLiquidityTransactionHex(sendAddress: sendAddress,
                                                                                      fee: fee,
                                                                                      mnemonic: mnemonic,
                                                                                      amounta_desired: amounta_desired,
                                                                                      amountb_desired: amountb_desired,
                                                                                      amounta_min: 0,
                                                                                      amountb_min: 0,
                                                                                      sequenceNumber: self.sequenceNumber ?? 0,
                                                                                      moduleA: moduleA,
                                                                                      moduleB: moduleB,
                                                                                      feeModule: "LBR")
                self.makeViolasTransaction(signature: signature)
            } catch {
                print(error.localizedDescription)
                DispatchQueue.main.async(execute: {
                    let data = setKVOData(error: LibraWalletError.error(error.localizedDescription), type: "SendViolasTransaction")
                    self.setValue(data, forKey: "dataDic")
                })
            }
            semaphore.signal()
        }
    }
    private func getViolasSequenceNumber(sendAddress: String, semaphore: DispatchSemaphore) {
        let request = mainProvide.request(.GetViolasAccountInfo(sendAddress)) {[weak self](result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(BalanceViolasMainModel.self)
                    if json.result != nil {
                       self?.sequenceNumber = json.result?.sequence_number ?? 0
                       semaphore.signal()
                    } else {
                        print("SendLibraTransaction_状态异常")
                        DispatchQueue.main.async(execute: {
                            if let message = json.error?.message, message.isEmpty == false {
                                let data = setKVOData(error: LibraWalletError.error(message), type: "SendLibraTransaction")
                                self?.setValue(data, forKey: "dataDic")
                            } else {
                                let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.dataCodeInvalid), type: "SendLibraTransaction")
                                self?.setValue(data, forKey: "dataDic")
                            }
                        })
                    }
                } catch {
                    print("GetViolasSequenceNumber_解析异常\(error.localizedDescription)")
                    DispatchQueue.main.async(execute: {
                        let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.parseJsonError), type: "GetViolasSequenceNumber")
                        self?.setValue(data, forKey: "dataDic")
                    })
                }
            case let .failure(error):
                guard error.errorCode != -999 else {
                    print("GetViolasSequenceNumber_网络请求已取消")
                    return
                }
                DispatchQueue.main.async(execute: {
                    let data = setKVOData(error: LibraWalletError.WalletRequest(reason: .networkInvalid), type: "GetViolasSequenceNumber")
                    self?.setValue(data, forKey: "dataDic")
                })
            }
        }
        self.requests.append(request)
    }
    private func makeViolasTransaction(signature: String) {
        let request = mainProvide.request(.SendViolasTransaction(signature)) {[weak self](result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(LibraTransferMainModel.self)
                    if json.result == nil {
                       DispatchQueue.main.async(execute: {
                           let data = setKVOData(type: "SendViolasTransaction")
                           self?.setValue(data, forKey: "dataDic")
                       })
                    } else {
                        print("SendViolasTransaction_状态异常")
                        DispatchQueue.main.async(execute: {
                            if let message = json.error?.message, message.isEmpty == false {
                                let data = setKVOData(error: LibraWalletError.error(message), type: "SendViolasTransaction")
                                self?.setValue(data, forKey: "dataDic")
                            } else {
                                let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.dataCodeInvalid), type: "SendViolasTransaction")
                                self?.setValue(data, forKey: "dataDic")
                            }
                        })
                    }
                } catch {
                    print("SendViolasTransaction_解析异常\(error.localizedDescription)")
                    DispatchQueue.main.async(execute: {
                        let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.parseJsonError), type: "SendViolasTransaction")
                        self?.setValue(data, forKey: "dataDic")
                    })
                }
            case let .failure(error):
                guard error.errorCode != -999 else {
                    print("SendViolasTransaction_网络请求已取消")
                    return
                }
                DispatchQueue.main.async(execute: {
                    let data = setKVOData(error: LibraWalletError.WalletRequest(reason: .networkInvalid), type: "SendViolasTransaction")
                    self?.setValue(data, forKey: "dataDic")
                })
                
            }
        }
        self.requests.append(request)
    }

    deinit {
        requests.forEach { cancellable in
            cancellable.cancel()
        }
        requests.removeAll()
        print("AssetsPoolModel销毁了")
    }
}
extension AssetsPoolModel {
    func getMarketMineTokens(address: String) {
        let request = mainProvide.request(.MarketMineTokens(address)) {[weak self](result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(MarketMineMainModel.self)
                    if json.code == 2000 {
                        guard let models = json.data?.balance, models.isEmpty == false else {
                            let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.dataEmpty), type: "GetMarketMineTokens")
                            self?.setValue(data, forKey: "dataDic")
                            print("GetMarketMineTokens_状态异常")
                            return
                        }
                        let data = setKVOData(type: "GetMarketMineTokens", data: json.data)
                        self?.setValue(data, forKey: "dataDic")
                    } else {
                        print("GetMarketMineTokens_状态异常")
                        if let message = json.message, message.isEmpty == false {
                            let data = setKVOData(error: LibraWalletError.error(message), type: "GetMarketMineTokens")
                            self?.setValue(data, forKey: "dataDic")
                        } else {
                            let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.dataCodeInvalid), type: "GetMarketMineTokens")
                            self?.setValue(data, forKey: "dataDic")
                        }
                    }
                } catch {
                    print("GetMarketMineTokens_解析异常\(error.localizedDescription)")
                    let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.parseJsonError), type: "GetMarketMineTokens")
                    self?.setValue(data, forKey: "dataDic")
                }
            case let .failure(error):
                guard error.errorCode != -999 else {
                    print("网络请求已取消")
                    return
                }
                let data = setKVOData(error: LibraWalletError.WalletRequest(reason: .networkInvalid), type: "GetMarketMineTokens")
                self?.setValue(data, forKey: "dataDic")
            }
            
        }
        self.requests.append(request)
    }
}
extension AssetsPoolModel {
    func getMarketAssetsPoolTransferOutRate(address: String, coinA: String, coinB: String, amount: Int64) {
        let request = mainProvide.request(.AssetsPoolTransferOutInfo(address, coinA, coinB, amount)) {[weak self](result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(AssetsPoolTransferOutInfoMainModel.self)
                    if json.code == 2000 {
//                        guard let models = json.data, models.isEmpty == false else {
//                            let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.dataEmpty), type: "GetAssetsPoolTransferOutInfo")
//                            self?.setValue(data, forKey: "dataDic")
//                            print("GetAssetsPoolTransferOutInfo_状态异常")
//                            return
//                        }
                        let data = setKVOData(type: "GetAssetsPoolTransferOutInfo", data: json.data)
                        self?.setValue(data, forKey: "dataDic")
                    } else {
                        print("GetAssetsPoolTransferOutInfo_状态异常")
                        if let message = json.message, message.isEmpty == false {
                            let data = setKVOData(error: LibraWalletError.error(message), type: "GetAssetsPoolTransferOutInfo")
                            self?.setValue(data, forKey: "dataDic")
                        } else {
                            let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.dataCodeInvalid), type: "GetAssetsPoolTransferOutInfo")
                            self?.setValue(data, forKey: "dataDic")
                        }
                    }
                } catch {
                    print("GetAssetsPoolTransferOutInfo_解析异常\(error.localizedDescription)")
                    let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.parseJsonError), type: "GetAssetsPoolTransferOutInfo")
                    self?.setValue(data, forKey: "dataDic")
                }
            case let .failure(error):
                guard error.errorCode != -999 else {
                    print("网络请求已取消")
                    return
                }
                let data = setKVOData(error: LibraWalletError.WalletRequest(reason: .networkInvalid), type: "GetAssetsPoolTransferOutInfo")
                self?.setValue(data, forKey: "dataDic")
            }
            
        }
        self.requests.append(request)
    }
}
