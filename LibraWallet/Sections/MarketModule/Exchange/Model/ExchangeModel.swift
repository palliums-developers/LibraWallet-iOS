//
//  ExchangeModel.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/7/9.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit
import Moya
struct MarketSupportMappingTokensAssetsDataModel: Codable {
    var address: String?
    var module: String?
    var name: String?
}
struct MarketSupportMappingTokensToCoinDataModel: Codable {
    var coin_type: String?
    var assets: MarketSupportMappingTokensAssetsDataModel?
}
struct MarketSupportMappingTokensDataModel: Codable {
    ///
    var input_coin_type: String?
    ///
    var lable: String?
    ///
    var receiver_address: String?
    ///
    var to_coin: MarketSupportMappingTokensToCoinDataModel?
}
struct MarketSupportMappingTokensMainModel: Codable {
    var code: Int?
    var message: String?
    var data: [MarketSupportMappingTokensDataModel]?
}
struct ExchangeInfoDataModel: Codable {
    /// 兑换数量
    var amount: Int64?
    /// 兑换比例
    var rate: Double?
    /// 手续费
    var fee: Int64?
    /// 兑换路径
    var path: [UInt8]?
}
struct ExchangeInfoMainModel: Codable {
    var code: Int?
    var message: String?
    var data: ExchangeInfoDataModel?
}
struct MarketSupportTokensDataModel: Codable {
    /// 币序列号
    var index: Int?
    /// 币图标
    var icon: String?
    /// 合约地址
    var address: String?
    /// module名
    var module: String?
    /// 币名
    var name: String?
    /// 展示名字
    var show_name: String?
    /// 激活状态（自行添加）
    var activeState: Bool?
    /// 余额（自行添加）
    var amount: Int64?
    /// 币链归属（自行添加）（1:violas，0:libra，2:btc）
    var chainType: Int?
}
struct MarketSupportTokensChainModel: Codable {
    var libra: [MarketSupportTokensDataModel]?
    var btc: [MarketSupportTokensDataModel]?
    var violas: [MarketSupportTokensDataModel]?
}
struct MarketSupportTokensMainModel: Codable {
    var code: Int?
    var message: String?
    var data: MarketSupportTokensChainModel?
}

class ExchangeModel: NSObject {
    private var requests: [Cancellable] = []
    @objc dynamic var dataDic: NSMutableDictionary = [:]
    private var sequenceNumber: Int?
    private var marketTokens: MarketSupportTokensChainModel?
    private var accountViolasTokens: [ViolasBalanceModel]?
    private var accountLibraTokens: [LibraBalanceModel]?
    private var accountBTCAmount: String?
    
