//
//  CreateIdentityWalletModel.swift
//  LibraWallet
//
//  Created by palliums on 2019/10/18.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit

class CreateIdentityWalletModel: NSObject {
    @objc var dataDic: NSMutableDictionary = [:]
    
    func createWallet(walletName: String, password: String){
        let quene = DispatchQueue.init(label: "createWalletQuene")
        quene.async {
            do {
                let mnemonic = try LibraMnemonic.generate(strength: .default, language: .english)
                try self.createViolasWallet(name: walletName, password: password, mnemonics: mnemonic)
                try self.createBTCWallet(name: walletName, password: password, mnemonics: mnemonic)
                try self.createLibraWallet(name: walletName, password: password, mnemonics: mnemonic)
                setIdentityWalletState(show: true)
                let tempWallet = CreateWalletModel.init(password: nil,
                                                        mnemonic: mnemonic,
                                                        wallet: nil)
                DispatchQueue.main.async(execute: {
                    //需更新
                    let data = setKVOData(type: "CreateWallet", data: tempWallet)
                    self.setValue(data, forKey: "dataDic")
                })
            } catch {
                DispatchQueue.main.async(execute: {
                    //需更新
                    let data = setKVOData(error: LibraWalletError.error(error.localizedDescription), type: "CreateWallet")
                    self.setValue(data, forKey: "dataDic")
                })
            }
        }
    }
    func createBTCWallet(name: String, password: String, mnemonics: [String]) throws {
//        let wallet = try! BTCManager().getWallet(mnemonic: mnemonics)
//        let walletModel = LibraWalletManager.init(walletID: 999,
//                                                  walletBalance: 0,
//                                                  walletAddress: wallet.address.description,
//                                                  walletRootAddress: "2_" + wallet.address.description,
//                                                  walletCreateTime: NSDate().timeIntervalSince1970,
//                                                  walletName: name,
//                                                  walletSubscription: false,
//                                                  walletBiometricLock: false,
//                                                  walletCreateType: 1,
//                                                  walletType: .BTC,
//                                                  walletIndex: 0,
//                                                  walletBackupState: false,
//                                                  walletAuthenticationKey: "",
//                                                  walletActiveState: true)
//        let result = DataBaseManager.DBManager.insertWallet(model: walletModel)
//        if result == true {
//            do {
//                try LibraWalletManager().saveMnemonicToKeychain(mnemonic: mnemonics, password: password, walletRootAddress: walletModel.walletRootAddress ?? "")
//            } catch {
//                print(error.localizedDescription)
//                //删除从数据库创建好钱包
//                _ = DataBaseManager.DBManager.deleteWalletFromTable(model: walletModel)
//                throw error
//            }
//        }
    }
    func createViolasWallet(name: String, password: String, mnemonics: [String]) throws {
//        do {
//            let wallet = try ViolasManager.getWallet(mnemonic: mnemonics)
//            let walletModel = LibraWalletManager.init(walletID: 999,
//                                                      walletBalance: 0,
//                                                      walletAddress: wallet.publicKey.toLegacy(),
//                                                      walletRootAddress: "1_" + wallet.publicKey.toLegacy(),
//                                                      walletCreateTime: NSDate().timeIntervalSince1970,
//                                                      walletName: name,
//                                                      walletSubscription: false,
//                                                      walletBiometricLock: false,
//                                                      walletCreateType: 1,
//                                                      walletType: .Violas,
//                                                      walletIndex: 0,
//                                                      walletBackupState: false,
//                                                      walletAuthenticationKey: wallet.publicKey.toActive(),
//                                                      walletActiveState: false)
//            let result = DataBaseManager.DBManager.insertWallet(model: walletModel)
//            if result == true {
//                do {
//                    try LibraWalletManager().saveMnemonicToKeychain(mnemonic: mnemonics, password: password, walletRootAddress: walletModel.walletRootAddress ?? "")
//                } catch {
//                    print(error.localizedDescription)
//                    //删除从数据库创建好钱包
//                    _ = DataBaseManager.DBManager.deleteWalletFromTable(model: walletModel)
//                    throw error
//                }
//            }
//        } catch {
//            throw error
//        }
    }
    func createLibraWallet(name: String, password: String, mnemonics: [String]) throws {
//        do {
//
//            let wallet = try LibraManager.getWallet(mnemonic: mnemonics)
//            let walletModel = LibraWalletManager.init(walletID: 999,
//                                                      walletBalance: 0,
//                                                      walletAddress: wallet.publicKey.toLegacy(),
//                                                      walletRootAddress: "0_" + wallet.publicKey.toLegacy(),
//                                                      walletCreateTime: NSDate().timeIntervalSince1970,
//                                                      walletName: name,
//                                                      walletSubscription: false,
//                                                      walletBiometricLock: false,
//                                                      walletCreateType: 1,
//                                                      walletType: .Libra,
//                                                      walletIndex: 0,
//                                                      walletBackupState: false,
//                                                      walletAuthenticationKey: wallet.publicKey.toActive(),
//                                                      walletActiveState: false)
//            let result = DataBaseManager.DBManager.insertWallet(model: walletModel)
//            if result == true {
//                do {
//                    try LibraWalletManager().saveMnemonicToKeychain(mnemonic: mnemonics, password: password, walletRootAddress: walletModel.walletRootAddress ?? "")
//                } catch {
//                    print(error.localizedDescription)
//                    //删除从数据库创建好钱包
//                    _ = DataBaseManager.DBManager.deleteWalletFromTable(model: walletModel)
//                    throw error
//                }
//            }
//        } catch {
//            throw error
//        }
    }
    deinit {
        print("CreateIdentityWalletModel销毁了")
    }
}
