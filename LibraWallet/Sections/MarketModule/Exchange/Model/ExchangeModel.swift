//
//  ExchangeModel.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/7/9.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit
import Moya
import BitcoinKit
struct ExchangeInfoModel {
    var input: Int64
    var output: Int64
    var path: [UInt8]
    var outputWithoutFee: Int64
    var fee: Int64
    var models: [PoolLiquidityDataModel]
}
struct PoolLiquidityCoinBDataModel: Codable {
    var index: UInt8?
    var name: String?
    var value: Int64?
}
struct PoolLiquidityCoinADataModel: Codable {
    var index: UInt8?
    var name: String?
    var value: Int64?
}
struct PoolLiquidityDataModel: Codable {
    var coina: PoolLiquidityCoinADataModel?
    var coinb: PoolLiquidityCoinBDataModel?
    var liquidity_total_supply: Int64?
}
struct PoolLiquidityMainModel: Codable {
    var code: Int?
    var message: String?
    var data: [PoolLiquidityDataModel]?
}
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
    var index: UInt8?
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
    private var supportSwapData: MarketSupportMappingTokensDataModel?
    var utxos: [TrezorBTCUTXOMainModel]?
    var totalLiquidity: [PoolLiquidityDataModel]?
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
    var shortPath = [[PoolLiquidityDataModel]]()
    var tempArray = [PoolLiquidityDataModel]()
}

