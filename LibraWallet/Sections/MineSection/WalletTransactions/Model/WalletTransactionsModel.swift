//
//  WalletTransactionsModel.swift
//  LibraWallet
//
//  Created by palliums on 2019/10/29.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit
import Moya
struct inputs: Codable {
    var prev_addresses: [String]?
    var prev_position: Int?
    var prev_tx_hash: String?
    var prev_type: String?
    var prev_value: Int?
    var sequence: Int?
}
struct outputs: Codable {
    var addresses: [String]?
    var value: Int?
    var type: String?
//    var spent_by_tx: String?
    var spent_by_tx_position: Int?
}
struct BTCTransaction: Codable {
    var confirmations: Int?
    var block_height: Int?
    var block_hash: String?
    var block_time: Int?
    var created_at: Int?
    var fee: Int?
    var hash: String?
    var inputs_count: Int?
    var inputs_value: Int?
    var is_coinbase: Bool?
    var is_double_spend: Bool?
    var is_sw_tx: Bool?
    var weight: Int?
    var vsize: Int?
    var witness_hash: String?
    var lock_time: Int?
    var outputs_count: Int?
    var outputs_value: Int?
    var size: Int?
    var sigops: Int?
    var version: Int?
    var inputs: [inputs]?
    var outputs: [outputs]?
    /// 交易金额
    var transaction_value: Int?
    /// 交易类型(0:转账,1:收款)
    var transaction_type: Int?
}
struct BTCDataModel: Codable {
    var total_count: Int?
    var page: Int?
    var pagesize: Int?
    var list: [BTCTransaction]?
    
}
struct BTCResponseModel: Codable {
    var data: BTCDataModel?
    var err_no: Int?
    var err_msg: String?
}
//struct transaction: Codable {
//    var version: Int?
//    var address: String?
//    var value: Int?
//    var sequence_number: Int?
//    var expiration_time: Int?
//}
//struct LibraModel: Codable {
//    var code: Int?
//    var message: String?
//    var data: [transaction]?
//}
struct LibraDataModel: Codable {
    var amount: String?
    var fromAddress: String?
    var toAddress: String?
    var date: String?
    var transactionVersion: Int?
    var explorerLink: String?
    var event: String?
    var type: String?
}
struct LibraResponseModel: Codable {
    var transactions: [LibraDataModel]?
}
struct ViolasDataModel: Codable {
    var amount: Int?
    var expiration_time: Int?
    var gas: Int?
    var receiver: String?
    var receiver_module: String?
    var sender: String?
    var sender_module: String?
    var sequence_number: Int?
    /// 0. vtoken p2p transaction; 1. module publish transaction; 2. module p2p transaction
    var type: Int?
    var version: Int?
    /// 判断接收发送(自行添加0:转账,1收款)
    var transaction_type: Int?
    /// 判断交易代币名字
    var module_name: String?
}
struct ViolasResponseModel: Codable {
    var code: Int?
    var message: String?
    var data: [ViolasDataModel]?
}

