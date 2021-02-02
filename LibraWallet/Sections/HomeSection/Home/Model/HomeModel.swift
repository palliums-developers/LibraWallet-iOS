//
//  HomeModel.swift
//  LibraWallet
//
//  Created by palliums on 2019/9/11.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit
import Moya
import Localize_Swift

struct isNewWalletDataModel: Codable {
    var is_new: Int?
}
struct isNewWalletMainModel: Codable {
    var code: Int?
    var message: String?
    var data: isNewWalletDataModel?
}
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
    private var activeDiemCount: Int = 0
    func updateLocalTokenBalance(tokens: [Token], type: WalletType, tokenBalances: [DiemBalanceDataModel]) {
        // 刷新本地缓存数据
        let tempTokens = tokens.filter {
            $0.tokenType == type
        }
        WalletManager.updateLibraTokensBalance(tokens: tempTokens, tokenBalances: tokenBalances)
    }
    func updateLocalTokenBalance(tokens: [Token], type: WalletType, tokenBalances: [ViolasBalanceDataModel]) {
        // 刷新本地缓存数据
        let tempTokens = tokens.filter {
            $0.tokenType == type
        }
        WalletManager.updateViolasTokensBalance(tokens: tempTokens, tokenBalances: tokenBalances)
    }
    func updateLocalBTCBalance(tokenID: Int64, balance: Int64) {
        // 刷新本地缓存数据
        WalletManager.updateBitcoinBalance(tokenID: tokenID, balance: balance)
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
    func updateLocalTokenActiveState(tokens: [Token], type: WalletType) {
        for token in tokens {
            do {
                try WalletManager.updateTokenActiveState(tokenID: token.tokenID)
            } catch {
                print(error)
            }
        }
    }
    func activeViolasAccountTemp(tokenID: Int64, address: String, authKey: String, tokens: [Token], completion: @escaping (Result<[ViolasBalanceDataModel], LibraWalletError>) -> Void) {
        let request = violasModuleProvide.request(.activeAccount(authKey, address)) { [weak self] (result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(ActiveAccountMainModel.self)
                    if json.code == 2000 {
                        self?.getViolasBalanceTemp(tokenID: tokenID, address: address, authKey: authKey, tokens: tokens) { (result) in
                            switch  result {
                            case let .success(models):
                                // 更新本地数据库
                                self?.updateLocalTokenActiveState(tokens: tokens, type: .Violas)
                                completion(.success(models))
                            case .failure(_):
                                completion(.success([ViolasBalanceDataModel]()))
                            }
                        }
                    } else {
                        print("ActiveViolasAccount_失败")
                        completion(.failure(LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.dataCodeInvalid)))
                    }
                } catch {
                    print("ActiveViolasAccount_解析异常\(error.localizedDescription)")
                    completion(.failure(LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.parseJsonError)))
                }
            case let .failure(error):
                guard error.errorCode != -999 else {
                    print("ActiveViolasAccount_网络请求已取消")
                    return
                }
                completion(.failure(LibraWalletError.WalletRequest(reason: .networkInvalid)))
            }
        }
        self.requests.append(request)
    }
    func activeDiemAccountTemp(tokenID: Int64, address: String, authKey: String, tokens: [Token], completion: @escaping (Result<[DiemBalanceDataModel], LibraWalletError>) -> Void) {
        let request = libraModuleProvide.request(.activeAccount(address, authKey)) { [weak self] (result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(ActiveAccountMainModel.self)
                    if json.code == 2000 {
                        self?.getDiemBalanceTemp(tokenID: tokenID, address: address, authKey: authKey, tokens: tokens) { (result) in
                            switch  result {
                            case let .success(models):
                                // 更新本地数据库
                                self?.updateLocalTokenActiveState(tokens: tokens, type: .Libra)
                                completion(.success(models))
                            case .failure(_):
                                completion(.success([DiemBalanceDataModel]()))
                            }
                        }
                    } else {
                        print("ActiveViolasAccount_失败")
                        completion(.success([DiemBalanceDataModel]()))
                    }
                } catch {
                    print("ActiveViolasAccount_解析异常\(error.localizedDescription)")
                    completion(.failure(LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.parseJsonError)))
                }
            case let .failure(error):
                guard error.errorCode != -999 else {
                    print("ActiveViolasAccount_网络请求已取消")
                    return
                }
                completion(.failure(LibraWalletError.WalletRequest(reason: .networkInvalid)))
            }
        }
        self.requests.append(request)
    }
}
// MARK: 查询是否是新钱包
extension HomeModel {
    func isNewWallet(address: String, completion: @escaping (Result<Bool, LibraWalletError>) -> Void) {
        let request = ActiveModuleProvide.request(.isNewWallet(address)) { (result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(isNewWalletMainModel.self)
                    if json.code == 2000 {
                        let state = json.data?.is_new == 0 ? true:false
                        do {
                            WalletManager.shared.changeWalletIsNewState(state: state)
                            try WalletManager.updateIsNewWallet()
                        } catch {
                            print(error.localizedDescription)
                        }
                        completion(.success(state))
                    } else {
                        print("IsNewWallet_状态异常")
                        if let message = json.message, message.isEmpty == false {
                            completion(.failure(LibraWalletError.error(message)))
                        } else {
                            completion(.failure(LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.dataCodeInvalid)))
                        }
                    }
                } catch {
                    print("IsNewWallet_解析异常\(error.localizedDescription)")
                    completion(.failure(LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.parseJsonError)))
                }
            case let .failure(error):
                guard error.errorCode != -999 else {
                    print("IsNewWallet_网络请求已取消")
                    return
                }
                completion(.failure(LibraWalletError.WalletRequest(reason: .networkInvalid)))
            }
        }
        self.requests.append(request)
    }
}
// MARK: 注册FCM Token
extension HomeModel {
    func registerFCMToken(address: String, token: String, completion: @escaping (Result<Bool, LibraWalletError>) -> Void) {
        let request = notificationModuleProvide.request(.registerNotification(address, token, "apple", Localize.currentLanguage())) { (result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(isNewWalletMainModel.self)
                    if json.code == 2000 {
                        completion(.success(true))
                    } else {
                        print("RegisterFCMToken_状态异常")
                        if let message = json.message, message.isEmpty == false {
                            completion(.failure(LibraWalletError.error(message)))
                        } else {
                            completion(.failure(LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.dataCodeInvalid)))
                        }
                    }
                } catch {
                    print("RegisterFCMToken_解析异常\(error.localizedDescription)")
                    completion(.failure(LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.parseJsonError)))
                }
            case let .failure(error):
                guard error.errorCode != -999 else {
                    print("RegisterFCMToken_网络请求已取消")
                    return
                }
                completion(.failure(LibraWalletError.WalletRequest(reason: .networkInvalid)))
            }
        }
        self.requests.append(request)
    }
}
// MARK: 获取Token
extension HomeModel {
    struct TokenDataModel {
        var tokens: [Token]
        var indexPath: [IndexPath]
        var totalPrice: String
    }
    func getTokens(completion: @escaping (Result<TokenDataModel, LibraWalletError>) -> Void) {
        do {
            // 加载本地数据
            let tokens = try WalletManager.getLocalEnableTokens()
            completion(.success(TokenDataModel.init(tokens: tokens, indexPath: [IndexPath](), totalPrice: "0")))
            // 更新本地数据
            updateTokensInfo(tokens: tokens, completion: completion)
        } catch {
            print(error.localizedDescription)
        }
    }
    private func updateTokensInfo(tokens: [Token], completion: @escaping (Result<TokenDataModel, LibraWalletError>) -> Void) {
        // 更新本地数据
        let group = DispatchGroup.init()
        let quene = DispatchQueue.init(label: "SupportTokenQuene")
        var violasAddress = ""
        var diemAddress = ""
        var btcAddress = ""
        var tempTokens = tokens
        for i in 0..<tokens.count {
            print(i)
            let token = tokens[i]
            if token.tokenType == .BTC && token.tokenEnable == true && btcAddress.isEmpty == true {
                print("查询到BTC 地址")
                btcAddress = token.tokenAddress
                quene.async(group: group, qos: .default, flags: [], execute: {
                    // 更新BTC数量
                    self.getBTCBalanceTemp(tokenID: token.tokenID, address: btcAddress) { (result) in
                        switch result {
                        case let .success(model):
                            if NSDecimalNumber.init(string: model.balance).int64Value != tempTokens[i].tokenBalance {
                                tempTokens[i].changeTokenBalance(banlance: NSDecimalNumber.init(string: model.balance ?? "0").int64Value)
                                let tempIndexPath = IndexPath.init(row: i, section: 0)
                                DispatchQueue.main.async(execute: {
                                    if tempIndexPath.isEmpty == false {
                                        completion(.success(TokenDataModel.init(tokens: tempTokens, indexPath: [tempIndexPath], totalPrice: "0")))
                                    }
                                })
                            }
                        case let .failure(error):
                            print(error.localizedDescription)
                            DispatchQueue.main.async(execute: {
                                completion(.failure(error))
                            })
                        }
                    }
                })
                quene.async(group: group, qos: .default, flags: [], execute: {
                    group.enter()
                    // 更新BTC价格
                    self.getBTCPriceTemp(address:btcAddress, group: group) { (result) in
                        switch result {
                        case let .success(model):
                            if model.first?.rate ?? 0 != NSDecimalNumber.init(string: tempTokens[i].tokenPrice).doubleValue {
                                tempTokens[i].changeTokenPrice(price: NSDecimalNumber.init(value: model.first?.rate ?? 0).stringValue)
                                WalletManager.updateTokenPrice(token: tempTokens[i], price: NSDecimalNumber.init(value: model.first?.rate ?? 0).stringValue)
                                let tempIndexPath = IndexPath.init(row: i, section: 0)
                                DispatchQueue.main.async(execute: {
                                    if tempIndexPath.isEmpty == false {
                                        completion(.success(TokenDataModel.init(tokens: tempTokens, indexPath: [tempIndexPath], totalPrice: "0")))
                                    }
                                })
                            }
                        case let .failure(error):
                            print(error.localizedDescription)
                            DispatchQueue.main.async(execute: {
                                completion(.failure(error))
                            })
                        }
                    }
                })
                continue
            } else if token.tokenType == .Violas && token.tokenEnable == true && violasAddress.isEmpty == true {
                print("查询到Violas 地址")
                violasAddress = token.tokenAddress
                quene.async(group: group, qos: .default, flags: [], execute: {
                    // 更新Violas数量
                    self.getViolasBalanceTemp(tokenID: token.tokenID, address: violasAddress, authKey: token.tokenAuthenticationKey, tokens: tokens) { (result) in
                        switch result {
                        case let .success(models):
                            var tempIndexPath = [IndexPath]()
                            for j in 0..<tokens.count {
                                guard tokens[j].tokenType == .Violas else {
                                    continue
                                }
                                for currency in models {
                                    if currency.currency == tempTokens[j].tokenModule {
                                        if currency.amount != tempTokens[j].tokenBalance {
                                            tempTokens[j].changeTokenBalance(banlance: currency.amount ?? 0)
                                            tempIndexPath.append(IndexPath.init(item: j, section: 0))
                                        }
                                    }
                                    if tempTokens[j].tokenActiveState == false {
                                        tempTokens[j].changeTokenActiveState(state: true)
                                    }
                                }
                            }
                            DispatchQueue.main.async(execute: {
                                if tempIndexPath.isEmpty == false {
                                    completion(.success(TokenDataModel.init(tokens: tempTokens, indexPath: tempIndexPath, totalPrice: "0")))
                                }
                            })
                        case let .failure(error):
                            print(error.localizedDescription)
                            DispatchQueue.main.async(execute: {
                                completion(.failure(error))
                            })
                        }
                    }
                })
                quene.async(group: group, qos: .default, flags: [], execute: {
                    group.enter()
                    guard token.tokenActiveState == true else {
                        print("Violas未激活不需要更新价格")
                        group.leave()
                        return
                    }
                    // 更新Violas价格
                    self.getViolasPriceTemp(address: violasAddress, group: group) { (result) in
                        switch result {
                        case let .success(models):
                            var tempIndexPath = [IndexPath]()
                            for j in 0..<tokens.count {
                                guard tokens[j].tokenType == .Violas else {
                                    continue
                                }
                                for currency in models {
                                    if currency.name == tempTokens[j].tokenModule {
                                        if currency.rate != NSDecimalNumber.init(string: tempTokens[j].tokenPrice).doubleValue {
                                            tempTokens[j].changeTokenPrice(price: NSDecimalNumber.init(value: currency.rate ?? 0).stringValue)
                                            WalletManager.updateTokenPrice(token: tempTokens[j], price: NSDecimalNumber.init(value: currency.rate ?? 0).stringValue)
                                            tempIndexPath.append(IndexPath.init(item: j, section: 0))
                                        }
                                    }
                                }
                            }
                            DispatchQueue.main.async(execute: {
                                if tempIndexPath.isEmpty == false {
                                    completion(.success(TokenDataModel.init(tokens: tempTokens, indexPath: tempIndexPath, totalPrice: "0")))
                                }
                            })
                        case let .failure(error):
                            print(error.localizedDescription)
                            DispatchQueue.main.async(execute: {
                                completion(.failure(error))
                            })
                        }
                    }
                })
                continue
            } else if token.tokenType == .Libra && token.tokenEnable == true && diemAddress.isEmpty == true  {
                print("查询到Diem 地址")
                diemAddress = token.tokenAddress
                quene.async(group: group, qos: .default, flags: [], execute: {
                    // 更新Libra数量
                    self.getDiemBalanceTemp(tokenID: token.tokenID, address: diemAddress, authKey: token.tokenAuthenticationKey, tokens: tokens) { (result) in
                        switch result {
                        case let .success(models):
                            var tempIndexPath = [IndexPath]()
                            for j in 0..<tokens.count {
                                guard tokens[j].tokenType == .Libra else {
                                    continue
                                }
                                for currency in models {
                                    if currency.currency == tempTokens[j].tokenModule {
                                        if currency.amount != tempTokens[j].tokenBalance {
                                            tempTokens[j].changeTokenBalance(banlance: currency.amount ?? 0)
                                            tempIndexPath.append(IndexPath.init(item: j, section: 0))
                                        }
                                    }
                                    if tempTokens[j].tokenActiveState == false {
                                        tempTokens[j].changeTokenActiveState(state: true)
                                    }
                                }
                            }
                            DispatchQueue.main.async(execute: {
                                if tempIndexPath.isEmpty == false {
                                    completion(.success(TokenDataModel.init(tokens: tempTokens, indexPath: tempIndexPath, totalPrice: "0")))
                                }
                            })
                        case let .failure(error):
                            print(error.localizedDescription)
                            DispatchQueue.main.async(execute: {
                                completion(.failure(error))
                            })
                        }
                    }
                })
                quene.async(group: group, qos: .default, flags: [], execute: {
                    group.enter()
                    guard token.tokenActiveState == true else {
                        print("Diem未激活不需要更新价格")
                        group.leave()
                        return
                    }
                    // 更新Diem价格
                    self.getDiemPriceTemp(address: diemAddress, group: group) { (result) in
                        switch result {
                        case let .success(models):
                            var tempIndexPath = [IndexPath]()
                            for j in 0..<tokens.count {
                                guard tokens[j].tokenType == .Libra else {
                                    continue
                                }
                                for currency in models {
                                    if currency.name == tempTokens[j].tokenModule {
                                        if currency.rate != NSDecimalNumber.init(string: tempTokens[j].tokenPrice).doubleValue {
                                            tempTokens[j].changeTokenPrice(price: NSDecimalNumber.init(value: currency.rate ?? 0).stringValue)
                                            WalletManager.updateTokenPrice(token: tempTokens[j], price: NSDecimalNumber.init(value: currency.rate ?? 0).stringValue)
                                            tempIndexPath.append(IndexPath.init(item: j, section: 0))
                                        }
                                    }
                                }
                            }
                            DispatchQueue.main.async(execute: {
                                if tempIndexPath.isEmpty == false {
                                    completion(.success(TokenDataModel.init(tokens: tempTokens, indexPath: tempIndexPath, totalPrice: "0")))
                                }
                            })
                        case let .failure(error):
                            print(error.localizedDescription)
                            DispatchQueue.main.async(execute: {
                                completion(.failure(error))
                            })
                        }
                    }
                })
                continue
            }
            if violasAddress.isEmpty == false && diemAddress.isEmpty == false && btcAddress.isEmpty == false {
                print("查询地址轮询结束")
                break
            }
        }
        group.notify(queue: quene) {
            print("回到该队列中执行")
            var totalPrice = 0.0
            for model in tempTokens {
                var unit = 1000000
                if model.tokenType == .BTC {
                    unit = 100000000
                }
                let rate = NSDecimalNumber.init(string: model.tokenPrice)
                let amount = getDecimalNumber(amount: NSDecimalNumber.init(value: model.tokenBalance),
                                              scale: 4,
                                              unit: unit)
                let value = rate.multiplying(by: amount)
                totalPrice += value.doubleValue
            }
            let numberConfig = NSDecimalNumberHandler.init(roundingMode: .down,
                                                           scale: 4,
                                                           raiseOnExactness: false,
                                                           raiseOnOverflow: false,
                                                           raiseOnUnderflow: false,
                                                           raiseOnDivideByZero: false)
            let value = NSDecimalNumber.init(value: totalPrice).multiplying(by: 1, withBehavior: numberConfig).stringValue
            DispatchQueue.main.async(execute: {
                completion(.success(TokenDataModel.init(tokens: [Token](), indexPath: [IndexPath](), totalPrice: value)))
            })
        }
    }
}
// MARK: 更新BTC数量、价格
extension HomeModel {
    private func getBTCBalanceTemp(tokenID: Int64, address: String, completion: @escaping (Result<TrezorBTCBalanceMainModel, LibraWalletError>) -> Void) {
        let request = BTCModuleProvide.request(.TrezorBTCBalance(address)) {[weak self](result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(TrezorBTCBalanceMainModel.self)
                    completion(.success(json))
                    // 刷新本地数据
                    self?.updateLocalBTCBalance(tokenID: tokenID, balance: NSDecimalNumber.init(string: json.balance ?? "").int64Value)
                } catch {
                    print("UpdateBTCBalance_解析异常\(error.localizedDescription)")
                    completion(.failure(LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.parseJsonError)))
                }
            case let .failure(error):
                guard error.errorCode != -999 else {
                    print("UpdateBTCBalance_网络请求已取消")
                    return
                }
                completion(.failure(LibraWalletError.WalletRequest(reason: .networkInvalid)))
            }
        }
        self.requests.append(request)
    }
    private func getBTCPriceTemp(address: String, group: DispatchGroup, completion: @escaping (Result<[ModelPriceDataModel], LibraWalletError>) -> Void) {
        let request = BTCModuleProvide.request(.price) { (result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(ModelPriceMainModel.self)
                    if json.code == 2000 {
                        completion(.success(json.data ?? [ModelPriceDataModel]()))
                    } else {
                        print("GetBTCPrice_状态异常")
                        if let message = json.message, message.isEmpty == false {
                            completion(.failure(LibraWalletError.error(message)))
                        } else {
                            completion(.failure(LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.dataCodeInvalid)))
                        }
                    }
                } catch {
                    print("GetBTCPrice_解析异常\(error.localizedDescription)")
                    completion(.failure(LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.parseJsonError)))
                }
            case let .failure(error):
                guard error.errorCode != -999 else {
                    print("GetBTCPrice_网络请求已取消")
                    return
                }
                completion(.failure(LibraWalletError.WalletRequest(reason: .networkInvalid)))
            }
            group.leave()
        }
        self.requests.append(request)
    }
}
// MARK: 更新Diem数量、价格
extension HomeModel {
    private func getDiemBalanceTemp(tokenID: Int64, address: String, authKey: String, tokens: [Token], completion: @escaping (Result<[DiemBalanceDataModel], LibraWalletError>) -> Void) {
        let request = libraModuleProvide.request(.accountInfo(address)) { [weak self] (result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(DiemAccountMainModel.self)
                    if json.result == nil {
                        if (self?.activeDiemCount ?? 0) < 5 {
                            self?.activeDiemAccountTemp(tokenID: tokenID, address: address, authKey: authKey, tokens: tokens) { (result) in
                                switch result {
                                case let .success(models):
                                    completion(.success(models))
                                case .failure(_):
                                    // 激活报错
                                    completion(.success([DiemBalanceDataModel]()))
                                }
                            }
                            self?.activeDiemCount += 1
                        } else {
                            completion(.success(json.result?.balances ?? [DiemBalanceDataModel]()))
                        }
                    } else {
                        completion(.success(json.result?.balances ?? [DiemBalanceDataModel]()))
                    }
                    // 刷新本地数据
                    self?.updateLocalTokenBalance(tokens: tokens, type: .Libra, tokenBalances: json.result?.balances ?? [DiemBalanceDataModel.init(amount: 0, currency: "LBR")])
                } catch {
                    print("UpdateDiemBalance_解析异常\(error.localizedDescription)")
                    completion(.failure(LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.parseJsonError)))
                }
            case let .failure(error):
                guard error.errorCode != -999 else {
                    print("UpdateDiemBalance_网络请求已取消")
                    return
                }
                completion(.failure(LibraWalletError.WalletRequest(reason: .networkInvalid)))
            }
        }
        self.requests.append(request)
    }
    private func getDiemPriceTemp(address: String, group: DispatchGroup, completion: @escaping (Result<[ModelPriceDataModel], LibraWalletError>) -> Void) {
        let request = libraModuleProvide.request(.price(address)) { (result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(ModelPriceMainModel.self)
                    if json.code == 2000 {
                        completion(.success(json.data ?? [ModelPriceDataModel]()))
                    } else {
                        print("GetLibraPrice_状态异常")
                        if let message = json.message, message.isEmpty == false {
                            completion(.failure(LibraWalletError.error(message)))
                        } else {
                            completion(.failure(LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.dataCodeInvalid)))
                        }
                    }
                } catch {
                    print("GetLibraPrice_解析异常\(error.localizedDescription)")
                    completion(.failure(LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.parseJsonError)))
                }
            case let .failure(error):
                guard error.errorCode != -999 else {
                    print("GetLibraPrice_网络请求已取消")
                    return
                }
                completion(.failure(LibraWalletError.WalletRequest(reason: .networkInvalid)))
            }
            group.leave()
        }
        self.requests.append(request)
    }
}
// MARK: 更新Violas数量、价格
extension HomeModel {
    private func getViolasBalanceTemp(tokenID: Int64, address: String, authKey: String, tokens: [Token], completion: @escaping (Result<[ViolasBalanceDataModel], LibraWalletError>) -> Void) {
        let request = violasModuleProvide.request(.accountInfo(address)) { [weak self] (result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(ViolasAccountMainModel.self)
                    if json.result == nil {
                        if (self?.activeCount ?? 0) < 5 {
                            self?.activeViolasAccountTemp(tokenID: tokenID, address: address, authKey: authKey, tokens: tokens) { (result) in
                                switch result {
                                case let .success(models):
                                    completion(.success(models))
                                case .failure(_):
                                    // 激活报错
                                    completion(.success([ViolasBalanceDataModel]()))
                                }
                            }
                            self?.activeCount += 1
                        } else {
                            completion(.success(json.result?.balances ?? [ViolasBalanceDataModel]()))
                        }
                    } else {
                        completion(.success(json.result?.balances ?? [ViolasBalanceDataModel]()))
                    }
                    // 刷新本地数据
                    self?.updateLocalTokenBalance(tokens: tokens, type: .Violas, tokenBalances: json.result?.balances ?? [ViolasBalanceDataModel.init(amount: 0, currency: "XUS")])
                } catch {
                    print("UpdateViolasBalance_解析异常\(error.localizedDescription)")
                    completion(.failure(LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.parseJsonError)))
                }
            case let .failure(error):
                guard error.errorCode != -999 else {
                    print("UpdateViolasBalance_网络请求已取消")
                    return
                }
                completion(.failure(LibraWalletError.WalletRequest(reason: .networkInvalid)))
            }
        }
        self.requests.append(request)
    }
    private func getViolasPriceTemp(address: String, group: DispatchGroup, completion: @escaping (Result<[ModelPriceDataModel], LibraWalletError>) -> Void) {
        let request = violasModuleProvide.request(.price(address)) { (result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(ModelPriceMainModel.self)
                    if json.code == 2000 {
                        completion(.success(json.data ?? [ModelPriceDataModel]()))
                    } else {
                        print("GetViolasPrice_状态异常")
                        if let message = json.message, message.isEmpty == false {
                            completion(.failure(LibraWalletError.error(message)))
                        } else {
                            completion(.failure(LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.dataCodeInvalid)))
                        }
                    }
                } catch {
                    print("GetViolasPrice_解析异常\(error.localizedDescription)")
                    completion(.failure(LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.parseJsonError)))
                }
            case let .failure(error):
                guard error.errorCode != -999 else {
                    print("GetViolasPrice_网络请求已取消")
                    return
                }
                completion(.failure(LibraWalletError.WalletRequest(reason: .networkInvalid)))
            }
            group.leave()
        }
        self.requests.append(request)
    }
}
