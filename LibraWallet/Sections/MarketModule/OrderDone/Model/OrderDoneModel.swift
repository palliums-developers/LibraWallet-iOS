//
//  OrderDoneModel.swift
//  LibraWallet
//
//  Created by palliums on 2019/12/17.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit
import Moya
class OrderDoneModel: NSObject {
    private var requests: [Cancellable] = []
    @objc var dataDic: NSMutableDictionary = [:]
    private var sequenceNumber: Int?
    func getAllDoneOrder(address: String, version: String) {
        let type = version.isEmpty == true ? "GetAllDoneOrderOrigin":"GetAllDoneOrderMore"
        let request = mainProvide.request(.GetAllDoneOrder(address, version)) {[weak self](result) in
            switch  result {
            case let .success(response):
                do {
                    print(try response.mapString())
                    let json = try response.map(AllProcessingOrderMainModel.self)
                    guard json.orders?.isEmpty == false else {
                        let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.dataEmpty), type: type)
                        self?.setValue(data, forKey: "dataDic")
                        return
                    }
                    let data = setKVOData(type: type, data: json.orders)
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
        print("OrderDoneModel销毁了")
    }
}
