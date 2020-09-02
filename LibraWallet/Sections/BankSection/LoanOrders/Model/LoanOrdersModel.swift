//
//  LoanOrdersModel.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/8/24.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit
import Moya
struct LoanOrdersMainDataModel: Codable {
    /// 订单数量
    var amount: UInt64?
    /// 订单ID
    var id: String?
    /// 订单币种图片
    var logo: String?
    /// 订单名字
    var name: String?
}
struct LoanOrdersMainModel: Codable {
    var code: Int?
    var message: String?
    var data: [LoanOrdersMainDataModel]?
}
class LoanOrdersModel: NSObject {
    private var requests: [Cancellable] = []
    @objc dynamic var dataDic: NSMutableDictionary = [:]
    deinit {
        requests.forEach { cancellable in
            cancellable.cancel()
        }
        requests.removeAll()
        print("LoanOrdersModel销毁了")
    }
    func getLoanTransactions(address: String, page: Int, limit: Int, requestStatus: Int) {
        let type = requestStatus == 0 ? "GetBankLoanTransactionsOrigin":"GetBankLoanTransactionsMore"
        let request = mainProvide.request(.loanTransactions(address, page, limit)) {[weak self](result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(LoanOrdersMainModel.self)
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