class WalletTransactionsModel: NSObject {
    private var requests: [Cancellable] = []
    @objc dynamic var dataDic: NSMutableDictionary = [:]
    private var transactionList: [ViolasDataModel]?
    private var supportTokens: [ViolasTokenModel]?
    /// 获取BTC交易记录
    /// - Parameters:
    ///   - address: 地址
    ///   - page: 页数
    ///   - pageSize: 数量
    func getBTCTransactionHistory(address: String, page: Int, pageSize: Int, requestStatus: Int) {
        let type = requestStatus == 0 ? "BTCTransactionHistoryOrigin":"BTCTransactionHistoryMore"
        let request = mainProvide.request(.GetBTCTransactionHistory(address, page, pageSize)) {[weak self](result) in
                switch  result {
                case let .success(response):
                    do {
                        let json = try response.map(BTCResponseModel.self)
                        print(json)
                        guard json.err_no == 0 else {
                            DispatchQueue.main.async(execute: {
                                let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.dataCodeInvalid), type: type)
                                self?.setValue(data, forKey: "dataDic")
                            })
                            return
                        }
                        guard let models = json.data?.list, models.isEmpty == false else {
                            let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.dataEmpty), type: type)
                            self?.setValue(data, forKey: "dataDic")
                            return
                        }
                        let resultModel = self!.dealTransactionAmount(models: models, requestAddress: address)
                                                                           
//                        let data = setKVOData(type: type, data: (json.data?.list)!)
                       let data = setKVOData(type: type, data: resultModel)
                       self?.setValue(data, forKey: "dataDic")
                        
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
    func getViolasTransactionList(address: String, page: Int, pageSize: Int, contract: String, requestStatus: Int) {
//        let type = requestStatus == 0 ? "ViolasTransactionHistoryOrigin":"ViolasTransactionHistoryMore"

//        let group = DispatchGroup.init()
//        let quene = DispatchQueue.init(label: "SupportTokenQuene")
//        quene.async(group: group, qos: .default, flags: [], execute: {
////            self.getMarketSupportToken(group: group)
//            self.getViolasTransactionHistory(address: address, page: page, pageSize: pageSize, contract: contract, requestStatus: requestStatus, group: group)
//        })
//        quene.async(group: group, qos: .default, flags: [], execute: {
//            self.getViolasTokenList(group: group)
//        })
//        group.notify(queue: quene) {
//            print("回到该队列中执行")
//            DispatchQueue.main.async(execute: {
//                guard let walletTokens = self.transactionList else {
//                    return
//                }
//                guard let tokenList = self.supportTokens else {
//                    return
//                }
////                let tempResult = self.rebuiltData(walletTokens: walletTokens, marketTokens: marketTokens)
//                let result = self.dealViolasTransactions(models: walletTokens, walletAddress: address, tokenList: tokenList)
//
////                let finalResult = self.dealModelWithSelect(walletID: walletID, models: tempResult)
//
//                let data = setKVOData(type: type, data: result)
//                self.setValue(data, forKey: "dataDic")
//            })
//        }
        let group = DispatchGroup.init()
        self.getViolasTransactionHistory(address: address, page: page, pageSize: pageSize, contract: contract, requestStatus: requestStatus, group: group)
    }
    /// 获取Violas交易记录
    /// - Parameters:
    ///   - address: 地址
    ///   - page: 页数
    ///   - pageSize: 数量
    private func getViolasTransactionHistory(address: String, page: Int, pageSize: Int, contract: String, requestStatus: Int, group: DispatchGroup) {
        group.enter()
        let type = requestStatus == 0 ? "ViolasTransactionHistoryOrigin":"ViolasTransactionHistoryMore"
        let request = mainProvide.request(.GetViolasAccountTransactionList(address, page, pageSize, contract)) {[weak self](result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(ViolasResponseModel.self)
                    print(try response.mapString())
                    guard json.code == 2000 else {
                        let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.dataCodeInvalid), type: type)
                        self?.setValue(data, forKey: "dataDic")
                        return
                    }
                    guard json.data?.isEmpty == false else {
                        let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.dataEmpty), type: type)
                        self?.setValue(data, forKey: "dataDic")
                        return
                    }
                    let result = self?.dealViolasTransactions(models: json.data!, walletAddress: address, tokenList: [ViolasTokenModel]())
                    let data = setKVOData(type: type, data: result)
                    self?.setValue(data, forKey: "dataDic")
//                    self?.transactionList = json.data
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
            group.leave()
        }
        self.requests.append(request)
    }
    private func getViolasTokenList(group: DispatchGroup) {
        group.enter()
        let request = mainProvide.request(.GetViolasTokenList) {[weak self](result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(ViolasTokenMainModel.self)
                    guard json.code == 2000 else {
                        let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.dataCodeInvalid), type: "GetWalletEnableCoin")
                        self?.setValue(data, forKey: "dataDic")
                        return
                    }
                    guard let models = json.data, models.isEmpty == false else {
                        let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.dataEmpty), type: "GetWalletEnableCoin")
                        self?.setValue(data, forKey: "dataDic")
                        return
                    }
