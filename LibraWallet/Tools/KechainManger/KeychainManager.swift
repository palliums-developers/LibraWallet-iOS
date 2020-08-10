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
    /// 保存助记词
    /// - Parameter mnemonic: 助记词
    /// - Throws: 错误描述
    static func saveMnemonicStringToKeychain(mnemonic: String) throws {
        let bundId: String = Bundle.main.bundleIdentifier ?? "LibraWallet"
        //"\(bundId)-\(walletAddress)"
        let keychain = Keychain(service: bundId)
        do {
            try keychain.set(mnemonic, key: "mnemonic_PalliumsWallet")
        } catch {
            print("error: \(error)")
            throw error
        }
    }
    /// 获取助记词
    /// - Throws: 错误描述
    /// - Returns: 助记词
    static func getMnemonicStringFromKeychain() throws -> String {
        //
        let bundId: String = Bundle.main.bundleIdentifier ?? "LibraWallet"
        let keychain = Keychain(service: bundId)
        do {
            let mnemonicString = try keychain.get("mnemonic_PalliumsWallet")
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
    /// 删除助记词(删除钱时包掉用)
    /// - Throws: 错误描述
    static func deleteMnemonicStringFromKeychain() throws {
        let bundId: String = Bundle.main.bundleIdentifier ?? "LibraWallet"
        let keychain = Keychain(service: bundId)
        do {
            try keychain.remove("mnemonic_PalliumsWallet")
        } catch {
            print("error: \(error)")
            throw error
        }
    }
    /// 添加生物识别
    /// - Parameters:
    ///   - password: 密码
    ///   - success: 成功回调（一个成功参数，第二个错误描述）
    static func addBiometric(password: String, success: @escaping (String, String)->Void) {
        let bundId: String = Bundle.main.bundleIdentifier ?? "LibraWallet"
        let keychain = Keychain(service: bundId)
        DispatchQueue.global().async {
            do {
                // Should be the secret invalidated when passcode is removed? If not then use `.WhenUnlocked`
                try keychain
                    .accessibility(.whenPasscodeSetThisDeviceOnly, authenticationPolicy: .userPresence)
                    .authenticationPrompt("Authenticate to update your access token")
                    .set(password, key: "pay_password_PalliumsWallet")
                DispatchQueue.main.async(execute: {
                    success("Success", "")
                })
            } catch {
                // Error handling if needed...
                print(error)
                DispatchQueue.main.async(execute: {
                    success("", error.localizedDescription)
                })
            }
        }
    }
    /// 通过生物识别获取密码
    /// - Parameter success: 成功回调（一个成功参数，第二个错误描述）
    static func getPasswordWithBiometric(success: @escaping (String, String)->Void) {
        let bundId: String = Bundle.main.bundleIdentifier ?? "LibraWallet"
        let keychain = Keychain(service: bundId)
        DispatchQueue.global().async {
            do {
                let passwordString = try keychain
                    .authenticationPrompt("Authenticate to login to server")
                    .get("pay_password_PalliumsWallet")
                guard let password = passwordString else {
                    success("", LibraWalletError.WalletKeychain(reason: .getPaymentPasswordFailedError).localizedDescription)
                    return
                }
                guard password.isEmpty == false else {
                    success("", LibraWalletError.WalletKeychain(reason: .getPaymentPasswordEmptyError).localizedDescription)
                    return
                }
                print("password: \(password)")
                DispatchQueue.main.async(execute: {
                    success(password, "")
                })
            } catch {
                // Error handling if needed...
                DispatchQueue.main.async(execute: {
                    success("", error.localizedDescription)
                    
                })
            }
        }
    }
    /// 移除生物识别
    /// - Throws: 错误描述
    static func removeBiometric() throws {
        let bundId: String = Bundle.main.bundleIdentifier ?? "LibraWallet"
        let keychain = Keychain(service: bundId)
        do {
            // Should be the secret invalidated when passcode is removed? If not then use `.WhenUnlocked`
            try keychain.remove("pay_password_PalliumsWallet")
            print("Remove_Biometric_Successful")
        } catch {
            // Error handling if needed...
            throw error
        }
    }
}
