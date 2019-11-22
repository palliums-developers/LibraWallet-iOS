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
                try self.createBTCWallet(name: walletName, password: password, mnemonics: mnemonic)
                try self.createLibraWallet(name: walletName, password: password, mnemonics: mnemonic)
                try self.createViolasWallet(name: walletName, password: password, mnemonics: mnemonic)
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
        let wallet = BTCManager().getWallet(mnemonic: mnemonics)
        let walletModel = LibraWalletManager.init(walletID: 999,
                                                  walletBalance: 0,
                                                  walletAddress: wallet.address.description,
                                                  walletRootAddress: "BTC_" + wallet.address.description,
                                                  walletCreateTime: Int(NSDate().timeIntervalSince1970),
                                                  walletName: name,
                                                  walletCurrentUse: false,
                                                  walletBiometricLock: false,
                                                  walletIdentity: 0,
                                                  walletType: .BTC)
        let result = DataBaseManager.DBManager.insertWallet(model: walletModel)
        if result == true {
            do {
                try LibraWalletManager().saveMnemonicToKeychain(mnemonic: mnemonics, walletRootAddress: walletModel.walletRootAddress ?? "")
                try LibraWalletManager().savePaymentPasswordToKeychain(password: password, walletRootAddress: walletModel.walletRootAddress ?? "")
            } catch {
                print(error.localizedDescription)
                //删除从数据库创建好钱包
                _ = DataBaseManager.DBManager.deleteWalletFromTable(model: walletModel)
                throw error
            }
        }
    }
    func createViolasWallet(name: String, password: String, mnemonics: [String]) throws {
        do {
            let wallet = try ViolasManager.getWallet(mnemonic: mnemonics)
            let walletModel = LibraWalletManager.init(walletID: 999,
                                                      walletBalance: 0,
                                                      walletAddress: wallet.publicKey.toAddress(),
                                                      walletRootAddress: "Violas_" + wallet.publicKey.toAddress(),
                                                      walletCreateTime: Int(NSDate().timeIntervalSince1970),
                                                      walletName: name,
                                                      walletCurrentUse: true,
                                                      walletBiometricLock: false,
                                                      walletIdentity: 0,
                                                      walletType: .Violas)
            let result = DataBaseManager.DBManager.insertWallet(model: walletModel)
            if result == true {
                do {
                    try LibraWalletManager().saveMnemonicToKeychain(mnemonic: mnemonics, walletRootAddress: walletModel.walletRootAddress ?? "")
                    try LibraWalletManager().savePaymentPasswordToKeychain(password: password, walletRootAddress: walletModel.walletRootAddress ?? "")
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
    func createLibraWallet(name: String, password: String, mnemonics: [String]) throws {
        do {

            let wallet = try LibraManager.getWallet(mnemonic: mnemonics)
            let walletModel = LibraWalletManager.init(walletID: 999,
                                                      walletBalance: 0,
                                                      walletAddress: wallet.publicKey.toAddress(),
                                                      walletRootAddress: "Libra_" + wallet.publicKey.toAddress(),
                                                      walletCreateTime: Int(NSDate().timeIntervalSince1970),
                                                      walletName: name,
                                                      walletCurrentUse: false,
                                                      walletBiometricLock: false,
                                                      walletIdentity: 0,
                                                      walletType: .Libra)
            let result = DataBaseManager.DBManager.insertWallet(model: walletModel)
            if result == true {
                do {
                    try LibraWalletManager().saveMnemonicToKeychain(mnemonic: mnemonics, walletRootAddress: walletModel.walletRootAddress ?? "")
                    try LibraWalletManager().savePaymentPasswordToKeychain(password: password, walletRootAddress: walletModel.walletRootAddress ?? "")
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
        print("CreateIdentityWalletModel销毁了")
    }
}
