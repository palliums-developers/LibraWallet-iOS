//
//  MappingTransactionsModel.swift
//  ViolasWallet
//
//  Created by wangyingdong on 2020/2/18.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit
import Moya

struct MappingTransactionsMainDataDetailModel: Codable {
//    var amount: Int64
//    var chain: String?
//    var name: String?
//    var show_name: String?
}
struct MappingTransactionsDataModel: Codable {
//    var amount_from: MappingTransactionsMainDataDetailModel?
//    var amount_to: MappingTransactionsMainDataDetailModel?
//    var confirmed_time: Int64?
//    var status: Int?
//    var version_or_block_height: Int64?
    var expiration_time: Int?
    var from_chain: String?
    var in_amount: UInt64?
    var in_show_name: String?
    var in_token: String?
    var opttype: String?
    var out_amount: UInt64?
    var out_show_name: String?
    var out_token: String?
    var state: String?
    var times: Int?
    var timestamps: UInt64?
    var to_address: String?
    var to_chain: String?
    var tran_id: String?
    var type: String?
    var version: Int?
}
struct MappingTransactionsMainModel: Codable {
    var code: Int?
    var message: String?
    var data: [MappingTransactionsDataModel]?
}
class MappingTransactionsModel: NSObject {
    private var requests: [Cancellable] = []
    @objc dynamic var dataDic: NSMutableDictionary = [:]
    func getMappingTransactions(walletAddress: String, page: Int, pageSize: Int, requestStatus: Int) {
        let type = requestStatus == 0 ? "MappingTransactionsOrigin":"MappingTransactionsMore"
        let request = mappingModuleProvide.request(.mappingTransactions(walletAddress, page, pageSize)) {[weak self](result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(MappingTransactionsMainModel.self)
                    if json.code == 2000 {
                        guard json.data?.isEmpty == false else {
                            let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.dataEmpty), type: type)
                            self?.setValue(data, forKey: "dataDic")
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