//                    let result = self?.dealModelWithSelect(walletID: walletID, models: models)
//                    let data = setKVOData(type: "UpdateViolasTokenList", data: result)
//                    self?.setValue(data, forKey: "dataDic")
                    self?.supportTokens = json.data
                } catch {
                    print("解析异常\(error.localizedDescription)")
                    let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.parseJsonError), type: "GetWalletEnableCoin")
                    self?.setValue(data, forKey: "dataDic")
                }
            case let .failure(error):
                guard error.errorCode != -999 else {
                    print("网络请求已取消")
                    return
                }
                let data = setKVOData(error: LibraWalletError.WalletRequest(reason: .networkInvalid), type: "GetWalletEnableCoin")
                self?.setValue(data, forKey: "dataDic")
            }
            group.leave()
        }
        self.requests.append(request)
    }
    /// 获取Libra交易记录
    /// - Parameters:
    ///   - address: 地址
    ///   - page: 页数
    ///   - pageSize: 数量
    func getLibraTransactionHistory(address: String, page: Int, pageSize: Int, requestStatus: Int) {
        let type = requestStatus == 0 ? "LibraTransactionHistoryOrigin":"LibraTransactionHistoryMore"
        guard requestStatus == 0 else {
            let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.dataEmpty), type: type)
            self.setValue(data, forKey: "dataDic")
            return
        }
        let request = mainProvide.request(.GetTransactionHistory(address, 0)) {[weak self](result) in
                switch  result {
                case let .success(response):
                    do {
                        let json = try response.map(LibraResponseModel.self)
//                        guard json.code == 2000 else {
//                            let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.dataCodeInvalid), type: type)
//                            self?.setValue(data, forKey: "dataDic")
//                            return
//                        }
                        guard json.transactions?.isEmpty == false else {
                            let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.dataEmpty), type: type)
                            self?.setValue(data, forKey: "dataDic")
                            return
                        }
                        let data = setKVOData(type: type, data: json.transactions)
                        self?.setValue(data, forKey: "dataDic")
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
    deinit {
        requests.forEach { cancellable in
            cancellable.cancel()
        }
        requests.removeAll()
        print("WalletTransactionsModel销毁了")
    }
    func dealTransactionAmount(models: [BTCTransaction], requestAddress: String) -> [BTCTransaction] {
        var resultModels = [BTCTransaction]()
        for model in models {
            var tempModel = model
            if let inputs = tempModel.inputs, inputs.isEmpty == false {
//                let inputFromMe = inputs.map {
//                    $0.prev_addresses?.filter({
//                        $0 == requestAddress
//                    })
//                }
                var inputFromMe = false
                for input in inputs {
                    for address in input.prev_addresses ?? [""] {
                        if address == requestAddress {
                            inputFromMe = true
                            break
                        }
                    }
                    if inputFromMe == true {
                        break
                    }
                }
                if inputFromMe == false {
                    //收款
                    tempModel.transaction_type = 1
                    let result = (tempModel.inputs_value ?? 0) - (tempModel.fee ?? 0)
                    tempModel.transaction_value = result
                } else {
                    //转账
                    tempModel.transaction_type = 0
                    var result = (tempModel.inputs_value ?? 0) - (tempModel.fee ?? 0)
                    if let outputs = tempModel.outputs, outputs.isEmpty == false {
                        for output in outputs {
                            let outputsToMe = output.addresses?.filter({
                                $0 == requestAddress
                            })
                            if outputsToMe?.isEmpty == false {
                                result -= (output.value ?? 0)
                            }
                        }
                        tempModel.transaction_value = result
                    }
                }
            }
            resultModels.append(tempModel)
        }
        return resultModels
    }
    func dealViolasTransactions(models: [ViolasDataModel], walletAddress: String, tokenList: [ViolasTokenModel]) -> [ViolasDataModel] {
        var tempModels = [ViolasDataModel]()
        for var item in models {
            if item.receiver == walletAddress {
                // 收款
                item.transaction_type = 1
            } else {
                // 转账
                item.transaction_type = 0
            }
//            for token in tokenList {
//                if item.receiver_module == token.address {
//                    item.module_name = token.name
//                    break
//                }
//            }
            if item.module_name == nil || item.module_name?.isEmpty == true {
                item.module_name = "vtoken"
            }
            tempModels.append(item)
            
        }
        return tempModels
    }
}
