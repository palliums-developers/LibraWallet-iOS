//
//  NotificationModuleNetworkManager.swift
//  LibraWallet
//
//  Created by wangyingdong on 2021/1/19.
//  Copyright © 2021 palliums. All rights reserved.
//

import UIKit
import Moya
import Localize_Swift

let notificationModuleProvide = MoyaProvider<NotificationModuleRequest>()
//let mainProvide = MoyaProvider<mainRequest>(stubClosure: MoyaProvider.immediatelyStub)
enum NotificationModuleRequest {
    /// 注册设备（钱包地址，FCM Token，设备类型，语言）
    case registerNotification(String, String, String, String)
    /// 钱包通知（钱包地址、offset、limit）
    case walletMessages(String, Int, Int)
    /// 获取钱包通知交易详情（钱包地址、Version）
    case getTransactionMessageDetail(String, String)
    /// 钱包通知（钱包地址、offset、limit）
    case systemMessages(String, Int, Int)
    /// 获取系统消息详情（钱包地址、消息ID）
    case systemMessageDetail(String, String)
}
extension NotificationModuleRequest: TargetType {
    var baseURL: URL {
        switch self {
        case .registerNotification(_, _, _, _),
             .walletMessages(_, _, _),
             .getTransactionMessageDetail(_, _),
             .systemMessages(_, _, _),
             .systemMessageDetail(_, _):
            if PUBLISH_VERSION == true {
                return URL(string:"https://api.violas.io")!
            } else {
                return URL(string:"https://api4.violas.io")!
            }
        }
    }
    var path: String {
        switch self {
        case .registerNotification(_, _, _, _):
            return "/1.0/violas/device/info"
        case .walletMessages(_, _, _):
            return "/1.0/violas/messages"
        case .getTransactionMessageDetail(_, _):
            return "/1.0/violas/message/content"
        case .systemMessages(_, _, _):
            return "/1.0/violas/notifications"
        case .systemMessageDetail(_, _):
            return "/1.0/violas/notifications/test"
        //        case .poolProfitList(_, _, _):
        //            return "/1.0/violas/incentive/orders/pool"
        //        case .bankProfitList(_, _, _):
        //            return "/1.0/violas/incentive/orders/bank"
        }
    }
    var method: Moya.Method {
        switch self {
        case .registerNotification(_, _, _, _):
            return .post
        case .walletMessages(_, _, _),
             .getTransactionMessageDetail(_, _),
             .systemMessages(_, _, _),
             .systemMessageDetail(_, _):
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
        case .registerNotification(let address, let FCMToken, let device, let language):
            return .requestParameters(parameters: ["address": address,
                                                   "token": FCMToken,
                                                   "device_type": device,
                                                   "language": language],
                                      encoding: JSONEncoding.default)
        case .walletMessages(let address, let page, let limit):
            return .requestParameters(parameters: ["address": address,
                                                   "offset": page,
                                                   "limit": limit],
                                      encoding: URLEncoding.queryString)
        case .getTransactionMessageDetail(let address, let version):
            return .requestParameters(parameters: ["address": address,
                                                   "version": version],
                                      encoding: URLEncoding.queryString)
        case .systemMessages(let address, let page, let limit):
            return .requestParameters(parameters: ["address": address,
                                                   "offset": page,
                                                   "limit": limit],
                                      encoding: URLEncoding.queryString)
        case .systemMessageDetail(let address, let id):
            return .requestParameters(parameters: ["address": address,
                                                   "id": id],
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
