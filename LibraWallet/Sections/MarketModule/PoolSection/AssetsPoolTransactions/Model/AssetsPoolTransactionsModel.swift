//
//  AssetsPoolTransactionsModel.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/7/14.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit
import Moya
class AssetsPoolTransactionsModel: NSObject {
    private var requests: [Cancellable] = []
    @objc dynamic var dataDic: NSMutableDictionary = [:]
    private var sequenceNumber: Int?
    func getAssetsPoolTransactions(address: String, page: Int, pageSize: Int, requestStatus: Int) {
        let type = requestStatus == 0 ? "AssetsPoolTransactionsOrigin":"AssetsPoolTransactionsMore"
        let request = marketModuleProvide.request(.assetsPoolTransactions(address, page, pageSize)) {[weak self](result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(AssetsPoolTransactionsMainModel.self)
                    if json.code == 2000 {
                        guard json.data?.isEmpty == false else {
                            if requestStatus == 0 {
                                let data = setKVOData(error: LibraWalletError.WalletRequest(reason: .dataEmpty), type: type)
                                self?.setValue(data, forKey: "dataDic")
                            } else {
                                let data = setKVOData(error: LibraWalletError.WalletRequest(reason: .noMoreData), type: type)
                                self?.setValue(data, forKey: "dataDic")
                            }
                            return
                        }
                        let data = setKVOData(type: type, data: json.data)
                        self?.setValue(data, forKey: "dataDic")
                    } else {
                        print("\(type)_状态异常")
                        if let message = json.message, message.isEmpty == false {
                            let data = setKVOData(error: LibraWalletError.error(message), type: type)
                            self?.setValue(data, forKey: "dataDic")
                        } else {
                            let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.dataCodeInvalid), type: type)
                            self?.setValue(data, forKey: "dataDic")
                        }
                    }
                } catch {
                    print("\(type)解析异常\(error.localizedDescription)")
                    let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.parseJsonError), type: type)
                    self?.setValue(data, forKey: "dataDic")
                }
            case let .failure(error):
                guard error.errorCode != -999 else {
                    print("网络请求已取消")
                    return
                }
                print("\(type)网络异常\(error.localizedDescription)")
                let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.networkInvalid), type: type)
                self?.setValue(data, forKey: "dataDic")
            }
        }
        self.requests.append(request)
    }
    deinit {
        requests.forEach { cancellable in
            cancellable.cancel()
        }
        requests.removeAll()
        print("AssetsPoolTransactionsModel销毁了")
    }
}
