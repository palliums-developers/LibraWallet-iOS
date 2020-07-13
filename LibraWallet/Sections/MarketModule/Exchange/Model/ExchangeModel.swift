//
//  ExchangeModel.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/7/9.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit
import Moya
struct MarketSupportTokensDataModel: Codable {
    /// 合约地址
    var address: String?
    /// module名
    var module: String?
    /// 币名
    var name: String?
    /// 展示名字
    var show_name: String?
}
struct MarketSupportTokensMainModel: Codable {
    var code: Int?
    var message: String?
    var data: [MarketSupportTokensDataModel]?
}
struct ExchangeTransactionsDataModel: Codable {
    /// 输入数量
    var input_amount: Int64?
    /// 兑换数量
    var output_amount: Int64?
    /// 输入币名
    var input_name: String?
    /// 兑换币名
    var output_name: String?
    /// 日期
    var date: Int?
    /// 状态（同链上状态）
    var status: Int?
    /// 交易唯一ID
    var version: Int?
}
struct ExchangeTransactionsMainModel: Codable {
    var code: Int?
    var message: String?
    var data: [ExchangeTransactionsDataModel]?
}
class ExchangeModel: NSObject {
    private var requests: [Cancellable] = []
    @objc dynamic var dataDic: NSMutableDictionary = [:]
    func getExchangeTransactions(address: String, page: Int, pageSize: Int, requestStatus: Int) {
        let type = requestStatus == 0 ? "ExchangeTransactionsOrigin":"ExchangeTransactionsMore"
        let request = mainProvide.request(.ExchangeTransactions(address, page, pageSize)) {[weak self](result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(ExchangeTransactionsMainModel.self)
                    if json.code == 2000 {
                        guard json.data?.isEmpty == false else {
                            if requestStatus == 0 {
                                let data = setKVOData(error: LibraWalletError.WalletRequest(reason: .dataEmpty), type: type)
                                self?.setValue(data, forKey: "dataDic")
                            } else {
                                let data = setKVOData(error: LibraWalletError.WalletRequest(reason: .noMoreData), type: type)
                                self?.setValue(data, forKey: "dataDic")
                            }
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
                print(error.localizedDescription)
                let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.networkInvalid), type: type)
                self?.setValue(data, forKey: "dataDic")
            }
        }
        self.requests.append(request)
    }
    func getMarketSupportTokens() {
        let request = mainProvide.request(.MarketSupportTokens) {[weak self](result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(MarketSupportTokensMainModel.self)
                    if json.code == 2000 {
                        guard json.data?.isEmpty == false else {
                            let data = setKVOData(error: LibraWalletError.WalletRequest(reason: .dataEmpty), type: "GetMarketSupportTokens")
                            self?.setValue(data, forKey: "dataDic")
                            return
                        }
                        let data = setKVOData(type: "GetMarketSupportTokens", data: json.data)
                        self?.setValue(data, forKey: "dataDic")
                    } else {
                        print("GetMarketSupportTokens_状态异常")
                        if let message = json.message, message.isEmpty == false {
                            let data = setKVOData(error: LibraWalletError.error(message), type: "GetMarketSupportTokens")
                            self?.setValue(data, forKey: "dataDic")
                        } else {
                            let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.dataCodeInvalid), type: "GetMarketSupportTokens")
                            self?.setValue(data, forKey: "dataDic")
                        }
                    }
                } catch {
                    print("GetMarketSupportTokens_解析异常\(error.localizedDescription)")
                    let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.parseJsonError), type: "GetMarketSupportTokens")
                    self?.setValue(data, forKey: "dataDic")
                }
            case let .failure(error):
                guard error.errorCode != -999 else {
                    print("网络请求已取消")
                    return
                }
                let data = setKVOData(error: LibraWalletError.WalletRequest(reason: .networkInvalid), type: "GetLibraTokens")
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
        print("ExchangeModel销毁了")
    }
}
