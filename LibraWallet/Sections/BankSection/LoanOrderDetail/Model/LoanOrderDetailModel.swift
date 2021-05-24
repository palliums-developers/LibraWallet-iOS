//
//  LoanDetailModel.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/8/24.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit

struct LoanOrderDetailMainDataListModel: Codable {
    /// 清算数量
    var cleared: UInt64?
    /// 清算日期
    var date: Int?
    /// 抵扣数量
    var deductioned: UInt64?
    /// 订单状态
    var status: Int?
    var amount: UInt64?
}
struct LoanOrderDetailMainDataModel: Codable {
    /// 订单待还金额
    var balance: UInt64?
    /// 订单ID
    var id: String?
    /// 订单细节
    var list: [LoanOrderDetailMainDataListModel]?
    /// 订单名字
    var name: String?
    /// 订单利率
    var rate: Double?
    /// 订单币种Address
    var token_address: String?
    /// 订单币种Module
    var token_module: String?
    /// 订单币种名字
    var token_name: String?
    /// 订单币种展示名字
    var token_show_name: String?
}
struct LoanOrderDetailMainModel: Codable {
    var code: Int?
    var message: String?
    var data: LoanOrderDetailMainDataModel?
}

class LoanOrderDetailModel: NSObject {
    deinit {
        print("LoanOrderDetailModel销毁了")
    }
}
