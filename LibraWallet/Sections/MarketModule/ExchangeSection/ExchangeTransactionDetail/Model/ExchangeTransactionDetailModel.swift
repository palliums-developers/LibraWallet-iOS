//
//  ExchangeTransactionDetailModel.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/7/6.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit
import Moya
class ExchangeTransactionDetailModel: NSObject {
    func getCustomModel(model: ExchangeTransactionsDataModel) -> [TransactionDetailCustomDataModel] {
        //         汇率
        //         手续费
        //         矿工费用
        //         下单时间
        //         成交时间
        var tempModels = [TransactionDetailCustomDataModel]()
        let inputAmount = NSDecimalNumber.init(value: model.input_amount ?? 0)
        let outputAmount = NSDecimalNumber.init(value: model.output_amount ?? 0)
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
        tempModels.append(TransactionDetailCustomDataModel.init(name: localLanguage(keyString: "wallet_market_transaction_content_order_fee_title"),
                                                                value: "---"))
        tempModels.append(TransactionDetailCustomDataModel.init(name: localLanguage(keyString: "wallet_market_transaction_content_miner_fee_title"),
                                                                value: minerFees.stringValue))
        tempModels.append(TransactionDetailCustomDataModel.init(name: localLanguage(keyString: "wallet_market_transaction_content_order_time_title"),
                                                                value: timestampToDateString(timestamp: model.confirmed_time ?? 0, dateFormat: "yyyy-MM-dd HH:mm:ss")))
        tempModels.append(TransactionDetailCustomDataModel.init(name: localLanguage(keyString: "wallet_market_transaction_content_order_done_time_title"),
                                                                value: timestampToDateString(timestamp: model.confirmed_time ?? 0, dateFormat: "yyyy-MM-dd HH:mm:ss")))
        return tempModels
    }
}
