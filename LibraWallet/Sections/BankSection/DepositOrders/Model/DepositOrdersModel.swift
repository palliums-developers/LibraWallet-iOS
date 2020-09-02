//
//  DepositOrdersModel.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/8/20.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit
import Moya
struct DepositOrdersMainDataModel: Codable {
    /// 订单可提取数量
    var available_quantity: UInt64?
    /// 订单收益
    var earnings: UInt64?
    /// 订单ID
    var id: String?
    /// 订单币种图片
    var logo: String?
    /// 订单本金
    var principal: UInt64?
    /// 订单收益率
    var rate: Double?
    /// 订单状态
    var status: Int?
    /// 订单币Address
    var token_address: String?
    /// 订单币Name
    var token_name: String?
    /// 订单币种名称
    var currency: String?
    /// 订单展示名字
    var token_show_name: String?
}
struct DepositOrdersMainModel: Codable {
        var code: Int?
    var message: String?
    var data: [DepositOrdersMainDataModel]?
}
class DepositOrdersModel: NSObject {
    private var requests: [Cancellable] = []
    @objc dynamic var dataDic: NSMutableDictionary = [:]
    deinit {
        requests.forEach { cancellable in
            cancellable.cancel()
        }
        requests.removeAll()
        print("DepositOrdersModel销毁了")
    }
    func getDepositTransactions(address: String, page: Int, limit: Int, requestStatus: Int) {
        let type = requestStatus == 0 ? "GetBankDepositTransactionsOrigin":"GetBankDepositTransactionsMore"
        let request = mainProvide.request(.depositTransactions(address, page, limit)) {[weak self](result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(DepositOrdersMainModel.self)
                    if json.code == 2000 {
                        guard let models = json.data, models.isEmpty == false else {
                            let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.dataEmpty), type: type)
                            self?.setValue(data, forKey: "dataDic")
                            print("\(type)_状态异常")
                            return
                        }
                        let data = setKVOData(type: type, data: models)
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
}
