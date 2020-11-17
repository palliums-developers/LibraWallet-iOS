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
    /// 获取BTC价格
    case GetBTCPrice
    case GetLibraPrice(String)
    /// 激活Libra（临时）
    case ActiveLibraAccount(String)
}
extension mainRequest:TargetType {
    var baseURL: URL {
        switch self {
        case .GetLibraTransactions(_, _, _, _, _),
             .GetLibraTokenList,
             .GetBTCPrice,
             .GetLibraPrice(_),
             .ActiveLibraAccount(_):
            if PUBLISH_VERSION == true {
                return URL(string:"https://api.violas.io")!
            } else {
                return URL(string:"https://api4.violas.io")!
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
        case .GetBTCPrice:
            return "/1.0/violas/value/btc"
        case .GetLibraPrice(_):
            return "/1.0/violas/value/libra"
        case .ActiveLibraAccount(_):
            return "/1.0/libra/mint"
        }
    }
    var method: Moya.Method {
        switch self {
        case .SendLibraTransaction(_),
             .GetLibraAccountBalance(_):
            return .post
        case .GetLibraTransactions(_, _, _, _, _),
             .GetLibraTokenList,
             .GetBTCPrice,
             .GetLibraPrice(_),
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
        case .GetBTCPrice:
            return .requestPlain
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
