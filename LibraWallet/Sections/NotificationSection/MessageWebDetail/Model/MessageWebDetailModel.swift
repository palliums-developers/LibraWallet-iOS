//
//  MessageWebDetailModel.swift
//  LibraWallet
//
//  Created by wangyingdong on 2021/2/1.
//  Copyright © 2021 palliums. All rights reserved.
//

import UIKit
import Moya

struct MessageWebDetailModelDataModel: Codable {
    /// 标题
    var title: String?
    /// 内容
    var content: String?
    /// 日期
    var date: Int?
    /// 作者
    var author: String?
    /// 消息ID
    var id: String?
}
struct MessageWebDetailModelMainModel: Codable {
    var code: Int?
    var message: String?
    var data: MessageWebDetailModelDataModel?
}

class MessageWebDetailModel: NSObject {
    private var requests: [Cancellable] = []
    deinit {
        requests.forEach { cancellable in
            cancellable.cancel()
        }
        requests.removeAll()
        print("MessageWebDetailModel销毁了")
    }
    func getWalletMessageDetail(address: String, token: String, id: String, completion: @escaping (Result<MessageWebDetailModelDataModel, LibraWalletError>) -> Void) {
        let request = notificationModuleProvide.request(.systemMessageDetail(address, token, id)) { (result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(MessageWebDetailModelMainModel.self)
                    if json.code == 2000 {
                        guard let model = json.data else {
                            print("SystemMessageDetail_数据为空")
                            completion(.success(MessageWebDetailModelDataModel()))
                            return
                        }
                        completion(.success(model))
                    } else {
                        print("SystemMessageDetail_状态异常")
                        if let message = json.message, message.isEmpty == false {
                            completion(.failure(LibraWalletError.error(message)))
                        } else {
                            completion(.failure(LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.dataCodeInvalid)))
                        }
                    }
                } catch {
                    print("SystemMessageDetail_解析异常\(error.localizedDescription)")
                    completion(.failure(LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.parseJsonError)))
                }
            case let .failure(error):
                guard error.errorCode != -999 else {
                    print("SystemMessageDetail_网络请求已取消")
                    return
                }
                completion(.failure(LibraWalletError.WalletRequest(reason: .networkInvalid)))
            }
        }
        self.requests.append(request)
    }
}
