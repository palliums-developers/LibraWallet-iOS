//
//  DepositListModel.swift
//  ViolasWallet
//
//  Created by wangyingdong on 2020/8/21.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit
import Moya
struct DepositListMainDataModel: Codable {
    /// 订单币种
    var currency: String?
    /// 订单日期
    var date: Int?
    /// 订单ID
    var id: String?
    /// 订单币种图片
    var logo: String?
    /// 订单状态（0（已存款），1（已提取），-1（提取失败），-2（存款失败））
    var status: Int?
    /// 订单价值
    var value: Double?
}
struct DepositListMainModel: Codable {
    var code: Int?
    var message: String?
    var data: [DepositListMainDataModel]?
}
class DepositListModel: NSObject {
    private var requests: [Cancellable] = []
    deinit {
        requests.forEach { cancellable in
            cancellable.cancel()
        }
        requests.removeAll()
        print("DepositListModel销毁了")
    }
    func getDepositList(address: String, currency: String, status: Int, page: Int, limit: Int, refresh: Bool, completion: @escaping (Result<[DepositListMainDataModel], LibraWalletError>) -> Void) {
        let type = refresh == true ? "GetBankDepositListOrigin":"GetBankDepositListMore"
        let request = bankModuleProvide.request(.depositList(address, currency, status, page, limit)) { (result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(DepositListMainModel.self)
                    if json.code == 2000 {
                        guard let models = json.data, models.isEmpty == false else {
                            print("\(type)_数据为空")
                            completion(.success([DepositListMainDataModel]()))
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
extension DepositListModel {
    func getDepositMarket(requestStatus: Int, completion: @escaping (Result<[BankDepositMarketDataModel], LibraWalletError>) -> Void) {
        let type = requestStatus == 0 ? "GetBankDepositMarketOrigin":"GetBankDepositMarketMore"
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
