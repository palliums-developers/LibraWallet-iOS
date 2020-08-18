//
//  HomeModel.swift
//  LibraWallet
//
//  Created by palliums on 2019/9/11.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit
import Moya

struct ModelPriceDataModel: Codable {
    var name: String?
    var rate: Double?
}
struct ModelPriceMainModel: Codable {
    var code: Int?
    var message: String?
    var data: [ModelPriceDataModel]?
}
struct ActiveAccountMainModel: Codable {
    var code: Int?
    var message: String?
}
struct ScanLoginDataModel: Codable {
    var type: Int?
    var session_id: String?
}
struct LibraBalanceModel: Codable {
    var amount: Int64?
    var currency: String?
}
struct BalanceLibraModel: Codable {
    /// 余额
    var balances: [LibraBalanceModel]?
    /// 验证密钥
    var authentication_key: String?
    ///
    var delegated_key_rotation_capability: Bool?
    ///
    var delegated_withdrawal_capability: Bool?
    ///
    var received_events_key: String?
    ///
    var sent_events_key: String?
    ///
    var sequence_number: UInt64?
}
struct BalanceLibraMainModel: Codable {
    /// 请求ID
    var id: String?
    /// JSON RPC版本
    var jsonrpc: String?
    /// 数据体
    var result: BalanceLibraModel?
    var error: LibraTransferErrorModel?
}
struct ViolasBalanceModel: Codable {
    var amount: Int64?
    var currency: String?
}
struct BalanceViolasModel: Codable {
    /// 余额
    var balances: [ViolasBalanceModel]?
    /// 验证密钥
    var authentication_key: String?
    ///
    var delegated_key_rotation_capability: Bool?
    ///
    var delegated_withdrawal_capability: Bool?
    ///
    var received_events_key: String?
    ///
    var sent_events_key: String?
    ///
    var sequence_number: UInt64?
}
struct BalanceViolasMainModel: Codable {
    /// 请求ID
    var id: String?
    /// JSON RPC版本
    var jsonrpc: String?
    /// 数据体
    var result: BalanceViolasModel?
    var error: LibraTransferErrorModel?
}
struct TrezorBTCBalanceMainModel: Codable {
    ///
    var page: Int64?
    ///
    var totalPages: Int64?
    ///
    var itemsOnPage: Int64?
    /// 地址
    var address: String?
    /// 当前余额
    var balance: String?
    /// 总接收
    var totalReceived: String?
    /// 总支出
    var totalSent: String?
    /// 未确认余额
    var unconfirmedBalance: String?
    ///
    var unconfirmedTxs: Int64?
    ///
    var txs: Int64?
    ///
    var txids: [String]?
}
class HomeModel: NSObject {
    private var requests: [Cancellable] = []
    @objc dynamic var dataDic: NSMutableDictionary = [:]
    private var activeCount: Int = 0
    func getLocalTokens() {
        do {
            let tokens = try DataBaseManager.DBManager.getTokens()
            let data = setKVOData(type: "LoadCurrentEnableTokens", data: tokens)
            self.setValue(data, forKey: "dataDic")
            // 更新本地数据
            let group = DispatchGroup.init()
            let quene = DispatchQueue.init(label: "SupportTokenQuene")
            let btcToken = tokens.filter {
                $0.tokenType == .BTC
            }
            quene.async(group: group, qos: .default, flags: [], execute: {
                guard btcToken.isEmpty == false else {
                    return
                }
                // 更新BTC数量
                self.getBTCBalance(tokenID: btcToken.first!.tokenID, address: btcToken.first!.tokenAddress, tokens: tokens)
            })
            let violasToken = tokens.filter {
                $0.tokenType == .Violas
            }
            quene.async(group: group, qos: .default, flags: [], execute: {
                guard violasToken.isEmpty == false else {
                    return
                }
                // 更新Violas数量
                self.getViolasBalance(tokenID: violasToken.first!.tokenID, address: violasToken.first!.tokenAddress, authKey: violasToken.first!.tokenAuthenticationKey, tokens: tokens)
            })
            let libraToken = tokens.filter {
                $0.tokenType == .Libra
            }
            quene.async(group: group, qos: .default, flags: [], execute: {
                guard libraToken.isEmpty == false else {
                    return
                }
                // 更新Libra数量
                self.getLibraBalance(tokenID: libraToken.first!.tokenID, address: libraToken.first!.tokenAddress, authKey: libraToken.first!.tokenAuthenticationKey, tokens: tokens)
            })
            quene.async(group: group, qos: .default, flags: [], execute: {
                guard btcToken.isEmpty == false else {
                    return
                }
                group.enter()
                // 更新BTC价格
                self.getBTCPrice(address: btcToken.first!.tokenAddress, group: group)
            })
            quene.async(group: group, qos: .default, flags: [], execute: {
                guard violasToken.isEmpty == false else {
                    return
                }
                group.enter()
                // 更新Violas价格
                self.getViolasPrice(address: violasToken.first!.tokenAddress, group: group)
            })
            quene.async(group: group, qos: .default, flags: [], execute: {
                guard libraToken.isEmpty == false else {
                    return
                }
                group.enter()
                // 更新Libra价格
                self.getLibraPrice(address: libraToken.first!.tokenAddress, group: group)
            })
            group.notify(queue: quene) {
                print("回到该队列中执行")
                DispatchQueue.main.async(execute: {
                    let data = setKVOData(type: "GetTotalPrice", data: "GetTotalPrice")
                    self.setValue(data, forKey: "dataDic")
                })
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    func getBTCBalance(tokenID: Int64, address: String, tokens: [Token]) {
        let request = mainProvide.request(.TrezorBTCBalance(address)) {[weak self](result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(TrezorBTCBalanceMainModel.self)
                    let data = setKVOData(type: "UpdateBTCBalance", data: json)
                    self?.setValue(data, forKey: "dataDic")
                    // 刷新本地数据
                    self?.updateLocalBTCBalance(tokenID: tokenID, balance: NSDecimalNumber.init(string: json.balance ?? "").int64Value)
                } catch {
                    print("UpdateBTCBalance_解析异常\(error.localizedDescription)")
                    let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.parseJsonError), type: "UpdateBTCBalance")
                    self?.setValue(data, forKey: "dataDic")
                }
            case let .failure(error):
                guard error.errorCode != -999 else {
                    print("UpdateBTCBalance_网络请求已取消")
                    return
                }
                let data = setKVOData(error: LibraWalletError.WalletRequest(reason: .networkInvalid), type: "UpdateBTCBalance")
                self?.setValue(data, forKey: "dataDic")
            }
        }
        self.requests.append(request)
    }
    func getLibraBalance(tokenID: Int64, address: String, authKey: String, tokens: [Token]) {
        let request = mainProvide.request(.GetLibraAccountBalance(address)) {[weak self](result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(BalanceLibraMainModel.self)
                    if json.result == nil {
                        if (self?.activeCount ?? 0) < 5 {
                            self?.activeLibraAccount(tokenID: tokenID, address: address, authKey: authKey, tokens: tokens)
                            self?.activeCount += 1
                        } else {
                            let data = setKVOData(type: "UpdateLibraBalance", data: [LibraBalanceModel.init(amount: 0, currency: "LBR")])
                            self?.setValue(data, forKey: "dataDic")
                            print("激活失败")
                        }
                    } else {
                        let data = setKVOData(type: "UpdateLibraBalance", data: json.result?.balances)
                        self?.setValue(data, forKey: "dataDic")
                    }
                    // 刷新本地数据
                    self?.updateLocalTokenBalance(tokens: tokens, type: .Libra, tokenBalances: json.result?.balances ?? [LibraBalanceModel.init(amount: 0, currency: "LBR")])
                } catch {
                    print("UpdateLibraBalance_解析异常\(error.localizedDescription)")
                    let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.parseJsonError), type: "UpdateLibraBalance")
                    self?.setValue(data, forKey: "dataDic")
                }
            case let .failure(error):
                guard error.errorCode != -999 else {
                    print("UpdateLibraBalance_网络请求已取消")
                    return
                }
                let data = setKVOData(error: LibraWalletError.WalletRequest(reason: .networkInvalid), type: "UpdateLibraBalance")
                self?.setValue(data, forKey: "dataDic")
            }
        }
        self.requests.append(request)
    }
    func getViolasBalance(tokenID: Int64, address: String, authKey: String, tokens: [Token]) {
        let request = mainProvide.request(.GetViolasAccountInfo(address)) {[weak self](result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(BalanceViolasMainModel.self)
                    if json.result == nil {
                        if (self?.activeCount ?? 0) < 5 {
                            self?.activeViolasAccount(tokenID: tokenID, address: address, authKey: authKey, tokens: tokens)
                            self?.activeCount += 1
                        } else {
                            let data = setKVOData(type: "UpdateViolasBalance", data: [ViolasBalanceModel.init(amount: 0, currency: "LBR")])
                            self?.setValue(data, forKey: "dataDic")
                            print("激活失败")
                        }
                    } else {
                        let data = setKVOData(type: "UpdateViolasBalance", data: json.result?.balances)
                        self?.setValue(data, forKey: "dataDic")
                    }
                    // 刷新本地数据
                    self?.updateLocalTokenBalance(tokens: tokens, type: .Violas, tokenBalances: json.result?.balances ?? [ViolasBalanceModel.init(amount: 0, currency: "LBR")])
                } catch {
                    print("UpdateViolasBalance_解析异常\(error.localizedDescription)")
                    let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.parseJsonError), type: "UpdateViolasBalance")
                    self?.setValue(data, forKey: "dataDic")
                }
            case let .failure(error):
                guard error.errorCode != -999 else {
                    print("UpdateViolasBalance_网络请求已取消")
                    return
                }
                let data = setKVOData(error: LibraWalletError.WalletRequest(reason: .networkInvalid), type: "UpdateViolasBalance")
                self?.setValue(data, forKey: "dataDic")
            }
        }
        self.requests.append(request)
    }
    func getBTCPrice(address: String, group: DispatchGroup) {
        let request = mainProvide.request(.GetBTCPrice) {[weak self](result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(ModelPriceMainModel.self)
                    if json.code == 2000 {
                        guard let models = json.data, models.isEmpty == false else {
                            let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.dataEmpty), type: "GetBTCPrice")
                            self?.setValue(data, forKey: "dataDic")
                            print("GetBTCPrice_状态异常")
                            return
                        }
                        let data = setKVOData(type: "GetBTCPrice", data: json.data)
                        self?.setValue(data, forKey: "dataDic")
                    } else {
                        print("GetBTCPrice_状态异常")
                        if let message = json.message, message.isEmpty == false {
                            let data = setKVOData(error: LibraWalletError.error(message), type: "GetBTCPrice")
                            self?.setValue(data, forKey: "dataDic")
                        } else {
                            let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.dataCodeInvalid), type: "GetBTCPrice")
                            self?.setValue(data, forKey: "dataDic")
                        }
                    }
                } catch {
                    print("GetBTCPrice_解析异常\(error.localizedDescription)")
                    let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.parseJsonError), type: "GetBTCPrice")
                    self?.setValue(data, forKey: "dataDic")
                }
            case let .failure(error):
                guard error.errorCode != -999 else {
                    print("GetBTCPrice_网络请求已取消")
                    return
                }
                let data = setKVOData(error: LibraWalletError.WalletRequest(reason: .networkInvalid), type: "GetBTCPrice")
                self?.setValue(data, forKey: "dataDic")
            }
            group.leave()
        }
        self.requests.append(request)
    }
    func getViolasPrice(address: String, group: DispatchGroup) {
        let request = mainProvide.request(.GetViolasPrice(address)) {[weak self](result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(ModelPriceMainModel.self)
                    if json.code == 2000 {
                        guard let models = json.data, models.isEmpty == false else {
                            let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.dataEmpty), type: "GetViolasPrice")
                            self?.setValue(data, forKey: "dataDic")
                            print("GetViolasPrice_状态异常")
                            return
                        }
                        let data = setKVOData(type: "GetViolasPrice", data: json.data)
                        self?.setValue(data, forKey: "dataDic")
                    } else {
                        print("GetViolasPrice_状态异常")
                        if let message = json.message, message.isEmpty == false {
                            let data = setKVOData(error: LibraWalletError.error(message), type: "GetViolasPrice")
                            self?.setValue(data, forKey: "dataDic")
                        } else {
                            let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.dataCodeInvalid), type: "GetViolasPrice")
                            self?.setValue(data, forKey: "dataDic")
                        }
                    }
                } catch {
                    print("GetViolasPrice_解析异常\(error.localizedDescription)")
                    let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.parseJsonError), type: "GetViolasPrice")
                    self?.setValue(data, forKey: "dataDic")
                }
            case let .failure(error):
                guard error.errorCode != -999 else {
                    print("GetViolasPrice_网络请求已取消")
                    return
                }
                let data = setKVOData(error: LibraWalletError.WalletRequest(reason: .networkInvalid), type: "GetViolasPrice")
                self?.setValue(data, forKey: "dataDic")
            }
            group.leave()
        }
        self.requests.append(request)
    }
    func getLibraPrice(address: String, group: DispatchGroup) {
        let request = mainProvide.request(.GetLibraPrice(address)) {[weak self](result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(ModelPriceMainModel.self)
                    if json.code == 2000 {
                        guard let models = json.data, models.isEmpty == false else {
                            let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.dataEmpty), type: "GetLibraPrice")
                            self?.setValue(data, forKey: "dataDic")
                            print("GetLibraPrice_状态异常")
                            return
                        }
                        let data = setKVOData(type: "GetLibraPrice", data: json.data)
                        self?.setValue(data, forKey: "dataDic")
                    } else {
                        print("GetLibraPrice_状态异常")
                        if let message = json.message, message.isEmpty == false {
                            let data = setKVOData(error: LibraWalletError.error(message), type: "GetLibraPrice")
                            self?.setValue(data, forKey: "dataDic")
                        } else {
                            let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.dataCodeInvalid), type: "GetLibraPrice")
                            self?.setValue(data, forKey: "dataDic")
                        }
                    }
                } catch {
                    print("GetLibraPrice_解析异常\(error.localizedDescription)")
                    let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.parseJsonError), type: "GetLibraPrice")
                    self?.setValue(data, forKey: "dataDic")
                }
            case let .failure(error):
                guard error.errorCode != -999 else {
                    print("GetLibraPrice_网络请求已取消")
                    return
                }
                let data = setKVOData(error: LibraWalletError.WalletRequest(reason: .networkInvalid), type: "UpdateViolasBalance")
                self?.setValue(data, forKey: "dataDic")
            }
            group.leave()
        }
        self.requests.append(request)
    }
    func updateLocalTokenBalance(tokens: [Token], type: WalletType, tokenBalances: [LibraBalanceModel]) {
        // 刷新本地缓存数据
        let tempTokens = tokens.filter {
            $0.tokenType == type
        }
        for model in tokenBalances {
            for token in tempTokens {
                if model.currency == token.tokenModule {
                    let result = DataBaseManager.DBManager.updateTokenBalance(tokenID: token.tokenID, balance: model.amount ?? 0)
                    print("刷新\(type.description)类型本地tokenID数据状态: \(result),walletID = \(token.tokenID)")
                    continue
                }
            }
        }
    }
    func updateLocalTokenBalance(tokens: [Token], type: WalletType, tokenBalances: [ViolasBalanceModel]) {
        // 刷新本地缓存数据
        let tempTokens = tokens.filter {
            $0.tokenType == type
        }
        for model in tokenBalances {
            for token in tempTokens {
                if model.currency == token.tokenModule {
                    let result = DataBaseManager.DBManager.updateTokenBalance(tokenID: token.tokenID, balance: model.amount ?? 0)
                    print("刷新\(type.description)类型本地tokenID数据状态: \(result),walletID = \(token.tokenID)")
                    continue
                }
            }
        }
    }
    func updateLocalBTCBalance(tokenID: Int64, balance: Int64) {
        // 刷新本地缓存数据
        let result = DataBaseManager.DBManager.updateTokenBalance(tokenID: tokenID, balance: balance)
        print("刷新BTC类型本地tokenID数据状态: \(result),walletID = \(tokenID)")
    }
    deinit {
        requests.forEach { cancellable in
            cancellable.cancel()
        }
        requests.removeAll()
        print("HomeModel销毁了")
    }
}
extension HomeModel {
    func activeLibraAccount(tokenID: Int64, address: String, authKey: String, tokens: [Token]) {
        let request = mainProvide.request(.ActiveLibraAccount(authKey)) {[weak self](result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(ActiveAccountMainModel.self)
                    if json.code == 2000 {
                        var tempTokens = [Token]()
                        for var item in tokens  {
                            item.changeTokenActiveState(state: true)
                            tempTokens.append(item)
                        }
                        self?.getLibraBalance(tokenID: tokenID, address: address, authKey: authKey, tokens: tempTokens)
                        self?.updateLocalTokenActiveState(tokens: tokens, type: .Libra)
                    } else {
                        let data = setKVOData(error: LibraWalletError.error("Active Error"), type: "ActiveLibraAccount")
                        self?.setValue(data, forKey: "dataDic")
                    }
                } catch {
                    print("ActiveLibraAccount_解析异常\(error.localizedDescription)")
                    let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.parseJsonError), type: "ActiveLibraAccount")
                    self?.setValue(data, forKey: "dataDic")
                }
            case let .failure(error):
                guard error.errorCode != -999 else {
                    print("ActiveLibraAccount_网络请求已取消")
                    return
                }
                let data = setKVOData(error: LibraWalletError.WalletRequest(reason: .networkInvalid), type: "ActiveLibraAccount")
                self?.setValue(data, forKey: "dataDic")
            }
        }
        self.requests.append(request)
    }
    func activeViolasAccount(tokenID: Int64, address: String, authKey: String, tokens: [Token]) {
        let request = mainProvide.request(.ActiveViolasAccount(authKey)) {[weak self](result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(ActiveAccountMainModel.self)
                    if json.code == 2000 {
                        var tempTokens = [Token]()
                        for var item in tokens  {
                            item.changeTokenActiveState(state: true)
                            tempTokens.append(item)
                        }
                        self?.getViolasBalance(tokenID: tokenID, address: address, authKey: authKey, tokens: tempTokens)
                        self?.updateLocalTokenActiveState(tokens: tokens, type: .Violas)
                    } else {
                        let data = setKVOData(error: LibraWalletError.error("Active Error"), type: "ActiveViolasAccount")
                        self?.setValue(data, forKey: "dataDic")
                    }
                } catch {
                    print("ActiveViolasAccount_解析异常\(error.localizedDescription)")
                    let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.parseJsonError), type: "ActiveViolasAccount")
                    self?.setValue(data, forKey: "dataDic")
                }
            case let .failure(error):
                guard error.errorCode != -999 else {
                    print("ActiveViolasAccount_网络请求已取消")
                    return
                }
                let data = setKVOData(error: LibraWalletError.WalletRequest(reason: .networkInvalid), type: "ActiveViolasAccount")
                self?.setValue(data, forKey: "dataDic")
            }
        }
        self.requests.append(request)
    }
    func updateLocalTokenActiveState(tokens: [Token], type: WalletType) {
        for token in tokens {
            _ = DataBaseManager.DBManager.updateTokenActiveState(tokenID: token.tokenID, state: true)
        }
    }
}
