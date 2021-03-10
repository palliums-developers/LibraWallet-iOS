//
//  BankModuleNetworkManager.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/11/17.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit
import Moya
import Localize_Swift

let bankModuleProvide = MoyaProvider<BankModuleRequest>()
/// 数字银行
enum BankModuleRequest {
    /// 银行账户详情（钱包地址）
    case bankAccountInfo(String)
    /// 存款市场
    case depositMarket
    /// 借款市场
    case loanMarket
    /// 存款订单详情（订单ID、钱包地址）
    case depositItemDetail(String, String)
    /// 贷款订单详情（订单ID、钱包地址）
    case loanItemDetail(String, String)
    /// 获取存款订单信息（钱包地址、offset、limit）
    case depositTransactions(String, Int, Int)
    /// 获取借贷订单信息（钱包地址、offset、limit）
    case loanTransactions(String, Int, Int)
    /// 借款订单详情（钱包地址、订单ID、请求类型（0:借贷明细 1:还款明细 2: 清算明细）、offset、limit）
    case loanTransactionDetail(String, String, Int, Int, Int)
    /// 存款订单列表（钱包地址、currency、status、offset、limit）
    case depositList(String, String, Int, Int, Int)
    /// 借款订单列表（钱包地址、currency、status、offset、limit）
    case loanList(String, String, Int, Int, Int)
    /// 获取借款还款详情（钱包地址、借款订单ID）
    case loanRepaymentDetail(String, String)
    /// 获取存款提款详情（钱包地址、存款ID）
    case depositWithdrawDetail(String, String)
    /// 存款交易上链（钱包地址、产品ID、数量、签名）
    case depositTransactiondSubmit(String, String, UInt64, String)
    /// 取款交易上链（钱包地址、产品ID、数量、签名）
    case withdrawTransactiondSubmit(String, String, UInt64, String)
    /// 贷款交易上链（钱包地址、产品ID、数量、签名）
    case loanTransactiondSubmit(String, String, UInt64, String)
    /// 还款交易上链（钱包地址、产品ID、数量、签名）
    case repaymentTransactiondSubmit(String, String, UInt64, String)
}
extension BankModuleRequest:TargetType {
    var baseURL: URL {
        switch self {
        //数字银行
        case .bankAccountInfo(_),
             .depositMarket,
             .loanMarket,
             .depositItemDetail(_, _),
             .loanItemDetail(_, _),
             .depositTransactions(_, _, _),
             .loanTransactions(_, _, _),
             .loanTransactionDetail(_, _, _, _, _),
             .depositList(_, _, _, _, _),
             .loanList(_, _, _, _, _),
             .loanRepaymentDetail(_, _),
             .depositWithdrawDetail(_, _),
             .depositTransactiondSubmit(_, _, _, _),
             .withdrawTransactiondSubmit(_, _, _, _),
             .loanTransactiondSubmit(_, _, _, _),
             .repaymentTransactiondSubmit(_, _, _, _):
            return URL(string:VIOLAS_PUBLISH_NET.serviceURL)!
        }
    }
    var path: String {
        switch self {
        case .bankAccountInfo(_):
            return "/1.0/violas/bank/account/info"
        case .depositMarket:
            return "/1.0/violas/bank/product/deposit"
        case .loanMarket:
            return "/1.0/violas/bank/product/borrow"
        case .depositItemDetail(_, _):
            return "/1.0/violas/bank/deposit/info"
        case .loanItemDetail(_, _):
            return "/1.0/violas/bank/borrow/info"
        case .depositTransactions(_, _, _):
            return "/1.0/violas/bank/deposit/orders"
        case .loanTransactions(_, _, _):
            return "/1.0/violas/bank/borrow/orders"
        case .loanTransactionDetail(_, _, _, _, _):
            return "/1.0/violas/bank/borrow/order/detail"
        case .depositList(_, _, _, _, _):
            return "/1.0/violas/bank/deposit/order/list"
        case .loanList(_, _, _, _, _):
            return "/1.0/violas/bank/borrow/order/list"
        case .loanRepaymentDetail(_, _):
            return "/1.0/violas/bank/borrow/repayment"
        case .depositWithdrawDetail(_, _):
            return "/1.0/violas/bank/deposit/withdrawal"
        case .depositTransactiondSubmit(_, _, _, _):
            return "/1.0/violas/bank/deposit"
        case .withdrawTransactiondSubmit(_, _, _, _):
            return "/1.0/violas/bank/deposit/withdrawal"
        case .loanTransactiondSubmit(_, _, _, _):
            return "/1.0/violas/bank/borrow"
        case .repaymentTransactiondSubmit(_, _, _, _):
            return "/1.0/violas/bank/borrow/repayment"
        }
    }
    var method: Moya.Method {
        switch self {
        case .depositTransactiondSubmit(_, _, _, _),
             .withdrawTransactiondSubmit(_, _, _, _),
             .loanTransactiondSubmit(_, _, _, _),
             .repaymentTransactiondSubmit(_, _, _, _):
            return .post
        case .bankAccountInfo(_),
             .depositMarket,
             .loanMarket,
             .depositItemDetail(_, _),
             .loanItemDetail(_, _),
             .depositTransactions(_, _, _),
             .loanTransactions(_, _, _),
             .loanTransactionDetail(_, _, _, _, _),
             .depositList(_, _, _, _, _),
             .loanList(_, _, _, _, _),
             .loanRepaymentDetail(_, _),
             .depositWithdrawDetail(_, _):
            return .get
        }
    }
    public var validate: Bool {
        return false
    }
    var sampleData: Data {
        switch self {
        default:
            return "{}".data(using: String.Encoding.utf8)!
        }
    }
    var task: Task {
        switch self {
        case .bankAccountInfo(let address):
            return .requestParameters(parameters: ["address":address],
                                      encoding: URLEncoding.queryString)
        case .depositMarket:
            return .requestPlain
        case .loanMarket:
            return .requestPlain
        case .depositItemDetail(let id, let address):
            return .requestParameters(parameters: ["id":id,
                                                   "address": address],
                                      encoding: URLEncoding.queryString)
        case .loanItemDetail(let id, let address):
            return .requestParameters(parameters: ["id":id,
                                                   "address": address],
                                      encoding: URLEncoding.queryString)
        case .depositTransactions(let address, let page, let limit):
            return .requestParameters(parameters: ["address": address,
                                                   "offset": page,
                                                   "limit": limit],
                                      encoding: URLEncoding.queryString)
        case .loanTransactions(let address, let page, let limit):
            return .requestParameters(parameters: ["address": address,
                                                   "offset": page,
                                                   "limit": limit],
                                      encoding: URLEncoding.queryString)
        case .loanTransactionDetail(let address, let orderID, let requestType, let page, let limit):
            return .requestParameters(parameters: ["address": address,
                                                   "id": orderID,
                                                   "q": requestType,
                                                   "offset": page,
                                                   "limit": limit],
                                      encoding: URLEncoding.queryString)
        case .depositList(let address, let currency, let status, let page, let limit):
            var dic = [String : Any]()
            if status != 999999 && currency.isEmpty == false {
                dic = ["address": address,
                       "currency": currency,
                       "status": status,
                       "offset": page,
                       "limit": limit]
            } else if status == 999999 && currency.isEmpty == false {
                dic = ["address": address,
                       "currency": currency,
                       "offset": page,
                       "limit": limit]
            } else if status != 999999 && currency.isEmpty == true {
                dic = ["address": address,
                       "status": status,
                       "offset": page,
                       "limit": limit]
            } else if status == 999999 && currency.isEmpty == true {
                dic = ["address": address,
                       "offset": page,
                       "limit": limit]
            }
            return .requestParameters(parameters: dic,
                                      encoding: URLEncoding.queryString)
        case .loanList(let address, let currency, let status, let page, let limit):
            var dic = [String: Any]()
            if status != 999999 && currency.isEmpty == false {
                dic = ["address": address,
                       "currency": currency,
                       "status": status,
                       "offset": page,
                       "limit": limit]
            } else if status == 999999 && currency.isEmpty == false {
                dic = ["address": address,
                       "currency": currency,
                       "offset": page,
                       "limit": limit]
            } else if status != 999999 && currency.isEmpty == true {
                dic = ["address": address,
                       "status": status,
                       "offset": page,
                       "limit": limit]
            } else if status == 999999 && currency.isEmpty == true {
                dic = ["address": address,
                       "offset": page,
                       "limit": limit]
            }
            return .requestParameters(parameters: dic,
                                      encoding: URLEncoding.queryString)
        case .loanRepaymentDetail(let address, let orderID):
            return .requestParameters(parameters: ["address": address,
                                                   "id": orderID],
                                      encoding: URLEncoding.queryString)
        case .depositWithdrawDetail(let address, let orderID):
            return .requestParameters(parameters: ["address": address,
                                                   "id": orderID],
                                      encoding: URLEncoding.queryString)
        case .depositTransactiondSubmit(let address, let productID, let amount, let signature):
            return .requestParameters(parameters: ["address": address,
                                                   "product_id": productID,
                                                   "value": amount,
                                                   "sigtxn": signature],
                                      encoding: JSONEncoding.default)
        case .withdrawTransactiondSubmit(let address, let productID, let amount, let signature):
            return .requestParameters(parameters: ["address": address,
                                                   "product_id": productID,
                                                   "value": amount,
                                                   "sigtxn": signature],
                                      encoding: JSONEncoding.default)
        case .loanTransactiondSubmit(let address, let productID, let amount, let signature):
            return .requestParameters(parameters: ["address": address,
                                                   "product_id": productID,
                                                   "value": amount,
                                                   "sigtxn": signature],
                                      encoding: JSONEncoding.default)
        case .repaymentTransactiondSubmit(let address, let productID, let amount, let signature):
            return .requestParameters(parameters: ["address": address,
                                                   "product_id": productID,
                                                   "value": amount,
                                                   "sigtxn": signature],
                                      encoding: JSONEncoding.default)
        }
    }
    var headers: [String : String]? {
        return ["Content-Type":"application/json",
                "versionName": appversion,
                "platform": "ios",
                "bundleId":bundleID!,
                "language":Localize.currentLanguage(),
                "chainId":"\(VIOLAS_PUBLISH_NET.chainId)"]
    }
}
