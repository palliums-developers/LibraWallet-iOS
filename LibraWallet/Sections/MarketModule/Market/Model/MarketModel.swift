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
struct MarketSupportCoinMainModel: Codable {
    
}
class MarketModel: NSObject {
    private var requests: [Cancellable] = []
    @objc var dataDic: NSMutableDictionary = [:]
    private var walletEnableTokens: [String]?
    private var marketEnableTokens: [MarketSupportCoinDataModel]?
    private var sequenceNumber: Int?
    func getMarketSupportToken(address: String) {
        let group = DispatchGroup.init()
        let quene = DispatchQueue.init(label: "SupportTokenQuene")
        quene.async(group: group, qos: .default, flags: [], execute: {
            self.getSupportToken(group: group)
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
                let data = setKVOData(type: "GetTokenList", data: result)
                self.setValue(data, forKey: "dataDic")
            })
        }
    }
    private func getSupportToken(group: DispatchGroup) {
        group.enter()
        let request = mainProvide.request(.GetMarketSupportCoin) {[weak self](result) in
            switch  result {
            case let .success(response):
                do {
                    print(try response.mapString())
                    let json = try response.map([MarketSupportCoinDataModel].self)
                    guard json.isEmpty == false else {
                        let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.dataEmpty), type: "GetMarketEnableCoin")
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
                    print(try response.mapString())
                    let json = try response.map(ViolasAccountEnableTokenResponseModel.self)
                    guard json.code == 2000 else {
                        let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.dataCodeInvalid), type: "GetWalletEnableCoin")
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
    func getCurrentOrder(baseAddress: String, exchangeAddress: String) {
        let request = mainProvide.request(.GetCurrentOrder(baseAddress, exchangeAddress)) {[weak self](result) in
            switch  result {
            case let .success(response):
                do {
                    print(try response.mapString())
                    let json = try response.map(MarketOrderModel.self)
//                    guard json. == 2000 else {
//                        let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.dataCodeInvalid), type: "GetCurrentOrder")
//                        self?.setValue(data, forKey: "dataDic")
//                        return
//                    }
                    let data = setKVOData(type: "GetCurrentOrder", data: json)
                    self?.setValue(data, forKey: "dataDic")
                } catch {
                    print("GetCurrentOrder_解析异常\(error.localizedDescription)")
                    let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.parseJsonError), type: "GetCurrentOrder")
                    self?.setValue(data, forKey: "dataDic")
                }
            case let .failure(error):
                guard error.errorCode != -999 else {
                    print("GetCurrentOrder_网络请求已取消")
                    return
                }
                let data = setKVOData(error: LibraWalletError.WalletRequest(reason: .networkInvalid), type: "GetCurrentOrder")
                self?.setValue(data, forKey: "dataDic")
            }
        }
        self.requests.append(request)
    }
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
                self.makeViolasTransaction(signature: signature.toHexString())
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
    private func makeViolasTransaction(signature: String) {
        let request = mainProvide.request(.SendViolasTransaction(signature)) {[weak self](result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(ViolaSendTransactionMainModel.self)
                    guard json.code == 2000 else {
                        DispatchQueue.main.async(execute: {
                            let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.dataCodeInvalid), type: "SendViolasTransaction")
                            self?.setValue(data, forKey: "dataDic")
                        })
                        return
                    }
                    DispatchQueue.main.async(execute: {
                        let data = setKVOData(type: "SendViolasTransaction")
                        self?.setValue(data, forKey: "dataDic")
                    })
                    // 刷新本地数据
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
        print("MarketModel销毁了")
    }
}
