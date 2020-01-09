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
    /// 获取测试币
    case GetTestCoin(String, Int64)
    /// 获取Libra交易记录
    case GetTransactionHistory(String, Int64)
    /// 获取BTC余额记录
    case GetBTCBalance(String)
    /// 获取BTC交易记录
    case GetBTCTransactionHistory(String, Int, Int)
    /// 获取UTXO
    case GetBTCUnspentUTXO(String)
    /// 发送BTC交易
    case SendBTCTransaction(String)
    /// 获取Libra账户余额
    case GetLibraAccountBalance(String)
    /// 获取Libra账户Sequence Number
    case GetLibraAccountSequenceNumber(String)
    /// 获取Libra账户交易记录(地址、偏移量、数量)
    case GetLibraAccountTransactionList(String, Int, Int)
    /// 发送Libra交易
    case SendLibraTransaction(String)
    /// 获取Violas账户余额(钱包地址,代币地址(逗号分隔))
    case GetViolasAccountBalance(String, String)
    /// 获取Violas账户Sequence Number
    case GetViolasAccountSequenceNumber(String)
    /// 获取Violas账户交易记录(地址、偏移量、数量, 合约地址)
    case GetViolasAccountTransactionList(String, Int, Int, String)
    /// 发送Violas交易
    case SendViolasTransaction(String)
    /// 获取代币
    case GetViolasTokenList
    
    /// 获取钱包已开启代币列表
    case GetViolasAccountEnableToken(String)
    /// 获取交易所支持的代币列表
    case GetMarketSupportCoin
    /// 获取当前委托（地址、付出稳定币合约、兑换稳定币合约）
    case GetCurrentOrder(String, String, String)
    /// 获取当前进行中全部委托（地址、Version）
    case GetAllProcessingOrder(String, String)
    /// 获取订单详情(地址、页数)
    case GetOrderDetail(String, Int)
    /// 获取已完成订单
    case GetAllDoneOrder(String, String)
}
extension mainRequest:TargetType {
    var baseURL: URL {
        switch self {
        case .GetTransactionHistory(_, _):
            return URL(string:"https://libraservice2.kulap.io")!
        case .GetBTCBalance(_),
             .GetBTCTransactionHistory(_, _, _),
             .GetBTCUnspentUTXO(_),
             .SendBTCTransaction(_):
            return URL(string:"https://tchain.api.btc.com/v3")!
        case .GetLibraAccountBalance(_),
             .GetLibraAccountSequenceNumber(_),
             .GetLibraAccountTransactionList(_),
             .SendLibraTransaction(_):
            return URL(string:"http://52.27.228.84:4000/1.0")!
        case .GetViolasAccountBalance(_, _),
             .GetViolasAccountSequenceNumber(_),
             .GetViolasAccountTransactionList(_, _, _, _),
             .SendViolasTransaction(_),
             .GetViolasTokenList,
             .GetViolasAccountEnableToken(_):
            return URL(string:"http://52.27.228.84:4000/1.0")!
        case .GetTestCoin(_, _):
            return URL(string:"http://faucet.testnet.libra.org/")!
        case .GetMarketSupportCoin,
             .GetCurrentOrder(_, _, _),
             .GetAllProcessingOrder(_, _),
             .GetOrderDetail(_, _),
             .GetAllDoneOrder(_, _):
            return URL(string:"http://18.220.66.235:38181/v1")!
        }
    }
    var path: String {
        switch self {
        // 获取测试币
        case .GetTestCoin(_, _):
            return ""
        case .GetTransactionHistory(_, _):
            return "/transactionHistory"
        case .GetBTCBalance(let address):
            return "/address/\(address)"
        case .GetBTCTransactionHistory(let address, _, _):
            return "/address/\(address)/tx"
        case .GetBTCUnspentUTXO(let address):
            return "/address/\(address)/unspent"
        case .SendBTCTransaction(_):
            return "/tools/tx-publish"
        case .GetLibraAccountBalance(_):
            return "/libra/balance"
        case .GetLibraAccountSequenceNumber(_):
            return "/libra/seqnum"
        case .GetLibraAccountTransactionList(_):
            return "/libra/transaction"
        case .SendLibraTransaction(_):
            return "/libra/transaction"
        case .GetViolasAccountBalance(_, _):
            return "/violas/balance"
        case .GetViolasAccountSequenceNumber(_):
            return "/violas/seqnum"
        case .GetViolasAccountTransactionList(_, _, _, _):
            return "/violas/transaction"
        case .SendViolasTransaction(_):
            return "/violas/transaction"
        case .GetViolasTokenList:
            return "/violas/currency"
        case .GetMarketSupportCoin:
            return "/tokens"
        case .GetViolasAccountEnableToken(_):
            return "/violas/module"
        case .GetCurrentOrder(_, _, _):
            return "/orders"
        case .GetAllProcessingOrder(_, _):
            return "/orders"
        case .GetOrderDetail(_, _):
            return "/trades"
        case .GetAllDoneOrder(_, _):
            return "/orders"
        }
    }
    var method: Moya.Method {
        switch self {
        case .GetTestCoin(_, _),
             .GetTransactionHistory(_, _),
             .SendLibraTransaction(_),
             .SendViolasTransaction(_),
             .SendBTCTransaction(_):
            return .post
        case .GetBTCBalance(_),
             .GetBTCTransactionHistory(_),
             .GetBTCUnspentUTXO(_),
             .GetLibraAccountBalance(_),
             .GetLibraAccountSequenceNumber(_),
             .GetLibraAccountTransactionList(_),
             .GetViolasAccountBalance(_, _),
             .GetViolasAccountSequenceNumber(_),
             .GetViolasAccountTransactionList(_, _, _, _),
             .GetViolasTokenList,
             .GetMarketSupportCoin,
             .GetViolasAccountEnableToken(_),
             .GetCurrentOrder(_, _, _),
             .GetAllProcessingOrder(_, _),
             .GetOrderDetail(_, _),
             .GetAllDoneOrder(_, _):
            return .get
        }
    }
    public var validate: Bool {
        return false
    }
    var sampleData: Data {
        switch self {
        case .GetLibraAccountTransactionList(_):
            return "{\"code\":2000,\"message\":\"ok\",\"data\":[{\"version\":1,\"address\":\"f053480d94d09a00f77fec9975463bfd109ebeb0915d62822702f453cc87c809\",\"value\":100,\"sequence_number\":1,\"expiration_time\":1572771944},{\"version\":2,\"address\":\"address\",\"value\":100,\"sequence_number\":2,\"expiration_time\":1572771224}]}".data(using: String.Encoding.utf8)!
        default:
            return "{}".data(using: String.Encoding.utf8)!
        }
    }
    var task: Task {
        switch self {
        // 获取测试币(暂废)
        case .GetTestCoin(let address, let amount):
            return .requestParameters(parameters: ["address": address,
                                                   "amount": amount],
                                      encoding: URLEncoding.queryString)
        case .GetTransactionHistory(let address, _):
            return .requestParameters(parameters: ["address": address],
                                      encoding: JSONEncoding.default)
        case .GetBTCBalance(_):
            return .requestPlain
        case .GetBTCTransactionHistory(_, let page, let pageSize):
            return .requestParameters(parameters: ["page": page,
                                                   "pagesize":pageSize],
                                      encoding: URLEncoding.queryString)
        case .GetBTCUnspentUTXO(_):
            return .requestPlain
        case .SendBTCTransaction(let signature):
            return .requestParameters(parameters: ["rawhex": signature],
                                      encoding: JSONEncoding.default)
        case .GetLibraAccountBalance(let address):
            return .requestParameters(parameters: ["addr": address],
                                      encoding: URLEncoding.queryString)
        case .GetLibraAccountSequenceNumber(let address):
            return .requestParameters(parameters: ["addr": address],
                                      encoding: URLEncoding.queryString)
        case .GetLibraAccountTransactionList(let address, let offset, let limit):
            return .requestParameters(parameters: ["addr": address,
                                                   "limit": offset,
                                                   "offset":limit],
                                      encoding: URLEncoding.queryString)
        case .SendLibraTransaction(let signature):
            return .requestParameters(parameters: ["signedtxn": signature],
                                      encoding: JSONEncoding.default)
        case .GetViolasAccountBalance(let address, let modules):
            return .requestParameters(parameters: ["addr": address,
                                                   "modu": modules],
                                      encoding: URLEncoding.queryString)
        case .GetViolasAccountSequenceNumber(let address):
            return .requestParameters(parameters: ["addr": address],
                                      encoding: URLEncoding.queryString)
        case .GetViolasAccountTransactionList(let address, let offset, let limit, let contract):
            if contract.isEmpty == true {
                return .requestParameters(parameters: ["addr": address,
                                                       "limit": limit,
                                                       "offset":offset],
                                          encoding: URLEncoding.queryString)
            } else {
                return .requestParameters(parameters: ["addr": address,
                                                       "limit": limit,
                                                       "offset":offset,
                                                       "modu":contract],
                                          encoding: URLEncoding.queryString)
            }
        case .SendViolasTransaction(let signature):
            return .requestParameters(parameters: ["signedtxn": signature],
                                      encoding: JSONEncoding.default)
        case .GetViolasTokenList:
            return .requestPlain
        case .GetMarketSupportCoin:
            return .requestPlain
        case .GetViolasAccountEnableToken(let address):
            return .requestParameters(parameters: ["addr": address],
                                      encoding: URLEncoding.queryString)
        case .GetCurrentOrder(let address, let baseAddress, let changeAddress):
            return .requestParameters(parameters: ["user":address,
                                                   "base": baseAddress,
                                                   "quote":changeAddress],
                                      encoding: URLEncoding.queryString)
        case .GetAllProcessingOrder(let address, let version):
            if version.isEmpty == true {
                return .requestParameters(parameters: ["user": address,
                                                       "state":0,
                                                       "limit":10],
                                          encoding: URLEncoding.queryString)
            } else {
                return .requestParameters(parameters: ["user": address,
                                                       "state":0,
                                                       "limit":10,
                                                       "version":version],
                                          encoding: URLEncoding.queryString)
            }
        case .GetOrderDetail(let version, let page):
            return .requestParameters(parameters: ["version":version,
                                                   "pagesize":10,
                                                   "pagenum":page],
                                      encoding: URLEncoding.queryString)
        case .GetAllDoneOrder(let address, let version):
            if version.isEmpty == true {
                return .requestParameters(parameters: ["user": address,
                                                       "state":3,
                                                       "limit":10],
                                          encoding: URLEncoding.queryString)
            } else {
                return .requestParameters(parameters: ["user": address,
                                                       "state":3,
                                                       "limit":10,
                                                       "version":version],
                                          encoding: URLEncoding.queryString)
            }
        }
    }
    var headers: [String : String]? {
        return ["Content-Type":"application/json"]
    }
}
