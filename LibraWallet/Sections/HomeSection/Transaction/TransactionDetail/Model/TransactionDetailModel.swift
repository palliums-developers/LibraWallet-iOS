//
//  TransactionDetailModel.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/6/5.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit
struct TransactionDetailDataModel {
    var type: String
    var title: String
    var value: String
}
class TransactionDetailModel: NSObject {
    func getViolasTransactionsData(transaction: ViolasDataModel) -> [TransactionDetailDataModel] {
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
        tempArray.append(TransactionDetailDataModel.init(type: "CellNormal",
                                                         title: localLanguage(keyString: "wallet_transaction_detail_version_title"),
                                                         value: transaction.txid ?? "---"))
        return tempArray
    }
}

