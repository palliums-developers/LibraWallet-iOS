//
//  NetworkManager.swift
//  LibraWallet
//
//  Created by palliums on 2019/9/17.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit
import Moya
import Localize_Swift
let mainProvide = MoyaProvider<mainRequest>()
//let mainProvide = MoyaProvider<mainRequest>(stubClosure: MoyaProvider.immediatelyStub)
enum mainRequest {
    
    /// 获取Libra账户余额
    case GetLibraAccountBalance(String)
    /// 获取Libra账户交易记录(地址、币名、请求类型（空：全部；0：转出；1：转入）、偏移量、数量)
    case GetLibraTransactions(String, String, String, Int, Int)
    /// 发送Libra交易
    case SendLibraTransaction(String)
    /// 获取Libra稳定币列表
    case GetLibraTokenList
    
    /// 获取Violas账户余额（钱包地址,代币地址（逗号分隔））
    case GetViolasAccountBalance(String, String)
    /// 获取Violas账户Sequence Number
    case GetViolasAccountSequenceNumber(String)
    /// 获取Violas账户交易记录（地址、币名、请求类型（空：全部；0：转出；1：转入）、偏移量、数量）
    case GetViolasTransactions(String, String, String, Int, Int)
    /// 发送Violas交易
    case SendViolasTransaction(String)
    /// 获取代币
    case GetViolasTokenList
    
