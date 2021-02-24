//
//  MarketModuleNetworkManager.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/11/17.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit
import Moya
import Localize_Swift

let marketModuleProvide = MoyaProvider<MarketModuleRequest>()
/// 交易所
enum MarketModuleRequest {
    /// 获取兑换交易记录（钱包地址、offset、limit）
    case exchangeTransactions(String, Int, Int)
    /// 获取资金池交易记录（钱包地址、offset、limit）
    case assetsPoolTransactions(String, Int, Int)
    /// 获取交易支持稳定币
    case marketSupportTokens
    /// 获取我的通证（钱包地址）
    case marketMineTokens(String)
    /// 获取资金池转出试算（钱包地址、输入Module、输出Module、数量）
    case assetsPoolTransferOutInfo(String, String, String, Int64)
    /// 获取资金池转入试算（输入Module、输出Module、数量）
    case assetsPoolTransferInInfo(String, String, Int64)
    /// 获取兑换试算（输入Module、输出Module、数量）
    case exchangeTransferInfo(String, String, Int64)
    /// 获取交易所支持映射币
    case marketSupportMappingTokens
    /// 获取资金池流动性（输入Module、输出Module）
    case poolLiquidity(String, String)
    /// 获取资金池全部流动性
    case poolTotalLiquidity
}
extension MarketModuleRequest: TargetType {
    var baseURL: URL {
        switch self {
        //数字银行
        case .exchangeTransactions(_, _, _),
             .assetsPoolTransactions(_, _, _),
             .marketSupportTokens,
             .marketMineTokens(_),
             .assetsPoolTransferOutInfo(_, _, _, _),
             .assetsPoolTransferInInfo(_, _, _),
             .exchangeTransferInfo(_, _, _),
             .marketSupportMappingTokens,
             .poolLiquidity(_, _),
             .poolTotalLiquidity:
            return URL(string:VIOLAS_PUBLISH_NET.serviceURL)!
        }
    }
    var path: String {
        switch self {
        case .exchangeTransactions(_, _, _):
            return "/1.0/market/exchange/transaction"
        case .assetsPoolTransactions(_, _, _):
            return "/1.0/market/pool/transaction"
        case .marketSupportTokens:
            return "/1.0/market/exchange/currency"
        case .marketMineTokens(_):
            return "/1.0/market/pool/info"
        case .assetsPoolTransferOutInfo(_, _, _, _):
            return "/1.0/market/pool/withdrawal/trial"
        case .assetsPoolTransferInInfo(_, _, _):
            return "/1.0/market/pool/deposit/trial"
        case .exchangeTransferInfo(_, _, _):
            return "/1.0/market/exchange/trial"
        case .marketSupportMappingTokens:
            return "/1.0/market/exchange/crosschain/address/info"
        case .poolLiquidity(_, _):
            return "/1.0/market/pool/reserve/info"
        case .poolTotalLiquidity:
            return "/1.0/market/pool/reserve/infos"
        }
    }
    var method: Moya.Method {
        switch self {
        case .exchangeTransactions(_, _, _),
             .assetsPoolTransactions(_, _, _),
             .marketSupportTokens,
             .marketMineTokens(_),
             .assetsPoolTransferOutInfo(_, _, _, _),
             .assetsPoolTransferInInfo(_, _, _),
             .exchangeTransferInfo(_, _, _),
             .marketSupportMappingTokens,
             .poolLiquidity(_, _),
             .poolTotalLiquidity:
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
        case .exchangeTransactions(let address, let offset, let limit):
            return .requestParameters(parameters: ["address": address,
                                                   "limit": limit,
                                                   "offset":offset],
                                      encoding: URLEncoding.queryString)
        case .assetsPoolTransactions(let address, let offset, let limit):
            return .requestParameters(parameters: ["address": address,
                                                   "limit": limit,
                                                   "offset":offset],
                                      encoding: URLEncoding.queryString)
        case .marketSupportTokens:
            return .requestPlain
        case .marketMineTokens(let address):
            return .requestParameters(parameters: ["address": address],
                                      encoding: URLEncoding.queryString)
        case .assetsPoolTransferOutInfo(let address, let coinA, let coinB, let amount):
            return .requestParameters(parameters: ["address": address,
                                                   "coin_a":coinA,
                                                   "coin_b":coinB,
                                                   "amount":amount],
                                      encoding: URLEncoding.queryString)
        case .assetsPoolTransferInInfo(let coinA, let coinB, let amount):
            return .requestParameters(parameters: ["coin_a":coinA,
                                                   "coin_b":coinB,
                                                   "amount":amount],
                                      encoding: URLEncoding.queryString)
        case .exchangeTransferInfo(let coinA, let coinB, let amount):
            return .requestParameters(parameters: ["currencyIn":coinA,
                                                   "currencyOut":coinB,
                                                   "amount":amount],
                                      encoding: URLEncoding.queryString)
        case .marketSupportMappingTokens:
            return .requestPlain
        case .poolLiquidity(let coinA, let coinB):
            return .requestParameters(parameters: ["coin_a":coinA,
                                                   "coin_b":coinB],
                                      encoding: URLEncoding.queryString)
        case .poolTotalLiquidity:
            return .requestPlain
        }
    }
    var headers: [String : String]? {
        return ["Content-Type":"application/json",
                "versionName": appversion,
                "platform": "ios",
                "bundleId":bundleID!,
                "language":Localize.currentLanguage(),
                "chainId":"2"]
    }
}
