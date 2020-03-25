//
//  LibraWalletManager.swift
//  LibraWallet
//
//  Created by palliums on 2019/9/5.
//  Copyright © 2019 palliums. All rights reserved.
//

import Foundation
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
    public var value: Int {
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
struct LibraWalletManager {
    static var shared = LibraWalletManager()
    
    private let semaphore = DispatchSemaphore.init(value: 1)
    /// 钱包ID
    private(set) var walletID: Int64?
    /// 钱包余额
    private(set) var walletBalance: Int64?
    /// 钱包地址
    private(set) var walletAddress: String?
    /// Libra_ 或者Violas_ 前缀 + 钱包0层地址
    private(set) var walletRootAddress: String?
    /// 钱包创建时间
    private(set) var walletCreateTime: Int?
    /// 钱包名字
    private(set) var walletName: String?
    /// 钱包当前使用状态
    private(set) var walletCurrentUse: Bool?
    /// 钱包生物锁开启状态
    private(set) var walletBiometricLock: Bool?
    /// 账户类型身份钱包、其他钱包(0=身份钱包、1=其它导入钱包)
    private(set) var walletIdentity: Int?
    /// 钱包类型(0=Libra、1=Violas、2=BTC)
    private(set) var walletType: WalletType?
    /// 钱包备份状态
    private(set) var walletBackupState: Bool?
}
extension LibraWalletManager {
    /// 创建Libra单例
    /// - Parameter walletID: 钱包ID
    /// - Parameter walletBalance: 钱包余额
    /// - Parameter walletAddress: 钱包地址
    /// - Parameter walletRootAddress: Libra_ 或者Violas_ 前缀 + 钱包0层地址
    /// - Parameter walletCreateTime: 钱包创建时间
    /// - Parameter walletName: 钱包名字
    /// - Parameter walletCurrentUse: 钱包当前使用状态
    /// - Parameter walletBiometricLock: 钱包生物锁开启状态
    /// - Parameter walletIdentity: 账户类型身份钱包、其他钱包(0=身份钱包、1=其它导入钱包)
    /// - Parameter walletType: 钱包类型(0=Libra、1=Violas、2=BTC)
    mutating func initWallet(walletID: Int64, walletBalance: Int64, walletAddress: String, walletRootAddress: String,  walletCreateTime: Int, walletName: String, walletCurrentUse: Bool, walletBiometricLock: Bool, walletIdentity: Int, walletType: WalletType, walletBackupState: Bool) {
        self.semaphore.wait()
        
        self.walletID = walletID
        self.walletBalance = walletBalance
        self.walletAddress = walletAddress
        self.walletRootAddress = walletRootAddress
        self.walletCreateTime = walletCreateTime
        self.walletName = walletName
        self.walletCurrentUse = walletCurrentUse
        self.walletBiometricLock = walletBiometricLock
        self.walletIdentity = walletIdentity
        self.walletType = walletType
        self.walletBackupState = walletBackupState
        
        self.semaphore.signal()
    }
    mutating func changeWalletBalance(banlance: Int64) {
        self.semaphore.wait()
        self.walletBalance = banlance
        self.semaphore.signal()
    }
    mutating func changeWalletName(name: String) {
        self.semaphore.wait()
        self.walletName = name
        self.semaphore.signal()
    }
    mutating func changeWalletAddress(address: String) {
        self.semaphore.wait()
        self.walletAddress = address
        self.semaphore.signal()
    }
    mutating func changeWalletBiometricLock(state: Bool) {
        self.semaphore.wait()
        self.walletBiometricLock = state
        self.semaphore.signal()
    }
    mutating func changeWalletCurrentUse(state: Bool) {
        self.semaphore.wait()
        self.walletCurrentUse = state
        self.semaphore.signal()
    }
    mutating func changeDefaultWallet(wallet: LibraWalletManager) {
        self.semaphore.wait()
        
        self.walletID = wallet.walletID
        self.walletBalance = wallet.walletBalance
        self.walletAddress = wallet.walletAddress
        self.walletRootAddress = wallet.walletRootAddress
        self.walletCreateTime = wallet.walletCreateTime
        self.walletName = wallet.walletName
        self.walletCurrentUse = true
        self.walletBiometricLock = wallet.walletBiometricLock
        self.walletIdentity = wallet.walletIdentity
        self.walletType = wallet.walletType
        
        self.semaphore.signal()
    }
    mutating func changeWalletBackupState(state: Bool) {
        self.semaphore.wait()
        self.walletBackupState = state
        self.semaphore.signal()
    }
}
extension LibraWalletManager {
    func savePaymentPasswordToKeychain(password: String, walletRootAddress: String) throws {
        guard password.isEmpty == false else {
            throw LibraWalletError.WalletCrypto(reason: .passwordEmptyError)
        }
        do {
            // 加密密码
            let encryptString = try PasswordCrypto().encryptPassword(password: password)
            // 保存加密字符串到KeyChain
            try KeychainManager.KeyManager.savePayPasswordToKeychain(walletAddress: walletRootAddress,
                                                                     password: encryptString)
        } catch {
            throw error
        }
    }
    
    func saveMnemonicToKeychain(mnemonic: [String], walletRootAddress: String) throws {
        guard mnemonic.isEmpty == false else {
            throw LibraWalletError.WalletCrypto(reason: .mnemonicEmptyError)
        }
        do {
            let mnemonicString = mnemonic.joined(separator: " ")
            // 加密密码
            let encryptMnemonicString = try PasswordCrypto().encryptPassword(password: mnemonicString)
            // 保存加密字符串到KeyChain
            try KeychainManager.KeyManager.saveMnemonicStringToKeychain(walletAddress: walletRootAddress, mnemonic: encryptMnemonicString)
        } catch {
            throw error
        }
    }
    func getMnemonicFromKeychain(walletRootAddress: String) throws -> [String] {
        guard walletRootAddress.isEmpty == false else {
            throw LibraWalletError.WalletKeychain(reason: .searchStringEmptyError)
        }
        do {
            // 取出加密后助记词字符串
            let menmonicString = try KeychainManager.KeyManager.getMnemonicStringFromKeychain(walletAddress: walletRootAddress)

            // 解密密文
            let decryptMnemonicString = try PasswordCrypto().decryptPassword(cryptoString: menmonicString)
            
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
    func isValidPaymentPassword(walletRootAddress: String, password: String) throws -> Bool {
        guard password.isEmpty == false else {
            throw LibraWalletError.WalletKeychain(reason: .searchStringEmptyError)
        }
        do {
            // 加密密码
            let encryptPasswordString = try PasswordCrypto().encryptPassword(password: password)
            // 验证结果
            let state = KeychainManager().checkPayPasswordInvalid(walletAddress: walletRootAddress, password: encryptPasswordString)
            guard state == true else {
                return false
            }
            return true
        } catch {
            return false
        }
    }
    func createLibraWallet() throws -> Bool {
        return false
    }
}
