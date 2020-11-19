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
    ///   - tokenID: 钱包ID
    ///   - tokenBalance: 钱包余额
    ///   - tokenAddress: 钱包地址
    ///   - tokenType: 钱包类型(0=Libra、1=Violas、2=BTC)
    ///   - tokenIndex: 钱包当前使用层数
    ///   - tokenAuthenticationKey: 授权Key
    ///   - tokenActiveState: 钱包激活状态
    ///   - tokenIcon: 钱包标志
    ///   - tokenContract: 钱包合约地址
    ///   - tokenModule: 钱包合约名称
    ///   - tokenModuleName: 钱包合约名称
    mutating func initToken(tokenID: Int64, tokenName: String, tokenBalance: Int64, tokenAddress: String, tokenType: WalletType, tokenIndex: Int64, tokenAuthenticationKey: String, tokenActiveState: Bool, tokenIcon: String, tokenContract: String, tokenModule: String, tokenModuleName: String, tokenPrice: String) {
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
    static func saveMnemonicToKeychain(mnemonic: [String], password: String) throws {
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
    static func unlockWallet(controller: UIViewController? = nil, successful: @escaping (([String])->Void), failed: @escaping((String)->Void)) {
        if WalletManager.shared.walletBiometricLock == true {
            KeychainManager.getPasswordWithBiometric() { (result, error) in
                if result.isEmpty == false {
                    do {
                        let mnemonic = try WalletManager.getMnemonicFromKeychain(password: result)
                        successful(mnemonic)
                    } catch {
                        failed(error.localizedDescription)
                    }
                } else {
                    failed(error)
                }
            }
        } else {
            let alert = libraWalletTool.passowordAlert(rootAddress: "", mnemonic: { (mnemonic) in
                successful(mnemonic)
            }) { (errorContent) in
                failed(errorContent)
            }
            if let con = controller {
                con.present(alert, animated: true, completion: nil)
            } else {
                var rootViewController = UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.rootViewController
                if let navigationController = rootViewController as? UINavigationController {
                    rootViewController = navigationController.viewControllers.first
                }
                if let tabBarController = rootViewController as? UITabBarController {
                    rootViewController = tabBarController.selectedViewController
                }
                rootViewController?.present(alert, animated: true, completion: nil)
//                let alertWindow = UIWindow(frame: UIScreen.main.bounds)
//                alertWindow.rootViewController = UIViewController()
//                alertWindow.windowLevel = UIWindow.Level.alert + 1;
//                alertWindow.makeKeyAndVisible()
//                alertWindow.rootViewController?.present(alert, animated: true, completion: nil)
            }
        }
    }
    static func ChangeBiometricState(controller: UIViewController, state: Bool, successful: @escaping (([String])->Void), failed: @escaping((String)->Void)) {
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
                        try KeychainManager.removeBiometric()
                        try DataBaseManager.DBManager.updateWalletBiometricLockState(walletID: WalletManager.shared.walletID!, state: state)
                        WalletManager.shared.changeWalletBiometricLock(state: state)
                    } catch {
                        failed(error.localizedDescription)
                    }
//                    KeychainManager().removeBiometric(password: "", success: { (result, error) in
//                        if result == "Success" {
//                            let result = DataBaseManager.DBManager.updateWalletBiometricLockState(walletID: WalletManager.shared.walletID!, state: state)
//                            guard result == true else {
//                                failed("Failed Insert DataBase")
//                                return
//                            }
//                            WalletManager.shared.changeWalletBiometricLock(state: state)
//                        } else {
//                            failed(error)
//                        }
//                    })
                case .failure(let error):
                    switch error {
                    // device does not support biometric (face id or touch id) authentication
                    case .biometryNotAvailable:
                        print("biometryNotAvailable")
                    // No biometry enrolled in this device, ask user to register fingerprint or face
                    case .biometryNotEnrolled:
                        print("biometryNotEnrolled")
                    case .fallback:
                        //                    self.txtUsername.becomeFirstResponder() // enter username password manually
                        print("fallback")
                        // Biometry is locked out now, because there were too many failed attempts.
                    // Need to enter device passcode to unlock.
                    case .biometryLockedout:
                        print("biometryLockedout")
                        if BioMetricAuthenticator.shared.touchIDAvailable() {
                            failed(localLanguage(keyString: "wallet_biometric_touch_id_attempts_too_much_error"))
                        } else {
                            failed(localLanguage(keyString: "wallet_biometric_face_id_attempts_too_much_error"))
                        }
                    // do nothing on canceled by system or user
                    case .canceledBySystem, .canceledByUser:
                        print("cancel")
                        break
                        
                    // show error for any other reason
                    default:
                        print(error.localizedDescription)
                    }
                    failed(error.localizedDescription)
                }
            }
        } else {
            // 打开
            let alert = libraWalletTool.passowordCheckAlert(rootAddress: "", passwordContent: { (password) in
                KeychainManager.addBiometric(password: password, success: { (result, error) in
                    if result == "Success" {
                        do {
                            try DataBaseManager.DBManager.updateWalletBiometricLockState(walletID: WalletManager.shared.walletID!, state: state)
                            WalletManager.shared.changeWalletBiometricLock(state: state)
                        } catch {
                            failed("Failed Insert DataBase")
                        }
                    } else {
                        failed(error)
                    }
                })
            }, errorContent: { (error) in
                failed(error)
            })
            controller.present(alert, animated: true, completion: nil)
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
                                   tokenModule: "",
                                   tokenModuleName: "",
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
