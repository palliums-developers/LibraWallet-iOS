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
// MARK: - 添加、移除流动性
extension AssetsPoolModel {
    func sendAddLiquidityViolasTransaction(sendAddress: String, amounta_desired: UInt64, amountb_desired: UInt64, amounta_min: UInt64, amountb_min: UInt64, fee: UInt64, mnemonic: [String], moduleA: String, moduleB: String, feeModule: String, completion: @escaping (Result<Bool, LibraWalletError>) -> Void) {
        let semaphore = DispatchSemaphore.init(value: 1)
        let queue = DispatchQueue.init(label: "SendQueue")
        var sequenceNumber: UInt64?
        queue.async {
            semaphore.wait()
            self.getViolasSequenceNumber(sendAddress: sendAddress) { (result) in
                switch result {
                case let .success(sequence):
                    sequenceNumber = sequence
                    semaphore.signal()
                case let .failure(error):
                    DispatchQueue.main.async(execute: {
                        completion(.failure(error))
                    })
                }
            }
        }
        queue.async {
            semaphore.wait()
            do {
                let signature = try ViolasManager.getMarketAddLiquidityTransactionHex(sendAddress: sendAddress,
                                                                                      mnemonic: mnemonic,
                                                                                      feeModule: feeModule,
                                                                                      maxGasAmount: self.maxGasAmount,
                                                                                      maxGasUnitPrice: ViolasManager.handleMaxGasUnitPrice(maxGasAmount: self.maxGasAmount),
                                                                                      sequenceNumber: sequenceNumber ?? 0,
                                                                                      desiredAmountA: amounta_desired,
                                                                                      desiredAmountB: amountb_desired,
                                                                                      minAmountA: amounta_min,
                                                                                      minAmountB: amountb_min,
                                                                                      inputModuleA: moduleA,
                                                                                      inputModuleB: moduleB)
                self.makeViolasTransaction(signature: signature) { (result) in
                    switch result {
                    case let .success(state):
                        print("success")
                        DispatchQueue.main.async(execute: {
                            completion(.success(state))
                        })
                    case let .failure(error):
                        DispatchQueue.main.async(execute: {
                            completion(.failure(error))
                        })
                    }
                }
            } catch {
                print(error.localizedDescription)
                DispatchQueue.main.async(execute: {
                    completion(.failure(LibraWalletError.error(error.localizedDescription)))
                })
            }
            semaphore.signal()
        }
    }
    func sendRemoveLiquidityViolasTransaction(sendAddress: String, liquidity: Double, amounta_min: Double, amountb_min: Double, fee: UInt64, mnemonic: [String], moduleA: String, moduleB: String, feeModule: String, completion: @escaping (Result<Bool, LibraWalletError>) -> Void) {
        let semaphore = DispatchSemaphore.init(value: 1)
        let queue = DispatchQueue.init(label: "SendQueue")
        var sequenceNumber: UInt64?
        queue.async {
            semaphore.wait()
            self.getViolasSequenceNumber(sendAddress: sendAddress) { (result) in
                switch result {
                case let .success(sequence):
                    sequenceNumber = sequence
                    semaphore.signal()
                case let .failure(error):
                    DispatchQueue.main.async(execute: {
                        completion(.failure(error))
                    })
                }
            }
        }
        queue.async {
            semaphore.wait()
            do {
                let signature = try ViolasManager.getMarketRemoveLiquidityTransactionHex(sendAddress: sendAddress,
                                                                                         mnemonic: mnemonic,
                                                                                         feeModule: feeModule,
                                                                                         maxGasAmount: self.maxGasAmount,
                                                                                         maxGasUnitPrice: ViolasManager.handleMaxGasUnitPrice(maxGasAmount: self.maxGasAmount),
                                                                                         sequenceNumber: sequenceNumber ?? 0,
                                                                                         liquidity: (NSDecimalNumber.init(value: liquidity).multiplying(by: NSDecimalNumber.init(value: 1000000))).uint64Value,
                                                                                         minAmountA: (NSDecimalNumber.init(value: amounta_min).multiplying(by: NSDecimalNumber.init(value: 1000000))).uint64Value,
                                                                                         minAmountB: (NSDecimalNumber.init(value: amountb_min).multiplying(by: NSDecimalNumber.init(value: 1000000))).uint64Value,
                                                                                         inputModuleA: moduleA,
                                                                                         inputModuleB: moduleB)
                self.makeViolasTransaction(signature: signature) { (result) in
                    switch result {
                    case let .success(state):
                        print("success")
                        DispatchQueue.main.async(execute: {
                            completion(.success(state))
                        })
                    case let .failure(error):
                        DispatchQueue.main.async(execute: {
                            completion(.failure(error))
                        })
                    }
                }
            } catch {
                print(error.localizedDescription)
                DispatchQueue.main.async(execute: {
                    completion(.failure(LibraWalletError.error(error.localizedDescription)))
                })
            }
            semaphore.signal()
        }
    }
    private func getViolasSequenceNumber(sendAddress: String, completion: @escaping (Result<UInt64, LibraWalletError>) -> Void) {
        let request = violasModuleProvide.request(.accountInfo(sendAddress)) {[weak self](result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(ViolasAccountMainModel.self)
                    if json.error == nil {
                        self?.maxGasAmount = ViolasManager.handleMaxGasAmount(balances: json.result?.balances ?? [ViolasBalanceDataModel.init(amount: 0, currency: "VLS")])
                        completion(.success(json.result?.sequence_number ?? 0))
                    } else {
                        print("GetViolasSequenceNumber_状态异常")
                        if let message = json.error?.message, message.isEmpty == false {
                            completion(.failure(LibraWalletError.error(message)))
                        } else {
                            completion(.failure(LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.dataCodeInvalid)))
                        }
                    }
                } catch {
                    print("GetViolasSequenceNumber_解析异常\(error.localizedDescription)")
                    completion(.failure(LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.parseJsonError)))
                }
            case let .failure(error):
                guard error.errorCode != -999 else {
                    print("GetViolasSequenceNumber_网络请求已取消")
                    return
                }
                completion(.failure(LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.networkInvalid)))
            }
        }
        self.requests.append(request)
    }
    private func makeViolasTransaction(signature: String, completion: @escaping (Result<Bool, LibraWalletError>) -> Void) {
        let request = violasModuleProvide.request(.sendTransaction(signature)) { (result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(ViolasAccountMainModel.self)
                    if json.result == nil {
                        completion(.success(true))
                    } else {
                        print("SendViolasTransaction_状态异常")
                        if let message = json.error?.message, message.isEmpty == false {
                            completion(.failure(LibraWalletError.error(message)))
                        } else {
                            completion(.failure(LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.dataCodeInvalid)))
                        }
                    }
                } catch {
                    print("SendViolasTransaction_解析异常\(error.localizedDescription)")
                    completion(.failure(LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.parseJsonError)))
                }
            case let .failure(error):
                guard error.errorCode != -999 else {
                    print("SendViolasTransaction_网络请求已取消")
                    return
                }
                completion(.failure(LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.networkInvalid)))
            }
        }
        self.requests.append(request)
    }
}
// MARK: - 获取交易所支持币种
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
// MARK: - 获取资金池流通性
extension AssetsPoolModel {
    func getPoolLiquidity(coinA: String, coinB: String, completion: @escaping (Result<AssetsPoolsInfoDataModel, LibraWalletError>) -> Void) {
        let request = marketModuleProvide.request(.poolLiquidity(coinA, coinB)) { (result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(AssetsPoolsInfoMainModel.self)
                    if json.code == 2000 {
                        guard let token = json.data else {
                            completion(.failure(LibraWalletError.WalletRequest(reason: .dataEmpty)))
                            return
                        }
                        completion(.success(token))
                    } else {
                        print("GetPoolTokenInfo_状态异常")
                        if let message = json.message, message.isEmpty == false {
                            completion(.failure(LibraWalletError.error(message)))
                        } else {
                            completion(.failure(LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.dataCodeInvalid)))
                        }
                    }
                } catch {
                    print("GetPoolTokenInfo_解析异常\(error.localizedDescription)")
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
// MARK: - 获取本人资金池中通证数量
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
