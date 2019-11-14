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
        /// 获取沙盒地址
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        /// 拼接路径
        let filePath = "\(path[0])" + "/" + "LibraWallet.sqlite3"
        print(filePath)
        do {
            self.db = try Connection(filePath)
        } catch {
            print("createDataError")
        }
    }
    func createWalletTable() {
        /// 判断是否存在表
        guard isExistTable(name: "Wallet") == false else {
            return
        }
        do {
            let walletTable = Table("Wallet")
            // 设置字段
            let walletID = Expression<Int64>("wallet_id")
            // 钱包金额
            let walletBalance = Expression<Int64>("wallet_balance")
            // 钱包地址
            let walletAddress = Expression<String>("wallet_address")
            // Libra_、Violas_或BTC_ 前缀 + 钱包0层地址
            let walletRootAddress = Expression<String>("wallet_root_address")
            // 钱包创建时间
            let walletCreateTime = Expression<Int>("wallet_creat_time")
            // 钱包名字
            let walletName = Expression<String>("wallet_name")
            // 钱包助记词
//            let walletMnemonic = Expression<String>("wallet_mnemonic")
            // 当前使用钱包
            let walletCurrentUse = Expression<Bool>("wallet_current_use")
            // 是否使用生物解锁
            let walletBiometricLock = Expression<Bool>("wallet_biometric_lock")
            // 账户类型身份钱包、其他钱包(0=身份钱包、1=其它导入钱包)
            let walletIdentity = Expression<Int>("wallet_identity")
            // 钱包类型(0=Libra、1=Violas、2=BTC)
            let walletType = Expression<Int>("wallet_type")
            
            // 建表
            try db!.run(walletTable.create { t in
                t.column(walletID, primaryKey: true)
                t.column(walletAddress)
                t.column(walletRootAddress, unique: true)
                t.column(walletBalance)
                t.column(walletCreateTime)
                t.column(walletName)
                t.column(walletCurrentUse)
                t.column(walletBiometricLock)
                t.column(walletIdentity)
                t.column(walletType)
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
    func isExistTable(name: String) -> Bool {
        do {
            let walletTable = Table(name)
            _ = try db!.scalar(walletTable.count)
            return true
        } catch {
            print(error.localizedDescription)
            return false
        }
    }
    func insertWallet(model: LibraWalletManager) -> Bool {
        let homeTable = Table("Wallet")
        do {
            if let tempDB = self.db {
                let insert = homeTable.insert(
                    Expression<Int64>("wallet_balance") <- model.walletBalance ?? 0,
                    Expression<String>("wallet_address") <- model.walletAddress ?? "",
                    Expression<String>("wallet_root_address") <- model.walletRootAddress ?? "",

                    Expression<Int>("wallet_creat_time") <- model.walletCreateTime ?? 0,
                    Expression<String>("wallet_name") <- model.walletName ?? "",
                    Expression<Bool>("wallet_current_use") <- model.walletCurrentUse ?? true,
                    Expression<Bool>("wallet_biometric_lock") <- model.walletBiometricLock ?? false,
                    Expression<Int>("wallet_identity") <- model.walletIdentity ?? 999,
                    Expression<Int>("wallet_type") <- model.walletType!.value)
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
    func isExistAddressInWallet(address: String) -> Bool {
        let walletTable = Table("Wallet")
        do {
            if let tempDB = self.db {
                let transection = walletTable.filter(Expression<String>("wallet_root_address") == address)
                let count = try tempDB.scalar(transection.count)
                guard count != 0 else {
                    return false
                }
                return true
            } else {
                return false
            }
        } catch {
            print(error.localizedDescription)
            return false
        }
    }
    func getLocalWallets() -> [[LibraWalletManager]] {
        let walletTable = Table("Wallet")
        do {
            // 身份钱包
            var allWallets = [[LibraWalletManager]]()
            var originWallets = [LibraWalletManager]()
            var importWallets = [LibraWalletManager]()
            if let tempDB = self.db {
                for wallet in try tempDB.prepare(walletTable) {
                    // 钱包ID
                    let walletID = wallet[Expression<Int64>("wallet_id")]
                    // 钱包金额
                    let walletBalance = wallet[Expression<Int64>("wallet_balance")]
                    // 钱包地址
                    let walletAddress = wallet[Expression<String>("wallet_address")]
                    // Libra_、Violas_或BTC_ 前缀 + 钱包0层地址
                    let walletRootAddress = wallet[Expression<String>("wallet_root_address")]
                    // 钱包创建时间
                    let walletCreateTime = wallet[Expression<Int>("wallet_creat_time")]
                    // 钱包名字
                    let walletName = wallet[Expression<String>("wallet_name")]
                    // 钱包助记词
//                    let walletMnemonic = wallet[Expression<String>("wallet_mnemonic")]
                    // 当前使用用户
                    let walletCurrentUse = wallet[Expression<Bool>("wallet_current_use")]
                    // 账户是否开启生物锁定
                    let walletBiometricLock = wallet[Expression<Bool>("wallet_biometric_lock")]
                    // 账户类型身份钱包、其他钱包(0=身份钱包、1=其它导入钱包)
                    let walletIdentity = wallet[Expression<Int>("wallet_identity")]
                    // 钱包类型(0=Libra、1=Violas、2=BTC)
                    let walletType = wallet[Expression<Int>("wallet_type")]
                    let type: WalletType
                    if walletType == 0 {
                        type = .Libra
                    } else if walletType == 1 {
                        type = .Violas
                    } else {
                        type = .BTC
                    }
                    
                    let wallet = LibraWalletManager.init(walletID: walletID,
                                                         walletBalance: walletBalance,
                                                         walletAddress: walletAddress,
                                                         walletRootAddress: walletRootAddress,
                                                         walletCreateTime: walletCreateTime,
                                                         walletName: walletName,
                                                         walletCurrentUse: walletCurrentUse,
                                                         walletBiometricLock: walletBiometricLock,
                                                         walletIdentity: walletIdentity,
                                                         walletType: type)
                    if walletIdentity == 0 {
                        originWallets.append(wallet)
                    } else {
                        importWallets.append(wallet)
                    }
                }
                allWallets.append(originWallets)
                allWallets.append(importWallets)
                return allWallets
            } else {
                return allWallets
            }
        } catch {
            print(error.localizedDescription)
            return [[LibraWalletManager]]()
        }
    }
    func getCurrentUseWallet() throws -> LibraWalletManager {
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
                    // Libra_、Violas_或BTC_ 前缀 + 钱包0层地址
                    let walletRootAddress = wallet[Expression<String>("wallet_root_address")]
                    // 钱包创建时间
                    let walletCreateTime = wallet[Expression<Int>("wallet_creat_time")]
                    // 钱包名字
                    let walletName = wallet[Expression<String>("wallet_name")]
                    // 钱包助记词
//                    let walletMnemonic = wallet[Expression<String>("wallet_mnemonic")]
                    // 当前使用用户
                    let walletCurrentUse = wallet[Expression<Bool>("wallet_current_use")]
                    // 账户是否开启生物锁定
                    let walletBiometricLock = wallet[Expression<Bool>("wallet_biometric_lock")]
                    // 账户类型身份钱包、其他钱包(0=身份钱包、1=其它导入钱包)
                    let walletIdentity = wallet[Expression<Int>("wallet_identity")]
                    // 钱包类型(0=Libra、1=Violas、2=BTC)
                    let walletType = wallet[Expression<Int>("wallet_type")]
                    
                    var tempWalletType = WalletType.Libra
                    if walletType == 1 {
                        tempWalletType = WalletType.Violas
                    } else if walletType == 2 {
                        tempWalletType = WalletType.BTC
                    }
                    
                    let wallet = LibraWalletManager.init(walletID: walletID,
                                                         walletBalance: walletBalance,
                                                         walletAddress: walletAddress,
                                                         walletRootAddress: walletRootAddress,
                                                         walletCreateTime: walletCreateTime,
                                                         walletName: walletName,
                                                         walletCurrentUse: walletCurrentUse,
                                                         walletBiometricLock: walletBiometricLock,
                                                         walletIdentity: walletIdentity,
                                                         walletType: tempWalletType)
                    return wallet
                }
                throw LibraWalletError.error("获取当前使用钱包检索失败")
            } else {
                throw LibraWalletError.error("读取数据库失败")
            }
        } catch {
            print(error.localizedDescription)
            throw error
        }
    }
    func deleteWalletFromTable(model: LibraWalletManager) -> Bool {
        let transectionAddressHistoryTable = Table("Wallet")
        do {
            if let tempDB = self.db {
                let contract = transectionAddressHistoryTable.filter(Expression<Int64>("wallet_id") == model.walletID!)
                let rowid = try tempDB.run(contract.delete())
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
    func updateWalletBalance(walletID: Int64, balance: Int64) -> Bool {
        let walletTable = Table("Wallet")
        do {
            if let tempDB = self.db {
                let contract = walletTable.filter(Expression<Int64>("wallet_id") == walletID)
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
                let contract = walletTable.filter(Expression<Int64>("wallet_id") == walletID)
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
                return false
            }
        } catch {
            print(error.localizedDescription)
            return false
        }
    }
    func createTransferAddressListTable() {
        /// 判断是否存在表
        guard isExistTable(name: "TransferAddress") == false else {
            return
        }
        do {
            let addressTable = Table("TransferAddress")
            // 设置字段
            let addressID = Expression<Int64>("address_id")
            // 地址名字
            let addressName = Expression<String>("address_name")
            // 地址
            let address = Expression<String>("address")
            // 地址类型(0=Libra、1=Violas、2=BTC)
            let addressType = Expression<String>("address_type")
            
            // 建表
            try db!.run(addressTable.create { t in
                t.column(addressID, primaryKey: true)
                t.column(addressName)
                t.column(address, unique: true)
                t.column(addressType)
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
    func insertTransferAddress(model: AddressModel) -> Bool {
        let addressTable = Table("TransferAddress")
        do {
            if let tempDB = self.db {
                let insert = addressTable.insert(
                    
                    Expression<String>("address_name") <- model.addressName ?? "",
                    Expression<String>("address") <- "\(model.addressType!)_" + (model.address ?? ""),
                    Expression<String>("address_type") <- model.addressType ?? "")
                
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
    func getTransferAddress(type: String) -> NSMutableArray {
        let addressTable = type.isEmpty == true ? Table("TransferAddress") : Table("TransferAddress").filter(Expression<String>("address_type") == type)
        do {
            if let tempDB = self.db {
                let addressArray = NSMutableArray()
                for wallet in try tempDB.prepare(addressTable) {
                    // 地址ID
                    let addressID = wallet[Expression<Int64>("address_id")]
                    // 地址名字
                    let addressName = wallet[Expression<String>("address_name")]
                    // 地址
                    let address = wallet[Expression<String>("address")]
                    // 地址类型(0=Libra、1=Violas、2=BTC)
                    let addressType = wallet[Expression<String>("address_type")]

                    let contentArray = address.split(separator: "_").compactMap { (item) -> String in
                        return "\(item)"
                    }
                    guard contentArray.count == 2 else {
                        continue
                    }
                    let model = AddressModel.init(addressID: addressID,
                                                  address: contentArray.last,
                                                  addressName: addressName,
                                                  addressType: addressType)

                    addressArray.add(model)
                }
                return addressArray
            } else {
                return NSMutableArray()
            }
        } catch {
            print(error.localizedDescription)
            return NSMutableArray()
        }
    }
    func updateTransferAddressName(model: AddressModel, name: String) -> Bool {
        let addressTable = Table("TransferAddress")
        do {
            if let tempDB = self.db {
                let item = addressTable.filter(Expression<String>("address") == model.address!)
                try tempDB.run(item.update(Expression<String>("address_name") <- name))
                return true
            } else {
                return false
            }
        } catch {
            print(error.localizedDescription)
            return false
        }
    }
    func deleteTransferAddressFromTable(model: AddressModel) -> Bool {
        let transectionAddressHistoryTable = Table("Wallet")
        do {
            if let tempDB = self.db {
                let contract = transectionAddressHistoryTable.filter(Expression<Int64>("address_id") == model.addressID!)
                let rowid = try tempDB.run(contract.delete())
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
    // MARK: 创建ViolasToken表
    func createViolasTokenTable() {
        /// 判断是否存在表
        guard isExistTable(name: "ViolasToken") == false else {
            return
        }
        do {
            let addressTable = Table("ViolasToken")
            // 设置字段
            let tokenID = Expression<Int64>("token_id")
            // 代币图片
            let tokenIcon = Expression<String>("token_icon")
            // 代币名字
            let tokenName = Expression<String>("token_name")
            // 代币描述
            let tokenDescription = Expression<String>("token_description")
            // 代币地址
            let tokenAddress = Expression<String>("token_address")
            // 代币绑定钱包
            let tokenBindingWalletID = Expression<Int64>("token_binding_wallet_id")
            // 代币金额
            let tokenAmount = Expression<Int64>("token_amount")
            // 建表
            try db!.run(addressTable.create { t in
                t.column(tokenID, primaryKey: true)
                t.column(tokenIcon)
                t.column(tokenName)
                t.column(tokenDescription)
                t.column(tokenAddress)
                t.column(tokenBindingWalletID)
                t.column(tokenAmount)
                t.unique([tokenBindingWalletID, tokenAddress])
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
    func insertViolasToken(walletID: Int64, model: ViolasTokenModel) -> Bool {
        let addressTable = Table("ViolasToken")
        do {
            if let tempDB = self.db {
                let insert = addressTable.insert(
                    Expression<String>("token_icon") <- model.icon ?? "",
                    Expression<String>("token_name") <- model.name ?? "",
                    Expression<String>("token_description") <- model.description ?? "",
                    Expression<String>("token_address") <- model.address ?? "",
                    Expression<Int64>("token_binding_wallet_id") <- walletID,
                    Expression<Int64>("token_amount") <- 0)
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
    func isExistViolasToken(walletID: Int64, address: String) -> Bool {
        let walletTable = Table("ViolasToken")
        do {
            if let tempDB = self.db {
                let transection = walletTable.filter(Expression<String>("token_address") == address && Expression<Int64>("token_binding_wallet_id") == walletID)
                let count = try tempDB.scalar(transection.count)
                guard count != 0 else {
                    return false
                }
                return true
            } else {
                return false
            }
        } catch {
            print(error.localizedDescription)
            return false
        }
    }
    func getViolasTokens(walletID: Int64) throws -> [ViolasTokenModel] {
        let walletTable = Table("ViolasToken").filter(Expression<Int64>("token_binding_wallet_id") == walletID)
        do {
            if let tempDB = self.db {
                var models = [ViolasTokenModel]()
                for wallet in try tempDB.prepare(walletTable) {
                    // 代币图片
                    let tokenIcon = wallet[Expression<String>("token_icon")]
                    // 代币名字
                    let tokenName = wallet[Expression<String>("token_name")]
                    // 代币描述
                    let tokenDescription = wallet[Expression<String>("token_description")]
                    // 代币地址
                    let tokenAddress = wallet[Expression<String>("token_address")]
                    // 代币绑定钱包
//                    let tokenBindingWalletID = wallet[Expression<Int64>("token_binding_wallet_id")]
                    
                    let wallet = ViolasTokenModel.init(name: tokenName,
                                                       description: tokenDescription,
                                                       address: tokenAddress,
                                                       icon: tokenIcon,
                                                       enable: true)
                    models.append(wallet)
                }
                return models
            } else {
                throw LibraWalletError.error("读取数据库失败")
            }
        } catch {
            print(error.localizedDescription)
            throw error
        }
    }
    func deleteViolasToken(walletID: Int64, address: String) -> Bool {
        let violasTokenTable = Table("ViolasToken")
        do {
            if let tempDB = self.db {
                let contract = violasTokenTable.filter(Expression<String>("token_address") == address && Expression<Int64>("token_binding_wallet_id") == walletID)
                let rowid = try tempDB.run(contract.delete())
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
    // MARK: 创建ViolasToken表
//    func createEnableTokenTable() {
//        /// 判断是否存在表
//        guard isExistTable(name: "ViolasToken") == false else {
//            return
//        }
//        do {
//            let addressTable = Table("ViolasToken")
//            // 设置字段
//            let tokenID = Expression<Int64>("token_id")
//            // 代币图片
//            let tokenIcon = Expression<String>("token_icon")
//            // 代币名字
//            let tokenName = Expression<String>("token_name")
//            // 代币描述
//            let tokenDescription = Expression<String>("token_description")
//            // 代币地址
//            let tokenAddress = Expression<String>("token_address")
//            // 代币绑定钱包
//            let tokenBindingWalletID = Expression<String>("token_binding_wallet_id")
//
//            // 建表
//            try db!.run(addressTable.create { t in
//                t.column(tokenID, primaryKey: true)
//                t.column(tokenIcon)
//                t.column(tokenName)
//                t.column(tokenDescription)
//                t.column(tokenAddress, unique: true)
//                t.column(tokenBindingWalletID)
//            })
//        } catch {
//            let errorString = error.localizedDescription
//            if errorString.hasSuffix("already exists") == true {
//                return
//            } else {
//                print(errorString)
//            }
//        }
//    }
}
