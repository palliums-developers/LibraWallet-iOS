//
//  WalletManager.swift
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
}

extension WalletManager {
    mutating func initWallet(walletID: Int64, walletName: String, walletCreateTime: Double, walletBiometricLock: Bool, walletCreateType: Int, walletBackupState: Bool, walletSubscription: Bool, walletMnemonicHash: String, walletUseState: Bool) {
        self.semaphore.wait()
        
        self.walletID = walletID
        self.walletName = walletName
        self.walletCreateTime = walletCreateTime
        self.walletCreateType = walletCreateType
        self.walletBackupState = walletBackupState
        self.walletSubscription = walletSubscription
        self.walletMnemonicHash = walletMnemonicHash
        self.walletUseState = walletUseState
        
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
    mutating func initToken(tokenID: Int64, tokenName: String, tokenBalance: Int64, tokenAddress: String, tokenType: WalletType, tokenIndex: Int64, tokenAuthenticationKey: String, tokenActiveState: Bool, tokenIcon: String, tokenContract: String, tokenModule: String, tokenModuleName: String) {
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
}
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
            try KeychainManager.KeyManager.saveMnemonicStringToKeychain(walletAddress: "PalliumsWallet", mnemonic: encryptMnemonicString)
        } catch {
            throw error
        }
    }
    static func getMnemonicFromKeychain(password: String) throws -> [String] {
//        guard walletRootAddress.isEmpty == false else {
//            throw LibraWalletError.WalletKeychain(reason: .searchStringEmptyError)
//        }
        do {
            // 取出加密后助记词字符串
            let menmonicString = try KeychainManager.KeyManager.getMnemonicStringFromKeychain(walletAddress: "PalliumsWallet")

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
    func createLibraWallet() throws -> Bool {
        return false
    }
}
