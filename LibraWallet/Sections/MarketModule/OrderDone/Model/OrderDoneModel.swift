//
//  OrderDoneModel.swift
//  LibraWallet
//
//  Created by palliums on 2019/12/17.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit
import Moya
class OrderDoneModel: NSObject {
    private var requests: [Cancellable] = []
    @objc var dataDic: NSMutableDictionary = [:]
    private var sequenceNumber: Int?
    private var orderModels: [MarketOrderDataModel]?
    private var priceModels: [MarketSupportCoinDataModel]?
    func getAllDoneOrder(address: String, version: String) {
//        let type = version.isEmpty == true ? "GetAllDoneOrderOrigin":"GetAllDoneOrderMore"

        let group = DispatchGroup.init()
//        let quene = DispatchQueue.init(label: "AllDoneOrderQuene")
//        quene.async(group: group, qos: .default, flags: [], execute: {
//            self.getAllDoneOrderList(address: address, version: version, group: group)
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
        self.getAllDoneOrderList(address: address, version: version, group: group)

    }
    private func getAllDoneOrderList(address: String, version: String, group: DispatchGroup) {
        group.enter()
//        let type = version.isEmpty == true ? "GetAllDoneOrderOrigin":"GetAllDoneOrderMore"
//        let request = mainProvide.request(.GetAllDoneOrder(address, version)) {[weak self](result) in
//            switch  result {
//            case let .success(response):
//                do {
//                    print(try response.mapString())
//                    let json = try response.map(AllProcessingOrderMainModel.self)
//                    guard json.orders?.isEmpty == false else {
//                        let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.dataEmpty), type: type)
//                        self?.setValue(data, forKey: "dataDic")
//                        return
//                    }
//                    let data = setKVOData(type: type, data: json.orders)
//                    self?.setValue(data, forKey: "dataDic")
////                    self?.orderModels = json.orders
//                } catch {
//                    print("\(type)_解析异常\(error.localizedDescription)")
//                    let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.parseJsonError), type: type)
//                    self?.setValue(data, forKey: "dataDic")
//                }
//            case let .failure(error):
//                guard error.errorCode != -999 else {
//                    print("\(type)_网络请求已取消")
//                    return
//                }
//                let data = setKVOData(error: LibraWalletError.WalletRequest(reason: .networkInvalid), type: type)
//                self?.setValue(data, forKey: "dataDic")
//            }
//            group.leave()
//        }
//        self.requests.append(request)
    }
    private func getCurrentPrice(group: DispatchGroup) {
//        group.enter()
//        let request = mainProvide.request(.GetMarketSupportCoin) {[weak self](result) in
//            switch  result {
//            case let .success(response):
//                do {
//                    let json = try response.map([MarketSupportCoinDataModel].self)
//                    guard json.isEmpty == false else {
//                        let data = setKVOData(error: LibraWalletError.WalletMarket(reason: .marketSupportTokenEmpty), type: "GetOrderPrices")
//                        self?.setValue(data, forKey: "dataDic")
//                        return
//                    }
////                    let data = setKVOData(type: "GetSupportCoin", data: json)
////                    self?.setValue(data, forKey: "dataDic")
//                    self?.priceModels = json
//                } catch {
//                    print("GetOrderPrices_解析异常\(error.localizedDescription)")
//                    let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.parseJsonError), type: "GetOrderPrices")
//                    self?.setValue(data, forKey: "dataDic")
//                }
//            case let .failure(error):
//                guard error.errorCode != -999 else {
//                    print("GetOrderPrices_网络请求已取消")
//                    return
//                }
//                let data = setKVOData(error: LibraWalletError.WalletRequest(reason: .networkInvalid), type: "GetOrderPrices")
//                self?.setValue(data, forKey: "dataDic")
//            }
//            group.leave()
//        }
//        self.requests.append(request)
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
    deinit {
        requests.forEach { cancellable in
            cancellable.cancel()
        }
        requests.removeAll()
        print("OrderDoneModel销毁了")
    }
}
