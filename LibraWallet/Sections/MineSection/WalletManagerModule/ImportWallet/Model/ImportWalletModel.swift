//
//  ImportWalletModel.swift
//  LibraWallet
//
//  Created by palliums on 2019/10/28.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit
class ImportWalletModel: NSObject {
    @objc dynamic var dataDic: NSMutableDictionary = [:]
    func importWallet(password: String, mnemonic: [String]){
        let quene = DispatchQueue.init(label: "createWalletQuene")
        quene.async {
            do {
                // 1.1创建Violas钱包
                let violasWallet = try self.createViolasWallet(mnemonics: mnemonic)
                // 1.2创建BTC钱包
                let btcWallet = try self.createBTCWallet(mnemonics: mnemonic)
                // 1.3创建Libra钱包
                let libraWallet = try self.createLibraWallet(mnemonics: mnemonic)
                // 1.4创建总钱包
                try self.createWallet(mnemonic: mnemonic, btcAddress: btcWallet.tokenAddress, violasAddress: violasWallet.tokenAddress, libraAddress: libraWallet.tokenAddress)
                // 2.设置已创建钱包状态
                setIdentityWalletState(show: true)
                // 3.加密助记词到Keychain
                try WalletManager.saveMnemonicToKeychain(mnemonic: mnemonic, password: password)
                let tempWallet = CreateWalletModel.init(password: password,
                                                        mnemonic: mnemonic,
                                                        wallet: [violasWallet, btcWallet, libraWallet])
                DispatchQueue.main.async(execute: {
                    //需更新
                    let data = setKVOData(type: "ImportWallet", data: tempWallet)
                    self.setValue(data, forKey: "dataDic")
                })
            } catch {
                DataBaseManager.DBManager.deleteHDWallet()
                DataBaseManager.DBManager.deleteAllTokens()
                setIdentityWalletState(show: false)
                DispatchQueue.main.async(execute: {
                    //需更新
                    let data = setKVOData(error: LibraWalletError.error(error.localizedDescription), type: "ImportWallet")
                    self.setValue(data, forKey: "dataDic")
                })
                
            }
        }
    }
    private func createWallet(mnemonic: [String], btcAddress: String, violasAddress: String, libraAddress: String) throws {
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
    private func createBTCWallet(mnemonics: [String]) throws -> Token {
        do {
            let wallet = try BTCManager().getWallet(mnemonic: mnemonics)
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
            let result = DataBaseManager.DBManager.insertToken(token: token)
            print("BTC钱包导入结果：\(result)")
            return token
        } catch {
            throw error
        }
    }
    private func createViolasWallet(mnemonics: [String]) throws -> Token {
        do {
            let wallet = try ViolasManager.getWallet(mnemonic: mnemonics)
            let token = Token.init(tokenID: 999,
                                     tokenName: "VLS",
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
            let result = DataBaseManager.DBManager.insertToken(token: token)
            print("Violas钱包导入结果：\(result)")
            return token
        } catch {
            throw error
        }
    }
    private func createLibraWallet(mnemonics: [String]) throws -> Token {
        do {

            let wallet = try LibraManager.getWallet(mnemonic: mnemonics)
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
            let result = DataBaseManager.DBManager.insertToken(token: token)
            print("Libra钱包导入结果：\(result)")
            return token
        } catch {
            throw error
        }
    }
    deinit {
        print("ImportWalletModel销毁了")
    }
}
