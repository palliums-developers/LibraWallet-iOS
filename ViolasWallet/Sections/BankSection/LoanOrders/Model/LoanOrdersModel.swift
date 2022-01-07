//
//  LoanOrdersModel.swift
//  ViolasWallet
//
//  Created by wangyingdong on 2020/8/24.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit
import Moya
struct LoanOrdersMainDataModel: Codable {
    /// 订单数量
    var amount: UInt64?
    /// 订单ID
    var id: String?
    /// 订单币种图片
    var logo: String?
    /// 订单名字
    var name: String?
}
struct LoanOrdersMainModel: Codable {
    var code: Int?
    var message: String?
    var data: [LoanOrdersMainDataModel]?
}
class LoanOrdersModel: NSObject {
    private var requests: [Cancellable] = []
    deinit {
        requests.forEach { cancellable in
            cancellable.cancel()
        }
        requests.removeAll()
        print("LoanOrdersModel销毁了")
    }
    func getLoanTransactions(address: String, page: Int, limit: Int, refresh: Bool, completion: @escaping (Result<[LoanOrdersMainDataModel], LibraWalletError>) -> Void) {
        let type = refresh == true ? "GetBankLoanTransactionsOrigin":"GetBankLoanTransactionsMore"
        let request = bankModuleProvide.request(.loanTransactions(address, page, limit)) { (result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(LoanOrdersMainModel.self)
                    if json.code == 2000 {
                        guard let models = json.data, models.isEmpty == false else {
                            print("\(type)_数据为空")
                            completion(.success([LoanOrdersMainDataModel]()))
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
