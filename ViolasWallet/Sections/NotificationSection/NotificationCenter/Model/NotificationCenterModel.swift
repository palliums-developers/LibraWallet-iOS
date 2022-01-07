//
//  NotificationCenterModel.swift
//  ViolasWallet
//
//  Created by wangyingdong on 2021/2/5.
//  Copyright © 2021 palliums. All rights reserved.
//

import UIKit
import Moya

struct WalletMessagesTotalReadMainModel: Codable {
    var code: Int?
    var message: String?
}

class NotificationCenterModel: NSObject {
    private var requests: [Cancellable] = []
    deinit {
        requests.forEach { cancellable in
            cancellable.cancel()
        }
        requests.removeAll()
        print("NotificationCenterModel销毁了")
    }
    func setTotalRead(address: String, token: String, completion: @escaping (Result<Bool, LibraWalletError>) -> Void) {
        let request = notificationModuleProvide.request(.setTotalRead(address, token)) { (result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(WalletMessagesTotalReadMainModel.self)
                    if json.code == 2000 {
                        completion(.success(true))
                    } else {
                        print("CleanUnread_状态异常")
                        if let message = json.message, message.isEmpty == false {
                            completion(.failure(LibraWalletError.error(message)))
                        } else {
                            completion(.failure(LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.dataCodeInvalid)))
                        }
                    }
                } catch {
                    print("CleanUnread_解析异常\(error.localizedDescription)")
                    completion(.failure(LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.parseJsonError)))
                }
            case let .failure(error):
                guard error.errorCode != -999 else {
                    print("CleanUnread_网络请求已取消")
                    return
                }
                completion(.failure(LibraWalletError.WalletRequest(reason: .networkInvalid)))
            }
        }
        self.requests.append(request)
    }
}
