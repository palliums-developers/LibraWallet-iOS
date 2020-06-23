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
    var transaction_value: Int64?
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
struct TrezorBTCVinModel: Codable {
    var txid: String?
    var vout: Int64?
    var sequence: Int64?
    var n: Int64?
    var addresses: [String]?
    var isAddress: Bool?
    var value: String?
    var hex: String?
}
struct TrezorBTCVoutModel: Codable {
    var value: String?
    var n: Int64?
    var hex: String?
    var addresses: [String]?
    var isAddress: Bool?
}
struct TrezorBTCTransactionDataModel: Codable {
    var txid: String?
    var version: Int64?
    var blockHash: String?
    var blockHeight: Int64?
    var confirmations: Int?
    var blockTime: Int?
    var value: String?
    var valueIn: String?
    var fees: String?
    var hex: String?
    var vin: [TrezorBTCVinModel]?
    var vout: [TrezorBTCVoutModel]?
    
    /// 交易金额
    var transaction_value: Int64?
    /// 交易类型(0:转账,1:收款)
    var transaction_type: Int?
}
struct TrezorBTCTransactionMainModel: Codable {
    var page: Int?
    var totalPages: Int?
    var itemsOnPage: Int?
    var address: String?
    var balance: String?
    var totalReceived: String?
    var totalSent: String?
    var unconfirmedBalance: String?
    var unconfirmedTxs: Int?
    var txs: Int?
    var transactions: [TrezorBTCTransactionDataModel]?
}
struct LibraDataModel: Codable {
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
struct LibraResponseModel: Codable {
//    var transactions: [LibraDataModel]?
    var code: Int?
    var message: String?
    var data: [LibraDataModel]?
}
struct ViolasDataModel: Codable {
    /// 数量
    var amount: Int?
    /// 交易币合约
    var module: String?
    /// 币种名字
    var currency: String?
    /// 过期时间
    var expiration_time: Int?
    /// 手续费
    var gas: Int?
    /// 接收方
    var receiver: String?
    /// 发送方
    var sender: String?
    /// 交易序列号
    var sequence_number: Int?
    /// 交易执行状态
    var status: Int?
    /// 类型超多，不一一展示
    var type: Int?
    /// 交易序列号
    var version: Int?
    /// 判断接收发送(自行添加0:转账,1收款)
    var transaction_type: Int?
//    /// 判断交易代币名字
//    var module_name: String?
    
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
    /// 获取BTC交易记录
    /// - Parameters:
    ///   - address: 地址
    ///   - page: 页数
    ///   - pageSize: 数量
    func getBTCTransactionHistory(address: String, page: Int, pageSize: Int, requestStatus: Int) {
        let type = requestStatus == 0 ? "BTCTransactionHistoryOrigin":"BTCTransactionHistoryMore"
        let request = mainProvide.request(.TrezorBTCTransactions(address, page, pageSize)) {[weak self](result) in
                switch  result {
                case let .success(response):
                    do {
                        let json = try response.map(TrezorBTCTransactionMainModel.self)
                        print(json)
                        guard let models = json.transactions, models.isEmpty == false else {
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
    /// 获取Violas交易记录
    /// - Parameters:
    ///   - address: 地址
    ///   - page: 页数
    ///   - pageSize: 数量
    func getViolasTransactions(address: String, module: String, requestType: String, page: Int, pageSize: Int, requestStatus: Int) {
        let type = requestStatus == 0 ? "ViolasTransactionsOrigin":"ViolasTransactionsMore"
        let request = mainProvide.request(.GetViolasTransactions(address, module, requestType, page, pageSize)) {[weak self](result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(ViolasResponseModel.self)
                    print(try response.mapString())
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
                        let result = self?.dealViolasTransactions(models: json.data!, walletAddress: address, tokenList: [ViolasTokenModel]())
                        let data = setKVOData(type: type, data: result)
                        self?.setValue(data, forKey: "dataDic")
    //                    self?.transactionList = json.data
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
    /// 获取Libra交易记录
    /// - Parameters:
    ///   - address: 地址
    ///   - page: 页数
    ///   - pageSize: 数量
    func getLibraTransactionHistory(address: String, module: String, requestType: String, page: Int, pageSize: Int, requestStatus: Int) {
        let type = requestStatus == 0 ? "LibraTransactionHistoryOrigin":"LibraTransactionHistoryMore"
        guard requestStatus == 0 else {
            let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.dataEmpty), type: type)
            self.setValue(data, forKey: "dataDic")
            return
        }
        let request = mainProvide.request(.GetLibraTransactions(address, module, requestType, page, pageSize)) {[weak self](result) in
                switch  result {
                case let .success(response):
                    do {
                        let json = try response.map(LibraResponseModel.self)
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
                            let result = self?.dealLibraTransactions(models: json.data!, walletAddress: address)
                            let data = setKVOData(type: type, data: result)
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
    deinit {
        requests.forEach { cancellable in
            cancellable.cancel()
        }
        requests.removeAll()
        print("WalletTransactionsModel销毁了")
    }
    func dealTransactionAmount(models: [TrezorBTCTransactionDataModel], requestAddress: String) -> [TrezorBTCTransactionDataModel] {
        var resultModels = [TrezorBTCTransactionDataModel]()
        for model in models {
            var tempModel = model
            if let inputs = tempModel.vin, inputs.isEmpty == false {
//                let inputFromMe = inputs.map {
//                    $0.prev_addresses?.filter({
//                        $0 == requestAddress
//                    })
//                }
                var inputFromMe = false
                for input in inputs {
                    for address in input.addresses ?? [""] {
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
                    
                    
                    let result = NSDecimalNumber.init(string: tempModel.valueIn ?? "0").subtracting(NSDecimalNumber.init(string: tempModel.fees ?? "0"))
                    tempModel.transaction_value = result.int64Value
                } else {
                    //转账
                    tempModel.transaction_type = 0
                    var result = NSDecimalNumber.init(string: tempModel.valueIn ?? "0").subtracting(NSDecimalNumber.init(string: tempModel.fees ?? "0"))
                    if let outputs = tempModel.vout, outputs.isEmpty == false {
                        for output in outputs {
                            let outputsToMe = output.addresses?.filter({
                                $0 == requestAddress
                            })
                            if outputsToMe?.isEmpty == false {
                                result = result.subtracting(NSDecimalNumber.init(string: output.value ?? "0"))
                            }
                        }
                        tempModel.transaction_value = result.int64Value
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
            tempModels.append(item)
            
        }
        return tempModels
    }
    func dealLibraTransactions(models: [LibraDataModel], walletAddress: String) -> [LibraDataModel] {
            var tempModels = [LibraDataModel]()
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
                    item.module_name = "libra"
                }
                tempModels.append(item)
                
            }
            return tempModels
        }
}
