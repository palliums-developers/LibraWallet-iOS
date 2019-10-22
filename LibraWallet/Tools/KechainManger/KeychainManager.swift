//
//  KeychainManager.swift
//  LibraWallet
//
//  Created by palliums on 2019/10/12.
//  Copyright © 2019 palliums. All rights reserved.
//

import Foundation
import KeychainAccess
struct KeychainManager {
    static let KeyManager = KeychainManager()
    //MARK: - 保存密码
    /// 保存密码
    /// - Parameter walletAddress: 该钱包0层地址
    /// - Parameter password: 支付密码
    func savePayPasswordToKeychain(walletAddress: String, password: String) throws {
        let bundId: String = Bundle.main.bundleIdentifier ?? "LibraWallet"
        //"\(bundId)-\(walletAddress)"
        let keychain = Keychain(service: bundId)
        do {
            try keychain.set(password, key: "pay_password_\(walletAddress)")
        } catch {
            print("error: \(error)")
            throw error
        }
    }
    //MARK: - 保存助记词
    /// 保存助记词
    /// - Parameter walletAddress: 该钱包0层地址
    /// - Parameter mnemonic: 助记词
    func saveMnemonicStringToKeychain(walletAddress: String, mnemonic: String) throws {
        let bundId: String = Bundle.main.bundleIdentifier ?? "LibraWallet"
        //"\(bundId)-\(walletAddress)"
        let keychain = Keychain(service: bundId)
        do {
            try keychain.set(mnemonic, key: "mnemonic_\(walletAddress)")
        } catch {
            print("error: \(error)")
            throw error
        }
    }
    //MARK: - 获取密码
    /// 获取密码
    /// - Parameter walletAddress: 该钱包0层地址
    func getPayPasswordFromKeychain(walletAddress: String) throws -> String {
        //
        let bundId: String = Bundle.main.bundleIdentifier ?? "LibraWallet"
        let keychain = Keychain(service: bundId)
        do {
            let passwordString = try keychain.get("pay_password_\(walletAddress)")
            guard let password = passwordString else {
                throw LibraWalletError.WalletKeychain(reason: .getPaymentPasswordFailedError)
            }
            guard password.isEmpty == false else {
                throw LibraWalletError.WalletKeychain(reason: .getPaymentPasswordEmptyError)
            }
            return password
        } catch {
            print("error: \(error)")
            throw error
        }
    }
    //MARK: - 获取助记词
    /// 获取助记词
    /// - Parameter walletAddress: 该钱包0层地址
    func getMnemonicStringFromKeychain(walletAddress: String) throws -> String {
        //
        let bundId: String = Bundle.main.bundleIdentifier ?? "LibraWallet"
        let keychain = Keychain(service: bundId)
        do {
            let mnemonicString = try keychain.get("mnemonic_\(walletAddress)")
            guard let mnemonic = mnemonicString else {
                throw LibraWalletError.WalletKeychain(reason: .getMnemonicFailedError)
            }
            guard mnemonic.isEmpty == false else {
                throw LibraWalletError.WalletKeychain(reason: .getMnemonicEmptyError)
            }
            return mnemonic
        } catch {
            print("error: \(error)")
            throw error
        }
    }
    //MARK: - 检查密码是否有效
    /// 检查密码是否有效
    /// - Parameter walletAddress: 该钱包0层地址
    /// - Parameter password: 密码
    func checkPayPasswordInvalid(walletAddress: String, password: String) -> Bool {
        let bundId: String = Bundle.main.bundleIdentifier ?? "LibraWallet"
        let keychain = Keychain(service: bundId)
        do {
            let localPassword = try keychain.get("pay_password_\(walletAddress)")
            guard localPassword == password else {
                return false
            }
            return true
        } catch let error {
            print("error: \(error)")
            return false
        }
    }
    //MARK: - 删除支付密码
    /// 删除支付密码(删除钱时包掉用)
    /// - Parameter walletAddress: 该钱包0层地址
    func deletePayPasswordFromKeychain(walletAddress: String) throws {
        let bundId: String = Bundle.main.bundleIdentifier ?? "LibraWallet"
        let keychain = Keychain(service: bundId)
        do {
            try keychain.remove("pay_password_\(walletAddress)")
        } catch {
            print("error: \(error)")
            throw error
        }
    }
    //MARK: - 删除助记词
    /// 删除助记词(删除钱时包掉用)
    /// - Parameter walletAddress: 该钱包0层地址
    func deleteMnemonicStringFromKeychain(walletAddress: String) throws {
        let bundId: String = Bundle.main.bundleIdentifier ?? "LibraWallet"
        let keychain = Keychain(service: bundId)
        do {
            try keychain.remove("mnemonic_\(walletAddress)")
        } catch {
            print("error: \(error)")
            throw error
        }
    }
}
