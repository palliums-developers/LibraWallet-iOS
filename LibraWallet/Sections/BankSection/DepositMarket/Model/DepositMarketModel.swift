//
//  DepositMarketModel.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/8/19.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit
import Moya
struct BankDepositMarketDataModel: Codable {
    var desc: String?
    var id: String?
    var logo: String?
    var name: String?
    var rate: Double?
    var rate_desc: String?
    var token_module: String?
}
struct BankDepositMarketMainModel: Codable {
    var code: Int?
    var message: String?
    var data: [BankDepositMarketDataModel]?
}
class DepositMarketModel: NSObject {
    private var requests: [Cancellable] = []
    deinit {
        requests.forEach { cancellable in
            cancellable.cancel()
        }
        requests.removeAll()
        print("DepositMarketModel销毁了")
    }
    func getDepositMarket(refresh: Bool, completion: @escaping (Result<[BankDepositMarketDataModel], LibraWalletError>) -> Void) {
        let type = refresh == true ? "GetBankDepositMarketOrigin":"GetBankDepositMarketMore"
        let request = bankModuleProvide.request(.depositMarket) { (result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(BankDepositMarketMainModel.self)
                    if json.code == 2000 {
                        guard let models = json.data, models.isEmpty == false else {
                            print("\(type)_数据为空")
                            completion(.success([BankDepositMarketDataModel]()))
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