    /// 获取Violas账户信息
    case GetViolasAccountInfo(String)
    /// 获取BTC价格
    case GetBTCPrice
    /// 获取Violas链资产价格（地址）
    case GetViolasPrice(String)
    /// 获取Libra链资产价格（地址）
    case GetLibraPrice(String)
    /// 激活Violas（临时）
    case ActiveViolasAccount(String)
    /// 激活Libra（临时）
    case ActiveLibraAccount(String)
}
extension mainRequest:TargetType {
    var baseURL: URL {
        switch self {
        case .GetLibraTransactions(_, _, _, _, _),
             .GetLibraTokenList,
             .GetBTCPrice,
             .GetViolasPrice(_),
             .GetLibraPrice(_),
             .ActiveLibraAccount(_),
             .ActiveViolasAccount(_):
            if PUBLISH_VERSION == true {
                return URL(string:"https://api.violas.io")!
            } else {
                return URL(string:"https://api4.violas.io")!
            }
        case .GetViolasAccountBalance(_, _),
             .GetViolasAccountSequenceNumber(_),
             .GetViolasTransactions(_, _, _, _, _),
             .GetViolasTokenList:
            if PUBLISH_VERSION == true {
                return URL(string:"https://api.violas.io")!
            } else {
                return URL(string:"https://api4.violas.io")!
            }
        case .GetViolasAccountInfo(_),
             .SendViolasTransaction(_):
            if PUBLISH_VERSION == true {
                //对外
                return URL(string:"https://ac.testnet.violas.io")!
            } else {
                //对内
                return URL(string:"https://ab.testnet.violas.io")!
            }
        case .GetLibraAccountBalance(_),
             .SendLibraTransaction(_):
            return URL(string:"https://client.testnet.libra.org")!
        }
    }
    var path: String {
        switch self {
        case .GetLibraAccountBalance(_):
            return ""
        case .GetLibraTransactions(_, _, _, _, _):
            return "/1.0/libra/transaction"
        case .SendLibraTransaction(_):
            return ""
        case .GetLibraTokenList:
            return "/1.0/libra/currency"
        case .GetViolasAccountBalance(_, _):
            return "/1.0/violas/balance"
        case .GetViolasAccountSequenceNumber(_):
            return "/1.0/violas/seqnum"
        case .GetViolasTransactions(_, _, _, _, _):
            return "/1.0/violas/transaction"
        case .SendViolasTransaction(_):
            return ""
        case .GetViolasTokenList:
            return "/1.0/violas/currency"
        case .GetViolasAccountInfo(_):
            return ""
        case .GetBTCPrice:
            return "/1.0/violas/value/btc"
        case .GetViolasPrice(_):
            return "/1.0/violas/value/violas"
        case .GetLibraPrice(_):
            return "/1.0/violas/value/libra"
        case .ActiveLibraAccount(_):
            return "/1.0/libra/mint"
        case .ActiveViolasAccount(_):
            return "/1.0/violas/mint"
        }
    }
    var method: Moya.Method {
        switch self {
        case .SendLibraTransaction(_),
             .SendViolasTransaction(_),
             .GetLibraAccountBalance(_),
             .GetViolasAccountInfo(_):
            return .post
        case .GetLibraTransactions(_, _, _, _, _),
             .GetViolasAccountBalance(_, _),
             .GetViolasAccountSequenceNumber(_),
             .GetViolasTransactions(_, _, _, _, _),
             .GetViolasTokenList,
             .GetLibraTokenList,
             .GetBTCPrice,
             .GetViolasPrice(_),
             .GetLibraPrice(_),
             .ActiveViolasAccount(_),
             .ActiveLibraAccount(_):
            return .get
        }
    }
    public var validate: Bool {
        return false
    }
    var sampleData: Data {
        switch self {
        case .GetLibraTransactions(_, _, _, _, _):
            return "{\"code\":2000,\"message\":\"ok\",\"data\":[{\"version\":1,\"address\":\"f053480d94d09a00f77fec9975463bfd109ebeb0915d62822702f453cc87c809\",\"value\":100,\"sequence_number\":1,\"expiration_time\":1572771944},{\"version\":2,\"address\":\"address\",\"value\":100,\"sequence_number\":2,\"expiration_time\":1572771224}]}".data(using: String.Encoding.utf8)!
        default:
            return "{}".data(using: String.Encoding.utf8)!
        }
    }
    var task: Task {
        switch self {
        case .GetLibraAccountBalance(let address):
            return .requestParameters(parameters: ["jsonrpc":"2.0",
                                                   "method":"get_account",
                                                   "id":"123",
                                                   "params":["\(address)"]],
                                      encoding: JSONEncoding.default)
        case .GetLibraTransactions(let address, let currency, let type, let offset, let limit):
            return .requestParameters(parameters: ["addr": address,
                                                   "currency": currency,
                                                   "flows": type,
                                                   "limit": limit,
                                                   "offset":offset],
                                      encoding: URLEncoding.queryString)
        case .SendLibraTransaction(let signature):
            return .requestParameters(parameters: ["jsonrpc":"2.0",
                                                   "method":"submit",
                                                   "id":"123",
                                                   "params":["\(signature)"]],
                                      encoding: JSONEncoding.default)
        case .GetLibraTokenList:
            return .requestPlain
        case .GetViolasAccountBalance(let address, let modules):
            return .requestParameters(parameters: ["addr": address,
                                                   "modu": modules],
                                      encoding: URLEncoding.queryString)
        case .GetViolasAccountSequenceNumber(let address):
            return .requestParameters(parameters: ["addr": address],
                                      encoding: URLEncoding.queryString)
        case .GetViolasTransactions(let address, let currency, let type, let offset, let limit):
            //            if type.isEmpty == true {
            //                return .requestParameters(parameters: ["addr": address,
            //                                                       "currency": currency,
            //                                                       "limit": limit,
            //                                                       "offset":offset],
            //                                          encoding: URLEncoding.queryString)
            //            } else {
            return .requestParameters(parameters: ["addr": address,
                                                   "currency": currency,
                                                   "flows": type,
                                                   "limit": limit,
                                                   "offset":offset],
                                      encoding: URLEncoding.queryString)
        //            }
        case .SendViolasTransaction(let signature):
            return .requestParameters(parameters: ["jsonrpc":"2.0",
                                                   "method":"submit",
                                                   "id":"123",
                                                   "params":["\(signature)"]],
                                      encoding: JSONEncoding.default)
        case .GetViolasTokenList:
            return .requestPlain
        case .GetViolasAccountInfo(let address):
            return .requestParameters(parameters: ["jsonrpc":"2.0",
                                                   "method":"get_account",
                                                   "id":"123",
                                                   "params":["\(address)"]],
                                      encoding: JSONEncoding.default)
        case .GetBTCPrice:
            return .requestPlain
        case .GetViolasPrice(let address):
            return .requestParameters(parameters: ["address":address],
                                      encoding: URLEncoding.queryString)
        case .GetLibraPrice(let address):
            return .requestParameters(parameters: ["address":address],
                                      encoding: URLEncoding.queryString)
        case .ActiveLibraAccount(let authKey):
            let index = authKey.index(authKey.startIndex, offsetBy: 32)
            let address = authKey.suffix(from: index)
            let authPrefix = authKey.prefix(upTo: index)
            return .requestParameters(parameters: ["address": address,
                                                   "auth_key_perfix": authPrefix,
                                                   "currency":"LBR"],
                                      encoding: URLEncoding.queryString)
        case .ActiveViolasAccount(let authKey):
            let index = authKey.index(authKey.startIndex, offsetBy: 32)
            let address = authKey.suffix(from: index)
            let authPrefix = authKey.prefix(upTo: index)
            return .requestParameters(parameters: ["address": address,
                                                   "auth_key_perfix": authPrefix,
                                                   "currency":"LBR"],
                                      encoding: URLEncoding.queryString)
        }
    }
    var headers: [String : String]? {
        return ["Content-Type":"application/json",
                "app_version": appversion,
                "platform": "ios",
                "app_bundle_id":bundleID!,
                "language":Localize.currentLanguage()]
    }
}
