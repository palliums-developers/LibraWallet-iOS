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
                let violasWallet = try self.createViolasWallet(mnemonics: mnemonic)
                // 2.2创建BTC钱包
                let btcWallet = try self.createBTCWallet(mnemonics: mnemonic)
                // 2.3创建Libra钱包
                let libraWallet = try self.createLibraWallet(mnemonics: mnemonic)
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
                setIdentityWalletState(show: false)
                DispatchQueue.main.async(execute: {
                    //需更新
                    let data = setKVOData(error: LibraWalletError.error(error.localizedDescription), type: "CreateWallet")
                    self.setValue(data, forKey: "dataDic")
                })
                
            }
        }
    }
    func createBTCWallet(mnemonics: [String]) throws -> Token {
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
                                   tokenEnable: true)
            let result = DataBaseManager.DBManager.insertToken(token: token)
            print("BTC钱包创建结果：\(result)")
            return token
        } catch {
            throw error
        }
    }
    func createViolasWallet(mnemonics: [String]) throws -> Token {
        do {
            let wallet = try ViolasManager.getWallet(mnemonic: mnemonics)
            let token = Token.init(tokenID: 999,
                                   tokenName: "Violas",
                                   tokenBalance: 0,
                                   tokenAddress: wallet.publicKey.toLegacy(),
                                   tokenType: .Violas,
                                   tokenIndex: 0,
                                   tokenAuthenticationKey: wallet.publicKey.toActive(),
                                   tokenActiveState: false,
                                   tokenIcon: "violas_icon",
                                   tokenContract: "00000000000000000000000000000000",
                                   tokenModule: "LBR",
                                   tokenModuleName: "T",
                                   tokenEnable: true)
            let result = DataBaseManager.DBManager.insertToken(token: token)
            print("Violas钱包创建结果：\(result)")
            return token
        } catch {
            throw error
        }
    }
    func createLibraWallet(mnemonics: [String]) throws -> Token {
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
                                   tokenContract: "00000000000000000000000000000000",
                                   tokenModule: "LBR",
                                   tokenModuleName: "T",
                                   tokenEnable: true)
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
