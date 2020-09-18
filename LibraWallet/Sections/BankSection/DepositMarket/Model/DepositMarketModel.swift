//
//  DepositMarketModel.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/8/19.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit
import Moya
struct BankDepositMarketDataModel: Codable {
    var desc: String?
    var id: String?
    var logo: String?
    var name: String?
    var rate: Double?
    var rate_desc: String?
    var token_module: String?
}
struct BankDepositMarketMainModel: Codable {
    var code: Int?
    var message: String?
    var data: [BankDepositMarketDataModel]?
}
class DepositMarketModel: NSObject {
    private var requests: [Cancellable] = []
    @objc dynamic var dataDic: NSMutableDictionary = [:]
    deinit {
        requests.forEach { cancellable in
            cancellable.cancel()
        }
        requests.removeAll()
        print("DepositMarketModel销毁了")
    }
    func getDepositMarket(requestStatus: Int) {
        let type = requestStatus == 0 ? "GetBankDepositMarketOrigin":"GetBankDepositMarketMore"
        let request = mainProvide.request(.depositMarket) {[weak self](result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(BankDepositMarketMainModel.self)
                    if json.code == 2000 {
                        guard let models = json.data, models.isEmpty == false else {
                            let error = requestStatus == 0 ? LibraWalletError.RequestError.dataEmpty:LibraWalletError.RequestError.noMoreData
                            let data = setKVOData(error: LibraWalletError.WalletRequest(reason: error), type: type)
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
