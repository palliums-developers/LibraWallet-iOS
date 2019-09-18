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
enum mainRequest {
    /// 获取测试币
    case GetTestCoin(String, Int64)
    /// 获取交易记录
    case GetTransactionHistory(String, Int64)
}
extension mainRequest:TargetType {
    var baseURL: URL {
        switch self {
        case .GetTransactionHistory(_, _):
            return URL(string:"https://libraservice2.kulap.io")!
        default:
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
        }
    }
    var method: Moya.Method {
        switch self {
        // 获取测试币
        case .GetTestCoin(_, _),
             .GetTransactionHistory(_, _):
            return .post
            
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
        // 获取测试币
        case .GetTestCoin(let address, let amount):
            return .requestParameters(parameters: ["address": address,
                                                   "amount": amount],
                                      encoding: URLEncoding.queryString)
        // 获取测试币
        case .GetTransactionHistory(let address, _):
            return .requestParameters(parameters: ["address": address],
                                      encoding: JSONEncoding.default)
        }
    }
    var headers: [String : String]? {
        return ["Content-Type":"application/json"]
    }
}
