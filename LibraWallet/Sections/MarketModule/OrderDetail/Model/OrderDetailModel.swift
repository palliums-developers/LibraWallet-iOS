//
//  OrderDetailModel.swift
//  LibraWallet
//
//  Created by palliums on 2019/12/10.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit
import Moya
struct OrderDetailDataModel: Codable {
    var version: String?
    var date: Int?
    var amount: String?
}
struct OrderDetailMainModel: Codable {
    var trades: [OrderDetailDataModel]?
}
class OrderDetailModel: NSObject {
    private var requests: [Cancellable] = []
    @objc var dataDic: NSMutableDictionary = [:]
    func getOrderDetail(address: String, version: String, page: Int, requestStatus: Int) {
        let type = requestStatus == 0 ? "OrderDetailOrigin":"OrderDetailMore"
        let request = mainProvide.request(.GetOrderDetail(version, page)) {[weak self](result) in
            switch  result {
            case let .success(response):
                do {
                    print(try response.mapString())
                    let json = try response.map(OrderDetailMainModel.self)
                    guard json.trades?.isEmpty == false else {
                        let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.dataEmpty), type: type)
                        self?.setValue(data, forKey: "dataDic")
                        return
                    }
                    let data = setKVOData(type: type, data: json.trades)
                    self?.setValue(data, forKey: "dataDic")
                } catch {
                    print("\(type)_解析异常\(error.localizedDescription)")
                    let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.parseJsonError), type: type)
                    self?.setValue(data, forKey: "dataDic")
                }
            case let .failure(error):
                guard error.errorCode != -999 else {
                    print("\(type)_网络请求已取消")
                    return
                }
                let data = setKVOData(error: LibraWalletError.WalletRequest(reason: .networkInvalid), type: type)
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
