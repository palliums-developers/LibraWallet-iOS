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
    //MARK: - 保存助记词
    /// 保存助记词
    /// - Parameter walletAddress: 该钱包0层地址
    /// - Parameter mnemonic: 助记词
    func saveMnemonicStringToKeychain(mnemonic: String) throws {
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
    //MARK: - 获取助记词
    /// 获取助记词
    /// - Parameter walletAddress: 该钱包0层地址
    func getMnemonicStringFromKeychain() throws -> String {
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
    //MARK: - 删除助记词
    /// 删除助记词(删除钱时包掉用)
    /// - Parameter walletAddress: 该钱包0层地址
    func deleteMnemonicStringFromKeychain() throws {
        let bundId: String = Bundle.main.bundleIdentifier ?? "LibraWallet"
        let keychain = Keychain(service: bundId)
        do {
            try keychain.remove("mnemonic_PalliumsWallet")
        } catch {
            print("error: \(error)")
            throw error
        }
    }
    func addBiometric(password: String, success: @escaping (String, String)->Void) {
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
    func getPasswordWithBiometric(success: @escaping (String, String)->Void) {
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
    func removeBiometric(password: String, success: @escaping (String, String)->Void) {
        let bundId: String = Bundle.main.bundleIdentifier ?? "LibraWallet"
        let keychain = Keychain(service: bundId)
        do {
            // Should be the secret invalidated when passcode is removed? If not then use `.WhenUnlocked`
            try keychain.remove("pay_password_PalliumsWallet")
            success("Success", "")
            print("Remove_Biometric_Successfule")
        } catch {
            // Error handling if needed...
            DispatchQueue.main.async(execute: {
                success("", error.localizedDescription)
            })
        }
    }
}
