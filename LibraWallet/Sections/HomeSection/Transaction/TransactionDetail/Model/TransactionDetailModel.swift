//
//  TransactionDetailModel.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/6/5.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit
import Moya

struct TransactionDetailDataModel {
    var type: String
    var title: String
    var value: String
}
struct MessageTransactionDetailMainModel: Codable {
    var code: Int?
    var message: String?
    var data: ViolasDataModel?
}
class TransactionDetailModel: NSObject {
    private var requests: [Cancellable] = []
    deinit {
        requests.forEach { cancellable in
            cancellable.cancel()
        }
        requests.removeAll()
        print("TransactionDetailModel销毁了")
    }
    func getViolasTransactionsData(transaction: ViolasDataModel) -> [TransactionDetailDataModel] {
        var tempArray = [TransactionDetailDataModel]()
        let amount = getDecimalNumber(amount: NSDecimalNumber.init(value: (transaction.amount ?? 0)),
                                            scale: 6,
                                            unit: 1000000)
        tempArray.append(TransactionDetailDataModel.init(type: "CellAmount",
                                                         title: localLanguage(keyString: "wallet_transaction_detail_amount_title"),
                                                         value: amount.stringValue + " " + (transaction.currency ?? "")))
        let gas = getDecimalNumber(amount: NSDecimalNumber.init(value: (transaction.gas ?? 0)),
                                   scale: 4,
                                   unit: 1000000)
        tempArray.append(TransactionDetailDataModel.init(type: "CellNormal",
                                                         title: localLanguage(keyString: "wallet_transaction_detail_gas_title"),
                                                         value: gas.stringValue + " " + (transaction.currency ?? "")))
        tempArray.append(TransactionDetailDataModel.init(type: "CellAddress",
                                                         title: localLanguage(keyString: "wallet_transaction_detail_transfer_address_title"),
                                                         value: transaction.sender ?? "---"))
        tempArray.append(TransactionDetailDataModel.init(type: "CellAddress",
                                                         title: localLanguage(keyString: "wallet_transaction_detail_receive_address_title"),
                                                         value: transaction.receiver ?? "---"))
        tempArray.append(TransactionDetailDataModel.init(type: "CellNormal",
                                                         title: localLanguage(keyString: "wallet_transaction_detail_version_title"),
                                                         value: "\(transaction.version ?? 0)"))
        return tempArray
    }
    func getLibraTransactionsData(transaction: LibraDataModel) -> [TransactionDetailDataModel] {
        var tempArray = [TransactionDetailDataModel]()
        let amount = getDecimalNumber(amount: NSDecimalNumber.init(value: (transaction.amount ?? 0)),
                                            scale: 4,
                                            unit: 1000000)
        tempArray.append(TransactionDetailDataModel.init(type: "CellAmount",
                                                         title: localLanguage(keyString: "wallet_transaction_detail_amount_title"),
                                                         value: amount.stringValue + " " + (transaction.currency ?? "")))
        let gas = getDecimalNumber(amount: NSDecimalNumber.init(value: (transaction.gas ?? 0)),
                                   scale: 4,
                                   unit: 1000000)
        tempArray.append(TransactionDetailDataModel.init(type: "CellNormal",
                                                         title: localLanguage(keyString: "wallet_transaction_detail_gas_title"),
                                                         value: gas.stringValue + " " + (transaction.currency ?? "")))
        tempArray.append(TransactionDetailDataModel.init(type: "CellAddress",
                                                         title: localLanguage(keyString: "wallet_transaction_detail_transfer_address_title"),
                                                         value: transaction.sender ?? "---"))
        tempArray.append(TransactionDetailDataModel.init(type: "CellAddress",
                                                         title: localLanguage(keyString: "wallet_transaction_detail_receive_address_title"),
                                                         value: transaction.receiver ?? "---"))
        tempArray.append(TransactionDetailDataModel.init(type: "CellNormal",
                                                         title: localLanguage(keyString: "wallet_transaction_detail_version_title"),
                                                         value: "\(transaction.version ?? 0)"))
        return tempArray
    }
    func getBTCTransactionsData(transaction: TrezorBTCTransactionDataModel, requestAddress: String) -> [TransactionDetailDataModel] {
        var tempArray = [TransactionDetailDataModel]()
        let amount = getDecimalNumber(amount: NSDecimalNumber.init(value: (transaction.transaction_value ?? 0)),
                                      scale: 4,
                                      unit: 100000000)
        tempArray.append(TransactionDetailDataModel.init(type: "CellAmount",
                                                         title: localLanguage(keyString: "wallet_transaction_detail_amount_title"),
                                                         value: amount.stringValue + " " + "BTC"))
        let gas = getDecimalNumber(amount: NSDecimalNumber.init(string: (transaction.fees ?? "0")),
                                   scale: 4,
                                   unit: 100000000)
        tempArray.append(TransactionDetailDataModel.init(type: "CellNormal",
                                                         title: localLanguage(keyString: "wallet_transaction_detail_gas_title"),
                                                         value: gas.stringValue + " " + "BTC"))
        var senderAddress = "---"
        if let inputs = transaction.vin, inputs.isEmpty == false {
            for input in inputs {
                for address in input.addresses ?? [""] {
                    if address == requestAddress {
                        senderAddress = requestAddress
                        break
                    }
                }
            }
            if senderAddress == "---" {
                senderAddress = inputs.first?.addresses?.first ?? "---"
            }
        }
        tempArray.append(TransactionDetailDataModel.init(type: "CellAddress",
                                                         title: localLanguage(keyString: "wallet_transaction_detail_transfer_address_title"),
                                                         value: senderAddress))
        tempArray.append(TransactionDetailDataModel.init(type: "CellAddress",
                                                         title: localLanguage(keyString: "wallet_transaction_detail_receive_address_title"),
                                                         value: transaction.vout?.first?.addresses?.first ?? "---"))
        tempArray.append(TransactionDetailDataModel.init(type: "CellAddress",
                                                         title: localLanguage(keyString: "wallet_transaction_detail_version_title"),
                                                         value: transaction.txid ?? "---"))
        return tempArray
    }
    func dealViolasTransactions(models: [ViolasDataModel], walletAddress: String) -> [ViolasDataModel] {
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
            if item.gas_currency == nil || item.gas_currency?.isEmpty == true {
                item.gas_currency = "XUS"
            }
            tempModels.append(item)
            
        }
        return tempModels
    }
}
extension TransactionDetailModel {
    func getMessageTransactionDetail(address: String, version: String, completion: @escaping (Result<ViolasDataModel, LibraWalletError>) -> Void) {
        let request = notificationModuleProvide.request(.getTransactionMessageDetail(address, version)) { (result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(MessageTransactionDetailMainModel.self)
                    print(try response.mapString())
                    if json.code == 2000 {
                        if let data = json.data {
                            let tempData = self.dealViolasTransactions(models: [data], walletAddress: WalletManager.shared.violasAddress ?? "")
                            completion(.success(tempData.first!))
                        } else {
                            completion(.failure(LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.parseJsonError)))
                        }
                    } else {
                        print("GetMessageTransactionDetail_状态异常")
                        if let message = json.message, message.isEmpty == false {
                            completion(.failure(LibraWalletError.error(message)))
                        } else {
                            completion(.failure(LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.dataCodeInvalid)))
                        }
                    }
                } catch {
                    print("GetMessageTransactionDetail_解析异常\(error.localizedDescription)")
                    completion(.failure(LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.parseJsonError)))
                }
            case let .failure(error):
                guard error.errorCode != -999 else {
                    print("GetMessageTransactionDetail_网络请求已取消")
                    return
                }
                print(error.localizedDescription)
                completion(.failure(LibraWalletError.WalletRequest(reason: .networkInvalid)))
            }
        }
        self.requests.append(request)
    }
}