//MARK: - 获取支持列表
extension ExchangeModel {
    func getMarketTokens(btcAddress: String, violasAddress: String, libraAddress: String) {
        let group = DispatchGroup.init()
        let quene = DispatchQueue.init(label: "SupportTokenQuene")
        quene.async(group: group, qos: .default, flags: [], execute: {
            group.enter()
            self.getMarketSupportTokens(group: group)
        })
        quene.async(group: group, qos: .default, flags: [], execute: {
            group.enter()
            self.getBTCBalance(address: btcAddress, group: group)
        })
        quene.async(group: group, qos: .default, flags: [], execute: {
            group.enter()
            self.getViolasBalance(address: violasAddress, group: group)
        })
        quene.async(group: group, qos: .default, flags: [], execute: {
            group.enter()
            self.getLibraBalance(address: libraAddress, group: group)
        })
        group.notify(queue: quene) {
            print("回到该队列中执行")
            print("\(Thread.current)")
            self.handleMarketTokenState()
        }
    }
    private func getMarketSupportTokens(group: DispatchGroup) {
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
                        group.leave()
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
    func getBTCBalance(address: String, group: DispatchGroup) {
        let request = mainProvide.request(.TrezorBTCBalance(address)) {[weak self](result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(TrezorBTCBalanceMainModel.self)
                    //                    let data = setKVOData(type: "UpdateBTCBalance", data: json)
                    //                    self?.setValue(data, forKey: "dataDic")
                    self?.accountBTCAmount = json.balance
                    group.leave()
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
    private func getViolasBalance(address: String, group: DispatchGroup) {
        let request = mainProvide.request(.GetViolasAccountInfo(address)) {[weak self](result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(BalanceViolasMainModel.self)
                    if json.result == nil {
//                        let data = setKVOData(type: "UpdateViolasBalance", data: [ViolasBalanceModel.init(amount: 0, currency: "LBR")])
//                        self?.setValue(data, forKey: "dataDic")
                        self?.accountViolasTokens = [ViolasBalanceModel.init(amount: 0, currency: "LBR")]
                        group.leave()
                    } else {
                        self?.accountViolasTokens = json.result?.balances
                        group.leave()
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
    func getLibraBalance(address: String, group: DispatchGroup) {
        let request = mainProvide.request(.GetLibraAccountBalance(address)) {[weak self](result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(BalanceLibraMainModel.self)
                    if json.result == nil {
//                        let data = setKVOData(type: "UpdateLibraBalance", data: [LibraBalanceModel.init(amount: 0, currency: "LBR")])
//                        self?.setValue(data, forKey: "dataDic")
                        self?.accountLibraTokens = [LibraBalanceModel.init(amount: 0, currency: "LBR")]
                        group.leave()
                    } else {
                        self?.accountLibraTokens = json.result?.balances
                        group.leave()
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
    private func handleMarketTokenState() {
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
    }
}
//MARK: - 获取跨链映射支持币
extension ExchangeModel {
    private func getMappingTokenList(semaphore: DispatchSemaphore, outputModuleName: String, inputModule: String) {
        let request = mainProvide.request(.MarketSupportMappingTokens) {[weak self](result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(MarketSupportMappingTokensMainModel.self)
                    if json.code == 2000 {
                        //                        let data = setKVOData(type: "GetMappingTokenList", data: json.data)
                        //                        self?.setValue(data, forKey: "dataDic")
                        let tempModule = json.data?.filter({
                            $0.to_coin?.assets?.module == outputModuleName && $0.input_coin_type == inputModule
                        })
                        guard tempModule?.isEmpty == false else {
                            let data = setKVOData(error: LibraWalletError.error("Market Not Support"), type: "GetMappingTokenList")
                            self?.setValue(data, forKey: "dataDic")
                            return
                        }
                        self?.supportSwapData = tempModule?.first
                        semaphore.signal()
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
//MARK: - 获取资金池流动性
extension ExchangeModel {
    func getPoolTotalLiquidity(inputCoinA: MarketSupportTokensDataModel, inputCoinB: MarketSupportTokensDataModel) {
        let request = mainProvide.request(.PoolTotalLiquidity) {[weak self](result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(PoolLiquidityMainModel.self)
                    if json.code == 2000 {
                        guard let violasTokens = json.data, violasTokens.isEmpty == false else {
                            let data = setKVOData(error: LibraWalletError.WalletRequest(reason: .dataEmpty), type: "GetPoolTotalLiquidity")
                            self?.setValue(data, forKey: "dataDic")
                            return
                        }
                        self?.totalLiquidity = json.data
                        self?.handleLiquidity(inputCoinA: inputCoinA, outputCoinB: inputCoinB, data: json.data!)
                    } else {
                        print("GetPoolTotalLiquidity_状态异常")
                        if let message = json.message, message.isEmpty == false {
                            let data = setKVOData(error: LibraWalletError.error(message), type: "GetPoolTotalLiquidity")
                            self?.setValue(data, forKey: "dataDic")
                        } else {
                            let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.dataCodeInvalid), type: "GetPoolTotalLiquidity")
                            self?.setValue(data, forKey: "dataDic")
                        }
                    }
                } catch {
                    print("GetPoolTotalLiquidity_解析异常\(error.localizedDescription)")
                    let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.parseJsonError), type: "GetPoolTotalLiquidity")
                    self?.setValue(data, forKey: "dataDic")
                }
            case let .failure(error):
                guard error.errorCode != -999 else {
                    print("网络请求已取消")
                    return
                }
                let data = setKVOData(error: LibraWalletError.WalletRequest(reason: .networkInvalid), type: "GetPoolTotalLiquidity")
                self?.setValue(data, forKey: "dataDic")
            }
        }
        self.requests.append(request)
    }
    func handleLiquidity(inputCoinA: MarketSupportTokensDataModel, outputCoinB: MarketSupportTokensDataModel, data: [PoolLiquidityDataModel]) {
        shortPath.removeAll()
        let date1 = Date().timeIntervalSince1970
        let tempData = data
        let fliterPrifix0Data = tempData.filter {
            $0.coina?.index == inputCoinA.index || $0.coinb?.index == inputCoinA.index
        }
        let fliterWithout0Data = tempData.filter {
            $0.coina?.index != inputCoinA.index && $0.coinb?.index != inputCoinA.index
        }
        for item in fliterPrifix0Data {
            print("\(item)")
            // 初始符合
            tempArray.removeAll()
            tempArray.append(item)
            // 判断路径结束是否符合
            if item.coinb?.index == outputCoinB.index {
                // 结束符合
                shortPath.append(tempArray)
                tempArray.removeAll()
            } else {
                // 结束不符合,进入路径搜索
                var startIndex = inputCoinA.index
                if item.coinb?.index == inputCoinA.index {
                    startIndex = item.coina?.index
                } else {
                    startIndex = item.coinb?.index
                }
                fliterPath(inputCoinA: startIndex!, outputCoinB: outputCoinB.index!, data: fliterWithout0Data, originData: fliterWithout0Data)
            }
        }
        let date2 = Date().timeIntervalSince1970
        print("time\(Int((date2 - date1) * 1000))ms")
        let data = setKVOData(type: "GetPoolTotalLiquidity")
        self.setValue(data, forKey: "dataDic")
    }
    func fliterPath(inputCoinA: UInt8, outputCoinB: UInt8, data: [PoolLiquidityDataModel], originData: [PoolLiquidityDataModel]) {
        let tempData = data
        if data.count == 0 {
            print(shortPath)
            return
        } else {
            for item in tempData {
                // 判断当前路径是否符合要求的起始路径
                if (item.coina?.index == inputCoinA || item.coinb?.index == inputCoinA) {
                    // 初始符合
                    tempArray.append(item)
                    // 判断路径是否符合要求的结束路径
                    if item.coinb?.index == outputCoinB || item.coina?.index == outputCoinB {
                        // 查询结束
                        shortPath.append(tempArray)
                        if tempArray.count == 3 {
                            tempArray.removeLast(2)
                            return
                        } else {
                            tempArray.removeLast()
                            continue
                        }
                    } else {
                        guard tempArray.count < 3 else {
                            tempArray.removeLast()
                            continue
                        }
                        // 初始不符合
                        // 删除本身
                        let lastArray = originData.filter {
                            $0.coina?.value != item.coina?.value && $0.coinb?.value != item.coinb?.value
                        }
                        // 筛选接下来初始Index
                        let index = item.coina?.index == inputCoinA ? (item.coinb?.index):(item.coina?.index)
                        let tempppp = lastArray.filter {
                            $0.coina?.index == index || $0.coinb?.index == index
                        }
                        fliterPath(inputCoinA: index!, outputCoinB: outputCoinB, data: tempppp, originData: originData)
                    }
                }
            }
        }
    }
    func fliterBestOutput(inputAAmount: Int64, inputCoinA: UInt8, paths: [[PoolLiquidityDataModel]]) {
        
        let numberConfig = NSDecimalNumberHandler.init(roundingMode: .down,
                                                       scale: 6,
                                                       raiseOnExactness: false,
                                                       raiseOnOverflow: false,
                                                       raiseOnUnderflow: false,
                                                       raiseOnDivideByZero: false)
        var tempArray = [ExchangeInfoModel]()
        for path in paths {
            var output: Int64 = inputAAmount
            var outputWithoutFee: Int64 = inputAAmount
            var nextIndex = inputCoinA
            var pathArray: [UInt8] = [inputCoinA]
            var fee: Int64 = 0
            for item in path {
                if item.coina?.index == nextIndex {
                    let amountInWithFee = NSDecimalNumber.init(value: output).multiplying(by: NSDecimalNumber.init(value: 997))
                    let numerator = amountInWithFee.multiplying(by: NSDecimalNumber.init(value: item.coinb?.value ?? 0))
                    let denominator = (NSDecimalNumber.init(value: item.coina?.value ?? 0).multiplying(by: NSDecimalNumber.init(value: 1000))).adding(amountInWithFee)
                    output = numerator.dividing(by: denominator, withBehavior: numberConfig).int64Value
                    // fee
                    nextIndex = (item.coinb?.index)!
                    let amountInWithoutFee = NSDecimalNumber.init(value: outputWithoutFee).multiplying(by: NSDecimalNumber.init(value: 1000))
                    let numeratorWithoutFee = amountInWithoutFee.multiplying(by: NSDecimalNumber.init(value: item.coinb?.value ?? 0))
                    let denominatorWithoutFee = (NSDecimalNumber.init(value: item.coina?.value ?? 0).multiplying(by: NSDecimalNumber.init(value: 1000))).adding(amountInWithoutFee)
                    outputWithoutFee = numeratorWithoutFee.dividing(by: denominatorWithoutFee, withBehavior: numberConfig).int64Value
                } else {
                    let amountInWithFee = NSDecimalNumber.init(value: output).multiplying(by: NSDecimalNumber.init(value: 997))
                    let numerator = amountInWithFee.multiplying(by: NSDecimalNumber.init(value: item.coina?.value ?? 0))
                    let denominator = NSDecimalNumber.init(value: item.coinb?.value ?? 0).multiplying(by: NSDecimalNumber.init(value: 1000)).adding(amountInWithFee)
                    output = numerator.dividing(by: denominator, withBehavior: numberConfig).int64Value
                    nextIndex = (item.coina?.index)!
                    // fee
                    let amountInWithoutFee = NSDecimalNumber.init(value: outputWithoutFee).multiplying(by: NSDecimalNumber.init(value: 1000))
                    let numeratorWithoutFee = amountInWithoutFee.multiplying(by: NSDecimalNumber.init(value: item.coina?.value ?? 0))
                    let denominatorWithoutFee = (NSDecimalNumber.init(value: item.coinb?.value ?? 0).multiplying(by: NSDecimalNumber.init(value: 1000))).adding(amountInWithoutFee)
                    outputWithoutFee = numeratorWithoutFee.dividing(by: denominatorWithoutFee, withBehavior: numberConfig).int64Value
                }
                pathArray.append(nextIndex)
            }
            fee = outputWithoutFee - output
            let tempModel = ExchangeInfoModel.init(input: inputAAmount, output: output, path: pathArray, outputWithoutFee: outputWithoutFee, fee: fee, models: path)
            tempArray.append(tempModel)
        }
        let tempaaa = tempArray.sorted { (item1, item2) in
            item1.output > item2.output
        }
        print(tempaaa)
        let data = setKVOData(type: "GetExchangeInfo", data: tempaaa.first)
        self.setValue(data, forKey: "dataDic")
        
    }
    func fliterBestInput(outputAAmount: Int64, outputCoinA: UInt8, paths: [[PoolLiquidityDataModel]]) {
        let numberConfig = NSDecimalNumberHandler.init(roundingMode: .down,
                                                       scale: 6,
                                                       raiseOnExactness: false,
                                                       raiseOnOverflow: false,
                                                       raiseOnUnderflow: false,
                                                       raiseOnDivideByZero: false)
        var tempArray = [ExchangeInfoModel]()
        for path in paths {
            var output: Int64 = outputAAmount
            var outputWithoutFee: Int64 = outputAAmount
            var nextIndex = outputCoinA
            var fee: Int64 = 0
            var pathArray: [UInt8] = [outputCoinA]
            for item in path.reversed() {
                if item.coina?.index == nextIndex {
                    let a = (NSDecimalNumber.init(value: item.coinb?.value ?? 0).multiplying(by: NSDecimalNumber.init(value: 1000))).multiplying(by: NSDecimalNumber.init(value: output))
                    let b = (NSDecimalNumber.init(value: item.coina?.value ?? 0).subtracting(NSDecimalNumber.init(value: output))).multiplying(by: NSDecimalNumber.init(value: 997))
                    output = (a.dividing(by: b, withBehavior: numberConfig)).int64Value
                    // fee
                    nextIndex = (item.coinb?.index)!
                    let aWithoutFee = (NSDecimalNumber.init(value: item.coinb?.value ?? 0).multiplying(by: NSDecimalNumber.init(value: 1000))).multiplying(by: NSDecimalNumber.init(value: output))
                    let bWithoutFee = (NSDecimalNumber.init(value: item.coina?.value ?? 0).subtracting(NSDecimalNumber.init(value: output))).multiplying(by: NSDecimalNumber.init(value: 1000))
                    outputWithoutFee = (aWithoutFee.dividing(by: bWithoutFee, withBehavior: numberConfig)).adding(NSDecimalNumber.init(value: 1)).int64Value
                } else {
                    let a = (NSDecimalNumber.init(value: item.coina?.value ?? 0).multiplying(by: NSDecimalNumber.init(value: 1000))).multiplying(by: NSDecimalNumber.init(value: output))
                    let b = (NSDecimalNumber.init(value: item.coinb?.value ?? 0).subtracting(NSDecimalNumber.init(value: output))).multiplying(by: NSDecimalNumber.init(value: 997))
                    output = (a.dividing(by: b, withBehavior: numberConfig)).int64Value
                    // fee
                    nextIndex = (item.coina?.index)!
                    let aWithoutFee = (NSDecimalNumber.init(value: item.coina?.value ?? 0).multiplying(by: NSDecimalNumber.init(value: 1000))).multiplying(by: NSDecimalNumber.init(value: output))
                    let bWithoutFee = (NSDecimalNumber.init(value: item.coinb?.value ?? 0).subtracting(NSDecimalNumber.init(value: output))).multiplying(by: NSDecimalNumber.init(value: 1000))
                    outputWithoutFee = (aWithoutFee.dividing(by: bWithoutFee, withBehavior: numberConfig)).int64Value
                }
                pathArray.insert(nextIndex, at: 0)
            }
            fee = output - outputWithoutFee
            let tempModel = ExchangeInfoModel.init(input: output, output: outputAAmount, path: pathArray, outputWithoutFee: outputWithoutFee, fee: fee, models: path)
            tempArray.append(tempModel)
        }

        let tempaaa = tempArray.sorted { (item1, item2) in
            item1.output > item2.output
        }
        let data = setKVOData(type: "GetExchangeInfo", data: tempaaa.first)
        self.setValue(data, forKey: "dataDic")
        
    }
}
//MARK: - 发送Violas兑换Violas交易
extension ExchangeModel {
    func sendSwapViolasTransaction(sendAddress: String, amountIn: Double, AmountOutMin: Double, path: [UInt8], fee: Double, mnemonic: [String], moduleA: String, moduleB: String, feeModule: String, outputModuleActiveState: Bool) {
        let semaphore = DispatchSemaphore.init(value: 1)
        let queue = DispatchQueue.init(label: "SendQueue")
        if outputModuleActiveState == false {
            queue.async {
                semaphore.wait()
                self.getViolasSequenceNumber(sendAddress: sendAddress, semaphore: semaphore)
            }
            queue.async {
                semaphore.wait()
                do {
                    let signature = try ViolasManager.getPublishTokenTransactionHex(mnemonic: mnemonic,
                                                                                    sequenceNumber: self.sequenceNumber ?? 0,
                                                                                    module: moduleB)
                    self.makeViolasTransaction(signature: signature, type: "SendPublishOutputModuleViolasTransaction", semaphore: semaphore)
                } catch {
                    print(error.localizedDescription)
                    DispatchQueue.main.async(execute: {
                        let data = setKVOData(error: LibraWalletError.error(error.localizedDescription), type: "SendPublishOutputModuleViolasTransaction")
                        self.setValue(data, forKey: "dataDic")
                    })
                }
            }
        }
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
                    if json.error == nil {
                        self?.sequenceNumber = json.result?.sequence_number ?? 0
                        semaphore.signal()
                    } else {
                        print("GetViolasSequenceNumber_状态异常")
                        DispatchQueue.main.async(execute: {
                            if let message = json.error?.message, message.isEmpty == false {
                                let data = setKVOData(error: LibraWalletError.error(message), type: "GetViolasSequenceNumber")
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
    private func makeViolasTransaction(signature: String, type: String, semaphore: DispatchSemaphore? = nil) {
        let request = mainProvide.request(.SendViolasTransaction(signature)) {[weak self](result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(LibraTransferMainModel.self)
                    if json.result == nil {
                        DispatchQueue.main.async(execute: {
                            if let sema = semaphore {
                                sema.signal()
                            } else {
                                let data = setKVOData(type: type)
                                self?.setValue(data, forKey: "dataDic")
                            }
                        })
                    } else {
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
//MARK: - 发送Violas兑换Libra交易
extension ExchangeModel {
    func sendSwapViolasToLibraTransaction(sendAddress: String, amountIn: Double, AmountOut: Double, fee: Double, mnemonic: [String], moduleInput: String, moduleOutput: String, feeModule: String, receiveAddress: String, outputModuleActiveState: Bool) {
        let semaphore = DispatchSemaphore.init(value: 1)
        let queue = DispatchQueue.init(label: "SendQueue")
        if outputModuleActiveState == false {
            queue.async {
                semaphore.wait()
                self.getLibraSequenceNumber(sendAddress: receiveAddress, semaphore: semaphore)
            }
            queue.async {
                semaphore.wait()
                do {
                    let signature = try LibraManager.getPublishTokenTransactionHex(mnemonic: mnemonic,
                                                                                    sequenceNumber: self.sequenceNumber ?? 0,
                                                                                    module: moduleOutput)
                    self.makeLibraTransaction(signature: signature, type: "SendPublishOutputModuleLibraTransaction", semaphore: semaphore)
                } catch {
                    print(error.localizedDescription)
                    DispatchQueue.main.async(execute: {
                        let data = setKVOData(error: LibraWalletError.error(error.localizedDescription), type: "SendPublishOutputModuleLibraTransaction")
                        self.setValue(data, forKey: "dataDic")
                    })
                }
            }
        }
        queue.async {
            semaphore.wait()
            self.getMappingTokenList(semaphore: semaphore, outputModuleName: moduleOutput, inputModule: "violas")
        }
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
                                                                                        exchangeCenterAddress: self.supportSwapData?.receiver_address ?? "",
                                                                                        libraReceiveAddress: receiveAddress,
                                                                                        feeModule: feeModule,
                                                                                        type: self.supportSwapData?.lable ?? "")
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
//MARK: - 发送Violas兑换BTC交易
extension ExchangeModel {
    func sendSwapViolasToBTCTransaction(sendAddress: String, amountIn: Double, AmountOut: Double, fee: Double, mnemonic: [String], moduleInput: String, feeModule: String,  receiveAddress: String, outputModuleActiveState: Bool) {
        let semaphore = DispatchSemaphore.init(value: 1)
        let queue = DispatchQueue.init(label: "SendQueue")
        queue.async {
            semaphore.wait()
            self.getViolasSequenceNumber(sendAddress: sendAddress, semaphore: semaphore)
        }
        queue.async {
            semaphore.wait()
            do {
                let signature = try ViolasManager.getViolasToBTCTransactionHex(sendAddress: sendAddress,
                                                                               module: moduleInput,
                                                                               amountIn: amountIn,
                                                                               amountOut: AmountOut,
                                                                               fee: fee,
                                                                               mnemonic: mnemonic,
                                                                               sequenceNumber: self.sequenceNumber ?? 0,
                                                                               exchangeCenterAddress: self.supportSwapData?.receiver_address ?? "",
                                                                               btcReceiveAddress: receiveAddress,
                                                                               feeModule: feeModule,
                                                                               type: self.supportSwapData?.lable ?? "")
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
//MARK: - 发送Libra兑换Violas交易
extension ExchangeModel {
    func sendLibraToViolasMappingTransaction(sendAddress: String, amountIn: Double, amountOut: Double, fee: Double, mnemonic: [String], moduleInput: String, moduleOutput: String, violasReceiveAddress: String, feeModule: String, outputModuleActiveState: Bool) {
        let semaphore = DispatchSemaphore.init(value: 1)
        let queue = DispatchQueue.init(label: "SendQueue")
        if outputModuleActiveState == false {
            queue.async {
                semaphore.wait()
                self.getViolasSequenceNumber(sendAddress: violasReceiveAddress, semaphore: semaphore)
            }
            queue.async {
                semaphore.wait()
                do {
                    let signature = try ViolasManager.getPublishTokenTransactionHex(mnemonic: mnemonic,
                                                                                    sequenceNumber: self.sequenceNumber ?? 0,
                                                                                    module: moduleOutput)
                    self.makeViolasTransaction(signature: signature, type: "SendPublishOutputModuleViolasTransaction", semaphore: semaphore)
                } catch {
                    print(error.localizedDescription)
                    DispatchQueue.main.async(execute: {
                        let data = setKVOData(error: LibraWalletError.error(error.localizedDescription), type: "SendPublishOutputModuleViolasTransaction")
                        self.setValue(data, forKey: "dataDic")
                    })
                }
            }
        }
        queue.async {
            semaphore.wait()
            self.getMappingTokenList(semaphore: semaphore, outputModuleName: moduleOutput, inputModule: "libra")
        }
        queue.async {
            semaphore.wait()
            self.getLibraSequenceNumber(sendAddress: sendAddress, semaphore: semaphore)
        }
        queue.async {
            semaphore.wait()
            do {
                let signature = try LibraManager.getLibraToViolasMappingTransactionHex(sendAddress: sendAddress,
                                                                                       module: moduleInput,
                                                                                       amountIn: amountIn,
                                                                                       amountOut: amountOut,
                                                                                       fee: fee,
                                                                                       mnemonic: mnemonic,
                                                                                       sequenceNumber: self.sequenceNumber ?? 0,
                                                                                       exchangeCenterAddress: self.supportSwapData?.receiver_address ?? "",
                                                                                       violasReceiveAddress: violasReceiveAddress,
                                                                                       feeModule: feeModule,
                                                                                       type: self.supportSwapData?.lable ?? "")
                self.makeLibraTransaction(signature: signature, type: "SendLibraToViolasTransaction")
            } catch {
                print(error.localizedDescription)
                DispatchQueue.main.async(execute: {
                    let data = setKVOData(error: LibraWalletError.error(error.localizedDescription), type: "SendLibraTransaction")
                    self.setValue(data, forKey: "dataDic")
                })
            }
            semaphore.signal()
        }
    }
    private func getLibraSequenceNumber(sendAddress: String, semaphore: DispatchSemaphore) {
        let request = mainProvide.request(.GetLibraAccountBalance(sendAddress)) {[weak self](result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(BalanceLibraMainModel.self)
                    self?.sequenceNumber = json.result?.sequence_number
                    semaphore.signal()
                } catch {
                    print("GetLibraSequenceNumber_解析异常\(error.localizedDescription)")
                    DispatchQueue.main.async(execute: {
                        let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.parseJsonError), type: "GetLibraSequenceNumber")
                        self?.setValue(data, forKey: "dataDic")
                    })
                }
            case let .failure(error):
                guard error.errorCode != -999 else {
                    print("GetLibraSequenceNumber_网络请求已取消")
                    return
                }
                DispatchQueue.main.async(execute: {
                    let data = setKVOData(error: LibraWalletError.WalletRequest(reason: .networkInvalid), type: "GetLibraSequenceNumber")
                    self?.setValue(data, forKey: "dataDic")
                })
            }
        }
        self.requests.append(request)
    }
    private func makeLibraTransaction(signature: String, type: String, semaphore: DispatchSemaphore? = nil) {
        let request = mainProvide.request(.SendLibraTransaction(signature)) {[weak self](result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(LibraTransferMainModel.self)
                    if json.result == nil {
                        DispatchQueue.main.async(execute: {
                            if let sema = semaphore {
                                sema.signal()
                            } else {
                                let data = setKVOData(type: type)
                                self?.setValue(data, forKey: "dataDic")
                            }
                        })
                    } else {
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

//MARK: - BTC跨链映射
extension ExchangeModel {
    func makeTransaction(wallet: HDWallet, amountIn: Double, amountOut: Double, fee: Double, mnemonic: [String], moduleOutput: String, mappingReceiveAddress: String, outputModuleActiveState: Bool, chainType: String) {
        let semaphore = DispatchSemaphore.init(value: 1)
        let queue = DispatchQueue.init(label: "SendQueue")
        if outputModuleActiveState == false {
            queue.async {
                semaphore.wait()
                if chainType == "libra" {
                    self.getLibraSequenceNumber(sendAddress: mappingReceiveAddress, semaphore: semaphore)
                } else {
                    self.getViolasSequenceNumber(sendAddress: mappingReceiveAddress, semaphore: semaphore)
                }
            }
            queue.async {
                semaphore.wait()
                if chainType == "libra" {
                    do {
                        let signature = try LibraManager.getPublishTokenTransactionHex(mnemonic: mnemonic,
                                                                                        sequenceNumber: self.sequenceNumber ?? 0,
                                                                                        module: moduleOutput)
                        self.makeLibraTransaction(signature: signature, type: "SendPublishOutputModuleLibraTransaction", semaphore: semaphore)
                    } catch {
                        print(error.localizedDescription)
                        DispatchQueue.main.async(execute: {
                            let data = setKVOData(error: LibraWalletError.error(error.localizedDescription), type: "SendPublishOutputModuleLibraTransaction")
                            self.setValue(data, forKey: "dataDic")
                        })
                    }
                } else {
                    do {
                        let signature = try ViolasManager.getPublishTokenTransactionHex(mnemonic: mnemonic,
                                                                                        sequenceNumber: self.sequenceNumber ?? 0,
                                                                                        module: moduleOutput)
                        self.makeViolasTransaction(signature: signature, type: "SendPublishOutputModuleViolasTransaction", semaphore: semaphore)
                    } catch {
                        print(error.localizedDescription)
                        DispatchQueue.main.async(execute: {
                            let data = setKVOData(error: LibraWalletError.error(error.localizedDescription), type: "SendPublishOutputModuleViolasTransaction")
                            self.setValue(data, forKey: "dataDic")
                        })
                    }
                }

            }
        }
        queue.async {
            semaphore.wait()
            self.getMappingTokenList(semaphore: semaphore, outputModuleName: moduleOutput, inputModule: "btc")
        }
        queue.async {
            self.getUnspentUTXO(address: wallet.addresses.first!.description, semaphore: semaphore)
        }
        queue.async {
            semaphore.wait()
            self.selectUTXOWithScriptSignature(utxos: self.utxos!,
                                               wallet: wallet,
                                               amountIn: amountIn,
                                               amountOut: amountOut,
                                               fee: fee,
                                               toAddress: self.supportSwapData?.receiver_address ?? "",
                                               mappingReceiveAddress: mappingReceiveAddress,
                                               mappingContract: self.supportSwapData?.to_coin?.assets?.address ?? "",
                                               type: self.supportSwapData?.lable ?? "")
            semaphore.signal()
        }
    }
    private func getUnspentUTXO(address: String, semaphore: DispatchSemaphore) {
        semaphore.wait()
        let request = mainProvide.request(.TrezorBTCUnspentUTXO(address)) {[weak self](result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map([TrezorBTCUTXOMainModel].self)
                    //                    guard json.isEmpty == false else {
                    //                        DispatchQueue.main.async(execute: {
                    //                            let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.dataEmpty), type: "GetUnspentUTXO")
                    //                            self?.setValue(data, forKey: "dataDic")
                    //                        })
                    //                        return
                    //                    }
                    self?.utxos = json
                    semaphore.signal()
                } catch {
                    print("GetUnspentUTXO_解析异常\(error.localizedDescription)")
                    DispatchQueue.main.async(execute: {
                        let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.parseJsonError), type: "GetUnspentUTXO")
                        self?.setValue(data, forKey: "dataDic")
                    })
                }
            case let .failure(error):
                guard error.errorCode != -999 else {
                    print("GetUnspentUTXO_网络请求已取消")
                    return
                }
                DispatchQueue.main.async(execute: {
                    let data = setKVOData(error: LibraWalletError.WalletRequest(reason: .networkInvalid), type: "GetUnspentUTXO")
                    self?.setValue(data, forKey: "dataDic")
                })
                
            }
        }
        self.requests.append(request)
    }
    private func selectUTXOWithScriptSignature(utxos: [TrezorBTCUTXOMainModel], wallet: HDWallet, amountIn: Double, amountOut: Double, fee: Double, toAddress: String, mappingReceiveAddress: String, mappingContract: String, type: String) {
        let amountt: UInt64 = UInt64(amountIn * 100000000)
        let feee: UInt64 = UInt64(fee * 100000000)
        
        // 个人公钥
        let lockingScript = Script.buildPublicKeyHashOut(pubKeyHash: wallet.pubKeys.first!.pubkeyHash)
        //
        let inputs = utxos.map { item in
            UnspentTransaction.init(output: TransactionOutput.init(value: NSDecimalNumber.init(string: item.value ?? "0").uint64Value, lockingScript: lockingScript),
                                    outpoint: TransactionOutPoint.init(hash: Data(Data(hex: item.txid!)!.reversed()), index: item.vout!))
        }
        let select = UnspentTransactionSelector.select(from: inputs, targetValue: amountt + feee, feePerByte: 30)
        
        let allUTXOAmount = select.reduce(0) {
            $0 + $1.output.value
        }
        let change = allUTXOAmount - feee - amountt
        
        let plan = TransactionPlan.init(unspentTransactions: select, amount: amountt, fee: feee, change: UInt64(change))
        
        let toAddressResult = try! BitcoinAddress(legacy: toAddress)
        
        let transaction = customBuild(from: plan, toAddress: toAddressResult, changeAddress: wallet.addresses.first!)
        // 添加脚本
        let script = BTCManager().getBTCScript(address: mappingReceiveAddress, type: type, tokenContract: mappingContract, amount: Int(amountOut * 1000000))
        let data = BTCManager().getData(script: script)
        let opReturn = TransactionOutput.init(value: 0, lockingScript: data)
        
        var tempOutputs = transaction.outputs
        tempOutputs.append(opReturn)
        let transactionResult = Transaction.init(version: transaction.version, inputs: transaction.inputs, outputs: tempOutputs, lockTime: transaction.lockTime)
        
        let signature = TransactionSigner.init(unspentTransactions: plan.unspentTransactions, transaction: transactionResult, sighashHelper: BTCSignatureHashHelper(hashType: .ALL))
        let result = try? signature.sign(with: wallet.privKeys)
        print(result!.serialized().toHexString())
        
        self.sendBTCTransaction(signature: result!.serialized().toHexString())
    }
    private func customBuild(from plan: TransactionPlan, toAddress: Address, changeAddress: Address) -> Transaction {
        let toLockScript: Data = Script(address: toAddress)!.data
        var outputs: [TransactionOutput] = [
            TransactionOutput(value: plan.amount, lockingScript: toLockScript)
        ]
        if plan.change > 0 {
            let changeLockScript: Data = Script(address: changeAddress)!.data
            outputs.insert(TransactionOutput(value: plan.change, lockingScript: changeLockScript), at: 0)
        }
        
        let unsignedInputs: [TransactionInput] = plan.unspentTransactions.map {
            TransactionInput(
                previousOutput: $0.outpoint,
                signatureScript: Data(),
                sequence: UInt32.max
            )
        }
        
        return Transaction(version: 2, inputs: unsignedInputs, outputs: outputs, lockTime: 0)
    }
    private func sendBTCTransaction(signature: String) {
        let request = mainProvide.request(.TrezorBTCPushTransaction(signature)) {[weak self](result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(TrezorBTCSendTransactionMainModel.self)
                    guard json.result?.isEmpty == false else {
                        DispatchQueue.main.async(execute: {
                            let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.dataCodeInvalid), type: "SendBTCTransaction")
                            self?.setValue(data, forKey: "dataDic")
                        })
                        return
                    }
                    DispatchQueue.main.async(execute: {
                        let data = setKVOData(type: "SendBTCTransaction")
                        self?.setValue(data, forKey: "dataDic")
                    })
                    // 刷新本地数据
                } catch {
                    print("SendBTCTransaction_解析异常\(error.localizedDescription)")
                    DispatchQueue.main.async(execute: {
                        let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.parseJsonError), type: "SendBTCTransaction")
                        self?.setValue(data, forKey: "dataDic")
                    })
                    
                }
            case let .failure(error):
                guard error.errorCode != -999 else {
                    print("SendBTCTransaction_网络请求已取消")
                    return
                }
                DispatchQueue.main.async(execute: {
                    let data = setKVOData(error: LibraWalletError.WalletRequest(reason: .networkInvalid), type: "SendBTCTransaction")
                    self?.setValue(data, forKey: "dataDic")
                })
                
            }
        }
        self.requests.append(request)
    }
}
