//
//  MarketModel.swift
//  LibraWallet
//
//  Created by palliums on 2019/11/6.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit
import Moya
struct MarketOrderDataModel: Codable {
    var id: String?
    var user: String?
    var state: String?
    var tokenGet: String?
    var tokenGetSymbol: String?
    var amountGet: String?
    var tokenGive: String?
    var tokenGiveSymbol: String?
    var amountGive: String?
    var version: String?
    var date: Int?
    var update_date: Int?
//    var date: String?
//    var update_date: String?
    var update_version: String?
    var amountFilled: String?
}
struct MarketOrderModel: Codable {
    var buys: [MarketOrderDataModel]?
    var sells: [MarketOrderDataModel]?
}
struct ViolasAccountEnableTokenResponseModel: Codable {
    var code: Int?
    var message: String?
    var data: [String]?
}
struct MarketSupportCoinDataModel: Codable {
    var addr: String?
    var name: String?
    var price: Double?
    // 自行添加
    var enable: Bool?
}
struct MarketResponseMainModel: Codable {
    var orders: [MarketOrderDataModel]?
    var depths: MarketOrderModel?
}
struct MarketSupportCoinMainModel: Codable {
    
}
class MarketModel: NSObject {
    private var requests: [Cancellable] = []
    @objc var dataDic: NSMutableDictionary = [:]
    private var walletEnableTokens: [String]?
    private var marketEnableTokens: [MarketSupportCoinDataModel]?
    private var sequenceNumber: Int?
    func getSupportToken(address: String) {
        let group = DispatchGroup.init()
        let quene = DispatchQueue.init(label: "SupportTokenQuene")
        quene.async(group: group, qos: .default, flags: [], execute: {
            self.getMarketSupportToken(group: group)
        })
        quene.async(group: group, qos: .default, flags: [], execute: {
            self.getWalletEnableToken(address: address, group: group)
        })
        group.notify(queue: quene) {
            print("回到该队列中执行")
            DispatchQueue.main.async(execute: {
                guard let walletTokens = self.walletEnableTokens else {
                    return
                }
                guard let marketTokens = self.marketEnableTokens else {
                    return
                }
                let result = self.rebuiltData(walletTokens: walletTokens, marketTokens: marketTokens)
//                let result = self.rebuiltData(walletTokens: [""], marketTokens: marketTokens)

                let data = setKVOData(type: "GetTokenList", data: result)
                self.setValue(data, forKey: "dataDic")
            })
        }
    }
    private func getMarketSupportToken(group: DispatchGroup) {
        group.enter()
        let request = mainProvide.request(.GetMarketSupportCoin) {[weak self](result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map([MarketSupportCoinDataModel].self)
                    guard json.isEmpty == false else {
                        let data = setKVOData(error: LibraWalletError.error(localLanguage(keyString: "交易所支持稳定币为空")), type: "GetMarketEnableCoin")
                        self?.setValue(data, forKey: "dataDic")
                        return
                    }
//                    let data = setKVOData(type: "GetSupportCoin", data: json)
//                    self?.setValue(data, forKey: "dataDic")
                    self?.marketEnableTokens = json
                } catch {
                    print("GetMarketEnableCoin_解析异常\(error.localizedDescription)")
                    let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.parseJsonError), type: "GetMarketEnableCoin")
                    self?.setValue(data, forKey: "dataDic")
                }
            case let .failure(error):
                guard error.errorCode != -999 else {
                    print("GetMarketEnableCoin_网络请求已取消")
                    return
                }
                let data = setKVOData(error: LibraWalletError.WalletRequest(reason: .networkInvalid), type: "GetMarketEnableCoin")
                self?.setValue(data, forKey: "dataDic")
            }
            group.leave()
        }
        self.requests.append(request)
    }
    private func getWalletEnableToken(address: String, group: DispatchGroup) {
        group.enter()
        let request = mainProvide.request(.GetViolasAccountEnableToken(address)) {[weak self](result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(ViolasAccountEnableTokenResponseModel.self)
                    guard json.code == 2000 else {
                        let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.dataCodeInvalid), type: "GetWalletEnableCoin")
                        self?.setValue(data, forKey: "dataDic")
                        return
                    }
                    guard json.data?.isEmpty == false else {
                        let data = setKVOData(error: LibraWalletError.error(localLanguage(keyString: "尚未注册任何稳定币")), type: "GetWalletEnableCoin")
                        self?.setValue(data, forKey: "dataDic")
                        return
                    }
//                    let data = setKVOData(type: "GetSupportCoin", data: json.data)
//                    self?.setValue(data, forKey: "dataDic")
                    self?.walletEnableTokens = json.data
                } catch {
                    print("GetWalletEnableCoin_解析异常\(error.localizedDescription)")
                    let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.parseJsonError), type: "GetWalletEnableCoin")
                    self?.setValue(data, forKey: "dataDic")
                }
            case let .failure(error):
                guard error.errorCode != -999 else {
                    print("GetWalletEnableCoin_网络请求已取消")
                    return
                }
                let data = setKVOData(error: LibraWalletError.WalletRequest(reason: .networkInvalid), type: "GetWalletEnableCoin")
                self?.setValue(data, forKey: "dataDic")
            }
            group.leave()
        }
        self.requests.append(request)
    }
    private func rebuiltData(walletTokens: [String], marketTokens: [MarketSupportCoinDataModel]) -> [MarketSupportCoinDataModel] {
        var tempMarketTokens = [MarketSupportCoinDataModel]()
        for var item in marketTokens {
            #warning("崩溃隐患")
            let tempAddress = item.addr?.suffix(item.addr!.count - 2).description
            for address in walletTokens {
                
                if tempAddress == address {
                    item.enable = true
                    break
                } else {
                    item.enable = false
                }
//                item.enable = item.addr == "0x07e92f79c67fdd6b80ed9103636a49511363de8c873bc709966fffb2e3fcd095" ? true:false
            }
            tempMarketTokens.append(item)
        }
        return tempMarketTokens
    }
