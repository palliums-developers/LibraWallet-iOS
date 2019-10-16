//
//  DataBaseManager.swift
//  LibraWallet
//
//  Created by palliums on 2019/9/11.
//  Copyright © 2019 palliums. All rights reserved.
//

import Foundation
import SQLite
struct DataBaseManager {
    static var DBManager = DataBaseManager()
    var db: Connection?
    mutating func creatLibraDB() {
        // 获取沙盒地址
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        // 拼接路径
        let filePath = "\(path[0])" + "/" + "LibraWallet.sqlite3"
        print(filePath)
        do {
            self.db = try Connection(filePath)
        } catch {
            print("createDataError")
        }
    }
    func createWalletTable() {
        do {
            let walletTable = Table("Wallet")
            // 设置字段
            let walletID = Expression<Int64>("wallet_id")
            // 钱包金额
            let walletBalance = Expression<Int64>("wallet_balance")
            // 钱包地址
            let walletAddress = Expression<String>("wallet_address")
            // 钱包创建时间
            let walletCreateTime = Expression<Int>("wallet_creat_time")
            // 钱包名字
            let walletName = Expression<String>("wallet_name")
            // 钱包助记词
            let walletMnemonic = Expression<String>("wallet_mnemonic")
            // 当前使用钱包
            let walletCurrentUse = Expression<Bool>("wallet_current_use")
            // 是否使用生物解锁
            let walletBiometricLock = Expression<Bool>("wallet_biometric_lock")
            
            //建表
            try db!.run(walletTable.create { t in
                t.column(walletID, primaryKey: true)
                t.column(walletMnemonic)
                t.column(walletAddress, unique: true)
                t.column(walletBalance)
                t.column(walletCreateTime)
                t.column(walletName)
                t.column(walletCurrentUse)
                t.column(walletBiometricLock)
            })
        } catch {
            let errorString = error.localizedDescription
            if errorString.hasSuffix("already exists") == true {
                return
            } else {
                print(errorString)
            }
        }
    }
    func insertWallet(model: LibraWalletManager) -> Bool {
        let homeTable = Table("Wallet")
        do {
            if let tempDB = self.db {
                let insert = homeTable.insert(
                    Expression<Int64>("wallet_balance") <- model.walletBalance ?? 0,
                    Expression<String>("wallet_address") <- model.walletAddress ?? "",
                    Expression<Int>("wallet_creat_time") <- model.walletCreateTime ?? 0,
                    Expression<String>("wallet_mnemonic") <- model.walletMnemonic ?? "",
                    Expression<String>("wallet_name") <- model.walletName ?? "",
                    Expression<Bool>("wallet_current_use") <- model.walletCurrentUse ?? true,
                    Expression<Bool>("wallet_biometric_lock") <- model.walletBiometricLock ?? false)
                
                let rowid = try tempDB.run(insert)
                print(rowid)
                return true
            } else {
                return false
            }
        } catch {
            print(error.localizedDescription)
            return false
        }
    }
    func loadCurrentUseWallet() -> Bool {
        let walletTable = Table("Wallet").filter(Expression<Bool>("wallet_current_use") == true)
        do {
            if let tempDB = self.db {
                for wallet in try tempDB.prepare(walletTable) {
                    // 钱包ID
                    let walletID = wallet[Expression<Int64>("wallet_id")]
                    // 钱包金额
                    let walletBalance = wallet[Expression<Int64>("wallet_balance")]
                    // 钱包地址
                    let walletAddress = wallet[Expression<String>("wallet_address")]
                    // 钱包创建时间
                    let walletCreateTime = wallet[Expression<Int>("wallet_creat_time")]
                    // 钱包名字
                    let walletName = wallet[Expression<String>("wallet_name")]
                    // 钱包助记词
                    let walletMnemonic = wallet[Expression<String>("wallet_mnemonic")]
                    // 当前使用用户
                    let walletCurrentUse = wallet[Expression<Bool>("wallet_current_use")]
                    // 账户是否开启生物锁定
                    let walletBiometricLock = wallet[Expression<Bool>("wallet_biometric_lock")]
                    
                    
                    let mnemonicArray = walletMnemonic.split(separator: " ").compactMap { (item) -> String in
                        return "\(item)"
                    }
                    let seed = try LibraMnemonic.seed(mnemonic: mnemonicArray)
//                    let tempWallet = LibraWallet.init(seed: seed)
                    let tempWallet = try LibraWallet.init(seed: seed)
                    LibraWalletManager.shared.initWallet(walletID: walletID,
                                                         walletBalance: walletBalance,
                                                         walletAddress: walletAddress,
                                                         walletCreateTime: walletCreateTime,
                                                         walletName: walletName,
                                                         walletMnemonic: walletMnemonic,
                                                         walletCurrentUse: walletCurrentUse,
                                                         walletBiometricLock: walletBiometricLock,
                                                         wallet: tempWallet)
                    return true
                }
                return false
            } else {
                return false
            }
        } catch {
            print(error.localizedDescription)
            return false
        }
    }
    func updateWalletBalance(walletID: Int64, balance: Int64) -> Bool {
        let walletTable = Table("Wallet")
        do {
            if let tempDB = self.db {
                let contract = walletTable.filter(Expression<Int64>("wallet_uid") == walletID)
                try tempDB.run(contract.update(Expression<Int64>("wallet_balance") <- balance))
                return true
            } else {
                return false
            }
        } catch {
            print(error.localizedDescription)
            return false
        }
    }
    func updateWalletName(walletID: Int64, name: String) -> Bool {
        let walletTable = Table("Wallet")
        do {
            if let tempDB = self.db {
                let contract = walletTable.filter(Expression<Int64>("wallet_uid") == walletID)
                try tempDB.run(contract.update(Expression<String>("wallet_name") <- name))
                return true
            } else {
                return false
            }
        } catch {
            print(error.localizedDescription)
            return false
        }
    }
    func updateWalletBiometricLockState(walletID: Int64, state: Bool) -> Bool {
        let walletTable = Table("Wallet")
        do {
            if let tempDB = self.db {
                let contract = walletTable.filter(Expression<Int64>("wallet_id") == walletID)
                try tempDB.run(contract.update(Expression<Bool>("wallet_biometric_lock") <- state))
                return true
            } else {
                return false
            }
        } catch {
            print(error.localizedDescription)
            return false
        }
    }
    func updateWalletCurrentUseState(walletID: Int64, state: Bool) -> Bool {
        let walletTable = Table("Wallet")
        do {
            if let tempDB = self.db {
                let contract = walletTable.filter(Expression<Int64>("wallet_id") == walletID)
                try tempDB.run(contract.update(Expression<Bool>("wallet_current_use") <- state))
                return true
            } else {
                return false
            }
        } catch {
            print(error.localizedDescription)
            return false
        }
    }
    func userExistInLocal(walletID: Int64) -> Bool {
        let walletTable = Table("Wallet")
        do {
            if let tempDB = self.db {
                let transection = walletTable.filter(Expression<Int64>("wallet_id") == walletID)
                let count = try tempDB.scalar(transection.count)
                if count == 0 {
                    return false
                } else {
                    return true
                }
            } else {
                return true
            }
        } catch {
            print(error.localizedDescription)
            return true
        }
    }
}
