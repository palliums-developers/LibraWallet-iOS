//
//  AssetsPoolTransactionDetailModel.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/7/9.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit
struct TransactionDetailCustomDataModel {
    var name: String
    var value: String
}
class AssetsPoolTransactionDetailModel: NSObject {
    func getCustomModel(model: AssetsPoolTransactionsDataModel) -> [TransactionDetailCustomDataModel] {
        var tempModels = [TransactionDetailCustomDataModel]()
        let amount = getDecimalNumber(amount: NSDecimalNumber.init(value: model.token ?? 0),
                                            scale: 6,
                                            unit: 1000000)
        tempModels.append(TransactionDetailCustomDataModel.init(name: localLanguage(keyString: "wallet_market_transaction_content_token_title"),
                                                           value: amount.stringValue))
        let inputAmount = NSDecimalNumber.init(value: model.amounta ?? 0)
        let outputAmount = NSDecimalNumber.init(value: model.amountb ?? 0)
        let numberConfig = NSDecimalNumberHandler.init(roundingMode: .up,
                                                       scale: 6,
                                                       raiseOnExactness: false,
                                                       raiseOnOverflow: false,
                                                       raiseOnUnderflow: false,
                                                       raiseOnDivideByZero: false)
        let rate = outputAmount.dividing(by: inputAmount, withBehavior: numberConfig)
        let minerFees = NSDecimalNumber.init(value: model.gas_used ?? 0).dividing(by: inputAmount, withBehavior: numberConfig)
        let rateValue = rate.stringValue == "NaN" ? "---":"1:\(rate.stringValue)"
        tempModels.append(TransactionDetailCustomDataModel.init(name: localLanguage(keyString: "wallet_market_transaction_content_exchange_rate_title"),
                                                                value: rateValue))
        tempModels.append(TransactionDetailCustomDataModel.init(name: localLanguage(keyString: "wallet_market_transaction_content_miner_fee_title"),
                                                                value: minerFees.stringValue))
        tempModels.append(TransactionDetailCustomDataModel.init(name: localLanguage(keyString: "wallet_market_transaction_content_order_time_title"),
                                                                value: timestampToDateString(timestamp: model.confirmed_time ?? 0, dateFormat: "yyyy-MM-dd HH:mm:ss")))
        tempModels.append(TransactionDetailCustomDataModel.init(name: localLanguage(keyString: "wallet_market_transaction_content_order_done_time_title"),
                                                                value: timestampToDateString(timestamp: model.confirmed_time ?? 0, dateFormat: "yyyy-MM-dd HH:mm:ss")))
        return tempModels
    }
}
