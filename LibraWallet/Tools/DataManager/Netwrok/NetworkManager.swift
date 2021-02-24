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
let mainProvide = MoyaProvider<MainRequest>()
//let mainProvide = MoyaProvider<mainRequest>(stubClosure: MoyaProvider.immediatelyStub)
enum MainRequest {
    
}
extension MainRequest:TargetType {
    var baseURL: URL {
        switch self {
//        case .walletMessages(_, _, _),
//             .systemMessages(_, _, _):
//            if PUBLISH_NET == true {
//                return URL(string:"https://api.violas.io")!
//            } else {
//                return URL(string:"https://api4.violas.io")!
//            }
        }
    }
    var path: String {
        switch self {
//        case .walletMessages(_, _, _):
//            return "/1.0/violas/notificatioin/walletMessages"
//        case .systemMessages(_, _, _):
//            return "/1.0/violas/notificatioin/systemMessages"
        }
    }
    var method: Moya.Method {
        switch self {
//        case .walletMessages(_, _, _),
//             .systemMessages(_, _, _):
//            return .get
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
//        case .walletMessages(let address, let page, let limit):
//            return .requestParameters(parameters: ["address": address,
//                                                   "offset": page,
//                                                   "limit": limit],
//                                      encoding: URLEncoding.queryString)
//        case .systemMessages(let address, let page, let limit):
//            return .requestParameters(parameters: ["address": address,
//                                                   "offset": page,
//                                                   "limit": limit],
//                                      encoding: URLEncoding.queryString)
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