    func getExchangeTransactions(address: String, page: Int, pageSize: Int, requestStatus: Int) {
        let type = requestStatus == 0 ? "ExchangeTransactionsOrigin":"ExchangeTransactionsMore"
        let request = mainProvide.request(.ExchangeTransactions(address, page, pageSize)) {[weak self](result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(ExchangeTransactionsMainModel.self)
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
                    print("解析异常\(error.localizedDescription)")
                    let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.parseJsonError), type: type)
                    self?.setValue(data, forKey: "dataDic")
                }
            case let .failure(error):
                guard error.errorCode != -999 else {
                    print("网络请求已取消")
                    return
                }
                print(error.localizedDescription)
                let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.networkInvalid), type: type)
                self?.setValue(data, forKey: "dataDic")
            }
        }
        self.requests.append(request)
    }
    func getExchangeInfo(amount: Int64, inputModule: String, outputModule: String) {
        let request = mainProvide.request(.ExchangeTransferInfo(inputModule, outputModule, amount)) {[weak self](result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(ExchangeInfoMainModel.self)
                    if json.code == 2000 {
                        let data = setKVOData(type: "GetExchangeInfo", data: json.data)
                        self?.setValue(data, forKey: "dataDic")
                    } else {
                        print("GetExchangeInfo_状态异常")
                        if let message = json.message, message.isEmpty == false {
                            let data = setKVOData(error: LibraWalletError.error(message), type: "GetExchangeInfo")
                            self?.setValue(data, forKey: "dataDic")
                        } else {
                            let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.dataCodeInvalid), type: "GetExchangeInfo")
                            self?.setValue(data, forKey: "dataDic")
                        }
                    }
                } catch {
                    print("GetExchangeInfo_解析异常\(error.localizedDescription)")
                    let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.parseJsonError), type: "GetExchangeInfo")
                    self?.setValue(data, forKey: "dataDic")
                }
            case let .failure(error):
                guard error.errorCode != -999 else {
                    print("网络请求已取消")
                    return
                }
                let data = setKVOData(error: LibraWalletError.WalletRequest(reason: .networkInvalid), type: "GetExchangeInfo")
                self?.setValue(data, forKey: "dataDic")
            }
        }
        self.requests.append(request)
    }
    deinit {
        requests.forEach { cancellable in
            cancellable.cancel()
        }
        requests.removeAll()
        print("ExchangeModel销毁了")
    }
}
extension ExchangeModel {
    func sendSwapViolasTransaction(sendAddress: String, amountIn: Double, AmountOutMin: Double, path: [UInt8], fee: Double, mnemonic: [String], moduleA: String, moduleB: String, feeModule: String) {
        let semaphore = DispatchSemaphore.init(value: 1)
        let queue = DispatchQueue.init(label: "SendQueue")
        queue.async {
            semaphore.wait()
            self.getViolasSequenceNumber(sendAddress: sendAddress, semaphore: semaphore)
        }
        queue.async {
            semaphore.wait()
            do {
                let signature = try ViolasManager.getMarketSwapTransactionHex(sendAddress: sendAddress,
                                                                              amountIn: amountIn,
                                                                              amountOutMin: AmountOutMin,
                                                                              path: path,
                                                                              fee: 0,
                                                                              mnemonic: mnemonic,
                                                                              sequenceNumber: self.sequenceNumber ?? 0,
                                                                              moduleA: moduleA,
                                                                              moduleB: moduleB,
                                                                              feeModule: feeModule)
                self.makeViolasTransaction(signature: signature, type: "SendViolasTransaction")
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
    private func makeViolasTransaction(signature: String, type: String) {
        let request = mainProvide.request(.SendViolasTransaction(signature)) {[weak self](result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(LibraTransferMainModel.self)
                    if json.result == nil {
                        DispatchQueue.main.async(execute: {
                            let data = setKVOData(type: type)
                            self?.setValue(data, forKey: "dataDic")
                        })
                    } else {
//
                        print("\(type)_状态异常")
                        DispatchQueue.main.async(execute: {
                            if let message = json.error?.message, message.isEmpty == false {
                                let data = setKVOData(error: LibraWalletError.error(message), type: type)
                                self?.setValue(data, forKey: "dataDic")
                            } else {
                                let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.dataCodeInvalid), type: type)
                                self?.setValue(data, forKey: "dataDic")
                            }
                        })
                    }
                } catch {
                    print("\(type)_解析异常\(error.localizedDescription)")
                    DispatchQueue.main.async(execute: {
                        let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.parseJsonError), type: type)
                        self?.setValue(data, forKey: "dataDic")
                    })
                }
            case let .failure(error):
                guard error.errorCode != -999 else {
                    print("\(type)_网络请求已取消")
                    return
                }
                DispatchQueue.main.async(execute: {
                    let data = setKVOData(error: LibraWalletError.WalletRequest(reason: .networkInvalid), type: type)
                    self?.setValue(data, forKey: "dataDic")
                })
                
            }
        }
        self.requests.append(request)
    }
}
//MARK: - 获取支持列表
extension ExchangeModel {
    func getMarketTokens(btcAddress: String, violasAddress: String, libraAddress: String) {
        let quene = DispatchQueue.init(label: "MarketSupportTokenQuene")
        let semaphore = DispatchSemaphore.init(value: 1)
        quene.async {
            semaphore.wait()
            self.getMarketSupportTokens(semaphore: semaphore)
        }
        quene.async {
            semaphore.wait()
            self.getBTCBalance(address: btcAddress, semaphore: semaphore)
        }
        quene.async {
            semaphore.wait()
            self.getViolasBalance(address: violasAddress, semaphore: semaphore)
        }
        quene.async {
            semaphore.wait()
            self.getLibraBalance(address: libraAddress, semaphore: semaphore)
        }
        quene.async {
            semaphore.wait()
            self.handleMarketTokenState(semaphore: semaphore)
        }
    }
    
