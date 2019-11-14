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
    /// 获取交易记录
    case GetTransactionHistory(String, Int64)
    /// 获取BTC余额记录
    case GetBTCBalance(String)
    /// 获取BTC交易记录
    case GetBTCTransactionHistory(String, Int, Int)
    /// 获取Libra账户余额
    case GetLibraAccountBalance(String)
    /// 获取Libra账户Sequence Number
    case GetLibraAccountSequenceNumber(String)
    /// 获取Libra账户交易记录(地址、偏移量、数量)
    case GetLibraAccountTransactionList(String, Int, Int)
    /// 发送Libra交易
    case SendLibraTransaction(String)
    /// 获取Violas账户余额
    case GetViolasAccountBalance(String)
    /// 获取Violas账户Sequence Number
    case GetViolasAccountSequenceNumber(String)
    /// 获取Violas账户交易记录(地址、偏移量、数量)
    case GetViolasAccountTransactionList(String, Int, Int)
    /// 发送Violas交易
    case SendViolasTransaction(String)
    /// 获取代币
    case GetViolasTokenList
}
extension mainRequest:TargetType {
    var baseURL: URL {
        switch self {
        case .GetTransactionHistory(_, _):
            return URL(string:"https://libraservice2.kulap.io")!
        case .GetBTCBalance(_), .GetBTCTransactionHistory(_, _, _):
            return URL(string:"https://tchain.api.btc.com/v3")!
        case .GetLibraAccountBalance(_),
             .GetLibraAccountSequenceNumber(_),
             .GetLibraAccountTransactionList(_),
             .SendLibraTransaction(_):
            return URL(string:"http://52.27.228.84:4000/1.0")!
        case .GetViolasAccountBalance(_),
             .GetViolasAccountSequenceNumber(_),
             .GetViolasAccountTransactionList(_),
             .SendViolasTransaction(_),
             .GetViolasTokenList:
        return URL(string:"http://52.27.228.84:4000/1.0")!
        case .GetTestCoin(_, _):
            return URL(string:"http://faucet.testnet.libra.org/")!
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
        case .GetLibraAccountBalance(_):
            return "/libra/balance"
        case .GetLibraAccountSequenceNumber(_):
            return "/libra/seqnum"
        case .GetLibraAccountTransactionList(_):
            return "/libra/transaction"
        case .SendLibraTransaction(_):
            return "/libra/transaction"
        case .GetViolasAccountBalance(_):
            return "/violas/balance"
        case .GetViolasAccountSequenceNumber(_):
            return "/violas/seqnum"
        case .GetViolasAccountTransactionList(_):
            return "/violas/transaction"
        case .SendViolasTransaction(_):
            return "/violas/transaction"
        case .GetViolasTokenList:
            return "/violas/currency"
        }
    }
    var method: Moya.Method {
        switch self {
        case .GetTestCoin(_, _),
             .GetTransactionHistory(_, _),
             .SendLibraTransaction(_),
             .SendViolasTransaction(_):
            return .post
        case .GetBTCBalance(_),
             .GetBTCTransactionHistory(_),
             .GetLibraAccountBalance(_),
             .GetLibraAccountSequenceNumber(_),
             .GetLibraAccountTransactionList(_),
             .GetViolasAccountBalance(_),
             .GetViolasAccountSequenceNumber(_),
             .GetViolasAccountTransactionList(_),
             .GetViolasTokenList:
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
        case .GetViolasAccountTransactionList(_):
            return "{\"code\":2000,\"message\":\"ok\",\"data\":[{\"version\":1,\"address\":\"address\",\"value\":100,\"sequence_number\":1,\"expiration_time\":1572771944},{\"version\":2,\"address\":\"address\",\"value\":100,\"sequence_number\":2,\"expiration_time\":1572771224}]}".data(using: String.Encoding.utf8)!
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
        // 获取测试币(暂废)
        case .GetTransactionHistory(let address, _):
            return .requestParameters(parameters: ["address": address],
                                      encoding: JSONEncoding.default)
        // 获取BTC余额
        case .GetBTCBalance(_):
            return .requestPlain
        // 获取BTC交易历史
        case .GetBTCTransactionHistory(_, let page, let pageSize):
            return .requestParameters(parameters: ["page": page,
                                                   "pagesize":pageSize],
                                      encoding: URLEncoding.queryString)
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
                                      encoding: URLEncoding.queryString)
        case .GetViolasAccountBalance(let address):
            return .requestParameters(parameters: ["addr": address],
                                      encoding: URLEncoding.queryString)
        case .GetViolasAccountSequenceNumber(let address):
            return .requestParameters(parameters: ["addr": address],
                                      encoding: URLEncoding.queryString)
        case .GetViolasAccountTransactionList(let address, let offset, let limit):
            return .requestParameters(parameters: ["addr": address,
                                                   "limit": offset,
                                                   "offset":limit],
                                      encoding: URLEncoding.queryString)
        case .SendViolasTransaction(let signature):
            return .requestParameters(parameters: ["signedtxn": signature],
                                      encoding: URLEncoding.queryString)
        case .GetViolasTokenList:
            return .requestPlain
        }
    }
    var headers: [String : String]? {
        return ["Content-Type":"application/json"]
    }
}
