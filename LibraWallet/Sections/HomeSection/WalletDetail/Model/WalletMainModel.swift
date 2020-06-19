//
//  WalletMainModel.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/6/4.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit
import Moya
class WalletMainModel: NSObject {
    private var requests: [Cancellable] = []
    @objc dynamic var dataDic: NSMutableDictionary = [:]
    /// 获取Violas交易记录
    /// - Parameters:
    ///   - address: 地址
    ///   - page: 页数
    ///   - pageSize: 数量
//    func getViolasTransactionHistory(address: String, page: Int, pageSize: Int, contract: String, requestStatus: Int, tokenName: String) {
//        let type = requestStatus == 0 ? "ViolasTransactionHistoryOrigin":"ViolasTransactionHistoryMore"
//        let request = mainProvide.request(.GetViolasAccountTransactionList(address, page, pageSize, contract)) {[weak self](result) in
//            switch  result {
//            case let .success(response):
//                do {
//                    let json = try response.map(ViolasResponseModel.self)
//                    if json.code == 2000 {
//                        guard json.data?.isEmpty == false else {
//                            if requestStatus == 0 {
//                                let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.dataEmpty), type: type)
//                                self?.setValue(data, forKey: "dataDic")
//                            } else {
//                                let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.noMoreData), type: type)
//                                    self?.setValue(data, forKey: "dataDic")
//                            }
//                            return
//                        }
//                        let result = self?.dealViolasTransactions(models: json.data!, walletAddress: address, tokenName: tokenName)
//                        let data = setKVOData(type: type, data: result)
//                        self?.setValue(data, forKey: "dataDic")
//                    } else {
//                        print("\(type)_状态异常")
//                        if let message = json.message, message.isEmpty == false {
//                            let data = setKVOData(error: LibraWalletError.error(message), type: type)
//                            self?.setValue(data, forKey: "dataDic")
//                        } else {
//                            let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.dataCodeInvalid), type: type)
//                            self?.setValue(data, forKey: "dataDic")
//                        }
//                    }
//                } catch {
//                    print("解析异常\(error.localizedDescription)")
//                    let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.parseJsonError), type: type)
//                    self?.setValue(data, forKey: "dataDic")
//                }
//            case let .failure(error):
//                guard error.errorCode != -999 else {
//                    print("网络请求已取消")
//                    return
//                }
//                print(error.localizedDescription)
//                let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.networkInvalid), type: type)
//                self?.setValue(data, forKey: "dataDic")
//            }
//        }
//        self.requests.append(request)
//    }
//    private func dealViolasTransactions(models: [ViolasDataModel], walletAddress: String, tokenName: String) -> [ViolasDataModel] {
//        var tempModels = [ViolasDataModel]()
//        for var item in models {
//            if item.receiver == walletAddress {
//                item.transaction_type = 1
//            } else {
//                item.transaction_type = 0
//            }
//            item.module_name = tokenName
//            tempModels.append(item)
//        }
//        return tempModels
//    }
    deinit {
        requests.forEach { cancellable in
            cancellable.cancel()
        }
        requests.removeAll()
        print("VTokenMainModel销毁了")
    }
}
