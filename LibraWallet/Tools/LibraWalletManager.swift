//
//  LibraWalletManager.swift
//  LibraWallet
//
//  Created by palliums on 2019/9/5.
//  Copyright © 2019 palliums. All rights reserved.
//

import Foundation
struct LibraWalletManager {
    static var shared = LibraWalletManager()
    
    private let semaphore = DispatchSemaphore.init(value: 1)
    
    private(set) var walletID: Int64?
    
    private(set) var walletBalance: Int64?
    
    private(set) var walletAddress: String?
    
//    private(set) var walletRootAddress: String?
    
    private(set) var walletCreateTime: Int?
    
    private(set) var walletName: String?
    
    private(set) var walletMnemonic: String?
    
    private(set) var walletCurrentUse: Bool?
    
    private(set) var walletBiometricLock: Bool?
    
    
    
    private(set) var coreWallet: LibraWallet?
    
}
extension LibraWalletManager {
    mutating func initWallet(walletID: Int64, walletBalance: Int64, walletAddress: String, walletCreateTime: Int, walletName: String, walletMnemonic: String, walletCurrentUse: Bool, walletBiometricLock: Bool, wallet: LibraWallet) {
        self.semaphore.wait()
        
        self.walletID = walletID
        self.walletBalance = walletBalance
        self.walletAddress = walletAddress
        self.walletCreateTime = walletCreateTime
        self.walletName = walletName
        self.walletMnemonic = walletMnemonic
        self.walletCurrentUse = walletCurrentUse
        self.walletBiometricLock = walletBiometricLock
        self.coreWallet = wallet
        
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
    func savePaymentPasswordToKeychain(password: String, walletRootAddress: String) throws {
        guard password.isEmpty == false else {
            throw LibraWalletError.error("empty")
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
            throw LibraWalletError.error("empty")
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
    func getMnemonicFromKeychain(walletRootAddress: String) throws -> [String]{
//        guard mnemonic.isEmpty == false else {
//            throw LibraWalletError.error("empty")
//        }
        do {
            // 取出加密后助记词字符串
            let menmonicString = try KeychainManager.KeyManager.getMnemonicStringFromKeychain(walletAddress: walletRootAddress)

            // 解密密文
            let decryptMnemonicString = try PasswordCrypto().decryptPassword(cryptoString: menmonicString)
            
            let mnemonicArray = decryptMnemonicString.split(separator: " ").compactMap { (item) -> String in
                return "\(item)"
            }
            guard mnemonicArray.isEmpty == false else {
                throw LibraWalletError.error("empty")
            }
            return mnemonicArray
        } catch {
            throw error
        }
    }
}
