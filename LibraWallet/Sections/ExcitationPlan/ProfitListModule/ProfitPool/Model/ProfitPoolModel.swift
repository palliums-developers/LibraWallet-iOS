//
//  ProfitPoolModel.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/12/2.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit
import Moya

struct PoolProfitDataModel: Codable {
    /// 金额
    var amount: UInt64?
    /// 邀请地址
    var be_invited: String?
    /// 邀请时间
    var date: Int?
    /// 状态（0：未到帐；1： 已到帐）
    var status: Int?
    ///
    var total_count: UInt64?
}
struct PoolProfitMainModel: Codable {
    var code: Int?
    var message: String?
    var data: [PoolProfitDataModel]?
}
class ProfitPoolModel: UIView {
    private var requests: [Cancellable] = []
    @objc dynamic var dataDic: NSMutableDictionary = [:]
    deinit {
        requests.forEach { cancellable in
            cancellable.cancel()
        }
        requests.removeAll()
        print("ProfitPoolModel销毁了")
    }
    func getLoanOrderDetailLoanList(address: String, orderID: String, page: Int, limit: Int, requestStatus: Int) {
        let type = requestStatus == 0 ? "GetPoolProfitListOrigin":"GetPoolProfitListMore"
        let request = ActiveModuleProvide.request(.poolProfitList(address, page, limit)) {[weak self](result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(PoolProfitMainModel.self)
                    if json.code == 2000 {
                        guard let models = json.data, models.isEmpty == false else {
                            let error = requestStatus == 0 ? LibraWalletError.RequestError.dataEmpty:LibraWalletError.RequestError.noMoreData
                            let data = setKVOData(error: LibraWalletError.WalletRequest(reason: error), type: type)
                            self?.setValue(data, forKey: "dataDic")
                            print("\(type)_状态异常")
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
