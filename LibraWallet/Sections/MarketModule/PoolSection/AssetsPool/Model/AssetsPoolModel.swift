//
//  AssetsPoolModel.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/7/1.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit
import Moya

struct AssetsPoolsInfoDataModel: Codable {
    var coina: PoolLiquidityCoinADataModel?
    var coinb: PoolLiquidityCoinBDataModel?
    var liquidity_total_supply: Int64?
}
struct AssetsPoolsInfoMainModel: Codable {
    var code: Int?
    var message: String?
    var data: AssetsPoolsInfoDataModel?
}
struct AssetsPoolTransferInInfoMainModel: Codable {
    var code: Int?
    var message: String?
    var data: Int64?
}
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
    var amounta: UInt64?
    /// 兑换数量
    var amountb: UInt64?
    /// 输入币名
    var coina: String?
    ///
    var coina_show_name: String?
    /// 兑换币名
    var coinb: String?
    ///
    var coinb_show_name: String?
    ///
    var confirmed_time: Int?
    /// 日期
    var date: Int?
    ///
    var gas_currency: String?
    ///
    var gas_used: UInt64?
    
    /// 状态（同链上状态）
    var status: String?
    ///
    var token: UInt64?
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
    private var sequenceNumber: UInt64?
    private var maxGasAmount: UInt64 = 600
    var tokenModel: AssetsPoolsInfoDataModel?
    deinit {
        requests.forEach { cancellable in
            cancellable.cancel()
        }
        requests.removeAll()
        print("AssetsPoolModel销毁了")
    }
}
extension AssetsPoolModel {
    func sendAddLiquidityViolasTransaction(sendAddress: String, amounta_desired: UInt64, amountb_desired: UInt64, amounta_min: UInt64, amountb_min: UInt64, fee: UInt64, mnemonic: [String], moduleA: String, moduleB: String, feeModule: String) {
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
                                                                                      mnemonic: mnemonic,
                                                                                      feeModule: feeModule,
                                                                                      maxGasAmount: self.maxGasAmount,
                                                                                      maxGasUnitPrice: ViolasManager.handleMaxGasUnitPrice(maxGasAmount: self.maxGasAmount),
                                                                                      sequenceNumber: self.sequenceNumber ?? 0,
                                                                                      desiredAmountA: amounta_desired,
                                                                                      desiredAmountB: amountb_desired,
                                                                                      minAmountA: amounta_min,
                                                                                      minAmountB: amountb_min,
                                                                                      inputModuleA: moduleA,
                                                                                      inputModuleB: moduleB)
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
    func sendRemoveLiquidityViolasTransaction(sendAddress: String, liquidity: Double, amounta_min: Double, amountb_min: Double, fee: UInt64, mnemonic: [String], moduleA: String, moduleB: String, feeModule: String) {
        let semaphore = DispatchSemaphore.init(value: 1)
        let queue = DispatchQueue.init(label: "SendQueue")
        queue.async {
            semaphore.wait()
            self.getViolasSequenceNumber(sendAddress: sendAddress, semaphore: semaphore)
        }
        queue.async {
            semaphore.wait()
            do {
                let signature = try ViolasManager.getMarketRemoveLiquidityTransactionHex(sendAddress: sendAddress,
                                                                                         mnemonic: mnemonic,
                                                                                         feeModule: feeModule,
                                                                                         maxGasAmount: self.maxGasAmount,
                                                                                         maxGasUnitPrice: ViolasManager.handleMaxGasUnitPrice(maxGasAmount: self.maxGasAmount),
                                                                                         sequenceNumber: self.sequenceNumber ?? 0,
                                                                                         liquidity: (NSDecimalNumber.init(value: liquidity).multiplying(by: NSDecimalNumber.init(value: 1000000))).uint64Value,
                                                                                         minAmountA: (NSDecimalNumber.init(value: amounta_min).multiplying(by: NSDecimalNumber.init(value: 1000000))).uint64Value,
                                                                                         minAmountB: (NSDecimalNumber.init(value: amountb_min).multiplying(by: NSDecimalNumber.init(value: 1000000))).uint64Value,
                                                                                         inputModuleA: moduleA,
                                                                                         inputModuleB: moduleB)
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
        let request = violasModuleProvide.request(.accountInfo(sendAddress)) {[weak self](result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(ViolasAccountMainModel.self)
                    if json.result != nil {
                        self?.sequenceNumber = json.result?.sequence_number ?? 0
                        self?.maxGasAmount = ViolasManager.handleMaxGasAmount(balances: json.result?.balances ?? [ViolasBalanceDataModel.init(amount: 0, currency: "VLS")])
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
        let request = violasModuleProvide.request(.sendTransaction(signature)) {[weak self](result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(ViolasAccountMainModel.self)
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
}

extension AssetsPoolModel {
    func getMarketMineTokens(address: String, completion: @escaping (Result<MarketMineMainDataModel, LibraWalletError>) -> Void) {
        let request = marketModuleProvide.request(.marketMineTokens(address)) { (result) in
            switch result {
            case let .success(response):
                do {
                    let json = try response.map(MarketMineMainModel.self)
                    if json.code == 2000 {
                        if let data = json.data {
                            completion(.success(data))
                        } else {
                            completion(.failure(LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.parseJsonError)))
                        }
                    } else {
                        print("GetMarketMineTokens_状态异常")
                        if let message = json.message, message.isEmpty == false {
                            completion(.failure(LibraWalletError.error(message)))
                        } else {
                            completion(.failure(LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.dataCodeInvalid)))
                        }
                    }
                } catch {
                    print("GetMarketMineTokens_解析异常\(error.localizedDescription)")
                    completion(.failure(LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.parseJsonError)))
                }
            case let .failure(error):
                guard error.errorCode != -999 else {
                    print("网络请求已取消")
                    return
                }
                completion(.failure(LibraWalletError.WalletRequest(reason: .networkInvalid)))
            }
        }
        self.requests.append(request)
    }
}
extension AssetsPoolModel {
    func getMarketAssetsPoolTransferOutRate(address: String, coinA: String, coinB: String, amount: Int64) {
        let request = marketModuleProvide.request(.assetsPoolTransferOutInfo(address, coinA, coinB, amount)) {[weak self](result) in
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
    func getMarketAssetsPoolTransferInRate(coinA: String, coinB: String, amount: Int64) {
        let request = marketModuleProvide.request(.assetsPoolTransferInInfo(coinA, coinB, amount)) {[weak self](result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(AssetsPoolTransferInInfoMainModel.self)
                    if json.code == 2000 {
                        //                        guard let models = json.data, models.isEmpty == false else {
                        //                            let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.dataEmpty), type: "GetAssetsPoolTransferOutInfo")
                        //                            self?.setValue(data, forKey: "dataDic")
                        //                            print("GetAssetsPoolTransferOutInfo_状态异常")
                        //                            return
                        //                        }
                        let data = setKVOData(type: "GetAssetsPoolTransferInInfo", data: json.data)
                        self?.setValue(data, forKey: "dataDic")
                    } else if json.code == 4000 {
                        let data = setKVOData(error: LibraWalletError.error("CalculateRateFailed"), type: "GetAssetsPoolTransferInInfo")
                        self?.setValue(data, forKey: "dataDic")
                    } else {
                        print("GetAssetsPoolTransferInInfo_状态异常")
                        if let message = json.message, message.isEmpty == false {
                            let data = setKVOData(error: LibraWalletError.error(message), type: "GetAssetsPoolTransferInInfo")
                            self?.setValue(data, forKey: "dataDic")
                        } else {
                            let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.dataCodeInvalid), type: "GetAssetsPoolTransferInInfo")
                            self?.setValue(data, forKey: "dataDic")
                        }
                    }
                } catch {
                    print("GetAssetsPoolTransferInInfo_解析异常\(error.localizedDescription)")
                    let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.parseJsonError), type: "GetAssetsPoolTransferInInfo")
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
extension AssetsPoolModel {
    func getMarketTokens(address: String, completion: @escaping (Result<[MarketSupportTokensDataModel], LibraWalletError>) -> Void) {
        let group = DispatchGroup.init()
        let quene = DispatchQueue.init(label: "MarketSupportTokenQuene")
        let semaphore = DispatchSemaphore.init(value: 1)
        var marketTokens = [MarketSupportTokensDataModel]()
        var accountTokens = [ViolasBalanceDataModel]()
        quene.async(group: group, qos: .default, flags: [], execute: {
            group.enter()
            semaphore.wait()
            self.getMarketSupportTokens() { (result) in
                switch result {
                case let .success(models):
                    marketTokens = models
                    group.leave()
                    semaphore.signal()
                case let .failure(error):
                    completion(.failure(error))
                }
            }
        })
        quene.async(group: group, qos: .default, flags: [], execute: {
            group.enter()
            semaphore.wait()
            self.getViolasBalance(address: address) { (result) in
                switch result {
                case let .success(models):
                    accountTokens = models
                case let .failure(error):
                    print(error.localizedDescription)
                    completion(.failure(error))
                }
                group.leave()
            }
            semaphore.signal()
        })
        group.notify(queue: quene) {
            let result = self.handleMarketTokenState(marketTokens: marketTokens, accountTokens: accountTokens)
            DispatchQueue.main.async(execute: {
                completion(.success(result))
            })
        }
    }
    
    private func getMarketSupportTokens(completion: @escaping (Result<[MarketSupportTokensDataModel], LibraWalletError>) -> Void) {
        let request = marketModuleProvide.request(.marketSupportTokens) { (result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(MarketSupportTokensMainModel.self)
                    if json.code == 2000 {
                        completion(.success(json.data ?? [MarketSupportTokensDataModel]()))
                    } else {
                        print("GetMarketSupportTokens_状态异常")
                        if let message = json.message, message.isEmpty == false {
                            completion(.failure(LibraWalletError.error(message)))
                        } else {
                            completion(.failure(LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.dataCodeInvalid)))
                        }
                    }
                } catch {
                    print("GetMarketSupportTokens_解析异常\(error.localizedDescription)")
                    completion(.failure(LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.parseJsonError)))
                }
            case let .failure(error):
                guard error.errorCode != -999 else {
                    print("网络请求已取消")
                    return
                }
                completion(.failure(LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.networkInvalid)))
            }
        }
        self.requests.append(request)
    }
    private func getViolasBalance(address: String, completion: @escaping (Result<[ViolasBalanceDataModel], LibraWalletError>) -> Void) {
        let request = violasModuleProvide.request(.accountInfo(address)) { (result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(ViolasAccountMainModel.self)
                    if json.result == nil {
                        completion(.failure(LibraWalletError.WalletRequest(reason: .walletUnActive)))
                    } else {
                        completion(.success(json.result?.balances ?? [ViolasBalanceDataModel]()))
                    }
                } catch {
                    print("GetViolasBalance_解析异常\(error.localizedDescription)")
                    completion(.failure(LibraWalletError.WalletRequest(reason: .parseJsonError)))
                }
            case let .failure(error):
                guard error.errorCode != -999 else {
                    print("GetViolasBalance_网络请求已取消")
                    return
                }
                completion(.failure(LibraWalletError.WalletRequest(reason: .networkInvalid)))
            }
        }
        self.requests.append(request)
    }
    private func handleMarketTokenState(marketTokens: [MarketSupportTokensDataModel], accountTokens: [ViolasBalanceDataModel]) -> [MarketSupportTokensDataModel] {
        var tempTokens = [MarketSupportTokensDataModel]()
        for var token in marketTokens {
            token.activeState = false
            token.amount = 0
            for activeToken in accountTokens {
                if token.module == activeToken.currency {
                    token.activeState = true
                    token.amount = activeToken.amount ?? 0
                    continue
                }
            }
            tempTokens.append(token)
        }
        return tempTokens
    }
}
extension AssetsPoolModel {
    func getPoolLiquidity(coinA: String, coinB: String) {
        let request = marketModuleProvide.request(.poolLiquidity(coinA, coinB)) {[weak self](result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(AssetsPoolsInfoMainModel.self)
                    if json.code == 2000 {
                        guard let token = json.data else {
                            let data = setKVOData(error: LibraWalletError.WalletRequest(reason: .dataEmpty), type: "GetPoolTokenInfo")
                            self?.setValue(data, forKey: "dataDic")
                            return
                        }
                        self?.tokenModel = token
                        let data = setKVOData(type: "GetPoolTokenInfo", data: token)
                        self?.setValue(data, forKey: "dataDic")
                    } else {
                        print("GetPoolTokenInfo_状态异常")
                        if let message = json.message, message.isEmpty == false {
                            let data = setKVOData(error: LibraWalletError.error(message), type: "GetPoolTokenInfo")
                            self?.setValue(data, forKey: "dataDic")
                        } else {
                            let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.dataCodeInvalid), type: "GetPoolTokenInfo")
                            self?.setValue(data, forKey: "dataDic")
                        }
                    }
                } catch {
                    print("GetPoolTokenInfo_解析异常\(error.localizedDescription)")
                    let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.parseJsonError), type: "GetPoolTokenInfo")
                    self?.setValue(data, forKey: "dataDic")
                }
            case let .failure(error):
                guard error.errorCode != -999 else {
                    print("网络请求已取消")
                    return
                }
                let data = setKVOData(error: LibraWalletError.WalletRequest(reason: .networkInvalid), type: "GetLibraTokens")
                self?.setValue(data, forKey: "dataDic")
            }
        }
        self.requests.append(request)
    }
}
