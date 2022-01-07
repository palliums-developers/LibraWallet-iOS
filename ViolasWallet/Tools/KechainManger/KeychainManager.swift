//
//  KeychainManager.swift
//  ViolasWallet
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
        let bundId: String = Bundle.main.bundleIdentifier ?? "PalliumsWallet"
        let keychain = Keychain(service: bundId)
        do {
            try keychain.set(mnemonic, key: "mnemonic_palliums_wallet")
            print("Save Mnemonic Successful")
        } catch {
            print("saveMnemonicStringToKeychain error: \(error)")
            throw error
        }
    }
    /// 获取助记词
    /// - Throws: 错误描述
    /// - Returns: 助记词
    static func getMnemonicStringFromKeychain() throws -> String {
        //
        let bundId: String = Bundle.main.bundleIdentifier ?? "PalliumsWallet"
        let keychain = Keychain(service: bundId)
        do {
            let mnemonicString = try keychain.get("mnemonic_palliums_wallet")
            guard let mnemonic = mnemonicString else {
                throw LibraWalletError.WalletKeychain(reason: .getMnemonicFailedError)
            }
            guard mnemonic.isEmpty == false else {
                throw LibraWalletError.WalletKeychain(reason: .getMnemonicEmptyError)
            }
            print("Get Mnemonic Successful")
            return mnemonic
        } catch {
            print("getMnemonicStringFromKeychain error: \(error)")
            throw error
        }
    }
    /// 删除助记词
    /// - Throws: 错误描述
    static func deleteMnemonicStringFromKeychain() throws {
        let bundId: String = Bundle.main.bundleIdentifier ?? "PalliumsWallet"
        let keychain = Keychain(service: bundId)
        do {
            try keychain.remove("mnemonic_palliums_wallet")
            print("Remove Mnemonic Successful")
        } catch {
            print("deleteMnemonicStringFromKeychain error: \(error)")
            throw error
        }
    }
    /// 添加生物识别
    /// - Parameters:
    ///   - password: 密码
    ///   - success: 成功回调（一个成功参数，第二个错误描述）
    static func addBiometric(password: String, completion: @escaping (Result<String, Error>)->Void) {
        let bundId: String = Bundle.main.bundleIdentifier ?? "PalliumsWallet"
        let keychain = Keychain(service: bundId)
        DispatchQueue.global().async {
            do {
                // Should be the secret invalidated when passcode is removed? If not then use `.WhenUnlocked`
                try keychain
                    .accessibility(.whenPasscodeSetThisDeviceOnly, authenticationPolicy: .userPresence)
                    .authenticationPrompt("Authenticate to update your access token")
                    .set(password, key: "pay_password_palliums_wallet")
                DispatchQueue.main.async(execute: {
                    completion(.success("Success"))
                })
            } catch {
                // Error handling if needed...
                print("addBiometric error: \(error)")
                DispatchQueue.main.async(execute: {
                    completion(.failure(error))
                })
            }
        }
    }
    /// 通过生物识别获取密码
    /// - Parameter success: 成功回调（一个成功参数，第二个错误描述）
    static func getPasswordWithBiometric(completion: @escaping (Result<String, Error>)->Void) {
        let bundId: String = Bundle.main.bundleIdentifier ?? "PalliumsWallet"
        let keychain = Keychain(service: bundId)
        DispatchQueue.global().async {
            do {
                let passwordString = try keychain
                    .authenticationPrompt("Authenticate to login to server")
                    .get("pay_password_palliums_wallet")
                guard let password = passwordString else {
                    completion(.failure(LibraWalletError.WalletKeychain(reason: .getPaymentPasswordFailedError)))
                    return
                }
                guard password.isEmpty == false else {
                    completion(.failure(LibraWalletError.WalletKeychain(reason: .getPaymentPasswordEmptyError)))
                    return
                }
                print("password: \(password)")
                DispatchQueue.main.async(execute: {
                    completion(.success(password))
                })
            } catch {
                // Error handling if needed...
                print("getPasswordWithBiometric error: \(error)")
                guard error.localizedDescription != "User canceled the operation." else {
                    return
                }
                DispatchQueue.main.async(execute: {
                    completion(.failure(error))
                })
            }
        }
    }
    /// 移除生物识别
    /// - Throws: 错误描述
    static func removeBiometric() throws {
        let bundId: String = Bundle.main.bundleIdentifier ?? "PalliumsWallet"
        let keychain = Keychain(service: bundId)
        do {
            // Should be the secret invalidated when passcode is removed? If not then use `.WhenUnlocked`
            try keychain.remove("pay_password_palliums_wallet")
            print("Remove Biometric Successful")
        } catch {
            // Error handling if needed...
            print("removeBiometric error: \(error)")
            throw error
        }
    }
}
