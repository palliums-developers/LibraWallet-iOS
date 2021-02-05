//
//  SystemMessagesModel.swift
//  LibraWallet
//
//  Created by wangyingdong on 2021/1/11.
//  Copyright © 2021 palliums. All rights reserved.
//

import UIKit
import Moya

struct SystemMessagesDataModel: Codable {
    /// 标题
    var title: String?
    /// 内容
    var body: String?
    /// 当前限额
    var date: Int?
    /// 消息类型
//    var type: Int?
    /// 服务
    var service: String?
    /// 是否已读（自行添加）
    var readed: Int?
    /// 消息ID
    var id: String?
}
struct SystemMessagesMainModel: Codable {
    var code: Int?
    var message: String?
    var data: [SystemMessagesDataModel]?
}
class SystemMessagesModel: NSObject {
    private var requests: [Cancellable] = []
    @objc dynamic var dataDic: NSMutableDictionary = [:]
    deinit {
        requests.forEach { cancellable in
            cancellable.cancel()
        }
        requests.removeAll()
        print("SystemMessagesModel销毁了")
    }
    func getSystemMessages(address: String, token: String, limit: Int, count: Int, refresh: Bool, completion: @escaping (Result<[SystemMessagesDataModel], LibraWalletError>) -> Void) {
        let type = refresh == true ? "GetSystemMessagesOrigin":"GetSystemMessagesMore"
        let request = notificationModuleProvide.request(.systemMessages(address, token, limit, count)) { (result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(SystemMessagesMainModel.self)
                    if json.code == 2000 {
                        guard let models = json.data, models.isEmpty == false else {
                            print("\(type)_数据为空")
                            completion(.success([SystemMessagesDataModel]()))
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