    private func getMarketSupportTokens(semaphore: DispatchSemaphore) {
        let request = mainProvide.request(.MarketSupportTokens) {[weak self](result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(MarketSupportTokensMainModel.self)
                    if json.code == 2000 {
                        //                        guard let violasTokens = json.data?.violas, violasTokens.isEmpty == false else {
                        //                            let data = setKVOData(error: LibraWalletError.WalletRequest(reason: .dataEmpty), type: "GetMarketSupportTokens")
                        //                            self?.setValue(data, forKey: "dataDic")
                        //                            return
                        //                        }
                        self?.marketTokens = json.data
                        semaphore.signal()
                    } else {
                        print("GetMarketSupportTokens_状态异常")
                        if let message = json.message, message.isEmpty == false {
                            let data = setKVOData(error: LibraWalletError.error(message), type: "GetMarketSupportTokens")
                            self?.setValue(data, forKey: "dataDic")
                        } else {
                            let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.dataCodeInvalid), type: "GetMarketSupportTokens")
                            self?.setValue(data, forKey: "dataDic")
                        }
                    }
                } catch {
                    print("GetMarketSupportTokens_解析异常\(error.localizedDescription)")
                    let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.parseJsonError), type: "GetMarketSupportTokens")
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
    func getBTCBalance(address: String, semaphore: DispatchSemaphore) {
        let request = mainProvide.request(.TrezorBTCBalance(address)) {[weak self](result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(TrezorBTCBalanceMainModel.self)
//                    let data = setKVOData(type: "UpdateBTCBalance", data: json)
//                    self?.setValue(data, forKey: "dataDic")
                    self?.accountBTCAmount = json.balance
                    semaphore.signal()
                } catch {
                    print("UpdateBTCBalance_解析异常\(error.localizedDescription)")
                    let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.parseJsonError), type: "UpdateBTCBalance")
                    self?.setValue(data, forKey: "dataDic")
                }
            case let .failure(error):
                guard error.errorCode != -999 else {
                    print("UpdateBTCBalance_网络请求已取消")
                    return
                }
                let data = setKVOData(error: LibraWalletError.WalletRequest(reason: .networkInvalid), type: "UpdateBTCBalance")
                self?.setValue(data, forKey: "dataDic")
            }
        }
        self.requests.append(request)
    }
    private func getViolasBalance(address: String, semaphore: DispatchSemaphore) {
        let request = mainProvide.request(.GetViolasAccountInfo(address)) {[weak self](result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(BalanceViolasMainModel.self)
                    if json.result == nil {
                        let data = setKVOData(type: "UpdateViolasBalance", data: [ViolasBalanceModel.init(amount: 0, currency: "LBR")])
                        self?.setValue(data, forKey: "dataDic")
                        print("激活失败")
                    } else {
                        self?.accountViolasTokens = json.result?.balances
                        semaphore.signal()
                    }
                } catch {
                    print("UpdateViolasBalance_解析异常\(error.localizedDescription)")
                    let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.parseJsonError), type: "UpdateViolasBalance")
                    self?.setValue(data, forKey: "dataDic")
                }
            case let .failure(error):
                guard error.errorCode != -999 else {
                    print("UpdateViolasBalance_网络请求已取消")
                    return
                }
                let data = setKVOData(error: LibraWalletError.WalletRequest(reason: .networkInvalid), type: "UpdateViolasBalance")
                self?.setValue(data, forKey: "dataDic")
            }
        }
        self.requests.append(request)
    }
    func getLibraBalance(address: String, semaphore: DispatchSemaphore) {
        let request = mainProvide.request(.GetLibraAccountBalance(address)) {[weak self](result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(BalanceLibraMainModel.self)
                    if json.result == nil {
                        let data = setKVOData(type: "UpdateLibraBalance", data: [LibraBalanceModel.init(amount: 0, currency: "LBR")])
                        self?.setValue(data, forKey: "dataDic")
                        print("激活失败")
                    } else {
                        self?.accountLibraTokens = json.result?.balances
                        semaphore.signal()
                    }
                } catch {
                    print("解析异常\(error.localizedDescription)")
                    let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.parseJsonError), type: "UpdateLibraBalance")
                    self?.setValue(data, forKey: "dataDic")
                }
            case let .failure(error):
                guard error.errorCode != -999 else {
                    print("网络请求已取消")
                    return
                }
                let data = setKVOData(error: LibraWalletError.WalletRequest(reason: .networkInvalid), type: "UpdateLibraBalance")
                self?.setValue(data, forKey: "dataDic")
            }
        }
        self.requests.append(request)
    }
    private func handleMarketTokenState(semaphore: DispatchSemaphore) {
        var tempTokens = [MarketSupportTokensDataModel]()
        if let tempBTCModels = self.marketTokens?.btc, tempBTCModels.isEmpty == false {
            var model = tempBTCModels[0]
            model.activeState = true
            model.chainType = 2
            model.amount = NSDecimalNumber.init(string: self.accountBTCAmount ?? "0").int64Value
            tempTokens.append(model)
        }
        if let tempViolasModels = self.marketTokens?.violas {
            for var token in tempViolasModels {
                token.activeState = false
                token.amount = 0
                token.chainType = 1
                for activeToken in self.accountViolasTokens! {
                    if token.module == activeToken.currency {
                        token.activeState = true
                        token.amount = activeToken.amount
                        continue
                    }
                }
                tempTokens.append(token)
            }
        }
        if let tempLibraModels = self.marketTokens?.libra {
            for var token in tempLibraModels {
                token.activeState = false
                token.amount = 0
                token.chainType = 0
                for activeToken in self.accountLibraTokens! {
                    if token.module == activeToken.currency {
                        token.activeState = true
                        token.amount = activeToken.amount
                        continue
                    }
                }
                tempTokens.append(token)
            }
        }
        
        DispatchQueue.main.async(execute: {
            let data = setKVOData(type: "SupportViolasTokens", data: tempTokens)
            self.setValue(data, forKey: "dataDic")
        })
        
        semaphore.signal()
        
    }
}
//MARK: - 发送Violas兑换Libra交易
extension ExchangeModel {
    func sendSwapViolasToLibraTransaction(sendAddress: String, amountIn: Double, AmountOut: Double, fee: Double, mnemonic: [String], moduleInput: String, feeModule: String, exchangeCenterAddress: String, receiveAddress: String, type: String) {
        let semaphore = DispatchSemaphore.init(value: 1)
        let queue = DispatchQueue.init(label: "SendQueue")
        queue.async {
            semaphore.wait()
            self.getViolasSequenceNumber(sendAddress: sendAddress, semaphore: semaphore)
        }
        queue.async {
            semaphore.wait()
            do {
                let signature = try ViolasManager.getViolasToLibraMappingTransactionHex(sendAddress: sendAddress,
                                                                                        module: moduleInput,
                                                                                        amountIn: amountIn,
                                                                                        amountOut: AmountOut,
                                                                                        fee: fee,
                                                                                        mnemonic: mnemonic,
                                                                                        sequenceNumber: self.sequenceNumber ?? 0,
                                                                                        exchangeCenterAddress: exchangeCenterAddress,
                                                                                        libraReceiveAddress: receiveAddress,
                                                                                        feeModule: feeModule,
                                                                                        type: type)
                self.makeViolasTransaction(signature: signature, type: "SendViolasToLibraMappingTransaction")
            } catch {
                print(error.localizedDescription)
                DispatchQueue.main.async(execute: {
                    let data = setKVOData(error: LibraWalletError.error(error.localizedDescription), type: "SendViolasToLibraMappingTransaction")
                    self.setValue(data, forKey: "dataDic")
                })
            }
            semaphore.signal()
        }
    }
}
//MARK: - 获取跨链映射支持币
extension ExchangeModel {
    func getMappingTokenList() {
        let request = mainProvide.request(.MarketSupportMappingTokens) {[weak self](result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(MarketSupportMappingTokensMainModel.self)
                    if json.code == 2000 {
                        let data = setKVOData(type: "GetMappingTokenList", data: json.data)
                        self?.setValue(data, forKey: "dataDic")
                    } else {
                        print("GetMappingTokenList_状态异常")
                        if let message = json.message, message.isEmpty == false {
                            let data = setKVOData(error: LibraWalletError.error(message), type: "GetMappingTokenList")
                            self?.setValue(data, forKey: "dataDic")
                        } else {
                            let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.dataCodeInvalid), type: "GetMappingTokenList")
                            self?.setValue(data, forKey: "dataDic")
                        }
                    }
                } catch {
                    print("GetMappingTokenList_解析异常\(error.localizedDescription)")
                    let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.parseJsonError), type: "GetMappingTokenList")
                    self?.setValue(data, forKey: "dataDic")
                }
            case let .failure(error):
                guard error.errorCode != -999 else {
                    print("网络请求已取消")
                    return
                }
                let data = setKVOData(error: LibraWalletError.WalletRequest(reason: .networkInvalid), type: "GetMappingTokenList")
                self?.setValue(data, forKey: "dataDic")
            }
        }
        self.requests.append(request)
    }
}
