//
//  ImportIdentityWalletModel.swift
//  LibraWallet
//
//  Created by palliums on 2019/11/12.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit

class ImportIdentityWalletModel: NSObject {
    @objc var dataDic: NSMutableDictionary = [:]
    
    func importWallet(walletName: String, password: String, mnemonic: [String]){
        let quene = DispatchQueue.init(label: "createWalletQuene")
        quene.async {
            do {
                try self.importViolasWallet(name: walletName, password: password, mnemonics: mnemonic)
                try self.importBTCWallet(name: walletName, password: password, mnemonics: mnemonic)
                try self.importLibraWallet(name: walletName, password: password, mnemonics: mnemonic)
                setIdentityWalletState(show: true)
                DispatchQueue.main.async(execute: {
                    //需更新
                    let data = setKVOData(type: "ImportWallet")
                    self.setValue(data, forKey: "dataDic")
                })
            } catch {
                DispatchQueue.main.async(execute: {
                    //需更新
                    let data = setKVOData(error: LibraWalletError.error(error.localizedDescription), type: "ImportWallet")
                    self.setValue(data, forKey: "dataDic")
                })
            }
        }
    }
    func importBTCWallet(name: String, password: String, mnemonics: [String]) throws {
        let wallet = try! BTCManager().getWallet(mnemonic: mnemonics)
        let walletModel = LibraWalletManager.init(walletID: 999,
                                                  walletBalance: 0,
                                                  walletAddress: wallet.address.description,
                                                  walletRootAddress: "2_" + wallet.address.description,
                                                  walletCreateTime: NSDate().timeIntervalSince1970,
                                                  walletName: name,
                                                  walletSubscription: false,
                                                  walletBiometricLock: false,
                                                  walletCreateType: 0,
                                                  walletType: .BTC,
                                                  walletIndex: 0,
                                                  walletBackupState: true,
                                                  walletAuthenticationKey: "",
                                                  walletActiveState: false)
        let result = DataBaseManager.DBManager.insertWallet(model: walletModel)
        if result == true {
            do {
                try LibraWalletManager().saveMnemonicToKeychain(mnemonic: mnemonics, password: password, walletRootAddress: walletModel.walletRootAddress ?? "")
            } catch {
                print(error.localizedDescription)
                //删除从数据库创建好钱包
                _ = DataBaseManager.DBManager.deleteWalletFromTable(model: walletModel)
                throw error
            }
        }
    }
    func importViolasWallet(name: String, password: String, mnemonics: [String]) throws {
        do {
            let wallet = try ViolasManager.getWallet(mnemonic: mnemonics)
            let walletModel = LibraWalletManager.init(walletID: 999,
                                                      walletBalance: 0,
                                                      walletAddress: wallet.publicKey.toLegacy(),
                                                      walletRootAddress: "1_" + wallet.publicKey.toLegacy(),
                                                      walletCreateTime: NSDate().timeIntervalSince1970,
                                                      walletName: name,
                                                      walletSubscription: false,
                                                      walletBiometricLock: false,
                                                      walletCreateType: 0,
                                                      walletType: .Violas,
                                                      walletIndex: 0,
                                                      walletBackupState: true,
                                                      walletAuthenticationKey: wallet.publicKey.toActive(),
                                                      walletActiveState: false)
            let result = DataBaseManager.DBManager.insertWallet(model: walletModel)
            if result == true {
                do {
                    try LibraWalletManager().saveMnemonicToKeychain(mnemonic: mnemonics, password: password, walletRootAddress: walletModel.walletRootAddress ?? "")
                } catch {
                    print(error.localizedDescription)
                    //删除从数据库创建好钱包
                    _ = DataBaseManager.DBManager.deleteWalletFromTable(model: walletModel)
                    throw error
                }
            }
        } catch {
            throw error
        }
    }
    func importLibraWallet(name: String, password: String, mnemonics: [String]) throws {
        do {
            let wallet = try LibraManager.getWallet(mnemonic: mnemonics)
            let walletModel = LibraWalletManager.init(walletID: 999,
                                                      walletBalance: 0,
                                                      walletAddress: wallet.publicKey.toLegacy(),
                                                      walletRootAddress: "0_" + wallet.publicKey.toLegacy(),
                                                      walletCreateTime: NSDate().timeIntervalSince1970,
                                                      walletName: name,
                                                      walletSubscription: false,
                                                      walletBiometricLock: false,
                                                      walletCreateType: 0,
                                                      walletType: .Libra,
                                                      walletIndex: 0,
                                                      walletBackupState: true,
                                                      walletAuthenticationKey: wallet.publicKey.toActive(),
                                                      walletActiveState: false)
            let result = DataBaseManager.DBManager.insertWallet(model: walletModel)
            if result == true {
                do {
                    try LibraWalletManager().saveMnemonicToKeychain(mnemonic: mnemonics, password: password, walletRootAddress: walletModel.walletRootAddress ?? "")
                } catch {
                    print(error.localizedDescription)
                    //删除从数据库创建好钱包
                    _ = DataBaseManager.DBManager.deleteWalletFromTable(model: walletModel)
                    throw error
                }
            }
        } catch {
            throw error
        }
    }
    deinit {
        print("ImportIdentityWalletModel销毁了")
    }
}
