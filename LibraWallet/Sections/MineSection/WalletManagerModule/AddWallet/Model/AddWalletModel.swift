//
//  AddWalletModel.swift
//  LibraWallet
//
//  Created by palliums on 2019/10/25.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit
struct CreateWalletModel {
    var password: String?
    var mnemonic: [String]?
    var wallet: [Token]?
}
class AddWalletModel: NSObject {
    @objc dynamic var dataDic: NSMutableDictionary = [:]
    func createWallet(password: String){
        let quene = DispatchQueue.init(label: "createWalletQuene")
        quene.async {
            do {
                // 1.生成助记词
                let mnemonic = try LibraMnemonic.generate(strength: .default, language: .english)
                // 2.1创建Violas钱包
                let violasWallet = try self.createViolasWallet(mnemonic: mnemonic)
                // 2.2创建BTC钱包
                let btcWallet = try self.createBTCWallet(mnemonic: mnemonic)
                // 2.3创建Libra钱包
                let libraWallet = try self.createLibraWallet(mnemonic: mnemonic)
                // 2.4创建总钱包
                try self.createWallet(mnemonic: mnemonic, btcAddress: btcWallet.tokenAddress, violasAddress: violasWallet.tokenAddress, libraAddress: libraWallet.tokenAddress)
                // 3.设置已创建钱包状态
                setIdentityWalletState(show: true)
                // 4.加密助记词到Keychain
                try WalletManager.saveMnemonicToKeychain(mnemonic: mnemonic, password: password)
                let tempWallet = CreateWalletModel.init(password: password,
                                                        mnemonic: mnemonic,
                                                        wallet: [violasWallet, btcWallet, libraWallet])
                DispatchQueue.main.async(execute: {
                    //需更新
                    let data = setKVOData(type: "CreateWallet", data: tempWallet)
                    self.setValue(data, forKey: "dataDic")
                })
            } catch {
                DataBaseManager.DBManager.deleteHDWallet()
                DataBaseManager.DBManager.deleteAllTokens()
                setIdentityWalletState(show: false)
                DispatchQueue.main.async(execute: {
                    //需更新
                    let data = setKVOData(error: LibraWalletError.error(error.localizedDescription), type: "CreateWallet")
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
                                            walletBackupState: false,
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
    func createBTCWallet(mnemonic: [String]) throws -> Token {
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
            let result = DataBaseManager.DBManager.insertToken(token: token)
            print("BTC钱包创建结果：\(result)")
            return token
        } catch {
            throw error
        }
    }
    func createViolasWallet(mnemonic: [String]) throws -> Token {
        do {
            let wallet = try ViolasManager.getWallet(mnemonic: mnemonic)
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
                                   tokenModuleName: "T",
                                   tokenEnable: true,
                                   tokenPrice: "0.0")
            let result = DataBaseManager.DBManager.insertToken(token: token)
            print("Violas钱包创建结果：\(result)")
            return token
        } catch {
            throw error
        }
    }
    func createLibraWallet(mnemonic: [String]) throws -> Token {
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
            let result = DataBaseManager.DBManager.insertToken(token: token)
            print("Libra钱包创建结果：\(result)")
            return token
        } catch {
            throw error
        }
    }
    deinit {
        print("CreateIdentityWalletModel销毁了")
    }
}
