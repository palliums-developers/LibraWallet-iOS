//
//  HomeModel.swift
//  LibraWallet
//
//  Created by palliums on 2019/9/11.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit
import Moya
struct ViolasAccountInfoDataModel: Codable {
    var authentication_key: String?
}
struct ViolasAccountInfoMainModel: Codable {
    var code: Int?
    var message: String?
    var data: ViolasAccountInfoDataModel?
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
    var sequence_number: Int64?
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
    var sequence_number: Int64?
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
struct BalanceBTCModel: Codable {
    /// 地址
    var address: String?
    /// 总接收
    var received: Int?
    /// 总支出
    var sent: Int?
    /// 当前余额
    var balance: Int64?
    /// 交易数量
    var tx_count: Int?
    /// 未确认交易数量
    var unconfirmed_tx_count: Int?
    /// 未确认总接收
    var unconfirmed_received: Int?
    /// 未确认总支出
    var unconfirmed_sent: Int?
    /// 未花费交易数量D
    var unspent_tx_count: Int?
    /// 第一笔交易
    var first_tx: String?
    /// 最后一笔交易
    var last_tx: String?
}
struct BalanceBTCMainModel: Codable {
    var err_no: Int?
    var data: BalanceBTCModel?
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
                self.getViolasBalance(tokenID: violasToken.first!.tokenID, address: violasToken.first!.tokenAddress, tokens: tokens)
            })
            let libraToken = tokens.filter {
                $0.tokenType == .Libra
            }
            quene.async(group: group, qos: .default, flags: [], execute: {
                guard libraToken.isEmpty == false else {
                    return
                }
                // 更新Libra数量
                self.getLibraBalance(tokenID: libraToken.first!.tokenID, address: libraToken.first!.tokenAddress, tokens: tokens)
            })
            quene.async(group: group, qos: .default, flags: [], execute: {
                // 更新BTC价格
            })
            quene.async(group: group, qos: .default, flags: [], execute: {
                // 更新Violas价格
            })
            quene.async(group: group, qos: .default, flags: [], execute: {
                // 更新Libra价格
            })
            group.notify(queue: quene) {
                print("回到该队列中执行")
                DispatchQueue.main.async(execute: {

//                    let tempResult = self.rebuiltData(walletTokenEnable: state, marketTokens: marketTokens)
//                    let finalResult = self.dealModelWithSelect(walletID: walletID, models: tempResult)
                    
                    let data = setKVOData(type: "UpdateLocalTokenBalance", data: "finalResult")
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
    func getLibraBalance(tokenID: Int64, address: String, tokens: [Token]) {
        let request = mainProvide.request(.GetLibraAccountBalance(address)) {[weak self](result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(BalanceLibraMainModel.self)
                    if json.result == nil {
                        let data = setKVOData(type: "UpdateLibraBalance", data: [LibraBalanceModel.init(amount: 0, currency: "LBR")])
                        self?.setValue(data, forKey: "dataDic")
                        print("激活失败")
                    } else {
                        let data = setKVOData(type: "UpdateLibraBalance", data: json.result?.balances)
                        self?.setValue(data, forKey: "dataDic")
                    }
                    // 刷新本地数据
                    self?.updateLocalTokenBalance(tokens: tokens, type: .Libra, tokenBalances: json.result?.balances ?? [LibraBalanceModel.init(amount: 0, currency: "LBR")])
                } catch {
                    print("解析异常\(error.localizedDescription)")
                    let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.parseJsonError), type: "UpdateLibraBalance")
                    self?.setValue(data, forKey: "dataDic")
                }
            case let .failure(error):
                guard error.errorCode != -999 else {
                    print("网络请求已取消")
                    return
                }
                let data = setKVOData(error: LibraWalletError.WalletRequest(reason: .networkInvalid), type: "UpdateLibraBalance")
                self?.setValue(data, forKey: "dataDic")
            }
        }
        self.requests.append(request)
    }