//    func getCurrentOrder(baseAddress: String, exchangeAddress: String) {
//        let request = mainProvide.request(.GetCurrentOrder(baseAddress, exchangeAddress)) {[weak self](result) in
//            switch  result {
//            case let .success(response):
//                do {
//                    let json = try response.map(MarketOrderModel.self)
////                    guard json. == 2000 else {
////                        let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.dataCodeInvalid), type: "GetCurrentOrder")
////                        self?.setValue(data, forKey: "dataDic")
////                        return
////                    }
//                    let data = setKVOData(type: "GetCurrentOrder", data: json)
//                    self?.setValue(data, forKey: "dataDic")
//                } catch {
//                    print("GetCurrentOrder_解析异常\(error.localizedDescription)")
//                    let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.parseJsonError), type: "GetCurrentOrder")
//                    self?.setValue(data, forKey: "dataDic")
//                }
//            case let .failure(error):
//                guard error.errorCode != -999 else {
//                    print("GetCurrentOrder_网络请求已取消")
//                    return
//                }
//                let data = setKVOData(error: LibraWalletError.WalletRequest(reason: .networkInvalid), type: "GetCurrentOrder")
//                self?.setValue(data, forKey: "dataDic")
//            }
//        }
//        self.requests.append(request)
//    }
    func getViolasSequenceNumber(sendAddress: String, semaphore: DispatchSemaphore, queue: DispatchQueue) {
        semaphore.wait()
        let request = mainProvide.request(.GetViolasAccountSequenceNumber(sendAddress)) {[weak self](result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(ViolaSequenceNumberMainModel.self)
                    guard json.code == 2000 else {
                        DispatchQueue.main.async(execute: {
                            let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.dataCodeInvalid), type: "GetViolasSequenceNumber")
                            self?.setValue(data, forKey: "dataDic")
                        })
                        return
                    }
//                    let data = setKVOData(type: "GetViolasSequenceNumber", data: json.data)
//                    self?.setValue(data, forKey: "dataDic")
                    self?.sequenceNumber = json.data
                    semaphore.signal()
                    
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
    func exchangeViolasTokenTransaction(sendAddress: String, amount: Double, fee: Double, mnemonic: [String], contact: String, exchangeTokenContract: String, exchangeTokenAmount: Double) {
//        "05599ef248e215849cc599f563b4883fc8aff31f1e43dff1e3ebe4de1370e054"
        let semaphore = DispatchSemaphore.init(value: 1)
        let queue = DispatchQueue.init(label: "SendQueue")
        queue.async {
            self.getViolasSequenceNumber(sendAddress: sendAddress, semaphore: semaphore, queue: queue)
        }
        queue.async {
            semaphore.wait()
            do {
                let wallet = try ViolasManager.getWallet(mnemonic: mnemonic)
                // 拼接交易
                let request = ViolasTransaction.init(sendAddress: sendAddress,
                                                    amount: amount,
                                                    fee: fee,
                                                    sequenceNumber: UInt64(self.sequenceNumber!),
                                                    code: Data.init(Array<UInt8>(hex: ViolasManager().getViolasTokenExchangeTransactionCode(content: contact))),
                                                    receiveTokenAddress: exchangeTokenContract,
                                                    exchangeAmount: exchangeTokenAmount)
                // 签名交易
                let signature = try wallet.privateKey.signTransaction(transaction: request.request, wallet: wallet)
                self.makeViolasTransaction(signature: signature.toHexString(), type: "ExchangeDone")
            } catch {
                print(error.localizedDescription)
                DispatchQueue.main.async(execute: {
                    let data = setKVOData(error: LibraWalletError.error(error.localizedDescription), type: "ExchangeDone")
                    self.setValue(data, forKey: "dataDic")
                })
            }
            semaphore.signal()
        }
        
    }
    private func makeViolasTransaction(signature: String, type: String) {
        let request = mainProvide.request(.SendViolasTransaction(signature)) {[weak self](result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(ViolaSendTransactionMainModel.self)
                    guard json.code == 2000 else {
                        DispatchQueue.main.async(execute: {
                            let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.dataCodeInvalid), type: type)
                            self?.setValue(data, forKey: "dataDic")
                        })
                        return
                    }
                    DispatchQueue.main.async(execute: {
                        let data = setKVOData(type: type)
                        self?.setValue(data, forKey: "dataDic")
                    })
                    // 刷新本地数据
                } catch {
                    print("ExchangeDone_解析异常\(error.localizedDescription)")
                    DispatchQueue.main.async(execute: {
                        let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.parseJsonError), type: type)
                        self?.setValue(data, forKey: "dataDic")
                    })
                }
            case let .failure(error):
                guard error.errorCode != -999 else {
                    print("ExchangeDone_网络请求已取消")
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
    func getViolasBalance(walletID: Int64, address: String, vtoken: String) {
        let tempVToken = Data.init(Array<UInt8>(hex: vtoken)).toHexString()
        let request = mainProvide.request(.GetViolasAccountBalance(address, tempVToken)) {[weak self](result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(BalanceLibraMainModel.self)
                    guard json.code == 2000 else {
                        let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.dataCodeInvalid), type: "UpdateViolasBalance")
                        self?.setValue(data, forKey: "dataDic")
                        return
                    }
                    let data = setKVOData(type: "UpdateViolasBalance", data: json.data)
                    self?.setValue(data, forKey: "dataDic")
                    // 刷新本地数据
                    self?.updateLocalWalletData(walletID: walletID, balance: json.data?.balance ?? 0)
                    guard let tokenModel = json.data?.modules else {
                        return
                    }
                    self?.updateLocalWalletTokenData(walletID: walletID, modules: tokenModel)
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
    func updateLocalWalletData(walletID: Int64, balance: Int64) {
        // 刷新本地缓存数据
        let result = DataBaseManager.DBManager.updateWalletBalance(walletID: walletID, balance: balance)
        print("刷新本地钱包数据状态: \(result),walletID = \(walletID)")
    }
    func updateLocalWalletTokenData(walletID: Int64, modules: [BalanceViolasModulesModel]) {
        // 刷新本地缓存数据
        for item in modules {
            let result = DataBaseManager.DBManager.updateViolasToken(walletID: walletID, model: item)
            print("刷新本地钱包Token数据状态: \(result),walletID = \(walletID)")
        }
    }
    func publishTokenForTransaction(sendAddress: String, mnemonic: [String], contact: String) {
        let semaphore = DispatchSemaphore.init(value: 1)
        let queue = DispatchQueue.init(label: "SendQueue")
        queue.async {
            self.getViolasSequenceNumber(sendAddress: sendAddress, semaphore: semaphore, queue: queue)
        }
        queue.async {
            semaphore.wait()
            do {
                let wallet = try ViolasManager.getWallet(mnemonic: mnemonic)

                // 拼接交易
                let request = ViolasTransaction.init(sendAddress: wallet.publicKey.toAddress(), sequenceNumber: UInt64(self.sequenceNumber!), code: Data.init(Array<UInt8>(hex: ViolasManager().getViolasPublishCode(content: contact))))
                // 签名交易
                let signature = try wallet.privateKey.signTransaction(transaction: request.request, wallet: wallet)
                self.makeViolasTransaction(signature: signature.toHexString(), type: "PublishTokenForTransaction")
            } catch {
                print(error.localizedDescription)
            }
            semaphore.signal()
        }
    }
    func addSocket() {
        ViolasSocketManager.shared.openSocket { result in
            print(result)
        }
        ViolasSocketManager.shared.addMarketListening { result in
            do {
                let modelObject = try JSONDecoder().decode(MarketResponseMainModel.self, from: result)
                print(modelObject)
                let data = setKVOData(type: "GetCurrentOrder", data: modelObject)
                self.setValue(data, forKey: "dataDic")
            } catch {
                print(error.localizedDescription)
            }

        }
        ViolasSocketManager.shared.addDepthsListening { result in
            do {
                let modelObject = try JSONDecoder().decode(MarketOrderModel.self, from: result)
                print(modelObject)
                let data = setKVOData(type: "OrderChange", data: modelObject)
                self.setValue(data, forKey: "dataDic")
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    func removeSocket() {
        ViolasSocketManager.shared.stopSocket()
    }
    func getMarketData(address: String, payContract: String, exchangeContract: String) {
        ViolasSocketManager.shared.getMarketData(address: address,
                                                 payContract: payContract,
                                                 exchangeContract: exchangeContract)
    }
    func addDepthsLisening(payContract: String, exchangeContract: String) {
        ViolasSocketManager.shared.addListeningData(payContract: payContract,
                                                    exchangeContract: exchangeContract)
    }
    func removeDepthsLisening(payContract: String, exchangeContract: String) {
        ViolasSocketManager.shared.removeListeningData(payContract: payContract,
                                                       exchangeContract: exchangeContract)
    }
    deinit {
        requests.forEach { cancellable in
            cancellable.cancel()
        }
        requests.removeAll()
        print("MarketModel销毁了")
    }
}
