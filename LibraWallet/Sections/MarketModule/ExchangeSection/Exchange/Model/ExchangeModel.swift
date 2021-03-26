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
    var value: UInt64?
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
}
struct MarketSupportTokensMainModel: Codable {
    var code: Int?
    var message: String?
    var data: [MarketSupportTokensDataModel]?
}

class ExchangeModel: NSObject {
    private var requests: [Cancellable] = []
    @objc dynamic var dataDic: NSMutableDictionary = [:]
    private var maxGasAmount: UInt64 = 600
    private var accountBTCAmount: String?
    private var supportSwapData: MarketSupportMappingTokensDataModel?
    var utxos: [TrezorBTCUTXOMainModel]?
    deinit {
        requests.forEach { cancellable in
            cancellable.cancel()
        }
        requests.removeAll()
        print("ExchangeModel销毁了")
    }
    var shortPath = [[PoolLiquidityDataModel]]()
    private var tempArray = [PoolLiquidityDataModel]()
}

// MARK: - 获取支持列表
extension ExchangeModel {
    func getMarketTokens(btcAddress: String, violasAddress: String, libraAddress: String, completion: @escaping (Result<[MarketSupportTokensDataModel], LibraWalletError>) -> Void) {
        // 1.请求交易所支持币列表-成功后匹配余额-返回
        let group = DispatchGroup.init()
        let quene = DispatchQueue.init(label: "SupportTokenQuene")
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
        if violasAddress.isEmpty == false {
            quene.async(group: group, qos: .default, flags: [], execute: {
                group.enter()
                semaphore.wait()
                self.getViolasBalance(address: violasAddress) { (result) in
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
        }
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
                completion(.failure(LibraWalletError.WalletRequest(reason: .networkInvalid)))
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
        guard marketTokens.isEmpty == false else {
            return tempTokens
        }
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
// MARK: - 获取流动性
extension ExchangeModel {
    func getPoolTotalLiquidity(inputCoinA: MarketSupportTokensDataModel, inputCoinB: MarketSupportTokensDataModel, completion: @escaping (Result<[[PoolLiquidityDataModel]], LibraWalletError>) -> Void) {
        let request = marketModuleProvide.request(.poolTotalLiquidity) {[weak self](result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(PoolLiquidityMainModel.self)
                    if json.code == 2000 {
                        guard let violasTokens = json.data, violasTokens.isEmpty == false else {
                            completion(.failure(LibraWalletError.WalletRequest(reason: .dataEmpty)))
                            return
                        }
                        self?.handleLiquidity(inputCoinA: inputCoinA, outputCoinB: inputCoinB, data: json.data!, completion: completion)
                    } else {
                        print("GetPoolTotalLiquidity_状态异常")
                        if let message = json.message, message.isEmpty == false {
                            completion(.failure(LibraWalletError.error(message)))
                        } else {
                            completion(.failure(LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.dataCodeInvalid)))
                        }
                    }
                } catch {
                    print("GetPoolTotalLiquidity_解析异常\(error.localizedDescription)")
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
    func handleLiquidity(inputCoinA: MarketSupportTokensDataModel, outputCoinB: MarketSupportTokensDataModel, data: [PoolLiquidityDataModel], completion: @escaping (Result<[[PoolLiquidityDataModel]], LibraWalletError>) -> Void) {
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
            if item.coinb?.index == outputCoinB.index || item.coina?.index == outputCoinB.index {
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
        completion(.success(shortPath))
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
    func fliterBestOutput(inputAAmount: Int64, inputCoinA: UInt8, paths: [[PoolLiquidityDataModel]]) -> ExchangeInfoModel {
        
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
                    let amountInWithFee = NSDecimalNumber.init(value: output).multiplying(by: NSDecimalNumber.init(value: 9997))
                    let numerator = amountInWithFee.multiplying(by: NSDecimalNumber.init(value: item.coinb?.value ?? 0))
                    let denominator = (NSDecimalNumber.init(value: item.coina?.value ?? 0).multiplying(by: NSDecimalNumber.init(value: 10000))).adding(amountInWithFee)
                    output = numerator.dividing(by: denominator, withBehavior: numberConfig).int64Value
                    // fee
                    nextIndex = (item.coinb?.index)!
                    let amountInWithoutFee = NSDecimalNumber.init(value: outputWithoutFee).multiplying(by: NSDecimalNumber.init(value: 10000))
                    let numeratorWithoutFee = amountInWithoutFee.multiplying(by: NSDecimalNumber.init(value: item.coinb?.value ?? 0))
                    let denominatorWithoutFee = (NSDecimalNumber.init(value: item.coina?.value ?? 0).multiplying(by: NSDecimalNumber.init(value: 10000))).adding(amountInWithoutFee)
                    outputWithoutFee = numeratorWithoutFee.dividing(by: denominatorWithoutFee, withBehavior: numberConfig).int64Value
                } else {
                    let amountInWithFee = NSDecimalNumber.init(value: output).multiplying(by: NSDecimalNumber.init(value: 9997))
                    let numerator = amountInWithFee.multiplying(by: NSDecimalNumber.init(value: item.coina?.value ?? 0))
                    let denominator = NSDecimalNumber.init(value: item.coinb?.value ?? 0).multiplying(by: NSDecimalNumber.init(value: 10000)).adding(amountInWithFee)
                    output = numerator.dividing(by: denominator, withBehavior: numberConfig).int64Value
                    nextIndex = (item.coina?.index)!
                    // fee
                    let amountInWithoutFee = NSDecimalNumber.init(value: outputWithoutFee).multiplying(by: NSDecimalNumber.init(value: 10000))
                    let numeratorWithoutFee = amountInWithoutFee.multiplying(by: NSDecimalNumber.init(value: item.coina?.value ?? 0))
                    let denominatorWithoutFee = (NSDecimalNumber.init(value: item.coinb?.value ?? 0).multiplying(by: NSDecimalNumber.init(value: 10000))).adding(amountInWithoutFee)
                    outputWithoutFee = numeratorWithoutFee.dividing(by: denominatorWithoutFee, withBehavior: numberConfig).int64Value
                }
                pathArray.append(nextIndex)
            }
            fee = outputWithoutFee - output
            let tempModel = ExchangeInfoModel.init(input: inputAAmount, output: output, path: pathArray, outputWithoutFee: outputWithoutFee, fee: fee, models: path)
            tempArray.append(tempModel)
            print(pathArray)
        }
        let tempaaa = tempArray.sorted { (item1, item2) in
            item1.output > item2.output
        }
        return tempaaa.first!
    }
    func fliterBestInput(outputAAmount: Int64, outputCoinA: UInt8, paths: [[PoolLiquidityDataModel]]) -> ExchangeInfoModel {
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
                    let a = (NSDecimalNumber.init(value: item.coinb?.value ?? 0).multiplying(by: NSDecimalNumber.init(value: 10000))).multiplying(by: NSDecimalNumber.init(value: output))
                    let b = (NSDecimalNumber.init(value: item.coina?.value ?? 0).subtracting(NSDecimalNumber.init(value: output))).multiplying(by: NSDecimalNumber.init(value: 9997))
                    output = (a.dividing(by: b, withBehavior: numberConfig)).int64Value
                    // fee
                    nextIndex = (item.coinb?.index)!
                    let aWithoutFee = (NSDecimalNumber.init(value: item.coinb?.value ?? 0).multiplying(by: NSDecimalNumber.init(value: 10000))).multiplying(by: NSDecimalNumber.init(value: output))
                    let bWithoutFee = (NSDecimalNumber.init(value: item.coina?.value ?? 0).subtracting(NSDecimalNumber.init(value: output))).multiplying(by: NSDecimalNumber.init(value: 10000))
                    outputWithoutFee = (aWithoutFee.dividing(by: bWithoutFee, withBehavior: numberConfig)).adding(NSDecimalNumber.init(value: 1)).int64Value
                } else {
                    let a = (NSDecimalNumber.init(value: item.coina?.value ?? 0).multiplying(by: NSDecimalNumber.init(value: 10000))).multiplying(by: NSDecimalNumber.init(value: output))
                    let b = (NSDecimalNumber.init(value: item.coinb?.value ?? 0).subtracting(NSDecimalNumber.init(value: output))).multiplying(by: NSDecimalNumber.init(value: 9997))
                    output = (a.dividing(by: b, withBehavior: numberConfig)).adding(NSDecimalNumber.init(value: 1)).int64Value
                    // fee
                    nextIndex = (item.coina?.index)!
                    let aWithoutFee = (NSDecimalNumber.init(value: item.coina?.value ?? 0).multiplying(by: NSDecimalNumber.init(value: 10000))).multiplying(by: NSDecimalNumber.init(value: output))
                    let bWithoutFee = (NSDecimalNumber.init(value: item.coinb?.value ?? 0).subtracting(NSDecimalNumber.init(value: output))).multiplying(by: NSDecimalNumber.init(value: 10000))
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
        return tempaaa.first!
    }
}
// MARK: - 发送Violas兑换Violas交易
extension ExchangeModel {
    func sendSwapViolasTransaction(sendAddress: String, amountIn: UInt64, AmountOutMin: UInt64, path: [UInt8], fee: UInt64, mnemonic: [String], moduleA: String, moduleB: String, feeModule: String, outputModuleActiveState: Bool, completion: @escaping (Result<Bool, LibraWalletError>) -> Void) {
        let semaphore = DispatchSemaphore.init(value: 1)
        let queue = DispatchQueue.init(label: "SendQueue")
        var sequenceNumber: UInt64?
        if outputModuleActiveState == false {
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
                    let signature = try ViolasManager.getPublishTokenTransactionHex(mnemonic: mnemonic,
                                                                                    maxGasAmount: self.maxGasAmount,
                                                                                    maxGasUnitPrice: ViolasManager.handleMaxGasUnitPrice(maxGasAmount: self.maxGasAmount),
                                                                                    sequenceNumber: sequenceNumber!,
                                                                                    inputModule: moduleB)
                    self.makeViolasTransaction(signature: signature, type: "SendPublishOutputModuleViolasTransaction", semaphore: semaphore) { (result) in
                        switch result {
                        case .success(_):
                            print("激活兑换币种成功")
                            semaphore.signal()
                        case let .failure(error):
                            print(error)
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
            }
        }
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
                let signature = try ViolasManager.getMarketSwapTransactionHex(sendAddress: sendAddress,
                                                                              mnemonic: mnemonic,
                                                                              feeModule: feeModule,
                                                                              maxGasAmount: self.maxGasAmount,
                                                                              maxGasUnitPrice: ViolasManager.handleMaxGasUnitPrice(maxGasAmount: self.maxGasAmount),
                                                                              sequenceNumber: sequenceNumber!,
                                                                              inputAmount: amountIn,
                                                                              outputAmountMin: AmountOutMin,
                                                                              path: path,
                                                                              inputModule: moduleA,
                                                                              outputModule: moduleB)
                self.makeViolasTransaction(signature: signature, type: "SendViolasTransaction") { (result) in
                    switch result {
                    case .success(_):
                        DispatchQueue.main.async(execute: {
                            completion(.success(true))
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
    private func makeViolasTransaction(signature: String, type: String, semaphore: DispatchSemaphore? = nil, completion: @escaping (Result<Bool, LibraWalletError>) -> Void) {
        let request = violasModuleProvide.request(.sendTransaction(signature)) { (result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(ViolasAccountMainModel.self)
                    if json.error == nil {
                        completion(.success(true))
                    } else {
                        print("\(type)_状态异常")
                        if let message = json.error?.message, message.isEmpty == false {
                            completion(.failure(LibraWalletError.error(message)))
                        } else {
                            completion(.failure(LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.dataCodeInvalid)))
                        }
                    }
                } catch {
                    print("\(type)_解析异常\(error.localizedDescription)")
                    completion(.failure(LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.parseJsonError)))
                }
            case let .failure(error):
                guard error.errorCode != -999 else {
                    print("\(type)_网络请求已取消")
                    return
                }
                completion(.failure(LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.networkInvalid)))
            }
        }
        self.requests.append(request)
    }
}
//MARK: - 发送Violas兑换Libra交易
//extension ExchangeModel {
//    func sendSwapViolasToLibraTransaction(sendAddress: String, amountIn: UInt64, AmountOut: UInt64, fee: UInt64, mnemonic: [String], moduleInput: String, moduleOutput: String, feeModule: String, receiveAddress: String, outputModuleActiveState: Bool) {
//        let semaphore = DispatchSemaphore.init(value: 1)
//        let queue = DispatchQueue.init(label: "SendQueue")
//        if outputModuleActiveState == false {
//            queue.async {
//                semaphore.wait()
//                self.getLibraSequenceNumber(sendAddress: receiveAddress, semaphore: semaphore)
//            }
//            queue.async {
//                semaphore.wait()
//                do {
//                    let signature = try DiemManager.getPublishTokenTransactionHex(mnemonic: mnemonic,
//                                                                                   sequenceNumber: self.sequenceNumber ?? 0,
//                                                                                   fee: 0,
//                                                                                   module: moduleOutput,
//                                                                                   feeModule: moduleOutput)
//                    self.makeLibraTransaction(signature: signature, type: "SendPublishOutputModuleLibraTransaction", semaphore: semaphore)
//                } catch {
//                    print(error.localizedDescription)
//                    DispatchQueue.main.async(execute: {
//                        let data = setKVOData(error: LibraWalletError.error(error.localizedDescription), type: "SendPublishOutputModuleLibraTransaction")
//                        self.setValue(data, forKey: "dataDic")
//                    })
//                }
//            }
//        }
//        queue.async {
//            semaphore.wait()
//            self.getMappingTokenList(semaphore: semaphore, outputModuleName: moduleOutput, inputModule: "violas")
//        }
//        queue.async {
//            semaphore.wait()
//            self.getViolasSequenceNumber(sendAddress: sendAddress, semaphore: semaphore)
//        }
//        queue.async {
//            semaphore.wait()
//            do {
//                let signature = try ViolasManager.getViolasMappingTransactionHex(sendAddress: sendAddress,
//                                                                                 mnemonic: mnemonic,
//                                                                                 feeModule: feeModule,
//                                                                                 maxGasAmount: self.maxGasAmount,
//                                                                                 maxGasUnitPrice: ViolasManager.handleMaxGasUnitPrice(maxGasAmount: self.maxGasAmount),
//                                                                                 sequenceNumber: self.sequenceNumber ?? 0,
//                                                                                 inputModule: moduleInput,
//                                                                                 inputAmount: amountIn,
//                                                                                 outputAmount: AmountOut,
//                                                                                 centerAddress: self.supportSwapData?.receiver_address ?? "",
//                                                                                 receiveAddress: receiveAddress,
//                                                                                 mappingType: self.supportSwapData?.lable ?? "")
//                self.makeViolasTransaction(signature: signature, type: "SendViolasToLibraMappingTransaction")
//            } catch {
//                print(error.localizedDescription)
//                DispatchQueue.main.async(execute: {
//                    let data = setKVOData(error: LibraWalletError.error(error.localizedDescription), type: "SendViolasToLibraMappingTransaction")
//                    self.setValue(data, forKey: "dataDic")
//                })
//            }
//            semaphore.signal()
//        }
//    }
//}
//MARK: - 发送Violas兑换BTC交易
//extension ExchangeModel {
//    func sendSwapViolasToBTCTransaction(sendAddress: String, amountIn: UInt64, AmountOut: UInt64, fee: UInt64, mnemonic: [String], moduleInput: String, feeModule: String,  receiveAddress: String, outputModuleActiveState: Bool) {
//        let semaphore = DispatchSemaphore.init(value: 1)
//        let queue = DispatchQueue.init(label: "SendQueue")
//        queue.async {
//            semaphore.wait()
//            self.getViolasSequenceNumber(sendAddress: sendAddress, semaphore: semaphore)
//        }
//        queue.async {
//            semaphore.wait()
//            do {
//                let signature = try ViolasManager.getViolasMappingTransactionHex(sendAddress: sendAddress,
//                                                                                 mnemonic: mnemonic,
//                                                                                 feeModule: feeModule,
//                                                                                 maxGasAmount: self.maxGasAmount,
//                                                                                 maxGasUnitPrice: ViolasManager.handleMaxGasUnitPrice(maxGasAmount: self.maxGasAmount),
//                                                                                 sequenceNumber: self.sequenceNumber ?? 0,
//                                                                                 inputModule: moduleInput,
//                                                                                 inputAmount: amountIn,
//                                                                                 outputAmount: AmountOut,
//                                                                                 centerAddress: self.supportSwapData?.receiver_address ?? "",
//                                                                                 receiveAddress: receiveAddress,
//                                                                                 mappingType: self.supportSwapData?.lable ?? "")
//                self.makeViolasTransaction(signature: signature, type: "SendViolasToLibraMappingTransaction")
//            } catch {
//                print(error.localizedDescription)
//                DispatchQueue.main.async(execute: {
//                    let data = setKVOData(error: LibraWalletError.error(error.localizedDescription), type: "SendViolasToLibraMappingTransaction")
//                    self.setValue(data, forKey: "dataDic")
//                })
//            }
//            semaphore.signal()
//        }
//    }
//}
//MARK: - 发送Libra兑换Violas交易
//extension ExchangeModel {
//    func sendLibraToViolasMappingTransaction(sendAddress: String, amountIn: UInt64, amountOut: UInt64, fee: UInt64, mnemonic: [String], moduleInput: String, moduleOutput: String, violasReceiveAddress: String, feeModule: String, outputModuleActiveState: Bool) {
//        let semaphore = DispatchSemaphore.init(value: 1)
//        let queue = DispatchQueue.init(label: "SendQueue")
//        if outputModuleActiveState == false {
//            queue.async {
//                semaphore.wait()
//                self.getViolasSequenceNumber(sendAddress: violasReceiveAddress, semaphore: semaphore)
//            }
//            queue.async {
//                semaphore.wait()
//                do {
//                    let signature = try ViolasManager.getPublishTokenTransactionHex(mnemonic: mnemonic,
//                                                                                    maxGasAmount: self.maxGasAmount,
//                                                                                    maxGasUnitPrice: ViolasManager.handleMaxGasUnitPrice(maxGasAmount: self.maxGasAmount),
//                                                                                    sequenceNumber: self.sequenceNumber ?? 0,
//                                                                                    inputModule: moduleOutput)
//                    self.makeViolasTransaction(signature: signature, type: "SendPublishOutputModuleViolasTransaction", semaphore: semaphore)
//                } catch {
//                    print(error.localizedDescription)
//                    DispatchQueue.main.async(execute: {
//                        let data = setKVOData(error: LibraWalletError.error(error.localizedDescription), type: "SendPublishOutputModuleViolasTransaction")
//                        self.setValue(data, forKey: "dataDic")
//                    })
//                }
//            }
//        }
//        queue.async {
//            semaphore.wait()
//            self.getMappingTokenList(semaphore: semaphore, outputModuleName: moduleOutput, inputModule: "libra")
//        }
//        queue.async {
//            semaphore.wait()
//            self.getLibraSequenceNumber(sendAddress: sendAddress, semaphore: semaphore)
//        }
//        queue.async {
//            semaphore.wait()
//            do {
//                let signature = try DiemManager.getLibraMappingTransactionHex(sendAddress: sendAddress,
//                                                                               mnemonic: mnemonic,
//                                                                               feeModule: feeModule,
//                                                                               fee: fee,
//                                                                               sequenceNumber: self.sequenceNumber ?? 0,
//                                                                               inputModule: moduleInput,
//                                                                               inputAmount: amountIn,
//                                                                               outputAmount: amountOut,
//                                                                               centerAddress: self.supportSwapData?.receiver_address ?? "",
//                                                                               receiveAddress: violasReceiveAddress,
//                                                                               mappingType: self.supportSwapData?.lable ?? "")
//                self.makeLibraTransaction(signature: signature, type: "SendLibraToViolasTransaction")
//            } catch {
//                print(error.localizedDescription)
//                DispatchQueue.main.async(execute: {
//                    let data = setKVOData(error: LibraWalletError.error(error.localizedDescription), type: "SendLibraTransaction")
//                    self.setValue(data, forKey: "dataDic")
//                })
//            }
//            semaphore.signal()
//        }
//    }
//    private func getLibraSequenceNumber(sendAddress: String, semaphore: DispatchSemaphore) {
//        let request = libraModuleProvide.request(.accountInfo(sendAddress)) {[weak self](result) in
//            switch  result {
//            case let .success(response):
//                do {
//                    let json = try response.map(DiemAccountMainModel.self)
//                    self?.sequenceNumber = json.result?.sequence_number
//                    semaphore.signal()
//                } catch {
//                    print("GetLibraSequenceNumber_解析异常\(error.localizedDescription)")
//                    DispatchQueue.main.async(execute: {
//                        let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.parseJsonError), type: "GetLibraSequenceNumber")
//                        self?.setValue(data, forKey: "dataDic")
//                    })
//                }
//            case let .failure(error):
//                guard error.errorCode != -999 else {
//                    print("GetLibraSequenceNumber_网络请求已取消")
//                    return
//                }
//                DispatchQueue.main.async(execute: {
//                    let data = setKVOData(error: LibraWalletError.WalletRequest(reason: .networkInvalid), type: "GetLibraSequenceNumber")
//                    self?.setValue(data, forKey: "dataDic")
//                })
//            }
//        }
//        self.requests.append(request)
//    }
//    private func makeLibraTransaction(signature: String, type: String, semaphore: DispatchSemaphore? = nil) {
//        let request = libraModuleProvide.request(.sendTransaction(signature)) {[weak self](result) in
//            switch  result {
//            case let .success(response):
//                do {
//                    let json = try response.map(DiemAccountMainModel.self)
//                    if json.result == nil {
//                        DispatchQueue.main.async(execute: {
//                            if let sema = semaphore {
//                                sema.signal()
//                            } else {
//                                let data = setKVOData(type: type)
//                                self?.setValue(data, forKey: "dataDic")
//                            }
//                        })
//                    } else {
//                        print("\(type)_状态异常")
//                        DispatchQueue.main.async(execute: {
//                            if let message = json.error?.message, message.isEmpty == false {
//                                let data = setKVOData(error: LibraWalletError.error(message), type: type)
//                                self?.setValue(data, forKey: "dataDic")
//                            } else {
//                                let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.dataCodeInvalid), type: type)
//                                self?.setValue(data, forKey: "dataDic")
//                            }
//                        })
//                    }
//                } catch {
//                    print("\(type)_解析异常\(error.localizedDescription)")
//                    DispatchQueue.main.async(execute: {
//                        let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.parseJsonError), type: type)
//                        self?.setValue(data, forKey: "dataDic")
//                    })
//                }
//            case let .failure(error):
//                guard error.errorCode != -999 else {
//                    print("\(type)_网络请求已取消")
//                    return
//                }
//                DispatchQueue.main.async(execute: {
//                    let data = setKVOData(error: LibraWalletError.WalletRequest(reason: .networkInvalid), type: type)
//                    self?.setValue(data, forKey: "dataDic")
//                })
//            }
//        }
//        self.requests.append(request)
//    }
//}

//MARK: - BTC跨链映射
//extension ExchangeModel {
//    func makeTransaction(wallet: HDWallet, amountIn: UInt64, amountOut: UInt64, fee: Double, mnemonic: [String], moduleOutput: String, mappingReceiveAddress: String, outputModuleActiveState: Bool, chainType: String) {
//        let semaphore = DispatchSemaphore.init(value: 1)
//        let queue = DispatchQueue.init(label: "SendQueue")
//        if outputModuleActiveState == false {
//            queue.async {
//                semaphore.wait()
//                if chainType == "libra" {
//                    self.getLibraSequenceNumber(sendAddress: mappingReceiveAddress, semaphore: semaphore)
//                } else {
//                    self.getViolasSequenceNumber(sendAddress: mappingReceiveAddress, semaphore: semaphore)
//                }
//            }
//            queue.async {
//                semaphore.wait()
//                if chainType == "libra" {
//                    do {
//                        let signature = try DiemManager.getPublishTokenTransactionHex(mnemonic: mnemonic,
//                                                                                       sequenceNumber: self.sequenceNumber ?? 0,
//                                                                                       fee: 0,
//                                                                                       module: moduleOutput,
//                                                                                       feeModule: moduleOutput)
//                        self.makeLibraTransaction(signature: signature, type: "SendPublishOutputModuleLibraTransaction", semaphore: semaphore)
//                    } catch {
//                        print(error.localizedDescription)
//                        DispatchQueue.main.async(execute: {
//                            let data = setKVOData(error: LibraWalletError.error(error.localizedDescription), type: "SendPublishOutputModuleLibraTransaction")
//                            self.setValue(data, forKey: "dataDic")
//                        })
//                    }
//                } else {
//                    do {
//                        let signature = try ViolasManager.getPublishTokenTransactionHex(mnemonic: mnemonic,
//                                                                                        maxGasAmount: self.maxGasAmount,
//                                                                                        maxGasUnitPrice: ViolasManager.handleMaxGasUnitPrice(maxGasAmount: self.maxGasAmount),
//                                                                                        sequenceNumber: self.sequenceNumber ?? 0,
//                                                                                        inputModule: moduleOutput)
//                        self.makeViolasTransaction(signature: signature, type: "SendPublishOutputModuleViolasTransaction", semaphore: semaphore)
//                    } catch {
//                        print(error.localizedDescription)
//                        DispatchQueue.main.async(execute: {
//                            let data = setKVOData(error: LibraWalletError.error(error.localizedDescription), type: "SendPublishOutputModuleViolasTransaction")
//                            self.setValue(data, forKey: "dataDic")
//                        })
//                    }
//                }
//
//            }
//        }
//        queue.async {
//            semaphore.wait()
//            self.getMappingTokenList(semaphore: semaphore, outputModuleName: moduleOutput, inputModule: "btc")
//        }
//        queue.async {
//            self.getUnspentUTXO(address: wallet.addresses.first!.description, semaphore: semaphore)
//        }
//        queue.async {
//            semaphore.wait()
//            self.selectUTXOWithScriptSignature(utxos: self.utxos!,
//                                               wallet: wallet,
//                                               amountIn: amountIn,
//                                               amountOut: amountOut,
//                                               fee: fee,
//                                               toAddress: self.supportSwapData?.receiver_address ?? "",
//                                               mappingReceiveAddress: mappingReceiveAddress,
//                                               mappingContract: self.supportSwapData?.to_coin?.assets?.address ?? "",
//                                               type: self.supportSwapData?.lable ?? "")
//            semaphore.signal()
//        }
//    }
//    private func getUnspentUTXO(address: String, semaphore: DispatchSemaphore) {
//        semaphore.wait()
//        let request = BTCModuleProvide.request(.TrezorBTCUnspentUTXO(address)) {[weak self](result) in
//            switch  result {
//            case let .success(response):
//                do {
//                    let json = try response.map([TrezorBTCUTXOMainModel].self)
//                    //                    guard json.isEmpty == false else {
//                    //                        DispatchQueue.main.async(execute: {
//                    //                            let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.dataEmpty), type: "GetUnspentUTXO")
//                    //                            self?.setValue(data, forKey: "dataDic")
//                    //                        })
//                    //                        return
//                    //                    }
//                    self?.utxos = json
//                    semaphore.signal()
//                } catch {
//                    print("GetUnspentUTXO_解析异常\(error.localizedDescription)")
//                    DispatchQueue.main.async(execute: {
//                        let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.parseJsonError), type: "GetUnspentUTXO")
//                        self?.setValue(data, forKey: "dataDic")
//                    })
//                }
//            case let .failure(error):
//                guard error.errorCode != -999 else {
//                    print("GetUnspentUTXO_网络请求已取消")
//                    return
//                }
//                DispatchQueue.main.async(execute: {
//                    let data = setKVOData(error: LibraWalletError.WalletRequest(reason: .networkInvalid), type: "GetUnspentUTXO")
//                    self?.setValue(data, forKey: "dataDic")
//                })
//
//            }
//        }
//        self.requests.append(request)
//    }
//    private func selectUTXOWithScriptSignature(utxos: [TrezorBTCUTXOMainModel], wallet: HDWallet, amountIn: UInt64, amountOut: UInt64, fee: Double, toAddress: String, mappingReceiveAddress: String, mappingContract: String, type: String) {
////        let amountt: UInt64 = UInt64(amountIn * 100000000)
//        let feee: UInt64 = UInt64(fee * 100000000)
//
//        // 个人公钥
//        let lockingScript = Script.buildPublicKeyHashOut(pubKeyHash: wallet.pubKeys.first!.pubkeyHash)
//        //
//        let inputs = utxos.map { item in
//            UnspentTransaction.init(output: TransactionOutput.init(value: NSDecimalNumber.init(string: item.value ?? "0").uint64Value, lockingScript: lockingScript),
//                                    outpoint: TransactionOutPoint.init(hash: Data(Data(hex: item.txid!)!.reversed()), index: item.vout!))
//        }
//        let select = UnspentTransactionSelector.select(from: inputs, targetValue: amountIn + feee, feePerByte: 30)
//
//        let allUTXOAmount = select.reduce(0) {
//            $0 + $1.output.value
//        }
//        let change = allUTXOAmount - feee - amountIn
//
//        let plan = TransactionPlan.init(unspentTransactions: select, amount: amountIn, fee: feee, change: UInt64(change))
//
//        let toAddressResult = try! BitcoinAddress(legacy: toAddress)
//
//        let transaction = customBuild(from: plan, toAddress: toAddressResult, changeAddress: wallet.addresses.first!)
//        // 添加脚本
//        let script = BTCManager().getBTCScript(address: mappingReceiveAddress, type: type, tokenContract: mappingContract, amount: amountOut)
//        let data = BTCManager().getData(script: script)
//        let opReturn = TransactionOutput.init(value: 0, lockingScript: data)
//
//        var tempOutputs = transaction.outputs
//        tempOutputs.append(opReturn)
//        let transactionResult = Transaction.init(version: transaction.version, inputs: transaction.inputs, outputs: tempOutputs, lockTime: transaction.lockTime)
//
//        let signature = TransactionSigner.init(unspentTransactions: plan.unspentTransactions, transaction: transactionResult, sighashHelper: BTCSignatureHashHelper(hashType: .ALL))
//        let result = try? signature.sign(with: wallet.privKeys)
//        print(result!.serialized().toHexString())
//
//        self.sendBTCTransaction(signature: result!.serialized().toHexString())
//    }
//    private func customBuild(from plan: TransactionPlan, toAddress: Address, changeAddress: Address) -> Transaction {
//        let toLockScript: Data = Script(address: toAddress)!.data
//        var outputs: [TransactionOutput] = [
//            TransactionOutput(value: plan.amount, lockingScript: toLockScript)
//        ]
//        if plan.change > 0 {
//            let changeLockScript: Data = Script(address: changeAddress)!.data
//            outputs.insert(TransactionOutput(value: plan.change, lockingScript: changeLockScript), at: 0)
//        }
//
//        let unsignedInputs: [TransactionInput] = plan.unspentTransactions.map {
//            TransactionInput(
//                previousOutput: $0.outpoint,
//                signatureScript: Data(),
//                sequence: UInt32.max
//            )
//        }
//
//        return Transaction(version: 2, inputs: unsignedInputs, outputs: outputs, lockTime: 0)
//    }
//    private func sendBTCTransaction(signature: String) {
//        let request = BTCModuleProvide.request(.TrezorBTCPushTransaction(signature)) {[weak self](result) in
//            switch  result {
//            case let .success(response):
//                do {
//                    let json = try response.map(TrezorBTCSendTransactionMainModel.self)
//                    guard json.result?.isEmpty == false else {
//                        DispatchQueue.main.async(execute: {
//                            let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.dataCodeInvalid), type: "SendBTCTransaction")
//                            self?.setValue(data, forKey: "dataDic")
//                        })
//                        return
//                    }
//                    DispatchQueue.main.async(execute: {
//                        let data = setKVOData(type: "SendBTCTransaction")
//                        self?.setValue(data, forKey: "dataDic")
//                    })
//                    // 刷新本地数据
//                } catch {
//                    print("SendBTCTransaction_解析异常\(error.localizedDescription)")
//                    DispatchQueue.main.async(execute: {
//                        let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.parseJsonError), type: "SendBTCTransaction")
//                        self?.setValue(data, forKey: "dataDic")
//                    })
//
//                }
//            case let .failure(error):
//                guard error.errorCode != -999 else {
//                    print("SendBTCTransaction_网络请求已取消")
//                    return
//                }
//                DispatchQueue.main.async(execute: {
//                    let data = setKVOData(error: LibraWalletError.WalletRequest(reason: .networkInvalid), type: "SendBTCTransaction")
//                    self?.setValue(data, forKey: "dataDic")
//                })
//
//            }
//        }
//        self.requests.append(request)
//    }
//}
// MARK: - 获取跨链映射支持币
//extension ExchangeModel {
//    private func getMappingTokenList(semaphore: DispatchSemaphore, outputModuleName: String, inputModule: String) {
//        let request = marketModuleProvide.request(.marketSupportMappingTokens) {[weak self](result) in
//            switch  result {
//            case let .success(response):
//                do {
//                    let json = try response.map(MarketSupportMappingTokensMainModel.self)
//                    if json.code == 2000 {
//                        //                        let data = setKVOData(type: "GetMappingTokenList", data: json.data)
//                        //                        self?.setValue(data, forKey: "dataDic")
//                        let tempModule = json.data?.filter({
//                            $0.to_coin?.assets?.module == outputModuleName && $0.input_coin_type == inputModule
//                        })
//                        guard tempModule?.isEmpty == false else {
//                            let data = setKVOData(error: LibraWalletError.error("Market Not Support"), type: "GetMappingTokenList")
//                            self?.setValue(data, forKey: "dataDic")
//                            return
//                        }
//                        self?.supportSwapData = tempModule?.first
//                        semaphore.signal()
//                    } else {
//                        print("GetMappingTokenList_状态异常")
//                        if let message = json.message, message.isEmpty == false {
//                            let data = setKVOData(error: LibraWalletError.error(message), type: "GetMappingTokenList")
//                            self?.setValue(data, forKey: "dataDic")
//                        } else {
//                            let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.dataCodeInvalid), type: "GetMappingTokenList")
//                            self?.setValue(data, forKey: "dataDic")
//                        }
//                    }
//                } catch {
//                    print("GetMappingTokenList_解析异常\(error.localizedDescription)")
//                    let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.parseJsonError), type: "GetMappingTokenList")
//                    self?.setValue(data, forKey: "dataDic")
//                }
//            case let .failure(error):
//                guard error.errorCode != -999 else {
//                    print("网络请求已取消")
//                    return
//                }
//                let data = setKVOData(error: LibraWalletError.WalletRequest(reason: .networkInvalid), type: "GetMappingTokenList")
//                self?.setValue(data, forKey: "dataDic")
//            }
//        }
//        self.requests.append(request)
//    }
//}
//MARK: - 获取资金池流动性
