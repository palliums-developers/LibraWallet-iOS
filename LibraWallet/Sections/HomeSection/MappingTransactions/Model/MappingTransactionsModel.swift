//
//  MappingTransactionsModel.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/2/18.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit
import Moya
struct MappingTransactionsMainDataModel: Codable {
    ///
    var date: Int?
    ///
    var amount: String?
    ///
    var state: Int?
    ///
    var address: String?
    ///
    var unit: String?
}
struct MappingTransactionsMainModel: Codable {
    var code: Int?
    var message: String?
    var data: [MappingTransactionsMainDataModel]?
}
class MappingTransactionsModel: NSObject {
    private var requests: [Cancellable] = []
    @objc var dataDic: NSMutableDictionary = [:]
    func getMappingTransactions(walletAddress: String, page: Int, pageSize: Int, contract: String, requestStatus: Int) {
        let type = requestStatus == 0 ? "MappingTransactionsOrigin":"MappingTransactionsMore"
        let request = mainProvide.request(.GetMappingTransactions(walletAddress)) {[weak self](result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(MappingTransactionsMainModel.self)
                    guard json.code == 2000 else {
                        let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.dataCodeInvalid), type: type)
                        self?.setValue(data, forKey: "dataDic")
                        return
                    }
                    let data = setKVOData(type: type, data: json.data)
                    self?.setValue(data, forKey: "dataDic")
                    // 刷新本地数据
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
        print("MappingTransactionsModel销毁了")
    }
}
