//
//  MarketModel.swift
//  LibraWallet
//
//  Created by palliums on 2019/11/6.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit
import Moya
struct MarketOrderDataModel: Codable {
    /// 用户ID
    var id: String?
    /// 用户
    var user: String?
    /// 状态（OPEN兑换中、FILLED已兑换、CANCELED已取消、CANCELLING取消中）
    var state: String?
    /// 将要兑换合约地址
    var tokenGet: String?
    /// 将要兑换名字
    var tokenGetSymbol: String?
    /// 将要兑换数量
    var amountGet: String?
    /// 付出合约地址
    var tokenGive: String?
    /// 付出名字
    var tokenGiveSymbol: String?
    /// 付出数量
    var amountGive: String?
    /// 交易编号
    var version: String?
    /// 日期
    var date: Int?
    /// 最后动作日期
    var update_date: Int?
    /// 最后交易编号
    var update_version: String?
    /// 已兑换数量
    var amountFilled: String?
    /// 付出稳定币价格
    var tokenGivePrice: Double?
    /// 兑换稳定币价格
    var tokenGetPrice: Double?
    /// 价格（自行添加）
//    var price: Double?
}
struct MarketOrderModel: Codable {
    var buys: [MarketOrderDataModel]?
    var sells: [MarketOrderDataModel]?
}
struct ViolasAccountEnableTokenResponseDataModel: Codable {
    var is_published: Int?
}
struct ViolasAccountEnableTokenResponseMainModel: Codable {
    var code: Int?
    var message: String?
    var data: ViolasAccountEnableTokenResponseDataModel?
}
struct MarketSupportCoinDataModel: Codable {
//    var addr: String?
    var name: String?
    var price: Double?
    var id: String?
    // 自行添加
    var enable: Bool?
}
struct MarketResponseMainModel: Codable {
    var orders: [MarketOrderDataModel]?
    var depths: MarketOrderModel?
    var price: Double?
}
class MarketModel: NSObject {
    private var requests: [Cancellable] = []
    @objc var dataDic: NSMutableDictionary = [:]
    deinit {
        requests.forEach { cancellable in
            cancellable.cancel()
        }
        requests.removeAll()
        print("MarketModel销毁了")
    }
}
