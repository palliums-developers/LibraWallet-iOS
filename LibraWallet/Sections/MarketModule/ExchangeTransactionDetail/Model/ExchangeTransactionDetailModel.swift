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
    func getCustomModel(model: AssetsPoolTransactionsDataModel) -> [TransactionDetailCustomDataModel] {
        //         汇率
        //         手续费
        //         矿工费用
        //         下单时间
        //         成交时间
        var tempModels = [TransactionDetailCustomDataModel]()
        let inputAmount = NSDecimalNumber.init(value: model.amounta ?? 0)
        let outputAmount = NSDecimalNumber.init(value: model.amountb ?? 0)
        let numberConfig = NSDecimalNumberHandler.init(roundingMode: .up,
                                                       scale: 4,
                                                       raiseOnExactness: false,
                                                       raiseOnOverflow: false,
                                                       raiseOnUnderflow: false,
                                                       raiseOnDivideByZero: false)
        let rate = outputAmount.dividing(by: inputAmount, withBehavior: numberConfig)
           tempModels.append(TransactionDetailCustomDataModel.init(name: localLanguage(keyString: "wallet_market_transaction_content_exchange_rate_title"),
                                                                   value: "1:\(rate.stringValue)"))
//        let amount = getDecimalNumber(amount: NSDecimalNumber.init(value: model.token ?? 0),
//                                      scale: 4,
//                                      unit: 1000000)
        tempModels.append(TransactionDetailCustomDataModel.init(name: localLanguage(keyString: "wallet_market_transaction_content_order_fee_title"),
                                                                value: "---"))
        tempModels.append(TransactionDetailCustomDataModel.init(name: localLanguage(keyString: "wallet_market_transaction_content_miner_fee_title"),
                                                                value: "---"))
        tempModels.append(TransactionDetailCustomDataModel.init(name: localLanguage(keyString: "wallet_market_transaction_content_order_time_title"),
                                                                value: timestampToDateString(timestamp: model.date ?? 0, dateFormat: "yyyy-MM-dd HH:mm:ss")))
        tempModels.append(TransactionDetailCustomDataModel.init(name: localLanguage(keyString: "wallet_market_transaction_content_order_done_time_title"),
                                                                value: "---"))
        return tempModels
    }
}
