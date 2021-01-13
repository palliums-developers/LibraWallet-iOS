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
    mutating func initDataBase() {
        do {
            try connectDataBase()
            if isExistTable(name: "Wallet") == false {
                print("首次进入创建Wallet表")
                try createWalletTable()
            }
            if isExistTable(name: "TransferAddress") == false {
                print("首次进入创建TransferAddress表")
                try createTransferAddressListTable()
            }
            if isExistTable(name: "Tokens") == false {
                print("首次进入创建Tokens表")
                try createViolasTokenTable()
            }
            try getDefaultWallet()
        } catch {
            print(error.localizedDescription)
        }
    }
    private mutating func connectDataBase() throws {
        /// 获取沙盒地址
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        /// 拼接路径
        let filePath = "\(path[0])" + "/" + "PalliumsWallet.sqlite3"
        print(filePath)
        do {
            self.db = try Connection(filePath)
        } catch {
            print("ConnectDataBaseError")
            throw error
        }
    }
    func isExistTable(name: String) -> Bool {
        do {
            let walletTable = Table(name)
            _ = try self.db!.scalar(walletTable.count)
            return true
        } catch {
            print(error.localizedDescription)
            return false
        }
    }
}
// MARK: 创建Wallet表
extension DataBaseManager {
    private func createWalletTable() throws {
        guard let tempDB = self.db else {
            throw LibraWalletError.WalletDataBase(reason: .openDataBaseError)
        }
        do {
            let walletTable = Table("Wallet")
            // 钱包序号
            let walletID = Expression<Int64>("wallet_id")
            // 钱包名字
            let walletName = Expression<String>("wallet_name")
            // 钱包创建时间
            let walletCreateTime = Expression<Double>("wallet_creat_time")
            // 是否使用生物解锁
            let walletBiometricLock = Expression<Bool>("wallet_biometric_lock")
            // 钱包创建类型(0导入、1创建)
            let walletCreateType = Expression<Int>("wallet_create_type")
            // 钱包是否已备份
            let walletBackupState = Expression<Bool>("wallet_backup_state")
            // 当前WalletConnect订阅钱包
            let walletSubscription = Expression<Bool>("wallet_subscription")
            // 助记词哈希
            let walletMnemonicHash = Expression<String>("wallet_mnemonic_hash")
            // 钱包使用状态
            let walletUseState = Expression<Bool>("wallet_use_state")
            // 钱包BTC地址
            let walletBTCAddress = Expression<String>("wallet_btc_address")
            // 钱包Violas地址
            let walletViolasAddress = Expression<String>("wallet_violas_address")
            // 钱包Libra地址
            let walletLibraAddress = Expression<String>("wallet_libra_address")
            // 是否是新钱包
            let isNewWallet = Expression<Bool>("wallet_new_state")
            // 建表
            try tempDB.run(walletTable.create { t in
                t.column(walletID, primaryKey: true)
                t.column(walletCreateTime)
                t.column(walletName)
                t.column(walletSubscription)
                t.column(walletBiometricLock)
                t.column(walletCreateType)
                t.column(walletBackupState)
                t.column(walletMnemonicHash, unique: true)
                t.column(walletUseState)
                t.column(walletBTCAddress)
                t.column(walletViolasAddress)
                t.column(walletLibraAddress)
                t.column(isNewWallet)
            })
        } catch {
            let errorString = error.localizedDescription
            if errorString.hasSuffix("already exists") == true {
                return
            } else {
                throw error
            }
        }
    }
    func insertWallet(model: WalletManager) throws {
        guard let tempDB = self.db else {
            throw LibraWalletError.WalletDataBase(reason: .openDataBaseError)
        }
        let walletTable = Table("Wallet")
        do {
            let insert = walletTable.insert(
                Expression<String>("wallet_name") <- model.walletName ?? "",
                Expression<Double>("wallet_creat_time") <- model.walletCreateTime ?? 0,
                Expression<Bool>("wallet_biometric_lock") <- model.walletBiometricLock ?? false,
                Expression<Int>("wallet_create_type") <- model.walletCreateType ?? 999,
                Expression<Bool>("wallet_backup_state") <- model.walletBackupState ?? false,
                Expression<Bool>("wallet_subscription") <- model.walletSubscription ?? false,
                Expression<String>("wallet_mnemonic_hash") <- model.walletMnemonicHash ?? "",
                Expression<Bool>("wallet_use_state") <- model.walletUseState ?? false,
                Expression<String>("wallet_btc_address") <- model.btcAddress ?? "",
                Expression<String>("wallet_violas_address") <- model.violasAddress ?? "",
                Expression<String>("wallet_libra_address") <- model.libraAddress ?? "",
                Expression<Bool>("wallet_new_state") <- model.isNewWallet ?? true)
            let rowid = try tempDB.run(insert)
            print(rowid)
        } catch {
            print(error.localizedDescription)
            throw error
        }
    }
    func isExistWalletInTable(wallet: WalletManager) throws -> Bool {
        guard let tempDB = self.db else {
            throw LibraWalletError.WalletDataBase(reason: .openDataBaseError)
        }
        let walletTable = Table("Wallet").filter(Expression<String>("wallet_mnemonic_hash") == wallet.walletMnemonicHash ?? "")
        do {
            let count = try tempDB.scalar(walletTable.count)
            guard count != 0 else {
                return false
            }
            return true
        } catch {
            print(error.localizedDescription)
            throw error
        }
    }
    func getDefaultWallet() throws {
        guard let tempDB = self.db else {
            throw LibraWalletError.WalletDataBase(reason: .openDataBaseError)
        }
        let walletTable = Table("Wallet").filter(Expression<Bool>("wallet_use_state") == true)
        do {
            for wallet in try tempDB.prepare(walletTable) {
                // 钱包序号
                let walletID = wallet[Expression<Int64>("wallet_id")]
                // 钱包名字
                let walletName = wallet[Expression<String>("wallet_name")]
                // 钱包创建时间
                let walletCreateTime = wallet[Expression<Double>("wallet_creat_time")]
                // 是否使用生物解锁
                let walletBiometricLock = wallet[Expression<Bool>("wallet_biometric_lock")]
                // 钱包创建类型(0导入、1创建)
                let walletCreateType = wallet[Expression<Int>("wallet_create_type")]
                // 钱包是否已备份
                let walletBackupState = wallet[Expression<Bool>("wallet_backup_state")]
                // 当前WalletConnect订阅钱包
                let walletSubscription = wallet[Expression<Bool>("wallet_subscription")]
                // 助记词哈希
                let walletMnemonicHash = wallet[Expression<String>("wallet_mnemonic_hash")]
                // 钱包使用状态
                let walletUseState = wallet[Expression<Bool>("wallet_use_state")]
                // 钱包BTC地址
                let walletBTCAddress = wallet[Expression<String>("wallet_btc_address")]
                // 钱包Violas地址
                let walletViolasAddress = wallet[Expression<String>("wallet_violas_address")]
                // 钱包Libra地址
                let walletLibraAddress = wallet[Expression<String>("wallet_libra_address")]
                // 是否是新钱包
                let isNewWallet = wallet[Expression<Bool>("wallet_new_state")]
                
                WalletManager.shared.initWallet(walletID: walletID,
                                                walletName: walletName,
                                                walletCreateTime: walletCreateTime,
                                                walletBiometricLock: walletBiometricLock,
                                                walletCreateType: walletCreateType,
                                                walletBackupState: walletBackupState,
                                                walletSubscription: walletSubscription,
                                                walletMnemonicHash: walletMnemonicHash,
                                                walletUseState: walletUseState,
                                                btcAddress: walletBTCAddress,
                                                violasAddress: walletViolasAddress,
                                                libraAddress: walletLibraAddress,
                                                isNewWallet: isNewWallet)
                return
            }
            // 未获取到默认钱包
            setIdentityWalletState(show: false)
            throw LibraWalletError.WalletDataBase(reason: .defaultWalletNotExist)
        } catch {
            throw error
        }
    }
    func deleteWalletFromTable(model: WalletManager) throws {
        guard let tempDB = self.db else {
            throw LibraWalletError.WalletDataBase(reason: .openDataBaseError)
        }
        let walletTable = Table("Wallet").filter(Expression<Int64>("wallet_id") == model.walletID ?? 9999)
        do {
            try tempDB.run(walletTable.delete())
        } catch {
            print(error.localizedDescription)
            throw error
        }
    }
    func updateWalletBiometricLockState(walletID: Int64, state: Bool) throws {
        guard let tempDB = self.db else {
            throw LibraWalletError.WalletDataBase(reason: .openDataBaseError)
        }
        let walletTable = Table("Wallet").filter(Expression<Int64>("wallet_id") == walletID)
        do {
            try tempDB.run(walletTable.update(Expression<Bool>("wallet_biometric_lock") <- state))
        } catch {
            print(error.localizedDescription)
            throw error
        }
    }
    func updateWalletCurrentUseState(walletID: Int64, state: Bool) throws {
        guard let tempDB = self.db else {
            throw LibraWalletError.WalletDataBase(reason: .openDataBaseError)
        }
        let walletTable = Table("Wallet").filter(Expression<Int64>("wallet_id") == walletID)
        do {
            try tempDB.run(walletTable.update(Expression<Bool>("wallet_use_state") <- state))
        } catch {
            print(error.localizedDescription)
            throw error
        }
    }
    func updateWalletBackupState(wallet: WalletManager) throws {
        guard let tempDB = self.db else {
            throw LibraWalletError.WalletDataBase(reason: .openDataBaseError)
        }
        let walletTable = Table("Wallet").filter(Expression<Int64>("wallet_id") == wallet.walletID ?? 9999)
        do {
            try tempDB.run(walletTable.update(Expression<Bool>("wallet_backup_state") <- true))
        } catch {
            print(error.localizedDescription)
            throw error
        }
    }
    func deleteHDWallet() throws {
        guard let tempDB = self.db else {
            throw LibraWalletError.WalletDataBase(reason: .openDataBaseError)
        }
        let walletTable = Table("Wallet")
        do {
            try tempDB.run(walletTable.delete())
        } catch {
            print(error.localizedDescription)
            throw error
        }
    }
    func updateIsNewWalletState(wallet: WalletManager) throws {
        guard let tempDB = self.db else {
            throw LibraWalletError.WalletDataBase(reason: .openDataBaseError)
        }
        let walletTable = Table("Wallet").filter(Expression<Int64>("wallet_id") == wallet.walletID ?? 9999)
        do {
            try tempDB.run(walletTable.update(Expression<Bool>("wallet_backup_state") <- wallet.isNewWallet ?? true))
        } catch {
            print(error.localizedDescription)
            throw error
        }
    }
}
// MARK: 创建Address表
extension DataBaseManager {
    func createTransferAddressListTable() throws {
        guard let tempDB = self.db else {
            throw LibraWalletError.WalletDataBase(reason: .openDataBaseError)
        }
        do {
            let addressTable = Table("TransferAddress")
            // 设置字段
            let addressID = Expression<Int64>("address_id")
            // 地址名字
            let addressName = Expression<String>("address_name")
            // 地址
            let address = Expression<String>("address")
            // 地址类型（0=Libra、1=Violas、2=BTC）
            let addressType = Expression<String>("address_type")
            // 建表
            try tempDB.run(addressTable.create { t in
                t.column(addressID, primaryKey: true)
                t.column(addressName)
                t.column(address)
                t.column(addressType)
                t.unique([address, addressType])
            })
        } catch {
            let errorString = error.localizedDescription
            if errorString.hasSuffix("already exists") == true {
                return
            } else {
                throw error
            }
        }
    }
    func insertTransferAddress(model: AddressModel) throws {
        guard let tempDB = self.db else {
            throw LibraWalletError.WalletDataBase(reason: .openDataBaseError)
        }
        let addressTable = Table("TransferAddress")
        do {
            let insert = addressTable.insert(
                Expression<String>("address_name") <- model.addressName,
                Expression<String>("address") <- (model.address),
                Expression<String>("address_type") <- model.addressType)
            try tempDB.run(insert)
        } catch {
            print(error.localizedDescription)
            throw error
        }
    }
    func getTransferAddress(type: String) throws -> [AddressModel] {
        guard let tempDB = self.db else {
            throw LibraWalletError.WalletDataBase(reason: .openDataBaseError)
        }
        let addressTable = type.isEmpty == true ? Table("TransferAddress") : Table("TransferAddress").filter(Expression<String>("address_type") == type)
        do {
            var addressArray = [AddressModel]()
            for wallet in try tempDB.prepare(addressTable) {
                // 地址ID
                let addressID = wallet[Expression<Int64>("address_id")]
                // 地址名字
                let addressName = wallet[Expression<String>("address_name")]
                // 地址
                let address = wallet[Expression<String>("address")]
                // 地址类型（0=Libra、1=Violas、2=BTC）
                let addressType = wallet[Expression<String>("address_type")]

                let model = AddressModel.init(addressID: addressID,
                                              address: address,
                                              addressName: addressName,
                                              addressType: addressType)
                
                addressArray.append(model)
            }
            return addressArray
        } catch {
            print(error.localizedDescription)
            return [AddressModel]()
        }
    }
    func updateTransferAddressName(model: AddressModel, name: String) throws {
        guard let tempDB = self.db else {
            throw LibraWalletError.WalletDataBase(reason: .openDataBaseError)
        }
        let addressTable = Table("TransferAddress").filter(Expression<String>("address") == model.address)
        do {
            try tempDB.run(addressTable.update(Expression<String>("address_name") <- name))
        } catch {
            print(error.localizedDescription)
            throw error
        }
    }
    func deleteTransferAddressFromTable(model: AddressModel) throws {
        guard let tempDB = self.db else {
            throw LibraWalletError.WalletDataBase(reason: .openDataBaseError)
        }
        let addressTable = Table("TransferAddress").filter(Expression<String>("address") == model.address && Expression<String>("address_type") == model.addressType)
        do {
            try tempDB.run(addressTable.delete())
        } catch {
            print(error.localizedDescription)
            throw error
        }
    }
    func isExistAddress(model: AddressModel) throws -> Bool {
        guard let tempDB = self.db else {
            throw LibraWalletError.WalletDataBase(reason: .openDataBaseError)
        }
        let tokenTable = Table("TransferAddress").filter(Expression<String>("address") == model.address && Expression<String>("address_type") == model.addressType)
        do {
            let count = try tempDB.scalar(tokenTable.count)
            guard count != 0 else {
                return false
            }
            return true
        } catch {
            print(error.localizedDescription)
            throw error
        }
    }
}
// MARK: 创建Token表
extension DataBaseManager {
    func createViolasTokenTable() throws {
        guard let tempDB = self.db else {
            throw LibraWalletError.WalletDataBase(reason: .openDataBaseError)
        }
        do {
            let tokenTable = Table("Tokens")
            // 币ID
            let tokenID = Expression<Int64>("token_id")
            // 币名字
            let tokenName = Expression<String>("token_name")
            // 币地址
            let tokenAddress = Expression<String>("token_address")
            // 币金额
            let tokenBalance = Expression<Int64>("token_balance")
            // 币授权Key
            let tokenAuthenticationKey = Expression<String>("token_authentication_key")
            // 币激活状态
            let walletActiveState = Expression<Bool>("token_active_state")
            // 币类型(0=Libra、1=Violas、2=BTC)
            let tokenType = Expression<Int64>("token_type")
            // 币当前使用层数
            let tokenIndex = Expression<Int64>("token_index")
            // 币合约地址
            let tokenContract = Expression<String>("token_contract")
            // 币合约名称
            let tokenModule = Expression<String>("token_module")
            // 币合约名称
            let tokenModuleName = Expression<String>("token_module_name")
            // 币启用状态
            let tokenEnable = Expression<Bool>("token_enable")
            // 币图片
            let tokenIcon = Expression<String>("token_icon")
            // 币价
            let tokenPrice = Expression<String>("token_price")
            // 建表
            try tempDB.run(tokenTable.create { t in
                t.column(tokenID, primaryKey: true)
                t.column(tokenName)
                t.column(tokenAddress)
                t.column(tokenBalance)
                t.column(tokenAuthenticationKey)
                t.column(walletActiveState)
                t.column(tokenType)
                t.column(tokenIndex)
                t.column(tokenContract)
                t.column(tokenModule)
                t.column(tokenModuleName)
                t.column(tokenEnable)
                t.column(tokenIcon)
                t.column(tokenPrice)
                t.unique([tokenAddress, tokenModule, tokenType])
            })
        } catch {
            let errorString = error.localizedDescription
            if errorString.hasSuffix("already exists") == true {
                return
            } else {
                throw error
            }
        }
    }
    func insertToken(token: Token) throws {
        guard let tempDB = self.db else {
            throw LibraWalletError.WalletDataBase(reason: .openDataBaseError)
        }
        let tokenTable = Table("Tokens")
        do {
            let insert = tokenTable.insert(
                // 币名字
                Expression<String>("token_name") <- token.tokenName,
                // 币地址
                Expression<String>("token_address") <- token.tokenAddress,
                // 币金额
                Expression<Int64>("token_balance") <- token.tokenBalance,
                // 币授权Key
                Expression<String>("token_authentication_key") <- token.tokenAuthenticationKey,
                // 币激活状态
                Expression<Bool>("token_active_state") <- token.tokenActiveState,
                // 币类型(0=Libra、1=Violas、2=BTC)
                Expression<Int64>("token_type") <- token.tokenType.value,
                // 币当前使用层数
                Expression<Int64>("token_index") <- token.tokenIndex,
                // 币合约地址
                Expression<String>("token_contract") <- token.tokenContract,
                // 币合约名称
                Expression<String>("token_module") <- token.tokenModule,
                // 币合约名称
                Expression<String>("token_module_name") <- token.tokenModuleName,
                // 币启用状态
                Expression<Bool>("token_enable") <- token.tokenEnable,
                // 币图片
                Expression<String>("token_icon") <- token.tokenIcon,
                // 币价
                Expression<String>("token_price") <- token.tokenPrice)
            try tempDB.run(insert)
        } catch {
            print(error.localizedDescription)
            throw error
        }
    }
    func isExistViolasToken(tokenAddress: String, tokenModule: String, tokenType: WalletType) throws -> Bool {
        guard let tempDB = self.db else {
            throw LibraWalletError.WalletDataBase(reason: .openDataBaseError)
        }
        let tokenTable = Table("Tokens").filter(Expression<String>("token_address") == tokenAddress && Expression<String>("token_module") == tokenModule && Expression<Int64>("token_type") == tokenType.value)
        do {
            let count = try tempDB.scalar(tokenTable.count)
            guard count != 0 else {
                return false
            }
            return true
        } catch {
            print(error.localizedDescription)
            throw error
        }
    }
    func getTokens() throws -> [Token] {
        guard let tempDB = self.db else {
            throw LibraWalletError.WalletDataBase(reason: .openDataBaseError)
        }
        let tokenTable = Table("Tokens").filter(Expression<Bool>("token_enable") == true)
        do {
            var models = [Token]()
            for wallet in try tempDB.prepare(tokenTable) {
                // 币ID
                let tokenID = wallet[Expression<Int64>("token_id")]
                // 币名字
                let tokenName = wallet[Expression<String>("token_name")]
                // 币地址
                let tokenAddress = wallet[Expression<String>("token_address")]
                // 币金额
                let tokenBalance = wallet[Expression<Int64>("token_balance")]
                // 币授权Key
                let tokenAuthenticationKey = wallet[Expression<String>("token_authentication_key")]
                // 币激活状态
                let walletActiveState = wallet[Expression<Bool>("token_active_state")]
                // 币类型(0=Libra、1=Violas、2=BTC)
                let tokenType = wallet[Expression<Int64>("token_type")]
                // 币当前使用层数
                let tokenIndex = wallet[Expression<Int64>("token_index")]
                // 币合约地址
                let tokenContract = wallet[Expression<String>("token_contract")]
                // 币合约名称
                let tokenModule = wallet[Expression<String>("token_module")]
                // 币合约名称
                let tokenModuleName = wallet[Expression<String>("token_module_name")]
                // 币启用状态
                let tokenEnable = wallet[Expression<Bool>("token_enable")]
                // 币图片
                let tokenIcon = wallet[Expression<String>("token_icon")]
                // 币价
                let tokenPrice = wallet[Expression<String>("token_price")]
                let type: WalletType
                if tokenType == 0 {
                    type = .Libra
                } else if tokenType == 1 {
                    type = .Violas
                } else {
                    type = .BTC
                }
                let wallet = Token.init(tokenID: tokenID,
                                        tokenName: tokenName,
                                        tokenBalance: tokenBalance,
                                        tokenAddress: tokenAddress,
                                        tokenType: type,
                                        tokenIndex: tokenIndex,
                                        tokenAuthenticationKey: tokenAuthenticationKey,
                                        tokenActiveState: walletActiveState,
                                        tokenIcon: tokenIcon,
                                        tokenContract: tokenContract,
                                        tokenModule: tokenModule,
                                        tokenModuleName: tokenModuleName,
                                        tokenEnable: tokenEnable,
                                        tokenPrice: tokenPrice)
                models.append(wallet)
            }
            return models
        } catch {
            print(error.localizedDescription)
            throw error
        }
    }
    func updateViolasTokenState(tokenAddress: String, tokenModule: String, tokenType: WalletType, state: Bool) throws {
        guard let tempDB = self.db else {
            throw LibraWalletError.WalletDataBase(reason: .openDataBaseError)
        }
        let tokenTable = Table("Tokens").filter(Expression<String>("token_address") == tokenAddress && Expression<String>("token_module") == tokenModule && Expression<Int64>("token_type") == tokenType.value)
        do {
            try tempDB.run(tokenTable.update(Expression<Bool>("token_enable") <- state))
        } catch {
            print(error.localizedDescription)
            throw error
        }
    }
    func updateTokenBalance(tokenID: Int64, balance: Int64) throws {
        guard let tempDB = self.db else {
            throw LibraWalletError.WalletDataBase(reason: .openDataBaseError)
        }
        let tokenTable = Table("Tokens").filter(Expression<Int64>("token_id") == tokenID)
        do {
            try tempDB.run(tokenTable.update(Expression<Int64>("token_balance") <- balance))
        } catch {
            print(error.localizedDescription)
            throw error
        }
    }
    func updateTokenActiveState(tokenID: Int64, state: Bool) throws {
        guard let tempDB = self.db else {
            throw LibraWalletError.WalletDataBase(reason: .openDataBaseError)
        }
        let tokenTable = Table("Tokens").filter(Expression<Int64>("token_id") == tokenID)
        do {
            try tempDB.run(tokenTable.update(Expression<Bool>("token_active_state") <- state))
        } catch {
            print(error.localizedDescription)
            throw error
        }
    }
    func updateTokenPrice(tokenID: Int64, price: String) throws {
        guard let tempDB = self.db else {
            throw LibraWalletError.WalletDataBase(reason: .openDataBaseError)
        }
        let tokenTable = Table("Tokens").filter(Expression<Int64>("token_id") == tokenID)
        do {
            try tempDB.run(tokenTable.update(Expression<String>("token_price") <- price))
        } catch {
            print(error.localizedDescription)
            throw error
        }
    }
    func deleteAllTokens() throws {
        guard let tempDB = self.db else {
            throw LibraWalletError.WalletDataBase(reason: .openDataBaseError)
        }
        let tokensTable = Table("Tokens")
        do {
            try tempDB.run(tokensTable.delete())
        } catch {
            print(error.localizedDescription)
            throw error
        }
    }
}
