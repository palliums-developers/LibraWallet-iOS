//
//  WalletManager.swift
//  LibraWallet
//
//  Created by palliums on 2019/9/5.
//  Copyright © 2019 palliums. All rights reserved.
//

import Foundation
import UIKit
import BiometricAuthentication
enum WalletType {
    case Violas
    case Libra
    case BTC
}
extension WalletType {
    public var description: String {
        switch self {
        case .Violas:
            return "Violas"
        case .Libra:
            return "Libra"
        case .BTC:
            return "Bitcoin"
        }
    }
    public var value: Int64 {
        switch self {
        case .Violas:
            return 1
        case .Libra:
            return 0
        case .BTC:
            return 2
        }
    }
}
struct WalletManager {
    static var shared = WalletManager()
    
    private let semaphore = DispatchSemaphore.init(value: 1)
    /// 钱包ID
    private(set) var walletID: Int64?
    /// 钱包名字
    private(set) var walletName: String?
    /// 钱包创建时间
    private(set) var walletCreateTime: Double?
    /// 钱包生物锁开启状态
    private(set) var walletBiometricLock: Bool?
    /// 钱包创建类型(0导入、1创建)
    private(set) var walletCreateType: Int?
    /// 钱包备份状态
    private(set) var walletBackupState: Bool?
    /// 当前WalletConnect订阅状态
    private(set) var walletSubscription: Bool?
    /// 助记词哈希
    private(set) var walletMnemonicHash: String?
    /// 当前钱包使用状态
    private(set) var walletUseState: Bool?
    /// 当前钱包BTC地址
    private(set) var btcAddress: String?
    /// 当前钱包Violas地址
    private(set) var violasAddress: String?
    /// 当前钱包Libra地址
    private(set) var libraAddress: String?
}

extension WalletManager {
    mutating func initWallet(walletID: Int64, walletName: String, walletCreateTime: Double, walletBiometricLock: Bool, walletCreateType: Int, walletBackupState: Bool, walletSubscription: Bool, walletMnemonicHash: String, walletUseState: Bool, btcAddress: String, violasAddress: String, libraAddress: String) {
        self.semaphore.wait()
        
        self.walletID = walletID
        self.walletName = walletName
        self.walletCreateTime = walletCreateTime
        self.walletCreateType = walletCreateType
        self.walletBiometricLock = walletBiometricLock
        self.walletBackupState = walletBackupState
        self.walletSubscription = walletSubscription
        self.walletMnemonicHash = walletMnemonicHash
        self.walletUseState = walletUseState
        self.btcAddress = btcAddress
        self.violasAddress = violasAddress
        self.libraAddress = libraAddress
        
        self.semaphore.signal()
    }
    
