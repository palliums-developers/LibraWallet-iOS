//
//  VTokenMainModel.swift
//  LibraWallet
//
//  Created by palliums on 2019/11/18.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit
import Moya
class VTokenMainModel: NSObject {
    private var requests: [Cancellable] = []
    @objc var dataDic: NSMutableDictionary = [:]
    /// 获取Violas交易记录
    /// - Parameters:
    ///   - address: 地址
    ///   - page: 页数
    ///   - pageSize: 数量
    func getViolasTransactionHistory(address: String, page: Int, pageSize: Int, contract: String, requestStatus: Int) {
        let type = requestStatus == 0 ? "ViolasTransactionHistoryOrigin":"ViolasTransactionHistoryMore"
        let request = mainProvide.request(.GetViolasAccountTransactionList(address, page, pageSize, contract)) {[weak self](result) in
                switch  result {
                case let .success(response):
                    do {
                        let json = try response.map(ViolasResponseModel.self)
                        print(try response.mapString())
                        guard json.code == 2000 else {
                            let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.dataCodeInvalid), type: type)
                            self?.setValue(data, forKey: "dataDic")
                            return
                        }
                        let data = setKVOData(type: type, data: json.data)
                        self?.setValue(data, forKey: "dataDic")
                    } catch {
                        print("解析异常\(error.localizedDescription)")
                        let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.parseJsonError), type: type)
                        self?.setValue(data, forKey: "dataDic")
                    }
                case let .failure(error):
                    guard error.errorCode != -999 else {
                        print("网络请求已取消")
                        return
                    }
                    print(error.localizedDescription)
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
        print("VTokenMainModel销毁了")
    }
}
