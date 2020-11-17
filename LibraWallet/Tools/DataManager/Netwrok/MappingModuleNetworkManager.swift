//
//  MappingModuleNetworkManager.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/11/17.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit
import Moya
import Localize_Swift

let mappingModuleProvide = MoyaProvider<MappingModuleRequest>()
//let mainProvide = MoyaProvider<mainRequest>(stubClosure: MoyaProvider.immediatelyStub)
enum MappingModuleRequest {
    /// 查询映射信息
    case mappingInfo
    /// 获取当前已开启映射币（钱包地址）
    case mappingTokenList(String)
    /// 获取映射交易记录（钱包地址、偏移量、数量）
    case mappingTransactions(String, Int, Int)
    /// 获取BTC映射交易（钱包地址、偏移量、数量）（临时）
    case BTCCrossChainTransactions(String, Int, Int)
    /// 获取Violas映射交易（钱包地址、偏移量、数量）（临时）
    case ViolasCrossChainTransactions(String, Int, Int)
    /// 获取Libra映射交易（钱包地址、偏移量、数量）（临时）
    case LibraCrossChainTransactions(String, Int, Int)
}
extension MappingModuleRequest:TargetType {
    var baseURL: URL {
        switch self {
        case .mappingInfo,
             .mappingTokenList(_),
             .mappingTransactions(_, _, _):
            if PUBLISH_VERSION == true {
                return URL(string:"https://api.violas.io")!
            } else {
                return URL(string:"https://api4.violas.io")!
            }
        case .BTCCrossChainTransactions(_, _, _),
             .ViolasCrossChainTransactions(_, _, _),
             .LibraCrossChainTransactions(_, _, _):
            return URL(string:"http://18.136.139.151")!
        }
    }
    var path: String {
        switch self {
        case .mappingInfo:
            return "/1.0/mapping/address/info"
        case .mappingTokenList(_):
            return "/1.0/crosschain/modules"
        case .mappingTransactions(_, _, _):
            return "/1.0/mapping/transaction"
        case .BTCCrossChainTransactions(_, _, _):
            return "/"
        case .ViolasCrossChainTransactions(_, _, _):
            return "/"
        case .LibraCrossChainTransactions(_, _, _):
            return "/"
        }
    }
    var method: Moya.Method {
        switch self {
        case .mappingInfo,
             .mappingTokenList(_),
             .mappingTransactions(_, _, _),
             .BTCCrossChainTransactions(_, _, _),
             .ViolasCrossChainTransactions(_, _, _),
             .LibraCrossChainTransactions(_, _, _):
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
        case .mappingInfo:
            return .requestPlain
        case .mappingTokenList(let walletAddress):
            return .requestParameters(parameters: ["address": walletAddress],
                                      encoding: URLEncoding.queryString)
        case .mappingTransactions(let walletAddress, let offset, let limit):
            return .requestParameters(parameters: ["address": walletAddress,
                                                   "limit": limit,
                                                   "offset":offset],
                                      encoding: URLEncoding.queryString)
        case .BTCCrossChainTransactions(let address, let page, let offset):
            return .requestParameters(parameters: ["opt":"record",
                                                   "sender":address,
                                                   "chain":"btc",
                                                   "cursor":page,
                                                   "limit":offset],
                                      encoding: URLEncoding.queryString)
        case .ViolasCrossChainTransactions(let address, let page, let offset):
            return .requestParameters(parameters: ["opt":"record",
                                                   "sender":address,
                                                   "chain":"violas",
                                                   "cursor":page,
                                                   "limit":offset],
                                      encoding: URLEncoding.queryString)
        case .LibraCrossChainTransactions(let address, let page, let offset):
            return .requestParameters(parameters: ["opt":"record",
                                                   "sender":address,
                                                   "chain":"libra",
                                                   "cursor":page,
                                                   "limit":offset],
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
