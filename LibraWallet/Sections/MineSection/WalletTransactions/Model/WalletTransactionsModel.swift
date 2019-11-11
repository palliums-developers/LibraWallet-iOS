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
struct transaction: Codable {
    var version: Int?
    var address: String?
    var value: Int?
    var sequence_number: Int?
    var expiration_time: Int?
}
struct LibraModel: Codable {
    var code: Int?
    var message: String?
    var data: [transaction]?
}

class WalletTransactionsModel: NSObject {
    private var requests: [Cancellable] = []
    @objc var dataDic: NSMutableDictionary = [:]
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
                        let resultModel = self!.dealTransactionAmount(models: (json.data?.list)!, requestAddress: address)
                        
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
    /// 获取Libra交易记录
    /// - Parameters:
    ///   - address: 地址
    ///   - page: 页数
    ///   - pageSize: 数量
    func getViolasTransactionHistory(address: String, page: Int, pageSize: Int, requestStatus: Int) {
        let type = requestStatus == 0 ? "ViolasTransactionHistoryOrigin":"ViolasTransactionHistoryMore"
        let request = mainProvide.request(.GetViolasAccountTransactionList(address, page, pageSize)) {[weak self](result) in
                switch  result {
                case let .success(response):
                    do {
                        let json = try response.map(LibraModel.self)
                        let data = setKVOData(type: type, data: json.data)
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
    /// 获取Libra交易记录
    /// - Parameters:
    ///   - address: 地址
    ///   - page: 页数
    ///   - pageSize: 数量
    func getLibraTransactionHistory(address: String, page: Int, pageSize: Int, requestStatus: Int) {
        let type = requestStatus == 0 ? "LibraTransactionHistoryOrigin":"LibraTransactionHistoryMore"
        let request = mainProvide.request(.GetLibraAccountTransactionList(address, page, pageSize)) {[weak self](result) in
                switch  result {
                case let .success(response):
                    do {
                        let json = try response.map(LibraModel.self)
                        print(json)
                        let data = setKVOData(type: type, data: json.data)
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
}
