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
    mutating func creatLocalDataBase() {
        /// 获取沙盒地址
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        /// 拼接路径
        let filePath = "\(path[0])" + "/" + "PalliumsWallet.sqlite3"
        print(filePath)
        do {
            self.db = try Connection(filePath)
        } catch {
            print("CreateDataBaseError")
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

}
extension DataBaseManager {
    func createWalletTable() {
        /// 判断是否存在表
        guard isExistTable(name: "Wallet") == false else {
            return
        }
        guard let dataBase = self.db else {
            return
        }
        do {
            let walletTable = Table("Wallet")
            // 钱包序号
            let walletID = Expression<Int64>("wallet_id")
            // 钱包金额（最小单位为基准）
            let walletBalance = Expression<Int64>("wallet_balance")
            // 钱包地址
            let walletAddress = Expression<String>("wallet_address")
            // 钱包创建时间
            let walletCreateTime = Expression<Double>("wallet_creat_time")
            // 钱包名字
            let walletName = Expression<String>("wallet_name")
            // 当前WalletConnect订阅钱包
            let walletSubscription = Expression<Bool>("wallet_subscription")
            // 是否使用生物解锁
            let walletBiometricLock = Expression<Bool>("wallet_biometric_lock")
            // 钱包创建类型(0导入、1创建)
            let walletCreateType = Expression<Int>("wallet_create_type")
            // 钱包类型(0=Libra、1=Violas、2=BTC)
            let walletType = Expression<Int>("wallet_type")
            // 钱包当前使用层数
            let walletIndex = Expression<Int>("wallet_index")
            // 钱包是否已备份
            let walletBackupState = Expression<Bool>("wallet_backup_state")
            // 授权Key
            let authenticationKey = Expression<String>("wallet_authentication_key")
            // 钱包激活状态
            let walletActiveState = Expression<Bool>("wallet_active_state")
            // 钱包标志
            let walletIcon = Expression<String>("wallet_icon")
            // 钱包合约地址
            let walletContract = Expression<String>("wallet_contract")
            // 钱包合约名称
            let walletModule = Expression<String>("wallet_module")
            // 钱包合约名称
            let walletModuleName = Expression<String>("wallet_module_name")
            // 建表
            try dataBase.run(walletTable.create { t in
                t.column(walletID, primaryKey: true)
                t.column(walletAddress)
                t.column(walletBalance)
                t.column(walletCreateTime)
                t.column(walletName)
                t.column(walletSubscription)
                t.column(walletBiometricLock)
                t.column(walletCreateType)
                t.column(walletType)
                t.column(walletIndex)
                t.column(walletBackupState)
                t.column(authenticationKey)
                t.column(walletActiveState)
                t.column(walletIcon)
                t.column(walletContract)
                t.column(walletModule)
                t.column(walletModuleName)
                t.unique([walletAddress, walletContract, walletType])
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
                    Expression<Int64>("wallet_balance") <- model.walletBalance,
                    Expression<String>("wallet_address") <- model.walletAddress,
                    Expression<Double>("wallet_creat_time") <- model.walletCreateTime,
                    Expression<String>("wallet_name") <- model.walletName,
                    Expression<Bool>("wallet_subscription") <- model.walletSubscription,
                    Expression<Bool>("wallet_biometric_lock") <- model.walletBiometricLock,
                    Expression<Int>("wallet_create_type") <- model.walletCreateType,
                    Expression<Int>("wallet_type") <- model.walletType.value,
                    Expression<Int>("wallet_index") <- model.walletIndex,
                    Expression<Bool>("wallet_backup_state") <- model.walletBackupState,
                    Expression<String>("wallet_authentication_key") <- model.walletAuthenticationKey,
                    Expression<Bool>("wallet_active_state") <- model.walletActiveState,
                    Expression<String>("wallet_icon") <- model.walletIcon,
                    Expression<String>("wallet_contract") <- model.walletContract,
                    Expression<String>("wallet_module") <- model.walletModule,
                    Expression<String>("wallet_module_name") <- model.walletModuleName)
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
    func isExistWalletInWallet(wallet: LibraWalletManager) -> Bool {
        let walletTable = Table("Wallet")
        do {
            if let tempDB = self.db {
                let transection = walletTable.filter(Expression<String>("wallet_address") == wallet.walletAddress && Expression<String>("wallet_contract") == wallet.walletContract && Expression<Int>("wallet_type") == wallet.walletType.value)
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
    func getLocalWallets() -> [LibraWalletManager] {
        let walletTable = Table("Wallet")
        do {
            // 身份钱包
            var allWallets = [LibraWalletManager]()
            if let tempDB = self.db {
                for wallet in try tempDB.prepare(walletTable) {
                    // 钱包ID
                    let walletID = wallet[Expression<Int64>("wallet_id")]
                    // 钱包金额
                    let walletBalance = wallet[Expression<Int64>("wallet_balance")]
                    // 钱包地址
                    let walletAddress = wallet[Expression<String>("wallet_address")]
                    // 钱包创建时间
                    let walletCreateTime = wallet[Expression<Double>("wallet_creat_time")]
                    // 钱包名字
                    let walletName = wallet[Expression<String>("wallet_name")]
                    // 当前WalletConnect订阅钱包
                    let walletSubscription = wallet[Expression<Bool>("wallet_subscription")]
                    // 账户是否开启生物锁定
                    let walletBiometricLock = wallet[Expression<Bool>("wallet_biometric_lock")]
                    // 钱包创建类型(0导入、1创建)
                    let walletCreateType = wallet[Expression<Int>("wallet_create_type")]
                    // 钱包类型(0=Libra、1=Violas、2=BTC)
                    let walletType = wallet[Expression<Int>("wallet_type")]
                    // 钱包当前使用层数
                    let walletIndex = wallet[Expression<Int>("wallet_index")]
                    // 授权Key
                    let authenticationKey = wallet[Expression<String>("wallet_authentication_key")]
                    // 钱包激活状态
                    let walletActiveState = wallet[Expression<Bool>("wallet_active_state")]

                    let type: WalletType
                    if walletType == 0 {
                        type = .Libra
                    } else if walletType == 1 {
                        type = .Violas
                    } else {
                        type = .BTC
                    }
                    // 钱包是否已备份
                    let walletBackupState = wallet[Expression<Bool>("wallet_backup_state")]
                    // 钱包标志
                    let walletIcon = wallet[Expression<String>("wallet_icon")]
                    // 钱包合约地址
                    let walletContract = wallet[Expression<String>("wallet_contract")]
                    // 钱包合约名称
                    let walletModule = wallet[Expression<String>("wallet_module")]
                    // 钱包合约名称
                    let walletModuleName = wallet[Expression<String>("wallet_module_name")]

                    let wallet = LibraWalletManager.init(walletID: walletID,
                                                         walletBalance: walletBalance,
                                                         walletAddress: walletAddress,
                                                         walletCreateTime: walletCreateTime,
                                                         walletName: walletName,
                                                         walletSubscription: walletSubscription,
                                                         walletBiometricLock: walletBiometricLock,
                                                         walletCreateType: walletCreateType,
                                                         walletType: type,
                                                         walletIndex: walletIndex,
                                                         walletBackupState: walletBackupState,
                                                         walletAuthenticationKey: authenticationKey,
                                                         walletActiveState: walletActiveState,
                                                         walletIcon: walletIcon,
                                                         walletContract: walletContract,
                                                         walletModule: walletModule,
                                                         walletModuleName: walletModuleName)
                    allWallets.append(wallet)
                }
                return allWallets
            } else {
                return allWallets
            }
        } catch {
            print(error.localizedDescription)
            return [LibraWalletManager]()
        }
    }
    func getWalletWithType(walletType: WalletType) -> [LibraWalletManager] {
        let walletTable = Table("Wallet").filter(Expression<Int>("wallet_type") == walletType.value)
        do {
            // 身份钱包
            var allWallets = [LibraWalletManager]()
            if let tempDB = self.db {
                for wallet in try tempDB.prepare(walletTable) {
                    // 钱包ID
                    let walletID = wallet[Expression<Int64>("wallet_id")]
                    // 钱包金额
                    let walletBalance = wallet[Expression<Int64>("wallet_balance")]
                    // 钱包地址
                    let walletAddress = wallet[Expression<String>("wallet_address")]
                    // 钱包创建时间
                    let walletCreateTime = wallet[Expression<Double>("wallet_creat_time")]
                    // 钱包名字
                    let walletName = wallet[Expression<String>("wallet_name")]
                    // 当前WalletConnect订阅钱包
                    let walletSubscription = wallet[Expression<Bool>("wallet_subscription")]
                    // 账户是否开启生物锁定
                    let walletBiometricLock = wallet[Expression<Bool>("wallet_biometric_lock")]
                    // 钱包创建类型(0导入、1创建)
                    let walletCreateType = wallet[Expression<Int>("wallet_create_type")]
                    // 钱包类型(0=Libra、1=Violas、2=BTC)
                    let walletType = wallet[Expression<Int>("wallet_type")]
                    // 钱包当前使用层数
                    let walletIndex = wallet[Expression<Int>("wallet_index")]
                    // 授权Key
                    let authenticationKey = wallet[Expression<String>("wallet_authentication_key")]
                    // 钱包激活状态
                    let walletActiveState = wallet[Expression<Bool>("wallet_active_state")]
                    
                    let type: WalletType
                    if walletType == 0 {
                        type = .Libra
                    } else if walletType == 1 {
                        type = .Violas
                    } else {
                        type = .BTC
                    }
                    // 钱包是否已备份
                    let walletBackupState = wallet[Expression<Bool>("wallet_backup_state")]
                    // 钱包标志
                    let walletIcon = wallet[Expression<String>("wallet_icon")]
                    
                    // 钱包合约地址
                    let walletContract = wallet[Expression<String>("wallet_contract")]
                    // 钱包合约名称
                    let walletModule = wallet[Expression<String>("wallet_module")]
                    // 钱包合约名称
                    let walletModuleName = wallet[Expression<String>("wallet_module_name")]

                    let wallet = LibraWalletManager.init(walletID: walletID,
                                                         walletBalance: walletBalance,
                                                         walletAddress: walletAddress,
                                                         walletCreateTime: walletCreateTime,
                                                         walletName: walletName,
                                                         walletSubscription: walletSubscription,
                                                         walletBiometricLock: walletBiometricLock,
                                                         walletCreateType: walletCreateType,
                                                         walletType: type,
                                                         walletIndex: walletIndex,
                                                         walletBackupState: walletBackupState,
                                                         walletAuthenticationKey: authenticationKey,
                                                         walletActiveState: walletActiveState,
                                                         walletIcon: walletIcon,
                                                         walletContract: walletContract,
                                                         walletModule: walletModule,
                                                         walletModuleName: walletModuleName)
                    allWallets.append(wallet)
                }
                return allWallets
            } else {
                return allWallets
            }
        } catch {
            print(error.localizedDescription)
            return [LibraWalletManager]()
        }
    }
    func updateDefaultViolasWallet() -> Bool {
        let walletTable = Table("Wallet").filter(Expression<Int>("wallet_identity") == 0 && Expression<Int>("wallet_type") == 1)
        do {
            if let tempDB = self.db {
                try tempDB.run(walletTable.update(Expression<Bool>("wallet_current_use") <- true))
                return true
            } else {
                return false
            }
        } catch {
            print(error.localizedDescription)
            return false
        }
    }
    func deleteWalletFromTable(model: LibraWalletManager) -> Bool {
        let transectionAddressHistoryTable = Table("Wallet")
        do {
            if let tempDB = self.db {
                let contract = transectionAddressHistoryTable.filter(Expression<Int64>("wallet_id") == model.walletID)
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
    func updateWalletBackupState(walletID: Int64, state: Bool) -> Bool {
        let walletTable = Table("Wallet")
        do {
            if let tempDB = self.db {
                let contract = walletTable.filter(Expression<Int64>("wallet_id") == walletID)
                try tempDB.run(contract.update(Expression<Bool>("wallet_backup_state") <- state))
                return true
            } else {
                return false
            }
        } catch {
            print(error.localizedDescription)
            return false
        }
    }
    func updateWalletBackupState(wallet: LibraWalletManager) -> Bool {
        let walletTable = Table("Wallet").filter(Expression<Int64>("wallet_id") == wallet.walletID)
        do {
            if let tempDB = self.db {
                try tempDB.run(walletTable.update(Expression<Bool>("wallet_backup_state") <- true))
                return true
            } else {
                return false
            }
        } catch {
            print(error.localizedDescription)
            return false
        }
    }
    func updateWalletActiveState(walletID: Int64, state: Bool) -> Bool {
        let walletTable = Table("Wallet")
        do {
            if let tempDB = self.db {
                let contract = walletTable.filter(Expression<Int64>("wallet_id") == walletID)
                try tempDB.run(contract.update(Expression<Bool>("wallet_active_state") <- state))
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
    func deleteHDWallet() {
        let walletTable = Table("Wallet")
        do {
            if let tempDB = self.db {
                let rowid = try tempDB.run(walletTable.delete())
                print(rowid)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
}
extension DataBaseManager {
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
        let transectionAddressHistoryTable = Table("TransferAddress")
        do {
            if let tempDB = self.db {
                let contract = transectionAddressHistoryTable.filter(Expression<String>("address") == "\(model.addressType!)_" + model.address!)
                let rowid = try tempDB.run(contract.delete())
                print(rowid)
                if rowid == 0 {
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
}
// MARK: 创建ViolasToken表
extension DataBaseManager {
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
            // 代币启用状态
            let tokenEnable = Expression<Bool>("token_enable")
            // 代币编号
            let tokenNumber = Expression<Int64>("token_number")
            // 建表
            try db!.run(addressTable.create { t in
                t.column(tokenID, primaryKey: true)
                t.column(tokenIcon)
                t.column(tokenName)
                t.column(tokenDescription)
                t.column(tokenAddress)
                t.column(tokenBindingWalletID)
                t.column(tokenAmount)
                t.column(tokenEnable)
                t.column(tokenNumber)
                t.unique([tokenBindingWalletID, tokenAddress, tokenNumber])
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
                    Expression<Int64>("token_amount") <- 0,
                    Expression<Bool>("token_enable") <- model.enable ?? false,
                    Expression<Int64>("token_number") <- model.id ?? 0)
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
    func isExistViolasToken(walletID: Int64, contract: String, tokenNumber: Int64) -> Bool {
        let walletTable = Table("ViolasToken")
        do {
            if let tempDB = self.db {
                let transection = walletTable.filter(Expression<String>("token_address") == contract && Expression<Int64>("token_binding_wallet_id") == walletID && Expression<Int64>("token_number") == tokenNumber)
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
                    // 余额
                    let balance = wallet[Expression<Int64>("token_amount")]
                    // 开启状态
                    let enable = wallet[Expression<Bool>("token_enable")]
                    // 代币编号
                    let tokenNumber = wallet[Expression<Int64>("token_number")]
                    
                    let wallet = ViolasTokenModel.init(name: tokenName,
                                                       description: tokenDescription,
                                                       address: tokenAddress,
                                                       icon: tokenIcon,
                                                       enable: enable,
                                                       balance: balance,
                                                       registerState: true,
                                                       id: tokenNumber)
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
    func deleteViolasToken(walletID: Int64, address: String, tokenNumber: Int64) -> Bool {
        let violasTokenTable = Table("ViolasToken")
        do {
            if let tempDB = self.db {
                let contract = violasTokenTable.filter(Expression<String>("token_address") == address && Expression<Int64>("token_binding_wallet_id") == walletID && Expression<Int64>("token_number") == tokenNumber)
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
    func updateViolasTokenState(walletID: Int64, tokenAddress: String, tokenNumber: Int64, state: Bool) -> Bool {
        let violasTokenTable = Table("ViolasToken")
        do {
            if let tempDB = self.db {
                let item = violasTokenTable.filter(Expression<Int64>("token_binding_wallet_id") == walletID && Expression<String>("token_address") == tokenAddress && Expression<Int64>("token_number") == tokenNumber)
                try tempDB.run(item.update(Expression<Bool>("token_enable") <- state))
                return true
            } else {
                return false
            }
        } catch {
            print(error.localizedDescription)
            return false
        }
    }
    func updateViolasTokenBalance(walletID: Int64, model: BalanceViolasModulesModel) -> Bool {
        let violasTokenTable = Table("ViolasToken")
        do {
            if let tempDB = self.db {
                let item = violasTokenTable.filter(Expression<Int64>("token_binding_wallet_id") == walletID && Expression<String>("token_address") == model.address ?? "" && Expression<Int64>("token_number") == model.id ?? 0)
                try tempDB.run(item.update(Expression<Int64>("token_amount") <- model.balance ?? 0))
                return true
            } else {
                return false
            }
        } catch {
            print(error.localizedDescription)
            return false
        }
    }
}
