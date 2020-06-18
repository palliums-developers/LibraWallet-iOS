//
//  AddAssetModel.swift
//  LibraWallet
//
//  Created by palliums on 2019/11/1.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit
import Moya
struct ViolasTokenModel: Codable {
    /// 名称
    var name: String?
    /// 描述
    var description: String?
    /// 合约地址
    var address: String?
    /// 代币图片
    var icon: String?
    /// 是否已展示
    var enable: Bool?
    /// 数量(自定义)
    var balance: Int64?
    /// 注册状态
    var registerState: Bool?
    /// id
    var id: Int64?
}
struct AssetsModel {
    /// 币图片
    var icon: String?
    /// 名称
    var name: String?
    /// 描述
    var description: String?
    /// 是否已展示
    var enable: Bool?
    /// 注册状态
    var registerState: Bool?
    /// 币类型
    var type: WalletType?
    /// 钱包激活状态
    var walletActiveState: Bool?
}
struct ViolasTokenListDataModel: Codable {
    /// Currency Code
    var code: String?
    /// Max fractional part of single unit of currency allowed in a transaction
    var fractional_part: Int64?
    /// Factor by which the amount is scaled before it is stored in the blockchain
    var scaling_factor: Int64
}
struct ViolasTokenListMainModel: Codable {
    var id: String?
    var jsonrpc: String?
    var result: [ViolasTokenListDataModel]?
    var error: LibraTransferErrorModel?
}
struct LibraTokenListDataModel: Codable {
    /// Currency Code
    var code: String?
    /// Max fractional part of single unit of currency allowed in a transaction
    var fractional_part: Int64?
    /// Factor by which the amount is scaled before it is stored in the blockchain
    var scaling_factor: Int64
}
struct LibraTokenListMainModel: Codable {
    var id: String?
    var jsonrpc: String?
    var result: [LibraTokenListDataModel]?
    var error: LibraTransferErrorModel?
}
class AddAssetModel: NSObject {
    private var requests: [Cancellable] = []
    @objc dynamic var dataDic: NSMutableDictionary = [:]
    private var violasEnableTokens: [ViolasBalanceModel]?
    private var libraEnableTokens: [LibraBalanceModel]?
    private var violasTokens: [ViolasTokenListDataModel]?
    private var libraTokens: [LibraTokenListDataModel]?
    private var resultTokens = [AssetsModel]()
    private var violasWalletActiveState: Bool = false
    private var libraWalletActiveState: Bool = false
    private var contract: String?
    func getSupportToken(walletAddress: String, localTokens: [Token]) {
        let group = DispatchGroup.init()
        let quene = DispatchQueue.init(label: "SupportTokenQuene")
        quene.async(group: group, qos: .default, flags: [], execute: {
            self.getViolasTokens(group: group)
        })
        quene.async(group: group, qos: .default, flags: [], execute: {
            self.getViolasAccountInfo(address: walletAddress, group: group)
        })
        quene.async(group: group, qos: .default, flags: [], execute: {
            self.getLibraTokens(group: group)
        })
        quene.async(group: group, qos: .default, flags: [], execute: {
            self.getLibraAccountInfo(address: walletAddress, group: group)
        })
        group.notify(queue: quene) {
            print("回到该队列中执行")
            DispatchQueue.main.async(execute: {
                self.rebuiltViolasData(enableTokens: self.violasEnableTokens!, allTokens: self.violasTokens!, localTokens: localTokens)
                self.rebuiltLibraData(enableTokens: self.libraEnableTokens!, allTokens: self.libraTokens!, localTokens: localTokens)
//                tempArray.add(tempLibraTokens)
                let data = setKVOData(type: "GetTokenList", data: self.resultTokens)
                self.setValue(data, forKey: "dataDic")
            })
        }
    }
    private func getViolasTokens(group: DispatchGroup) {
        group.enter()
        let request = mainProvide.request(.GetViolasTokenList) {[weak self](result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(ViolasTokenListMainModel.self)
                    guard let models = json.result, models.isEmpty == false else {
                        let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.dataEmpty), type: "GetViolasTokens")
                        self?.setValue(data, forKey: "dataDic")
                        print("GetViolasTokens_状态异常")
                        return
                    }
                    self?.violasTokens = models
                    group.leave()
                } catch {
                    print("GetViolasTokens_解析异常\(error.localizedDescription)")
                    let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.parseJsonError), type: "GetViolasTokens")
                    self?.setValue(data, forKey: "dataDic")
                }
            case let .failure(error):
                guard error.errorCode != -999 else {
                    print("网络请求已取消")
                    return
                }
                let data = setKVOData(error: LibraWalletError.WalletRequest(reason: .networkInvalid), type: "GetViolasTokens")
                self?.setValue(data, forKey: "dataDic")
            }
            
        }
        self.requests.append(request)
    }
    func getViolasAccountInfo(address: String, group: DispatchGroup) {
        group.enter()
        let request = mainProvide.request(.GetViolasAccountInfo(address)) {[weak self](result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(BalanceViolasMainModel.self)
                    if json.result == nil {
//                        let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.dataEmpty), type: "GetViolasAccountInfo")
//                        self?.setValue(data, forKey: "dataDic")
                        print("ViolasWallet尚未激活")
                        self?.violasEnableTokens = [ViolasBalanceModel]()
                    } else {
//                        let data = setKVOData(type: "UpdateViolasBalance", data: json.result?.balances)
//                        self?.setValue(data, forKey: "dataDic")
                        self?.violasWalletActiveState = true
                        self?.violasEnableTokens = json.result?.balances
                    }
                    group.leave()
                } catch {
                    print("GetViolasAccountInfo_解析异常\(error.localizedDescription)")
                    let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.parseJsonError), type: "GetViolasAccountInfo")
                    self?.setValue(data, forKey: "dataDic")
                }
            case let .failure(error):
                guard error.errorCode != -999 else {
                    print("GetViolasAccountInfo_网络请求已取消")
                    return
                }
                let data = setKVOData(error: LibraWalletError.WalletRequest(reason: .networkInvalid), type: "UpdateViolasBalance")
                self?.setValue(data, forKey: "dataDic")
            }
        }
        self.requests.append(request)
    }
    private func getLibraTokens(group: DispatchGroup) {
        group.enter()
        let request = mainProvide.request(.GetLibraTokenList) {[weak self](result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(LibraTokenListMainModel.self)
                    guard let models = json.result, models.isEmpty == false else {
                        let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.dataEmpty), type: "GetViolasTokens")
                        self?.setValue(data, forKey: "dataDic")
                        return
                    }
                    self?.libraTokens = models
                    group.leave()
                } catch {
                    print("GetViolasTokens_解析异常\(error.localizedDescription)")
                    let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.parseJsonError), type: "GetViolasTokens")
                    self?.setValue(data, forKey: "dataDic")
                }
            case let .failure(error):
                guard error.errorCode != -999 else {
                    print("网络请求已取消")
                    return
                }
                let data = setKVOData(error: LibraWalletError.WalletRequest(reason: .networkInvalid), type: "GetViolasTokens")
                self?.setValue(data, forKey: "dataDic")
            }
        }
        self.requests.append(request)
    }
    private func getLibraAccountInfo(address: String, group: DispatchGroup) {
        group.enter()
        let request = mainProvide.request(.GetLibraAccountBalance(address)) {[weak self](result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(BalanceLibraMainModel.self)
                    if json.result == nil {
//                        let data = setKVOData(type: "UpdateLibraBalance", data: [LibraBalanceModel.init(amount: 0, currency: "LBR")])
//                        self?.setValue(data, forKey: "dataDic")
                        print("LibraWallet尚未激活")
                        self?.libraEnableTokens = [LibraBalanceModel]()
                    } else {
//                        let data = setKVOData(type: "UpdateLibraBalance", data: json.result?.balances)
//                        self?.setValue(data, forKey: "dataDic")
                        self?.libraWalletActiveState = true
                        self?.libraEnableTokens = json.result?.balances
                    }
                    group.leave()
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
    private func rebuiltViolasData(enableTokens: [ViolasBalanceModel], allTokens: [ViolasTokenListDataModel], localTokens: [Token]) {
        for item in allTokens {
            var tempModel = AssetsModel.init(icon: "violas_icon", name: item.code, description: "", enable: false, registerState: false, type: .Violas, walletActiveState: false)
            for token in enableTokens {
                if item.code == token.currency {
                    tempModel.registerState = true
                    continue
                }
            }
            let tempLocalTokens = localTokens.filter {
                $0.tokenType == .Violas
            }
            for token in tempLocalTokens {
                if item.code == token.tokenModule {
                    tempModel.enable = self.violasWalletActiveState == true ? true:false
                    continue
                }
            }
            tempModel.walletActiveState = self.violasWalletActiveState
            self.resultTokens.append(tempModel)
        }
    }
    private func rebuiltLibraData(enableTokens: [LibraBalanceModel], allTokens: [LibraTokenListDataModel], localTokens: [Token]) {
        for item in allTokens {
            var tempModel = AssetsModel.init(icon: "libra_icon", name: item.code, description: "", enable: false, registerState: false, type: .Libra)
            for token in enableTokens {
                if item.code == token.currency {
                    tempModel.registerState = true
                    continue
                }
            }
            let tempLocalTokens = localTokens.filter {
                $0.tokenType == .Libra
            }
            for token in tempLocalTokens {
                if item.code == token.tokenModule {
                    tempModel.enable = true
                    continue
                }
            }
            tempModel.walletActiveState = self.libraWalletActiveState
            self.resultTokens.append(tempModel)
        }
    }
//    func dealModelWithSelect(walletID: Int64, models: [ViolasTokenModel]) -> [ViolasTokenModel] {
//        let localSelectModel = try! DataBaseManager.DBManager.getViolasTokens(walletID: walletID)
//        var tempDataArray = [ViolasTokenModel]()
//        for model in models {
//            var tempModel = model
//            for item in localSelectModel {
//                if tempModel.id == item.id {
//                    tempModel.enable = item.enable
//                    break
//                } else {
//                    tempModel.enable = false
//                }
//            }
//            tempDataArray.append(tempModel)
//        }
//        return tempDataArray
//    }
    // MARK: 开启ViolasToken
    func publishViolasToken(sendAddress: String, mnemonic: [String], type: WalletType, module: String) {
        if type == .Libra {
            getLibraSequenceNumber(sendAddress: sendAddress, mnemonic: mnemonic, type: type, module: module)
            
        } else if type == .Violas  {
            getViolasSequenceNumber(sendAddress: sendAddress, mnemonic: mnemonic, type: type, module: module)
        }
    }
    private func getViolasSequenceNumber(sendAddress: String, mnemonic: [String], type: WalletType, module: String) {
        let request = mainProvide.request(.GetViolasAccountInfo(sendAddress)) {[weak self](result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(BalanceViolasMainModel.self)
                    self?.makeTransaction(sendAddress: sendAddress, mnemonic: mnemonic, sequenceNumber: Int(json.result?.sequence_number ?? 0), type: type, module: module)
                } catch {
                    print("GetViolasSequenceNumber__解析异常\(error.localizedDescription)")
                    let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.parseJsonError), type: "GetLibraSequenceNumber")
                    self?.setValue(data, forKey: "dataDic")
                }
            case let .failure(error):
                guard error.errorCode != -999 else {
                    print("GetViolasSequenceNumber_网络请求已取消")
                    return
                }
                let data = setKVOData(error: LibraWalletError.WalletRequest(reason: .networkInvalid), type: "GetViolasSequenceNumber")
                self?.setValue(data, forKey: "dataDic")
            }
        }
        self.requests.append(request)
    }
    private func getLibraSequenceNumber(sendAddress: String, mnemonic: [String], type: WalletType, module: String) {
        let request = mainProvide.request(.GetLibraAccountBalance(sendAddress)) {[weak self](result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(BalanceLibraMainModel.self)
                    self?.makeTransaction(sendAddress: sendAddress, mnemonic: mnemonic, sequenceNumber: Int(json.result?.sequence_number ?? 0), type: type, module: module)
                } catch {
                    print("GetLibraSequenceNumber_解析异常\(error.localizedDescription)")
                    let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.parseJsonError), type: "GetLibraSequenceNumber")
                    self?.setValue(data, forKey: "dataDic")
                }
            case let .failure(error):
                guard error.errorCode != -999 else {
                    print("GetLibraSequenceNumber_网络请求已取消")
                    return
                }
                let data = setKVOData(error: LibraWalletError.WalletRequest(reason: .networkInvalid), type: "GetViolasSequenceNumber")
                self?.setValue(data, forKey: "dataDic")
            }
        }
        self.requests.append(request)
    }
    private func makeTransaction(sendAddress: String, mnemonic: [String], sequenceNumber: Int, type: WalletType, module: String) {
        do {
            if type == .Libra {
                let signature = try LibraManager.getPublishTokenTransactionHex(mnemonic: mnemonic,
                                                                               sequenceNumber: sequenceNumber,
                                                                               module: module)
                makeLibraTransaction(signature: signature)
            } else if type == .Violas  {
                let signature = try ViolasManager.getPublishTokenTransactionHex(mnemonic: mnemonic,
                                                                                sequenceNumber: sequenceNumber,
                                                                                module: module)
                makeViolasTransaction(signature: signature)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    private func makeViolasTransaction(signature: String) {
        let request = mainProvide.request(.SendViolasTransaction(signature)) {[weak self](result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(LibraTransferMainModel.self)
                    if json.result == nil {
                        let data = setKVOData(type: "SendViolasTransaction")
                        self?.setValue(data, forKey: "dataDic")
                    } else {
                        print("SendViolasTransaction_状态异常")
                        if let message = json.error?.message, message.isEmpty == false {
                            let data = setKVOData(error: LibraWalletError.error(message), type: "SendViolasTransaction")
                            self?.setValue(data, forKey: "dataDic")
                        } else {
                            let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.dataCodeInvalid), type: "SendViolasTransaction")
                            self?.setValue(data, forKey: "dataDic")
                        }
                    }
                } catch {
                    print("SendViolasTransaction_解析异常\(error.localizedDescription)")
                    let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.parseJsonError), type: "SendViolasTransaction")
                    self?.setValue(data, forKey: "dataDic")
                }
            case let .failure(error):
                guard error.errorCode != -999 else {
                    print("SendViolasTransaction_网络请求已取消")
                    return
                }
                let data = setKVOData(error: LibraWalletError.WalletRequest(reason: .networkInvalid), type: "SendViolasTransaction")
                self?.setValue(data, forKey: "dataDic")
            }
        }
        self.requests.append(request)
    }
    private func makeLibraTransaction(signature: String) {
        let request = mainProvide.request(.SendLibraTransaction(signature)) {[weak self](result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(LibraTransferMainModel.self)
                    if json.result == nil {
                       DispatchQueue.main.async(execute: {
                           let data = setKVOData(type: "SendLibraTransaction")
                           self?.setValue(data, forKey: "dataDic")
                       })
                    } else {
                        print("SendLibraTransaction_状态异常")
                        DispatchQueue.main.async(execute: {
                            if let message = json.error?.message, message.isEmpty == false {
                                let data = setKVOData(error: LibraWalletError.error(message), type: "SendLibraTransaction")
                                self?.setValue(data, forKey: "dataDic")
                            } else {
                                let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.dataCodeInvalid), type: "SendLibraTransaction")
                                self?.setValue(data, forKey: "dataDic")
                            }
                        })
                    }
                } catch {
                    print("解析异常\(error.localizedDescription)")
                    DispatchQueue.main.async(execute: {
                        let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.parseJsonError), type: "SendLibraTransaction")
                        self?.setValue(data, forKey: "dataDic")
                    })
                }
            case let .failure(error):
                guard error.errorCode != -999 else {
                    print("网络请求已取消")
                    return
                }
                DispatchQueue.main.async(execute: {
                    let data = setKVOData(error: LibraWalletError.WalletRequest(reason: .networkInvalid), type: "SendLibraTransaction")
                    self?.setValue(data, forKey: "dataDic")
                })
                
            }
        }
        self.requests.append(request)
    }
    deinit {
        requests.forEach { cancellable in
            cancellable.cancel()
        }
        requests.removeAll()
        print("AddAssetModel销毁了")
    }
}
