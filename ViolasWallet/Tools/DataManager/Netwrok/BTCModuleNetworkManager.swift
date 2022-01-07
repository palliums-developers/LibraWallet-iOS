//
//  BTCModuleNetworkManager.swift
//  ViolasWallet
//
//  Created by wangyingdong on 2020/11/17.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit
import Moya
import Localize_Swift
let BTCModuleProvide = MoyaProvider<BTCModuleRequest>()

//let mainProvide = MoyaProvider<BTCModuleRequest>(stubClosure: MoyaProvider.immediatelyStub)
enum BTCModuleRequest {
    /// TChain获取BTC余额记录（钱包地址）
    case TChainBTCBalance(String)
    /// TChain获取BTC交易记录
    case TChainBTCTransactions(String, Int, Int)
    /// TChain获取UTXO
    case TChainBTCUnspentUTXO(String)
    /// TChain发送BTC交易（交易签名）
    case TChainBTCPushTransaction(String)
    
    /// Trezor获取BTC余额记录（钱包地址）
    case TrezorBTCBalance(String)
    /// Trezor获取UTXO（钱包地址）
    case TrezorBTCUnspentUTXO(String)
    /// Trezor（钱包地址、页数、每页数量）
    case TrezorBTCTransactions(String, Int, Int)
    /// Trezor发送BTC交易（交易签名）
    case TrezorBTCPushTransaction(String)
    
    /// 获取BTC价格
    case price
}
extension BTCModuleRequest: TargetType {
    var baseURL: URL {
        switch self {
        case .TChainBTCBalance(_),
             .TChainBTCTransactions(_, _, _),
             .TChainBTCUnspentUTXO(_),
             .TChainBTCPushTransaction(_):
            return URL(string:"https://tchain.api.btc.com")!
        
        case .TrezorBTCBalance(_),
             .TrezorBTCUnspentUTXO(_),
             .TrezorBTCTransactions(_, _, _),
             .TrezorBTCPushTransaction:
            return URL(string:"https://tbtc1.trezor.io/api")!
            
        case .price:
            return URL(string:VIOLAS_PUBLISH_NET.serviceURL)!
        }
    }
    var path: String {
        switch self {
        case .TChainBTCBalance(let address):
            return "/v3/address/\(address)"
        case .TChainBTCTransactions(let address, _, _):
            return "/v3/address/\(address)/tx"
        case .TChainBTCUnspentUTXO(let address):
            return "/v3/address/\(address)/unspent"
        case .TChainBTCPushTransaction(_):
            return "/v3/tools/tx-publish"
            
        case .TrezorBTCBalance(let address):
            return "/v2/address/\(address)"
        case .TrezorBTCUnspentUTXO(let address):
            return "/v2/utxo/\(address)"
        case .TrezorBTCTransactions(let address, _, _):
            return "/v2/address/\(address)"
        case .TrezorBTCPushTransaction(let signature):
            return "/v2/sendtx/\(signature)"
            
        case .price:
            return "/1.0/violas/value/btc"
        }
    }
    var method: Moya.Method {
        switch self {
        case .TChainBTCPushTransaction(_):
            return .post
        case .TChainBTCBalance(_),
             .TChainBTCTransactions(_, _, _),
             .TChainBTCUnspentUTXO(_),
             
             .TrezorBTCBalance(_),
             .TrezorBTCUnspentUTXO(_),
             .TrezorBTCTransactions(_, _, _),
             .TrezorBTCPushTransaction(_),
             
             .price:
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
        case .TChainBTCBalance(_):
            return .requestPlain
        case .TChainBTCTransactions(_, let page, let pageSize):
            return .requestParameters(parameters: ["page": page,
                                                   "pagesize":pageSize],
                                      encoding: URLEncoding.queryString)
        case .TChainBTCUnspentUTXO(_):
            return .requestPlain
        case .TChainBTCPushTransaction(let signature):
            return .requestParameters(parameters: ["rawhex": signature],
                                      encoding: JSONEncoding.default)
            
        case .TrezorBTCBalance(_):
            return .requestPlain
        case .TrezorBTCUnspentUTXO(_):
            return .requestPlain
        case .TrezorBTCTransactions(_, let page, let pageSize):
            return .requestParameters(parameters: ["page": page,
                                                   "pageSize": pageSize,
                                                   "details":"txs"],
                                      encoding: URLEncoding.queryString)
        case .TrezorBTCPushTransaction(_):
            return .requestPlain
            
        case .price:
            return .requestPlain
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
