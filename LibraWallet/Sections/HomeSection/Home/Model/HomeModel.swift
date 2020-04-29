//
//  HomeModel.swift
//  LibraWallet
//
//  Created by palliums on 2019/9/11.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit
import Moya
struct ScanLoginDataModel: Codable {
    var type: Int?
    var session_id: String?
}
struct BalanceViolasModulesModel: Codable {
    /// 代币余额
    var balance: Int64?
    /// 代币地址
    var address: String?
    /// 代币ID
    var id: Int64?
}
struct BalanceLibraBalanceModel: Codable {
    var amount: Int64?
    var currency: String?
}
struct BalanceLibraModel: Codable {
    /// 余额
    var balance: BalanceLibraBalanceModel?
    /// 验证密钥
    var authentication_key: String?
    ///
    var delegated_key_rotation_capability: Bool?
    ///
    var delegated_withdrawal_capability: Bool?
    ///
    var received_events_key: String?
    ///
    var sent_events_key: String?
    ///
    var sequence_number: Int64?
}
struct BalanceLibraMainModel: Codable {
    /// 请求ID
    var id: String?
    /// JSON RPC版本
    var jsonrpc: String?
    /// 数据体
    var result: BalanceLibraModel?
}
struct BalanceViolasModel: Codable {
    /// 余额
    var balance: Int64?
    /// 地址
    var address: String?
    /// 代币
    var modules: [BalanceViolasModulesModel]?
}
struct BalanceViolasMainModel: Codable {
    /// 错误代码
    var code: Int?
    /// 错误信息
    var message: String?
    /// 数据体
    var data: BalanceViolasModel?
}
struct BalanceBTCModel: Codable {
    /// 地址
    var address: String?
    /// 总接收
    var received: Int?
    /// 总支出
    var sent: Int?
    /// 当前余额
    var balance: Int64?
    /// 交易数量
    var tx_count: Int?
    /// 未确认交易数量
    var unconfirmed_tx_count: Int?
    /// 未确认总接收
    var unconfirmed_received: Int?
    /// 未确认总支出
    var unconfirmed_sent: Int?
    /// 未花费交易数量D
    var unspent_tx_count: Int?
    /// 第一笔交易
    var first_tx: String?
    /// 最后一笔交易
    var last_tx: String?
}
struct BalanceBTCMainModel: Codable {
    var err_no: Int?
    var data: BalanceBTCModel?
}
struct BlockCypherBTCBalanceMainModel: Codable {
    /// 地址
    var address: String?
    /// 总接收
    var total_received: Int?
    /// 总支出
    var total_sent: Int?
    /// 当前余额
    var balance: Int64?
    /// 未确认余额
    var unconfirmed_balance: Int64?
    /// 总余额
    var final_balance: Int64?
    ///
    var n_tx: Int64?
    ///
    var unconfirmed_n_tx: Int64?
    ///
    var final_n_tx: Int64?
}
class HomeModel: NSObject {
    private var requests: [Cancellable] = []
    @objc dynamic var dataDic: NSMutableDictionary = [:]
    func getLocalUserInfo() {
        do {
            let wallet = try DataBaseManager.DBManager.getCurrentUseWallet()
            let data = setKVOData(type: "LoadCurrentUseWallet", data: wallet)
            self.setValue(data, forKey: "dataDic")
            guard let address = wallet.walletAddress else {
                return
            }
            guard let walletID = wallet.walletID else {
                return
            }
            // 更新本地数据
            switch wallet.walletType {
            case .Libra:
//                tempGetLibraBalance(walletID: walletID, address: address)
                getLibraBalance(walletID: walletID, address: address)
                break
            case .Violas:
                getEnableViolasToken(walletID: walletID, address: address)
                break
            case .BTC:
                getBTCBalance(walletID: walletID, address: address)
                break
            default:
                break
            }
        } catch {
            
        }
    }
    
//    func getBTCBalance(walletID: Int64, address: String) {
//        let request = mainProvide.request(.BlockCypherBTCBalance(address)) {[weak self](result) in
//            switch  result {
//            case let .success(response):
//                do {
//                    let json = try response.map(BalanceBTCMainModel.self)
//                    guard json.err_no == 0 else {
//                        let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.dataCodeInvalid), type: "UpdateBTCBalance")
//                        self?.setValue(data, forKey: "dataDic")
//                        return
//                    }
//                    let data = setKVOData(type: "UpdateBTCBalance", data: json.data)
//                    self?.setValue(data, forKey: "dataDic")
//                    // 刷新本地数据
//                    self?.updateLocalWalletData(walletID: walletID, balance: json.data?.balance ?? 0)
//                } catch {
//                    print("UpdateBTCBalance_解析异常\(error.localizedDescription)")
//                    let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.parseJsonError), type: "UpdateBTCBalance")
//                    self?.setValue(data, forKey: "dataDic")
//                }
//            case let .failure(error):
//                guard error.errorCode != -999 else {
//                    print("UpdateBTCBalance_网络请求已取消")
//                    return
//                }
//                let data = setKVOData(error: LibraWalletError.WalletRequest(reason: .networkInvalid), type: "UpdateBTCBalance")
//                self?.setValue(data, forKey: "dataDic")
//            }
//        }
//        self.requests.append(request)
//    }
    func getBTCBalance(walletID: Int64, address: String) {
        let request = mainProvide.request(.BlockCypherBTCBalance(address)) {[weak self](result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(BlockCypherBTCBalanceMainModel.self)
                    let data = setKVOData(type: "UpdateBTCBalance", data: json)
                    self?.setValue(data, forKey: "dataDic")
                    // 刷新本地数据
                    self?.updateLocalWalletData(walletID: walletID, balance: json.balance ?? 0)
                } catch {
                    print("UpdateBTCBalance_解析异常\(error.localizedDescription)")
                    let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.parseJsonError), type: "UpdateBTCBalance")
                    self?.setValue(data, forKey: "dataDic")
                }
            case let .failure(error):
                guard error.errorCode != -999 else {
                    print("UpdateBTCBalance_网络请求已取消")
                    return
                }
                let data = setKVOData(error: LibraWalletError.WalletRequest(reason: .networkInvalid), type: "UpdateBTCBalance")
                self?.setValue(data, forKey: "dataDic")
            }
        }
        self.requests.append(request)
    }

    func getLibraBalance(walletID: Int64, address: String) {
        let request = mainProvide.request(.GetLibraAccountBalance(address)) {[weak self](result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(BalanceLibraMainModel.self)
                    guard json.result != nil else {
                        let data = setKVOData(type: "UpdateLibraBalance", data: BalanceLibraModel.init(balance: BalanceLibraBalanceModel.init(amount: 0, currency: "LBR")))
                        self?.setValue(data, forKey: "dataDic")
                        return
                    }
                    let data = setKVOData(type: "UpdateLibraBalance", data: json.result)
                    self?.setValue(data, forKey: "dataDic")
                    // 刷新本地数据
                    self?.updateLocalWalletData(walletID: walletID, balance: json.result?.balance?.amount ?? 0)
                } catch {
                    print("解析异常\(error.localizedDescription)")
                    let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.parseJsonError), type: "UpdateLibraBalance")
                    self?.setValue(data, forKey: "dataDic")
                }
            case let .failure(error):
                guard error.errorCode != -999 else {
                    print("网络请求已取消")
                    return
                }
                let data = setKVOData(error: LibraWalletError.WalletRequest(reason: .networkInvalid), type: "UpdateLibraBalance")
                self?.setValue(data, forKey: "dataDic")
            }
        }
        self.requests.append(request)
    }
    func getEnableViolasToken(walletID: Int64,  address: String) {
        do {
            let vtokens = try DataBaseManager.DBManager.getViolasTokens(walletID: walletID).filter({ item in
                item.enable == true
            })
            let data = setKVOData(type: "LoadEnableViolasTokenList", data: vtokens)
            self.setValue(data, forKey: "dataDic")
            
            getViolasBalance(walletID: walletID, address: address, vtokens: vtokens)
        } catch {
            print(error.localizedDescription)
        }
    }
    func getViolasBalance(walletID: Int64, address: String, vtokens: [ViolasTokenModel]) {
        let modules = vtokens.map { item in
            "\(item.id ?? 9999)"
        }.joined(separator: ",")
        let request = mainProvide.request(.GetViolasAccountBalance(address, modules)) {[weak self](result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(BalanceViolasMainModel.self)
                    if json.code == 2000 {
                        let data = setKVOData(type: "UpdateViolasBalance", data: json.data)
                        self?.setValue(data, forKey: "dataDic")
                        // 刷新本地数据
                        self?.updateLocalWalletData(walletID: walletID, balance: json.data?.balance ?? 0)
                        guard let tokenModel = json.data?.modules else {
                            return
                        }
                        self?.updateLocalWalletTokenData(walletID: walletID, modules: tokenModel)
                     } else {
                         print("UpdateViolasBalance_状态异常")
                         DispatchQueue.main.async(execute: {
                             if let message = json.message, message.isEmpty == false {
                                 let data = setKVOData(error: LibraWalletError.error(message), type: "UpdateViolasBalance")
                                 self?.setValue(data, forKey: "dataDic")
                             } else {
                                 let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.dataCodeInvalid), type: "UpdateViolasBalance")
                                 self?.setValue(data, forKey: "dataDic")
                             }
                         })
                     }
                } catch {
                    print("UpdateViolasBalance_解析异常\(error.localizedDescription)")
                    let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.parseJsonError), type: "UpdateViolasBalance")
                    self?.setValue(data, forKey: "dataDic")
                }
            case let .failure(error):
                guard error.errorCode != -999 else {
                    print("UpdateViolasBalance_网络请求已取消")
                    return
                }
                let data = setKVOData(error: LibraWalletError.WalletRequest(reason: .networkInvalid), type: "UpdateViolasBalance")
                self?.setValue(data, forKey: "dataDic")
            }
        }
        self.requests.append(request)
    }
    func dealBalanceWithContract(modules: [BalanceViolasModulesModel], violasTokens: [ViolasTokenModel]) -> [ViolasTokenModel] {
        var tempArray = [ViolasTokenModel]()
        for var token in violasTokens {
            for module in modules {
                if module.id == token.id {
                    token.balance = module.balance
                    tempArray.append(token)
                }
            }
        }
        return tempArray
    }
    func updateLocalWalletData(walletID: Int64, balance: Int64) {
        // 刷新本地缓存数据
        let result = DataBaseManager.DBManager.updateWalletBalance(walletID: walletID, balance: balance)
        print("刷新本地钱包数据状态: \(result),walletID = \(walletID)")
    }
    func updateLocalWalletTokenData(walletID: Int64, modules: [BalanceViolasModulesModel]) {
        // 刷新本地缓存数据
        for item in modules {
            let result = DataBaseManager.DBManager.updateViolasTokenBalance(walletID: walletID, model: item)
            print("刷新本地钱包Token数据状态: \(result),walletID = \(walletID)")
        }
    }
    func scanResultHandle(content: String, contracts: [ViolasTokenModel]?) throws -> QRCodeHandleResult {
        if content.hasPrefix("bitcoin:") {
            let tempAddress = content.replacingOccurrences(of: "bitcoin:", with: "")
            guard BTCManager.isValidBTCAddress(address: tempAddress) else {
                throw LibraWalletError.WalletScan(reason: .btcAddressInvalid)
            }
            return QRCodeHandleResult.init(addressType: .BTC,
                                           originContent: content,
                                           address: tempAddress,
                                           contract: nil,
                                           type: .transfer)
        } else if content.hasPrefix("libra:") {
            let tempAddress = content.replacingOccurrences(of: "libra:", with: "")
            guard LibraManager.isValidLibraAddress(address: tempAddress) else {
               throw LibraWalletError.WalletScan(reason: .libraAddressInvalid)
            }
            return QRCodeHandleResult.init(addressType: .Libra,
                                           originContent: content,
                                           address: tempAddress,
                                           contract: nil,
                                           type: .transfer)
        } else if content.hasPrefix("violas:") {
            let tempAddress = content.replacingOccurrences(of: "violas:", with: "")
            guard ViolasManager.isValidViolasAddress(address: tempAddress) else {
                throw LibraWalletError.WalletScan(reason: .violasAddressInvalid)
            }
            return QRCodeHandleResult.init(addressType: .Violas,
                                           originContent: content,
                                           address: tempAddress,
                                           contract: nil,
                                           type: .transfer)
        } else if content.hasPrefix("violas-") {
            let coinAddress = content.split(separator: ":").last?.description
            let addressPrifix = content.split(separator: ":").first?.description
            let coinNames = addressPrifix?.split(separator: "-")
            guard coinNames?.count == 2 else {
                print("token名称为空")
                throw LibraWalletError.WalletScan(reason: .violasTokenNameEmpty)
            }
            let contract = contracts?.filter({ item in
                item.name?.lowercased() == coinNames?.last?.description.lowercased()
            })
            guard (contract?.count ?? 0) > 0 else {
                // 不支持或未开启
                print("不支持或未开启")
                throw LibraWalletError.WalletScan(reason: .violasTokenContractInvalid)
            }
            guard ViolasManager.isValidViolasAddress(address: coinAddress ?? "") else {
                throw LibraWalletError.WalletScan(reason: .violasAddressInvalid)
            }
            return QRCodeHandleResult.init(addressType: .Violas,
                                           originContent: content,
                                           address: coinAddress,
                                           contract: contract?.first,
                                           type: .transfer)
        } else {
            do {
                let model = try JSONDecoder().decode(ScanLoginDataModel.self, from: content.data(using: .utf8)!)
                guard model.type == 2 else {
                    return QRCodeHandleResult.init(addressType: nil,
                                                   originContent: content,
                                                   address: nil,
                                                   contract: nil,
                                                   type: .others)
                }
                return QRCodeHandleResult.init(addressType: nil,
                                               originContent: content,
                                               address: model.session_id,
                                               contract: nil,
                                               type: .login)
            } catch {
                return QRCodeHandleResult.init(addressType: nil,
                                               originContent: content,
                                               address: nil,
                                               contract: nil,
                                               type: .others)
            }
        }
    }
    struct QRCodeHandleResult {
        var addressType: WalletType?
        var originContent: String
        var address: String?
        var contract: ViolasTokenModel?
        var type: QRCodeType
    }
    enum QRCodeType {
        case transfer
        case login
        case others
    }
    deinit {
        requests.forEach { cancellable in
            cancellable.cancel()
        }
        requests.removeAll()
        print("HomeModel销毁了")
    }
}
