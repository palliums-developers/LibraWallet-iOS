//
//  OrderDetailModel.swift
//  LibraWallet
//
//  Created by palliums on 2019/12/10.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit
import Moya
class OrderDetailModel: NSObject {
    private var requests: [Cancellable] = []
    @objc var dataDic: NSMutableDictionary = [:]
    func getOrderDetail(address: String, payContract: String, receiveContract: String, version: String) {
        let request = mainProvide.request(.GetOrderDetail(address, payContract, receiveContract, version)) {[weak self](result) in
            switch  result {
            case let .success(response):
                do {
                    print(try response.mapString())
                    let json = try response.map(AllProcessingOrderMainModel.self)
//                    guard json. == 2000 else {
//                        let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.dataCodeInvalid), type: "GetCurrentOrder")
//                        self?.setValue(data, forKey: "dataDic")
//                        return
//                    }
                    let data = setKVOData(type: "GetOrderDetail", data: json.orders)
                    self?.setValue(data, forKey: "dataDic")
                } catch {
                    print("GetOrderDetail_解析异常\(error.localizedDescription)")
                    let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.parseJsonError), type: "GetOrderDetail")
                    self?.setValue(data, forKey: "dataDic")
                }
            case let .failure(error):
                guard error.errorCode != -999 else {
                    print("GetOrderDetail_网络请求已取消")
                    return
                }
                let data = setKVOData(error: LibraWalletError.WalletRequest(reason: .networkInvalid), type: "GetOrderDetail")
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
        print("OrderDetailModel销毁了")
    }
}
