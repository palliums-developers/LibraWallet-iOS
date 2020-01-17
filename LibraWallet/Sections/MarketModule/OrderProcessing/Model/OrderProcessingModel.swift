//
//  OrderProcessingModel.swift
//  LibraWallet
//
//  Created by palliums on 2019/12/10.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit
import Moya
struct AllProcessingOrderMainModel: Codable {
    var orders: [MarketOrderDataModel]?
}
class OrderProcessingModel: NSObject {
    private var requests: [Cancellable] = []
    @objc var dataDic: NSMutableDictionary = [:]
    private var sequenceNumber: Int?
    private var orderModels: [MarketOrderDataModel]?
    private var priceModels: [MarketSupportCoinDataModel]?
    func getAllProcessingOrder(address: String, version: String) {
//        let type = version.isEmpty == true ? "GetAllProcessingOrderOrigin":"GetAllProcessingOrderMore"
//
        let group = DispatchGroup.init()
//        let quene = DispatchQueue.init(label: "AllProcessingOrderQuene")
//        quene.async(group: group, qos: .default, flags: [], execute: {
//            self.getAllProcessingOrderList(address: address, version: version, group: group)
//        })
//        quene.async(group: group, qos: .default, flags: [], execute: {
//            self.getCurrentPrice(group: group)
//        })
//        group.notify(queue: quene) {
//            print("回到该队列中执行")
//            DispatchQueue.main.async(execute: {
//                guard let tempOrderModels = self.orderModels else {
//                    return
//                }
//                guard let tempPriceModels = self.priceModels else {
//                    return
//                }
//                let result = self.rebuiltData(orderModel: tempOrderModels, priceModel: tempPriceModels)
//
//                let data = setKVOData(type: type, data: result)
//                self.setValue(data, forKey: "dataDic")
//            })
//        }
        self.getAllProcessingOrderList(address: address, version: version, group: group)
    }
    func getAllProcessingOrderList(address: String, version: String, group: DispatchGroup) {
        group.enter()
        let type = version.isEmpty == true ? "GetAllProcessingOrderOrigin":"GetAllProcessingOrderMore"
        let request = mainProvide.request(.GetAllProcessingOrder(address, version)) {[weak self](result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(AllProcessingOrderMainModel.self)
                    guard json.orders?.isEmpty == false else {
                        let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.dataEmpty), type: type)
                        self?.setValue(data, forKey: "dataDic")
                        return
                    }
                    let data = setKVOData(type: type, data: json.orders)
                    self?.setValue(data, forKey: "dataDic")
//                    self?.orderModels = json.orders
                } catch {
                    print("\(type)_解析异常\(error.localizedDescription)")
                    let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.parseJsonError), type: type)
                    self?.setValue(data, forKey: "dataDic")
                }
            case let .failure(error):
                guard error.errorCode != -999 else {
                    print("\(type)_网络请求已取消")
                    return
                }
                let data = setKVOData(error: LibraWalletError.WalletRequest(reason: .networkInvalid), type: type)
                self?.setValue(data, forKey: "dataDic")
            }
            group.leave()
        }
        self.requests.append(request)
    }
    private func getCurrentPrice(group: DispatchGroup) {
        group.enter()
        let request = mainProvide.request(.GetMarketSupportCoin) {[weak self](result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map([MarketSupportCoinDataModel].self)
                    guard json.isEmpty == false else {
                        let data = setKVOData(error: LibraWalletError.WalletMarket(reason: .marketSupportTokenEmpty), type: "GetOrderPrices")
                        self?.setValue(data, forKey: "dataDic")
                        return
                    }
//                    let data = setKVOData(type: "GetSupportCoin", data: json)
//                    self?.setValue(data, forKey: "dataDic")
                    self?.priceModels = json
                } catch {
                    print("GetOrderPrices_解析异常\(error.localizedDescription)")
                    let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.parseJsonError), type: "GetOrderPrices")
                    self?.setValue(data, forKey: "dataDic")
                }
            case let .failure(error):
                guard error.errorCode != -999 else {
                    print("GetOrderPrices_网络请求已取消")
                    return
                }
                let data = setKVOData(error: LibraWalletError.WalletRequest(reason: .networkInvalid), type: "GetOrderPrices")
                self?.setValue(data, forKey: "dataDic")
            }
            group.leave()
        }
        self.requests.append(request)
    }
//    func rebuiltData(orderModel: [MarketOrderDataModel], priceModel: [MarketSupportCoinDataModel]) -> [MarketOrderDataModel] {
//        var tempOrderModel = [MarketOrderDataModel]()
//        for var item in orderModel {
//            for model in priceModel {
//                if model.addr == item.tokenGet {
//                    item.price = model.price
//                    break
//                }
//            }
//            tempOrderModel.append(item)
//        }
//        return tempOrderModel
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
                    print("解析异常\(error.localizedDescription)")
                    DispatchQueue.main.async(execute: {
                        let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.parseJsonError), type: "GetViolasSequenceNumber")
                        self?.setValue(data, forKey: "dataDic")
                    })
                    
                }
            case let .failure(error):
                guard error.errorCode != -999 else {
                    print("网络请求已取消")
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
    func cancelTransaction(sendAddress: String, fee: Double, mnemonic: [String], contact: String, version: String) {
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
                                                     fee: fee,
                                                     sequenceNumber: UInt64(self.sequenceNumber!),
                                                     code: Data.init(Array<UInt8>(hex: ViolasManager().getViolasTokenExchangeTransactionCode(content: contact))),
                                                     version: version)
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
                    print("解析异常\(error.localizedDescription)")
                    DispatchQueue.main.async(execute: {
                        let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.parseJsonError), type: "SendViolasTransaction")
                        self?.setValue(data, forKey: "dataDic")
                    })
                }
            case let .failure(error):
                guard error.errorCode != -999 else {
                    print("网络请求已取消")
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
        print("OrderProcessingModel销毁了")
    }
}
