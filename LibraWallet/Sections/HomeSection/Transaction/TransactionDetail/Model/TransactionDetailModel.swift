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
                                                         value: amount.stringValue))
        let gas = getDecimalNumber(amount: NSDecimalNumber.init(value: (transaction.gas ?? 0)),
                                   scale: 4,
                                   unit: 1000000)
        tempArray.append(TransactionDetailDataModel.init(type: "CellNormal",
                                                         title: localLanguage(keyString: "wallet_transaction_detail_gas_title"),
                                                         value: gas.stringValue))
        
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
}

