//
//  LibraModuleNetworkManager.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/11/17.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit
import Moya
import Localize_Swift

let libraModuleProvide = MoyaProvider<LibraModuleRequest>()
//let mainProvide = MoyaProvider<mainRequest>(stubClosure: MoyaProvider.immediatelyStub)
enum LibraModuleRequest {
    /// 获取Libra账户信息（可获取钱包开启币、Sequence Number、账户余额）（钱包地址）（链上操作）
    case accountInfo(String)
    /// 发送Libra交易（链上操作）
    case sendTransaction(String)
    /// 获取Libra账户交易记录（地址、币名、请求类型（空：全部；0：转出；1：转入）、offset、limit）
    case accountTransactions(String, String, String, Int, Int)
    /// 获取Libra货币列表
    case currencyList
    /// 获取Libra链资产价格（钱包地址）
    case price(String)
    /// 激活Libra（钱包地址）（临时）
    case activeAccount(String)
}
extension LibraModuleRequest: TargetType {
    var baseURL: URL {
        switch self {
        case .accountInfo(_),
             .sendTransaction(_):
            return URL(string:"https://client.testnet.libra.org")!
        case .accountTransactions(_, _, _, _, _),
             .currencyList,
             .price(_),
             .activeAccount(_):
            if PUBLISH_VERSION == true {
                return URL(string:"https://api.violas.io")!
            } else {
                return URL(string:"https://api4.violas.io")!
            }
        }
    }
    var path: String {
        switch self {
        case .accountInfo(_):
            return ""
        case .sendTransaction(_):
            return ""
        case .accountTransactions(_, _, _, _, _):
            return "/1.0/libra/transaction"
        case .currencyList:
            return "/1.0/libra/currency"
        case .price(_):
            return "/1.0/violas/value/libra"
        case .activeAccount(_):
            return "/1.0/libra/mint"
        }
    }
    var method: Moya.Method {
        switch self {
        case .sendTransaction(_),
             .accountInfo(_):
            return .post
        case .accountTransactions(_, _, _, _, _),
             .currencyList,
             .price(_),
             .activeAccount(_):
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
        case .accountInfo(let address):
            return .requestParameters(parameters: ["jsonrpc":"2.0",
                                                   "method":"get_account",
                                                   "id":"123",
                                                   "params":["\(address)"]],
                                      encoding: JSONEncoding.default)
        case .sendTransaction(let signature):
            return .requestParameters(parameters: ["jsonrpc":"2.0",
                                                   "method":"submit",
                                                   "id":"123",
                                                   "params":["\(signature)"]],
                                      encoding: JSONEncoding.default)
        case .accountTransactions(let address, let currency, let type, let offset, let limit):
            return .requestParameters(parameters: ["addr": address,
                                                   "currency": currency,
                                                   "flows": type,
                                                   "limit": limit,
                                                   "offset":offset],
                                      encoding: URLEncoding.queryString)
        case .currencyList:
            return .requestPlain
        case .price(let address):
            return .requestParameters(parameters: ["address":address],
                                      encoding: URLEncoding.queryString)
        case .activeAccount(let authKey):
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
                "versionName": appversion,
                "platform": "ios",
                "bundleId":bundleID!,
                "language":Localize.currentLanguage()]
    }
}