//    func activeLibraAccount(tokenID: Int64, address: String, authKey: String, tokens: [Token]) {
//        let request = mainProvide.request(.ActiveLibraAccount(authKey)) {[weak self](result) in
//            switch  result {
//            case let .success(response):
//                do {
//                    let json = try response.map(ActiveAccountMainModel.self)
//                    if json.code == 2000 {
//                        self?.getLibraBalance(tokenID: tokenID, address: address, authKey: authKey, tokens: tokens)
//                        self?.updateLocalTokenActiveState(tokens: tokens, type: .Libra)
//                    } else {
//                        let data = setKVOData(error: LibraWalletError.error("Active Error"), type: "ActiveLibraAccount")
//                        self?.setValue(data, forKey: "dataDic")
//                    }
//                } catch {
//                    print("ActiveLibraAccount_解析异常\(error.localizedDescription)")
//                    let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.parseJsonError), type: "ActiveLibraAccount")
//                    self?.setValue(data, forKey: "dataDic")
//                }
//            case let .failure(error):
//                guard error.errorCode != -999 else {
//                    print("ActiveLibraAccount_网络请求已取消")
//                    return
//                }
//                let data = setKVOData(error: LibraWalletError.WalletRequest(reason: .networkInvalid), type: "ActiveLibraAccount")
//                self?.setValue(data, forKey: "dataDic")
//            }
//        }
//        self.requests.append(request)
//    }
    func getViolasBalance(tokenID: Int64, address: String, tokens: [Token]) {
        let request = mainProvide.request(.GetViolasAccountInfo(address)) {[weak self](result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(BalanceViolasMainModel.self)
                    if json.result == nil {
                        let data = setKVOData(type: "UpdateViolasBalance", data: [ViolasBalanceModel.init(amount: 0, currency: "LBR")])
                        self?.setValue(data, forKey: "dataDic")
                        print("激活失败")
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
//    func activeViolasAccount(tokenID: Int64, address: String, authKey: String, tokens: [Token]) {
//        let request = mainProvide.request(.ActiveViolasAccount(authKey)) {[weak self](result) in
//            switch  result {
//            case let .success(response):
//                do {
//                    let json = try response.map(ActiveAccountMainModel.self)
//                    if json.code == 2000 {
//                        self?.getViolasBalance(tokenID: tokenID, address: address, authKey: authKey, tokens: tokens)
//                        self?.updateLocalTokenActiveState(tokens: tokens, type: .Violas)
//                    } else {
//                        let data = setKVOData(error: LibraWalletError.error("Active Error"), type: "ActiveViolasAccount")
//                        self?.setValue(data, forKey: "dataDic")
//                    }
//                } catch {
//                    print("ActiveViolasAccount_解析异常\(error.localizedDescription)")
//                    let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.parseJsonError), type: "ActiveViolasAccount")
//                    self?.setValue(data, forKey: "dataDic")
//                }
//            case let .failure(error):
//                guard error.errorCode != -999 else {
//                    print("ActiveViolasAccount_网络请求已取消")
//                    return
//                }
//                let data = setKVOData(error: LibraWalletError.WalletRequest(reason: .networkInvalid), type: "ActiveViolasAccount")
//                self?.setValue(data, forKey: "dataDic")
//            }
//        }
//        self.requests.append(request)
//    }

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
    func updateLocalTokenActiveState(tokens: [Token], type: WalletType) {
        for token in tokens {
            _ = DataBaseManager.DBManager.updateTokenActiveState(tokenID: token.tokenID, state: true)
        }
    }
    func updateLocalWalletTokenData(walletID: Int64, modules: [ViolasBalanceModel]) {
        // 刷新本地缓存数据
        for item in modules {
//            let result = DataBaseManager.DBManager.updateViolasTokenBalance(walletID: walletID, model: item)
//            print("刷新本地钱包Token数据状态: \(result),walletID = \(walletID)")
        }
    }
    deinit {
        requests.forEach { cancellable in
            cancellable.cancel()
        }
        requests.removeAll()
        print("HomeModel销毁了")
    }
}
