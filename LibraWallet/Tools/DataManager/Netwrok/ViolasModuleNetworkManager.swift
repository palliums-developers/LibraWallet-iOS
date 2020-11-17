//
//  ViolasModuleNetworkManager.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/11/17.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit
import Moya
import Localize_Swift

let violasModuleProvide = MoyaProvider<ViolasModuleRequest>()
//let mainProvide = MoyaProvider<mainRequest>(stubClosure: MoyaProvider.immediatelyStub)
enum ViolasModuleRequest {
    /// 获取Violas账户信息（可获取钱包开启币、Sequence Number、账户余额）（钱包地址）（链上操作）
    case accountInfo(String)
    /// 发送Violas交易（交易签名）（链上操作）
    case sendTransaction(String)
    /// 获取Violas账户余额（钱包地址、代币地址（逗号分隔））
    case accountBalance(String, String)
    /// 获取Violas账户Sequence Number
    case accountSequenceNumber(String)
    /// 获取Violas账户交易记录（地址、币名、请求类型（空：全部；0：转出；1：转入）、offset、limit）
    case accountTransactions(String, String, String, Int, Int)
    /// 获取Violas货币列表
    case currencyList
    /// 获取Violas链资产价格（钱包地址）
    case price(String)
    /// 激活Violas（临时）
    case activeAccount(String)
}
extension ViolasModuleRequest: TargetType {
    var baseURL: URL {
        switch self {
        case .accountInfo(_),
             .sendTransaction(_):
            if PUBLISH_VERSION == true {
                //对外
                return URL(string:"https://ac.testnet.violas.io")!
            } else {
                //对内
                return URL(string:"https://ab.testnet.violas.io")!
            }
        case .price(_),
             .activeAccount(_):
            if PUBLISH_VERSION == true {
                return URL(string:"https://api.violas.io")!
            } else {
                return URL(string:"https://api4.violas.io")!
            }
        case .accountBalance(_, _),
             .accountSequenceNumber(_),
             .accountTransactions(_, _, _, _, _),
             .currencyList:
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
        case .accountBalance(_, _):
            return "/1.0/violas/balance"
        case .accountSequenceNumber(_):
            return "/1.0/violas/seqnum"
        case .accountTransactions(_, _, _, _, _):
            return "/1.0/violas/transaction"
        case .currencyList:
            return "/1.0/violas/currency"
        case .price(_):
            return "/1.0/violas/value/violas"
        case .activeAccount(_):
            return "/1.0/violas/mint"
        }
    }
    var method: Moya.Method {
        switch self {
        case .accountInfo(_),
             .sendTransaction(_):
            return .post
        case .accountBalance(_, _),
             .accountSequenceNumber(_),
             .accountTransactions(_, _, _, _, _),
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
        case .accountBalance(let address, let modules):
            return .requestParameters(parameters: ["addr": address,
                                                   "modu": modules],
                                      encoding: URLEncoding.queryString)
        case .accountSequenceNumber(let address):
            return .requestParameters(parameters: ["addr": address],
                                      encoding: URLEncoding.queryString)
        case .accountTransactions(let address, let currency, let type, let offset, let limit):
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
                "app_version": appversion,
                "platform": "ios",
                "app_bundle_id":bundleID!,
                "language":Localize.currentLanguage()]
    }
}
