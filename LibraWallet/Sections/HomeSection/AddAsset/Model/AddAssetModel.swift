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
    /// 展示名字
    var show_name: String?
    /// 名称
    var name: String?
    /// 合约地址
    var address: String?
    /// module名字
    var module: String?
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
struct ViolasTokensCurrenciesModel: Codable {
    var address: String?
    var module: String?
    var name: String?
    var show_icon: String?
    var show_name: String?
}
struct ViolasTokensDataModel: Codable {
    var currencies: [ViolasTokensCurrenciesModel]?
}
struct ViolasTokensMainModel: Codable {
    var code: Int?
    var message: String?
    var data: ViolasTokensDataModel?
}
struct LibraTokensCurrenciesModel: Codable {
    var address: String?
    var module: String?
    var name: String?
    var show_icon: String?
    var show_name: String?
}
struct LibraTokensDataModel: Codable {
    var currencies: [LibraTokensCurrenciesModel]?
}
struct LibraTokensMainModel: Codable {
    var code: Int?
    var message: String?
    var data: LibraTokensDataModel?
}
class AddAssetModel: NSObject {
    private var requests: [Cancellable] = []
    @objc dynamic var dataDic: NSMutableDictionary = [:]
    private var violasEnableTokens: [ViolasBalanceDataModel]?
    private var libraEnableTokens: [DiemBalanceDataModel]?
    private var violasTokens: [ViolasTokensCurrenciesModel]?
    private var libraTokens: [LibraTokensCurrenciesModel]?
    private var resultTokens = [AssetsModel]()
    private var violasWalletActiveState: Bool = false
    private var libraWalletActiveState: Bool = false
    private var contract: String?
    private var maxGasAmount: UInt64 = 600
    func getSupportToken(localTokens: [Token]) {
        let group = DispatchGroup.init()
        let quene = DispatchQueue.init(label: "SupportTokenQuene")
        quene.async(group: group, qos: .default, flags: [], execute: {
            self.getViolasTokens(group: group)
        })
        quene.async(group: group, qos: .default, flags: [], execute: {
            self.getViolasAccountInfo(address: WalletManager.shared.violasAddress ?? "", group: group)
        })
        quene.async(group: group, qos: .default, flags: [], execute: {
            self.getLibraTokens(group: group)
        })
        quene.async(group: group, qos: .default, flags: [], execute: {
            self.getLibraAccountInfo(address: WalletManager.shared.libraAddress ?? "", group: group)
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
        let request = violasModuleProvide.request(.currencyList) {[weak self](result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(ViolasTokensMainModel.self)
                    if json.code == 2000 {
                        guard let models = json.data?.currencies, models.isEmpty == false else {
                            let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.dataEmpty), type: "GetViolasTokens")
                            self?.setValue(data, forKey: "dataDic")
                            print("GetViolasTokens_状态异常")
                            return
                        }
                        self?.violasTokens = models
                        group.leave()
                    } else {
                        print("GetViolasTokens_状态异常")
                        if let message = json.message, message.isEmpty == false {
                            let data = setKVOData(error: LibraWalletError.error(message), type: "GetViolasTokens")
                            self?.setValue(data, forKey: "dataDic")
                        } else {
                            let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.dataCodeInvalid), type: "GetViolasTokens")
                            self?.setValue(data, forKey: "dataDic")
                        }
                    }
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
        let request = violasModuleProvide.request(.accountInfo(address)) {[weak self](result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(ViolasAccountMainModel.self)
                    if json.result == nil {
//                        let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.dataEmpty), type: "GetViolasAccountInfo")
//                        self?.setValue(data, forKey: "dataDic")
                        print("ViolasWallet尚未激活")
                        self?.violasEnableTokens = [ViolasBalanceDataModel]()
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
        let request = libraModuleProvide.request(.currencyList) {[weak self](result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(LibraTokensMainModel.self)
                    if json.code == 2000 {
                        guard let models = json.data?.currencies, models.isEmpty == false else {
                            let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.dataEmpty), type: "GetViolasTokens")
                            self?.setValue(data, forKey: "dataDic")
                            print("GetLibraTokens_状态异常")
                            return
                        }
                        self?.libraTokens = models
                        group.leave()
                    } else {
                        print("GetLibraTokens_状态异常")
                        if let message = json.message, message.isEmpty == false {
                            let data = setKVOData(error: LibraWalletError.error(message), type: "GetLibraTokens")
                            self?.setValue(data, forKey: "dataDic")
                        } else {
                            let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.dataCodeInvalid), type: "GetLibraTokens")
                            self?.setValue(data, forKey: "dataDic")
                        }
                    }
                } catch {
                    print("GetLibraTokens_解析异常\(error.localizedDescription)")
                    let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.parseJsonError), type: "GetLibraTokens")
                    self?.setValue(data, forKey: "dataDic")
                }
            case let .failure(error):
                guard error.errorCode != -999 else {
                    print("网络请求已取消")
                    return
                }
                let data = setKVOData(error: LibraWalletError.WalletRequest(reason: .networkInvalid), type: "GetLibraTokens")
                self?.setValue(data, forKey: "dataDic")
            }
        }
        self.requests.append(request)
    }
    private func getLibraAccountInfo(address: String, group: DispatchGroup) {
        group.enter()
        let request = libraModuleProvide.request(.accountInfo(address)) {[weak self](result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(DiemAccountMainModel.self)
                    if json.result == nil {
//                        let data = setKVOData(type: "UpdateLibraBalance", data: [LibraBalanceModel.init(amount: 0, currency: "LBR")])
//                        self?.setValue(data, forKey: "dataDic")
                        print("LibraWallet尚未激活")
                        self?.libraEnableTokens = [DiemBalanceDataModel]()
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
    private func rebuiltViolasData(enableTokens: [ViolasBalanceDataModel], allTokens: [ViolasTokensCurrenciesModel], localTokens: [Token]) {
        for item in allTokens {
            var tempModel = AssetsModel.init(icon: item.show_icon,
                                             show_name: item.show_name,
                                             name: item.name,
                                             address: item.address,
                                             module: item.module,
                                             description: "",
                                             enable: false,
                                             registerState: false,
                                             type: .Violas,
                                             walletActiveState: false)
            for token in enableTokens {
                if item.module == token.currency {
                    tempModel.registerState = true
                    continue
                }
            }
            let tempLocalTokens = localTokens.filter {
                $0.tokenType == .Violas
            }
            for token in tempLocalTokens {
                if item.module == token.tokenModule {
                    if tempModel.registerState == true {
                        tempModel.enable = self.violasWalletActiveState == true ? true:false
                    } else {
                        tempModel.enable = false
                    }
                    continue
                }
            }
            tempModel.walletActiveState = self.violasWalletActiveState
            self.resultTokens.append(tempModel)
        }
    }
    private func rebuiltLibraData(enableTokens: [DiemBalanceDataModel], allTokens: [LibraTokensCurrenciesModel], localTokens: [Token]) {
        for item in allTokens {
            var tempModel = AssetsModel.init(icon: item.show_icon,
                                             show_name: item.show_name,
                                             name: item.name,
                                             address: item.address,
                                             module: item.module,
                                             description: "",
                                             enable: false,
                                             registerState: false,
                                             type: .Libra,
                                             walletActiveState: false)
            for token in enableTokens {
                if item.module == token.currency {
                    tempModel.registerState = true
                    continue
                }
            }
            let tempLocalTokens = localTokens.filter {
                $0.tokenType == .Libra
            }
            for token in tempLocalTokens {
                if item.module == token.tokenModule {
                    tempModel.enable = true
                    continue
                }
            }
            tempModel.walletActiveState = self.libraWalletActiveState
            self.resultTokens.append(tempModel)
        }
    }
    // MARK: 开启ViolasToken
    func publishViolasToken(sendAddress: String, mnemonic: [String], type: WalletType, module: String) {
        if type == .Libra {
            getLibraSequenceNumber(sendAddress: sendAddress, mnemonic: mnemonic, type: type, module: module)
            
        } else if type == .Violas  {
            getViolasSequenceNumber(sendAddress: sendAddress, mnemonic: mnemonic, type: type, module: module)
        }
    }
    private func getViolasSequenceNumber(sendAddress: String, mnemonic: [String], type: WalletType, module: String) {
        let request = violasModuleProvide.request(.accountInfo(sendAddress)) {[weak self](result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(ViolasAccountMainModel.self)
                    guard json.result != nil else {
                        let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.walletUnActive), type: "GetLibraSequenceNumber")
                        self?.setValue(data, forKey: "dataDic")
                        return
                    }
                    self?.maxGasAmount = ViolasManager.handleMaxGasAmount(balances: json.result?.balances ?? [ViolasBalanceDataModel.init(amount: 0, currency: "VLS")])
                    self?.makeTransaction(sendAddress: sendAddress, mnemonic: mnemonic, sequenceNumber: UInt64(json.result?.sequence_number ?? 0), type: type, module: module)
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
        let request = libraModuleProvide.request(.accountInfo(sendAddress)) {[weak self](result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(DiemAccountMainModel.self)
                    guard json.result != nil else {
                        let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.walletUnActive), type: "GetLibraSequenceNumber")
                        self?.setValue(data, forKey: "dataDic")
                        return
                    }
                    self?.makeTransaction(sendAddress: sendAddress, mnemonic: mnemonic, sequenceNumber: UInt64(json.result?.sequence_number ?? 0), type: type, module: module)
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
    private func makeTransaction(sendAddress: String, mnemonic: [String], sequenceNumber: UInt64, type: WalletType, module: String) {
        do {
            if type == .Libra {
                let signature = try DiemManager.getPublishTokenTransactionHex(mnemonic: mnemonic,
                                                                               sequenceNumber: sequenceNumber,
                                                                               fee: 0,
                                                                               module: module)
                makeLibraTransaction(signature: signature)
            } else if type == .Violas  {
                let signature = try ViolasManager.getPublishTokenTransactionHex(mnemonic: mnemonic,
                                                                                maxGasAmount: self.maxGasAmount,
                                                                                maxGasUnitPrice: ViolasManager.handleMaxGasUnitPrice(maxGasAmount: self.maxGasAmount),
                                                                                sequenceNumber: sequenceNumber,
                                                                                inputModule: module)
                makeViolasTransaction(signature: signature)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    private func makeViolasTransaction(signature: String) {
        let request = violasModuleProvide.request(.sendTransaction(signature)) {[weak self](result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(ViolasAccountMainModel.self)
                    if json.error == nil {
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
        let request = libraModuleProvide.request(.sendTransaction(signature)) {[weak self](result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(DiemAccountMainModel.self)
                    if json.error == nil {
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
