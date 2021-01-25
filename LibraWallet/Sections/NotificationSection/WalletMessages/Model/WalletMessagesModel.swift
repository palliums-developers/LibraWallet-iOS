//
//  WalletMessagesModel.swift
//  LibraWallet
//
//  Created by wangyingdong on 2021/1/11.
//  Copyright © 2021 palliums. All rights reserved.
//

import UIKit
import Moya

struct WalletMessagesDataModel: Codable {
    /// 标题
    var title: String?
    /// 内容
    var body: String?
    /// 日期
    var date: String?
    /// 是否已读
    var readed: Int?
    /// 服务
    var service: String?
    /// 执行状态（Executed、Failed）
    var status: String?
    /// 脚本类型
    var type: String?
    /// 交易ID
    var version: String?
    /// 消息ID
    var id: Int?
}
struct WalletMessagesMainModel: Codable {
    var code: Int?
    var message: String?
    var data: [WalletMessagesDataModel]?
}
class WalletMessagesModel: NSObject {
    private var requests: [Cancellable] = []
    deinit {
        requests.forEach { cancellable in
            cancellable.cancel()
        }
        requests.removeAll()
        print("WalletMessagesModel销毁了")
    }
    func getWalletMessages(address: String, limit: Int, count: Int, refresh: Bool, completion: @escaping (Result<[WalletMessagesDataModel], LibraWalletError>) -> Void) {
        let type = refresh == true ? "GetWalletMessagesOrigin":"GetWalletMessagesMore"
        let request = notificationModuleProvide.request(.walletMessages(address, limit, count)) { (result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(WalletMessagesMainModel.self)
                    if json.code == 2000 {
                        guard let models = json.data, models.isEmpty == false else {
                            print("\(type)_数据为空")
                            completion(.success([WalletMessagesDataModel]()))
                            return
                        }
                        completion(.success(models))
                    } else {
                        print("\(type)_状态异常")
                        if let message = json.message, message.isEmpty == false {
                            completion(.failure(LibraWalletError.error(message)))
                        } else {
                            completion(.failure(LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.dataCodeInvalid)))
                        }
                    }
                } catch {
                    print("\(type)_解析异常\(error.localizedDescription)")
                    completion(.failure(LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.parseJsonError)))
                }
            case let .failure(error):
                guard error.errorCode != -999 else {
                    print("\(type)_网络请求已取消")
                    return
                }
                completion(.failure(LibraWalletError.WalletRequest(reason: .networkInvalid)))
            }
        }
        self.requests.append(request)
    }
}
