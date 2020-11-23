//
//  ExchangeTransactionsModel.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/7/14.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit
import Moya

struct CrossChainTransactionsDataModel: Codable {
    var expiration_time: Int?
    var from_chain: String?
    var in_amount: Int64?
    var in_token: String?
    var opttype: String?
    var out_amount: Int64?
    var out_token: String?
    var state: String?
    var times: Int?
    var timestamps: Int64?
    var to_address: String?
    var to_chain: String?
    var tran_id: String?
    var type: String?
    var version: Int?
}
struct CrossChainTransactionsDatasModel: Codable {
    /// 数量
    var count: Int?
    /// 页数
    var cursor: Int?
    var datas: [CrossChainTransactionsDataModel]?
}
struct CrossChainTransactionsMainModel: Codable {
    var state: String?
    var message: String?
    var datas: CrossChainTransactionsDatasModel?
}
struct ExchangeTransactionsDataModel: Codable {
    /// 输入数量
    var input_amount: Int64?
    /// 兑换数量
    var output_amount: Int64?
    /// 输入币名
    var input_name: String?
    /// 兑换币名
    var output_name: String?
    /// 日期
    var date: Int?
    /// 状态（同链上状态）
    var status: Int?
    /// 交易唯一ID
    var version: Int?
}
struct ExchangeTransactionsMainModel: Codable {
    var code: Int?
    var message: String?
    var data: [ExchangeTransactionsDataModel]?
}
class ExchangeTransactionsModel: NSObject {
    private var requests: [Cancellable] = []
    @objc dynamic var dataDic: NSMutableDictionary = [:]
    private var btcCrossChainTransactions: [CrossChainTransactionsDataModel]?
    private var violasCrossChainTransactions: [CrossChainTransactionsDataModel]?
    private var libraCrossChainTransactions: [CrossChainTransactionsDataModel]?
    private var exchangeTransactions: [ExchangeTransactionsDataModel]?
    func getAllExchangeTrans(page: Int, pageSize: Int, requestStatus: Int) {
        let group = DispatchGroup.init()
        let quene = DispatchQueue.init(label: "SupportTokenQuene")
        quene.async(group: group, qos: .default, flags: [], execute: {
            group.enter()
            self.getBTCExchangeTransactions(address: WalletManager.shared.btcAddress ?? "",
                                            page: page,
                                            pageSize: pageSize,
                                            requestStatus: requestStatus,
                                            group: group)
        })
        quene.async(group: group, qos: .default, flags: [], execute: {
            group.enter()
            self.getViolasExchangeTransactions(address: WalletManager.shared.violasAddress ?? "",
                                               page: page,
                                               pageSize: pageSize,
                                               requestStatus: requestStatus,
                                               group: group)
        })
        quene.async(group: group, qos: .default, flags: [], execute: {
            group.enter()
            self.getLibraExchangeTransactions(address: WalletManager.shared.libraAddress ?? "",
                                              page: page,
                                              pageSize: pageSize,
                                              requestStatus: requestStatus,
                                              group: group)
        })
        quene.async(group: group, qos: .default, flags: [], execute: {
            group.enter()
            self.getExchangeTransactions(address: WalletManager.shared.violasAddress ?? "",
                                         page: page,
                                         pageSize: pageSize,
                                         requestStatus: requestStatus,
                                         group: group)
        })
        group.notify(queue: quene) {
            print("回到该队列中执行")
            let type = requestStatus == 0 ? "ExchangeTransactionsOrigin":"ExchangeTransactionsMore"
            self.handleData(type: type)
        }
    }
    func getBTCExchangeTransactions(address: String, page: Int, pageSize: Int, requestStatus: Int, group: DispatchGroup) {
        let type = requestStatus == 0 ? "BTCExchangeTransactionsOrigin":"BTCExchangeTransactionsMore"
        let request = mappingModuleProvide.request(.BTCCrossChainTransactions(address, page, pageSize)) {[weak self](result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(CrossChainTransactionsMainModel.self)
                    if json.state == "SUCCEED" {
//                        guard json.datas?.datas?.isEmpty == false else {
//                            if requestStatus == 0 {
//                                let data = setKVOData(error: LibraWalletError.WalletRequest(reason: .dataEmpty), type: type)
//                                self?.setValue(data, forKey: "dataDic")
//                            } else {
//                                let data = setKVOData(error: LibraWalletError.WalletRequest(reason: .noMoreData), type: type)
//                                self?.setValue(data, forKey: "dataDic")
//                            }
//                            return
//                        }
                        self?.btcCrossChainTransactions = json.datas?.datas
                        group.leave()
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
                    print("\(type)_解析异常\(error.localizedDescription)")
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
    func getViolasExchangeTransactions(address: String, page: Int, pageSize: Int, requestStatus: Int, group: DispatchGroup) {
        let type = requestStatus == 0 ? "ViolasExchangeTransactionsOrigin":"ViolasExchangeTransactionsMore"
        let request = mappingModuleProvide.request(.ViolasCrossChainTransactions(address, page, pageSize)) {[weak self](result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(CrossChainTransactionsMainModel.self)
                    if json.state == "SUCCEED" {
//                        guard json.datas?.datas?.isEmpty == false else {
//                            if requestStatus == 0 {
//                                let data = setKVOData(error: LibraWalletError.WalletRequest(reason: .dataEmpty), type: type)
//                                self?.setValue(data, forKey: "dataDic")
//                            } else {
//                                let data = setKVOData(error: LibraWalletError.WalletRequest(reason: .noMoreData), type: type)
//                                self?.setValue(data, forKey: "dataDic")
//                            }
//                            return
//                        }
//                        let data = setKVOData(type: type, data: json.data)
//                        self?.setValue(data, forKey: "dataDic")
                        self?.violasCrossChainTransactions = json.datas?.datas
                        group.leave()
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
                    print("\(type)_解析异常\(error.localizedDescription)")
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
    func getLibraExchangeTransactions(address: String, page: Int, pageSize: Int, requestStatus: Int, group: DispatchGroup) {
        let type = requestStatus == 0 ? "LibraExchangeTransactionsOrigin":"LibraExchangeTransactionsMore"
        let request = mappingModuleProvide.request(.LibraCrossChainTransactions(address, page, pageSize)) {[weak self](result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(CrossChainTransactionsMainModel.self)
                    if json.state == "SUCCEED" {
//                        guard json.datas?.datas?.isEmpty == false else {
//                            if requestStatus == 0 {
//                                let data = setKVOData(error: LibraWalletError.WalletRequest(reason: .dataEmpty), type: type)
//                                self?.setValue(data, forKey: "dataDic")
//                            } else {
//                                let data = setKVOData(error: LibraWalletError.WalletRequest(reason: .noMoreData), type: type)
//                                self?.setValue(data, forKey: "dataDic")
//                            }
//                            return
//                        }
//                        let data = setKVOData(type: type, data: json.data)
//                        self?.setValue(data, forKey: "dataDic")
                        self?.libraCrossChainTransactions = json.datas?.datas
                        group.leave()
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
                    print("\(type)_解析异常\(error.localizedDescription)")
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
    func getExchangeTransactions(address: String, page: Int, pageSize: Int, requestStatus: Int, group: DispatchGroup) {
        let type = requestStatus == 0 ? "ExchangeTransactionsOrigin":"ExchangeTransactionsMore"
        let request = marketModuleProvide.request(.exchangeTransactions(address, page, pageSize)) {[weak self](result) in
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
//                        let data = setKVOData(type: type, data: json.data)
//                        self?.setValue(data, forKey: "dataDic")
                        self?.exchangeTransactions = json.data
                        group.leave()
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
    func handleData(type: String) {
        var tempTransactions = [ExchangeTransactionsDataModel]()

        if let btcTransactions = self.btcCrossChainTransactions, btcTransactions.isEmpty == false {
            for item in btcTransactions {
                // 兑换完成
                var status = 4001
                if item.state == "start" {
                    // 兑换中
                    status = 4002
                } else if item.state == "stop" {
                    // 兑换失败
                    status = 4003
                } else if item.state == "cancel" {
                    // 已取消
                    status = 4004
                }
                let model = ExchangeTransactionsDataModel.init(input_amount: item.in_amount,
                                                               output_amount: item.out_amount,
                                                               input_name: item.in_token,
                                                               output_name: item.out_token,
                                                               date: item.expiration_time,
                                                               status: status,
                                                               version: item.version)
                tempTransactions.append(model)
            }
        }
        if let libraTransactions = self.libraCrossChainTransactions, libraTransactions.isEmpty == false {
            for item in libraTransactions {
                // 兑换完成
                var status = 4001
                if item.state == "start" {
                    // 兑换中
                    status = 4002
                } else if item.state == "stop" {
                    // 兑换失败
                    status = 4003
                } else if item.state == "cancel" {
                    // 已取消
                    status = 4004
                }
                let model = ExchangeTransactionsDataModel.init(input_amount: item.in_amount,
                                                               output_amount: item.out_amount,
                                                               input_name: item.in_token,
                                                               output_name: item.out_token,
                                                               date: item.expiration_time,
                                                               status: status,
                                                               version: item.version)
                tempTransactions.append(model)
            }
        }
        if let violasTransactions = self.violasCrossChainTransactions, violasTransactions.isEmpty == false {
            for item in violasTransactions {
                // 兑换完成
                var status = 4001
                if item.state == "start" {
                    // 兑换中
                    status = 4002
                } else if item.state == "stop" {
                    // 兑换失败
                    status = 4003
                } else if item.state == "cancel" {
                    // 已取消
                    status = 4004
                }
                let model = ExchangeTransactionsDataModel.init(input_amount: item.in_amount,
                                                               output_amount: item.out_amount,
                                                               input_name: item.in_token,
                                                               output_name: item.out_token,
                                                               date: item.expiration_time,
                                                               status: status,
                                                               version: item.version)
                tempTransactions.append(model)
            }
        }
        if let tempeExchangeTransactions = self.exchangeTransactions, tempeExchangeTransactions.isEmpty == false {
            tempTransactions += tempeExchangeTransactions
        }
        DispatchQueue.main.async(execute: {
            let data = setKVOData(type: type, data: tempTransactions)
            self.setValue(data, forKey: "dataDic")
        })
    }
    deinit {
        requests.forEach { cancellable in
            cancellable.cancel()
        }
        requests.removeAll()
        print("ExchangeModel销毁了")
    }
}
