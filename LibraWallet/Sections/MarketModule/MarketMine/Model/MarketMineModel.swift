//
//  MarketMineModel.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/7/9.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit
import Moya
struct MarketMineMainTokensDataModel: Codable {
    var coin_a_index: Int?
    var coin_a_name: String?
    var coin_b_index: Int?
    var coin_b_name: String?
    var token: Int64?
}
struct MarketMineMainDataModel: Codable {
    var balance: [MarketMineMainTokensDataModel]?
    var total_token: Int64?
}
struct MarketMineMainModel: Codable {
    var code: Int?
    var message: String?
    var data: MarketMineMainDataModel?
}
class MarketMineModel: NSObject {
    private var requests: [Cancellable] = []
    @objc dynamic var dataDic: NSMutableDictionary = [:]
    func getMarketMineTokens(address: String) {
        let request = mainProvide.request(.MarketMineTokens(address)) {[weak self](result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(MarketMineMainModel.self)
                    if json.code == 2000 {
                        guard let models = json.data?.balance, models.isEmpty == false else {
                            let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.dataEmpty), type: "GetMarketMineTokens")
                            self?.setValue(data, forKey: "dataDic")
                            print("GetMarketMineTokens_状态异常")
                            return
                        }
                        let data = setKVOData(type: "GetMarketMineTokens", data: json.data)
                        self?.setValue(data, forKey: "dataDic")
                    } else {
                        print("GetMarketMineTokens_状态异常")
                        if let message = json.message, message.isEmpty == false {
                            let data = setKVOData(error: LibraWalletError.error(message), type: "GetMarketMineTokens")
                            self?.setValue(data, forKey: "dataDic")
                        } else {
                            let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.dataCodeInvalid), type: "GetMarketMineTokens")
                            self?.setValue(data, forKey: "dataDic")
                        }
                    }
                } catch {
                    print("GetMarketMineTokens_解析异常\(error.localizedDescription)")
                    let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.parseJsonError), type: "GetMarketMineTokens")
                    self?.setValue(data, forKey: "dataDic")
                }
            case let .failure(error):
                guard error.errorCode != -999 else {
                    print("网络请求已取消")
                    return
                }
                let data = setKVOData(error: LibraWalletError.WalletRequest(reason: .networkInvalid), type: "GetMarketMineTokens")
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
        print("AddAssetModel销毁了")
    }
}