    mutating func changeWalletName(name: String) {
        self.semaphore.wait()
        self.walletName = name
        self.semaphore.signal()
    }
    mutating func changeWalletBiometricLock(state: Bool) {
        self.semaphore.wait()
        self.walletBiometricLock = state
        self.semaphore.signal()
    }
    mutating func changeWalletSubscriptionUse(state: Bool) {
        self.semaphore.wait()
        self.walletSubscription = state
        self.semaphore.signal()
    }
    mutating func changeDefaultWallet(wallet: WalletManager) {
        self.semaphore.wait()
        
        self.walletID = wallet.walletID
        self.walletName = wallet.walletName
        self.walletCreateTime = wallet.walletCreateTime
        self.walletBiometricLock = wallet.walletBiometricLock
        self.walletCreateType = wallet.walletCreateType
        self.walletBackupState = wallet.walletBackupState
        self.walletSubscription = wallet.walletSubscription
        self.walletMnemonicHash = wallet.walletMnemonicHash
        self.walletUseState = wallet.walletUseState
        
        self.semaphore.signal()
    }
    mutating func changeWalletBackupState(state: Bool) {
        self.semaphore.wait()
        self.walletBackupState = state
        self.semaphore.signal()
    }
    mutating func deleteWallet() {
        self.semaphore.wait()
        
        self.walletID = nil
        self.walletName = nil
        self.walletCreateTime = nil
        self.walletCreateType = nil
        self.walletBiometricLock = nil
        self.walletBackupState = nil
        self.walletSubscription = nil
        self.walletMnemonicHash = nil
        self.walletUseState = nil
        self.btcAddress = nil
        self.violasAddress = nil
        self.libraAddress = nil
        
        self.semaphore.signal()
    }
}
struct Token {
    private let semaphore = DispatchSemaphore.init(value: 1)
    /// 币ID
    private(set) var tokenID: Int64
    /// 币名
    private(set) var tokenName: String
    /// 币余额
    private(set) var tokenBalance: Int64
    /// 币地址
    private(set) var tokenAddress: String
    /// 币类型(0=Libra、1=Violas、2=BTC)
    private(set) var tokenType: WalletType
    /// 币当前使用层数
    private(set) var tokenIndex: Int64
    /// 币授权Key
    private(set) var tokenAuthenticationKey: String
    /// 币激活状态
    private(set) var tokenActiveState: Bool
    /// 币标志
    private(set) var tokenIcon: String
    /// 币合约地址
    private(set) var tokenContract: String
    /// 币合约名称
    private(set) var tokenModule: String
    /// 币合约名称
    private(set) var tokenModuleName: String
    /// 币启用状态
    private(set) var tokenEnable: Bool
    /// 币单价
    private(set) var tokenPrice: String
}
extension Token {
    /// 创建Token单例
    /// - Parameters:
    ///   - tokenID: 币ID
    ///   - tokenBalance: 币余额
    ///   - tokenAddress: 币钱包地址
    ///   - tokenType: 币类型(0=Libra、1=Violas、2=BTC)
    ///   - tokenIndex: 币当前使用钱包层数
    ///   - tokenAuthenticationKey: 币钱包授权Key
    ///   - tokenActiveState: 币激活状态
    ///   - tokenIcon: 币标志
    ///   - tokenContract: 币合约地址
    ///   - tokenModule: 币合约名称
    ///   - tokenModuleName: 币合约名称
    ///   - tokenEnable: 币开启状态
    ///   - tokenPrice: 币价
    mutating func initToken(tokenID: Int64, tokenName: String, tokenBalance: Int64, tokenAddress: String, tokenType: WalletType, tokenIndex: Int64, tokenAuthenticationKey: String, tokenActiveState: Bool, tokenIcon: String, tokenContract: String, tokenModule: String, tokenModuleName: String, tokenEnable: Bool, tokenPrice: String) {
        self.semaphore.wait()
        
        self.tokenID = tokenID
        self.tokenName = tokenName
        self.tokenBalance = tokenBalance
        self.tokenAddress = tokenAddress
        self.tokenType = tokenType
        self.tokenIndex = tokenIndex
        self.tokenAuthenticationKey = tokenAuthenticationKey
        self.tokenActiveState = tokenActiveState
        self.tokenIcon = tokenIcon
        self.tokenContract = tokenContract
        self.tokenModule = tokenModule
        self.tokenModuleName = tokenModuleName
        self.tokenEnable = tokenEnable
        self.tokenPrice = tokenPrice
        
        self.semaphore.signal()
    }
    mutating func changeTokenBalance(banlance: Int64) {
        self.semaphore.wait()
        self.tokenBalance = banlance
        self.semaphore.signal()
    }
    mutating func changeTokenActiveState(state: Bool) {
        self.semaphore.wait()
        self.tokenActiveState = state
        self.semaphore.signal()
    }
    mutating func changeTokenPrice(price: String) {
        self.semaphore.wait()
        self.tokenPrice = price
        self.semaphore.signal()
    }
}
// MARK: 助记词存储钥匙串相关操作
extension WalletManager {
    private static func saveMnemonicToKeychain(mnemonic: [String], password: String) throws {
        guard mnemonic.isEmpty == false else {
            throw LibraWalletError.WalletCrypto(reason: .mnemonicEmptyError)
        }
        do {
            let mnemonicString = mnemonic.joined(separator: " ")
            // 加密密码
            let encryptMnemonicString = try PasswordCrypto.encryptPassword(content: mnemonicString, password: password)
            // 保存加密字符串到KeyChain
            try KeychainManager.saveMnemonicStringToKeychain(mnemonic: encryptMnemonicString)
        } catch {
            throw error
        }
    }
    static func getMnemonicFromKeychain(password: String) throws -> [String] {
        do {
            // 取出加密后助记词字符串
            let menmonicString = try KeychainManager.getMnemonicStringFromKeychain()
            
            // 解密密文
            let decryptMnemonicString = try PasswordCrypto.decryptPassword(cryptoString: menmonicString, password: password)
            
            let mnemonicArray = decryptMnemonicString.split(separator: " ").compactMap { (item) -> String in
                return "\(item)"
            }
            guard mnemonicArray.isEmpty == false else {
                throw LibraWalletError.WalletCrypto(reason: .decryptStringSplitError)
            }
            return mnemonicArray
        } catch {
            throw error
        }
    }
    static func deleteMnemonicFromKeychain() throws {
        do {
            try KeychainManager.deleteMnemonicStringFromKeychain()
        } catch {
            throw error
        }
    }
}
// MARK: 解锁钱包
extension WalletManager {
    /// 解锁钱包
    /// - Parameter completion: 返回结果
    static func unlockWallet(completion: @escaping (Result<[String], Error>) -> Void) {
        if WalletManager.shared.walletBiometricLock == true {
            KeychainManager.getPasswordWithBiometric { (result) in
                switch result {
                case let .success(password):
                    do {
                        let mnemonic = try WalletManager.getMnemonicFromKeychain(password: password)
                        completion(.success(mnemonic))
                    } catch {
                        completion(.failure(error))
                    }
                case let .failure(error):
                    completion(.failure(error))
                }
            }
        } else {
            let alert = libraWalletTool.passowordAlert { (result) in
                switch result {
                case let .success(mnemonic):
                    completion(.success(mnemonic))
                case let .failure(error):
                    completion(.failure(error))
                }
            }
            var rootViewController = UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.rootViewController
            if let tabBarController = rootViewController as? UITabBarController {
                rootViewController = tabBarController.selectedViewController
            }
            if let navigationController = rootViewController as? UINavigationController {
                rootViewController = navigationController.viewControllers.first
            }
            rootViewController?.present(alert, animated: true, completion: nil)
        }
    }
}
// MARK: 钱包添加生物验证
extension WalletManager {
    static func changeBiometricState(state: Bool, completion: @escaping (Result<String, Error>) -> Void) {
        if state == false {
            // 关闭
            var str = localLanguage(keyString: "wallet_biometric_alert_face_id_describe")
            if BioMetricAuthenticator.shared.touchIDAvailable() {
                str = localLanguage(keyString: "wallet_biometric_alert_fingerprint_describe")
            }
            BioMetricAuthenticator.authenticateWithBioMetrics(reason: str) { (result) in
                switch result {
                case .success( _):
                    do {
                        // 移除钥匙串
                        try KeychainManager.removeBiometric()
                        // 移除数据库生物识别状态
                        try DataBaseManager.DBManager.updateWalletBiometricLockState(walletID: WalletManager.shared.walletID!, state: state)
                        // 移除钱包单里状态
                        WalletManager.shared.changeWalletBiometricLock(state: state)
                        completion(.success(""))
                    } catch {
                        completion(.failure(error))
                    }
                case .failure(let error):
                    switch error {
                    case .biometryNotAvailable:
                        print("biometryNotAvailable")
                        completion(.failure(LibraWalletError.error(localLanguage(keyString: "wallet_biometric_not_available_error"))))
                    case .biometryNotEnrolled:
                        print("biometryNotEnrolled")
                        if BioMetricAuthenticator.shared.touchIDAvailable() {
                            completion(.failure(LibraWalletError.error(localLanguage(keyString: "wallet_biometric_touch_id_not_enrolled_error"))))
                        } else {
                            completion(.failure(LibraWalletError.error(localLanguage(keyString: "wallet_biometric_face_id_not_enrolled_error"))))
                        }
                    case .fallback:
                        print("fallback")
                        break
                    case .biometryLockedout:
                        print("biometryLockedout")
                        if BioMetricAuthenticator.shared.touchIDAvailable() {
                            completion(.failure(LibraWalletError.error(localLanguage(keyString: "wallet_biometric_touch_id_locked_error"))))
                        } else {
                            completion(.failure(LibraWalletError.error(localLanguage(keyString: "wallet_biometric_face_id_locked_error"))))
                        }
                    case .passcodeNotSet:
                        print("biometryLockedout")
                        if BioMetricAuthenticator.shared.touchIDAvailable() {
                            completion(.failure(LibraWalletError.error(localLanguage(keyString: "wallet_biometric_touch_id_without_password_error"))))
                        } else {
                            completion(.failure(LibraWalletError.error(localLanguage(keyString: "wallet_biometric_face_id_without_password_error"))))
                        }
                    case .failed:
                        print("biometryLockedout")
                        if BioMetricAuthenticator.shared.touchIDAvailable() {
                            completion(.failure(LibraWalletError.error(localLanguage(keyString: "wallet_biometric_touch_id_failed_error"))))
                        } else {
                            completion(.failure(LibraWalletError.error(localLanguage(keyString: "wallet_biometric_face_id_failed_error"))))
                        }
                    case .canceledBySystem, .canceledByUser:
                        completion(.failure(LibraWalletError.error("Cancel")))
                        break
                    default:
                        print(error.localizedDescription)
                        completion(.failure(error))
                    }
                }
            }
        } else {
            // 打开
            let alert = libraWalletTool.passowordCheckAlert { (result) in
                switch result {
                case let .success(password):
                    KeychainManager.addBiometric(password: password) { (result) in
                        switch result {
                        case .success(_):
                            do {
                                try DataBaseManager.DBManager.updateWalletBiometricLockState(walletID: WalletManager.shared.walletID!, state: state)
                                WalletManager.shared.changeWalletBiometricLock(state: state)
                                completion(.success(""))
                            } catch {
                                completion(.failure(error))
                            }
                        case let .failure(error):
                            completion(.failure(error))
                        }
                    }
                case let .failure(error):
                    completion(.failure(error))
                }
            }
            var rootViewController = UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.rootViewController
            if let tabBarController = rootViewController as? UITabBarController {
                rootViewController = tabBarController.selectedViewController
            }
            if let navigationController = rootViewController as? UINavigationController {
                rootViewController = navigationController.viewControllers.first
            }
            rootViewController?.present(alert, animated: true, completion: nil)
        }
    }
}
// MARK: 删除钱包
extension WalletManager {
    static func deleteWallet(password: String, createOrImport: Bool, step: Int) {
        do {
            // 移除钱包包含所有币
            if DataBaseManager.DBManager.isExistTable(name: "Tokens") == true && step >= 1 {
                try DataBaseManager.DBManager.deleteAllTokens()
            }
            // 移除本地钱包
            if DataBaseManager.DBManager.isExistTable(name: "Wallet") == true && step >= 2 {
                try DataBaseManager.DBManager.deleteHDWallet()
            }
            if step >= 3 {
                // 初始化钱包状态
                setIdentityWalletState(show: false)
            }
            if step >= 4 {
                // 移除钥匙串
                try WalletManager.deleteMnemonicFromKeychain()
            }
            // 清空钱包单例
            WalletManager.shared.deleteWallet()
            if createOrImport == false {
                // 发送钱包已删除广播
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "PalliumsWalletDelete"), object: nil)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
}
// MARK: 创建Palliums钱包
extension WalletManager {
    static func createWallet(password: String, mnemonic: [String]) throws {
        var step = 0
        do {
            // 创建Violas币
            let violasTokenAddress = try WalletManager.initViolasToken(mnemonic: mnemonic)
            print("创建Violas Token Successful")
            // 创建Libra币
            let libraTokenAddress = try WalletManager.initLibraToken(mnemonic: mnemonic)
            print("创建Libra Token Successful")
            // 创建BTC币
            let bitcoinTokenAddress = try WalletManager.initBitcoinToken(mnemonic: mnemonic)
            print("创建Bitcoin Token Successful")
            step += 1
            // 创建钱包
            try WalletManager.createWallet(mnemonic: mnemonic,
                                           btcAddress: bitcoinTokenAddress,
                                           violasAddress: violasTokenAddress,
                                           libraAddress: libraTokenAddress)
            print("创建钱包 Successful")
            step += 1
            // 设置已创建钱包状态
            setIdentityWalletState(show: true)
            print("设置已创建钱包状态 Successful")
            step += 1
            // 加密助记词到Keychain
            try WalletManager.saveMnemonicToKeychain(mnemonic: mnemonic,
                                                     password: password)
            print("保存助记词到钥匙串 Successful")
            step += 1
        } catch {
            print(error)
            WalletManager.deleteWallet(password: password, createOrImport: true, step: step)
            throw error
        }
    }
    private static func createWallet(mnemonic: [String], btcAddress: String, violasAddress: String, libraAddress: String) throws {
        do {
            let wallet = WalletManager.init(walletID: 999,
                                            walletName: "PalliumsWallet",
                                            walletCreateTime: NSDate().timeIntervalSince1970,
                                            walletBiometricLock: false,
                                            walletCreateType: 0,
                                            walletBackupState: true,
                                            walletSubscription: false,
                                            walletMnemonicHash: mnemonic.joined(separator: " ").md5(),
                                            walletUseState: true,
                                            btcAddress: btcAddress,
                                            violasAddress: violasAddress,
                                            libraAddress: libraAddress)
            try DataBaseManager.DBManager.insertWallet(model: wallet)
        } catch {
            throw error
        }
    }
    private static func initViolasToken(mnemonic: [String]) throws -> String {
        do {
            let wallet = try ViolasManager.getWallet(mnemonic: mnemonic)
            let token = Token.init(tokenID: 999,
                                   tokenName: "LBR",
                                   tokenBalance: 0,
                                   tokenAddress: wallet.publicKey.toLegacy(),
                                   tokenType: .Violas,
                                   tokenIndex: 0,
                                   tokenAuthenticationKey: wallet.publicKey.toActive(),
                                   tokenActiveState: false,
                                   tokenIcon: "violas_icon",
                                   tokenContract: "00000000000000000000000000000001",
                                   tokenModule: "LBR",
                                   tokenModuleName: "LBR",
                                   tokenEnable: true,
                                   tokenPrice: "0.0")
            try DataBaseManager.DBManager.insertToken(token: token)
            print("Violas钱包创建结果：\(true)")
            return wallet.publicKey.toLegacy()
        } catch {
            throw error
        }
    }
    private static func initLibraToken(mnemonic: [String]) throws -> String {
        do {
            let wallet = try LibraManager.getWallet(mnemonic: mnemonic)
            let token = Token.init(tokenID: 999,
                                   tokenName: "LBR",
                                   tokenBalance: 0,
                                   tokenAddress: wallet.publicKey.toLegacy(),
                                   tokenType: .Libra,
                                   tokenIndex: 0,
                                   tokenAuthenticationKey: wallet.publicKey.toActive(),
                                   tokenActiveState: false,
                                   tokenIcon: "libra_icon",
                                   tokenContract: "00000000000000000000000000000001",
                                   tokenModule: "LBR",
                                   tokenModuleName: "LBR",
                                   tokenEnable: true,
                                   tokenPrice: "0.0")
            try DataBaseManager.DBManager.insertToken(token: token)
            print("Libra钱包创建结果：\(true)")
            return wallet.publicKey.toLegacy()
        } catch {
            throw error
        }
    }
    private static func initBitcoinToken(mnemonic: [String]) throws -> String {
        do {
            let wallet = try BTCManager().getWallet(mnemonic: mnemonic)
            let token = Token.init(tokenID: 999,
                                   tokenName: "BTC",
                                   tokenBalance: 0,
                                   tokenAddress: wallet.address.description,
                                   tokenType: .BTC,
                                   tokenIndex: 0,
                                   tokenAuthenticationKey: "",
                                   tokenActiveState: true,
                                   tokenIcon: "btc_icon",
                                   tokenContract: "",
                                   tokenModule: "BTC",
                                   tokenModuleName: "BTC",
                                   tokenEnable: true,
                                   tokenPrice: "0.0")
            try DataBaseManager.DBManager.insertToken(token: token)
            print("BTC钱包创建结果：\(true)")
            return wallet.address.description
        } catch {
            throw error
        }
    }
}
// MARK: 更新钱包余额
extension WalletManager {
    static func updateLibraTokensBalance(tokens: [Token], tokenBalances: [LibraBalanceModel]) {
        // 刷新本地缓存数据
        for model in tokenBalances {
            for token in tokens {
                if model.currency == token.tokenModule {
                    do {
                        try DataBaseManager.DBManager.updateTokenBalance(tokenID: token.tokenID, balance: model.amount ?? 0)
                        print("刷新Libra Token数据状态: \(true)")
                    } catch {
                        print("刷新Libra Token数据状态: \(false)")
                    }
                    break
                }
            }
        }
    }
    static func updateViolasTokensBalance(tokens: [Token], tokenBalances: [ViolasBalanceModel]) {
        // 刷新本地缓存数据
        for model in tokenBalances {
            for token in tokens {
                if model.currency == token.tokenModule {
                    do {
                        try DataBaseManager.DBManager.updateTokenBalance(tokenID: token.tokenID, balance: model.amount ?? 0)
                        print("刷新Violas Token数据状态: \(true)")
                    } catch {
                        print("刷新Violas Token数据状态: \(false)")
                    }
                    break
                }
            }
        }
    }
    static func updateBitcoinBalance(tokenID: Int64, balance: Int64) {
        // 刷新本地缓存数据
        do {
            try DataBaseManager.DBManager.updateTokenBalance(tokenID: tokenID, balance: balance)
            print("刷新Bitcoin Token数据状态: \(true)")
        } catch {
            print("刷新Bitcoin Token数据状态: \(false)")
        }
    }
}
// MARK: 更新钱包币种价格
extension WalletManager {
    static func updateTokenPrice(token: Token, price: String) {
        // 刷新本地缓存数据
        do {
            try DataBaseManager.DBManager.updateTokenPrice(tokenID: token.tokenID, price: price)
            print("刷新\(token.tokenName) Token Price数据状态: \(true)")
        } catch {
            print("刷新\(token.tokenName) Token Price数据状态: \(false)")
        }
    }
}
// MARK: 钱包添加资产
extension WalletManager {
    static func addCurrencyToWallet(token: Token) throws {
        do {
            let isExist = try DataBaseManager.DBManager.isExistViolasToken(tokenAddress: token.tokenAddress, tokenModule: token.tokenModule, tokenType: token.tokenType)
            if isExist == true {
                // 已存在改状态
                print("Token 数据库中已存在,改状态: \(token.tokenEnable)")
                do {
                    try DataBaseManager.DBManager.updateViolasTokenState(tokenAddress: token.tokenAddress, tokenModule: token.tokenModule, tokenType: token.tokenType, state: token.tokenEnable)
                } catch {
                    throw error
                }
            } else {
                // 不存在插入
                print("Token数据库中不存在,插入")
                do {
                    try DataBaseManager.DBManager.insertToken(token: token)
                } catch {
                    throw error
                }
            }
        } catch {
            throw error
        }
    }
}
// MARK: 更新钱包备份状态
extension WalletManager {
    static func updateWalletBackupState() throws {
        do {
            try DataBaseManager.DBManager.updateWalletBackupState(wallet: WalletManager.shared)
            print("钱包更新备份状态-\(true)")
            WalletManager.shared.changeWalletBackupState(state: true)
        } catch {
            throw error
        }
    }
}
// MARK: 加载钱包所有已开启币种
extension WalletManager {
    static func getLocalEnableTokens() throws -> [Token] {
        do {
            let tokens = try DataBaseManager.DBManager.getTokens()
            return tokens
        } catch {
            throw error
        }
    }
}
// MARK: 加载默认钱包
extension WalletManager {
    static func getDefaultWallet() throws {
        do {
            try DataBaseManager.DBManager.getDefaultWallet()
        } catch {
            throw error
        }
    }
}
// MARK: 更新币种激活状态
extension WalletManager {
    static func updateTokenActiveState(tokenID: Int64) throws {
        do {
            try DataBaseManager.DBManager.updateTokenActiveState(tokenID: tokenID, state: true)
        } catch {
            print(error)
            throw error
        }
    }
}
