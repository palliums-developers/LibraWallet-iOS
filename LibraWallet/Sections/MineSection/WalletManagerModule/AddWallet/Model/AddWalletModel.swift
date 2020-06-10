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
    var wallet: [LibraWalletManager]?
}
class AddWalletModel: NSObject {
    @objc dynamic var dataDic: NSMutableDictionary = [:]
    func createWallet(walletName: String, password: String){
        let quene = DispatchQueue.init(label: "createWalletQuene")
        quene.async {
            do {
                // 1.生成助记词
                let mnemonic = try LibraMnemonic.generate(strength: .default, language: .english)
                // 2.1创建Violas钱包
                let violasWallet = try self.createViolasWallet(name: walletName, password: password, mnemonics: mnemonic)
                // 2.2创建BTC钱包
                let btcWallet = try self.createBTCWallet(name: walletName, password: password, mnemonics: mnemonic)
                // 2.3创建Libra钱包
                let libraWallet = try self.createLibraWallet(name: walletName, password: password, mnemonics: mnemonic)
                // 3.设置已创建钱包状态
                setIdentityWalletState(show: true)
                // 4.加密助记词到Keychain
                try LibraWalletManager.saveMnemonicToKeychain(mnemonic: mnemonic, password: password)
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
    func createBTCWallet(name: String, password: String, mnemonics: [String]) throws -> LibraWalletManager {
        do {
            let wallet = try BTCManager().getWallet(mnemonic: mnemonics)
            let walletModel = LibraWalletManager.init(walletID: 999,
                                                      walletBalance: 0,
                                                      walletAddress: wallet.address.description,
                                                      walletCreateTime: NSDate().timeIntervalSince1970,
                                                      walletName: name,
                                                      walletSubscription: false,
                                                      walletBiometricLock: false,
                                                      walletCreateType: 1,
                                                      walletType: .BTC,
                                                      walletIndex: 0,
                                                      walletBackupState: false,
                                                      walletAuthenticationKey: "",
                                                      walletActiveState: true,
                                                      walletIcon: "btc_icon",
                                                      walletContract: "",
                                                      walletModule: "",
                                                      walletModuleName: "")
            let result = DataBaseManager.DBManager.insertWallet(model: walletModel)
            print("BTC钱包创建结果：\(result)")
            return walletModel
        } catch {
            throw error
        }
    }
    func createViolasWallet(name: String, password: String, mnemonics: [String]) throws -> LibraWalletManager {
        do {
            let wallet = try ViolasManager.getWallet(mnemonic: mnemonics)
            let walletModel = LibraWalletManager.init(walletID: 999,
                                                      walletBalance: 0,
                                                      walletAddress: wallet.publicKey.toLegacy(),
                                                      walletCreateTime: NSDate().timeIntervalSince1970,
                                                      walletName: name,
                                                      walletSubscription: false,
                                                      walletBiometricLock: false,
                                                      walletCreateType: 1,
                                                      walletType: .Violas,
                                                      walletIndex: 0,
                                                      walletBackupState: false,
                                                      walletAuthenticationKey: wallet.publicKey.toActive(),
                                                      walletActiveState: false,
                                                      walletIcon: "violas_icon",
                                                      walletContract: "00000000000000000000000000000000",
                                                      walletModule: "LBR",
                                                      walletModuleName: "T")
            let result = DataBaseManager.DBManager.insertWallet(model: walletModel)
            print("Violas钱包创建结果：\(result)")
            return walletModel
        } catch {
            throw error
        }
    }
    func createLibraWallet(name: String, password: String, mnemonics: [String]) throws -> LibraWalletManager {
        do {

            let wallet = try LibraManager.getWallet(mnemonic: mnemonics)
            let walletModel = LibraWalletManager.init(walletID: 999,
                                                      walletBalance: 0,
                                                      walletAddress: wallet.publicKey.toLegacy(),
                                                      walletCreateTime: NSDate().timeIntervalSince1970,
                                                      walletName: name,
                                                      walletSubscription: false,
                                                      walletBiometricLock: false,
                                                      walletCreateType: 1,
                                                      walletType: .Libra,
                                                      walletIndex: 0,
                                                      walletBackupState: false,
                                                      walletAuthenticationKey: wallet.publicKey.toActive(),
                                                      walletActiveState: false,
                                                      walletIcon: "libra_icon",
                                                      walletContract: "00000000000000000000000000000000",
                                                      walletModule: "LBR",
                                                      walletModuleName: "T")
            let result = DataBaseManager.DBManager.insertWallet(model: walletModel)
            print("Libra钱包创建结果：\(result)")
            return walletModel
        } catch {
            throw error
        }
    }
    deinit {
        print("CreateIdentityWalletModel销毁了")
    }
}
