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
        }
    }
    var path: String {
        switch self {
        }
    }
    var method: Moya.Method {
        switch self {
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
