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
struct ViolasTokenDataModel: Codable {
    var currencies: [ViolasTokenModel]?
    var module: String?
}
struct ViolasTokenMainModel: Codable {
    /// 错误代码
    var code: Int?
    /// 错误信息
    var message: String?
    /// 数据体
    var data: ViolasTokenDataModel?
}
class AddAssetModel: NSObject {
    private var requests: [Cancellable] = []
    @objc var dataDic: NSMutableDictionary = [:]
    private var walletTokenEnable: Bool?
    private var supportTokens: [ViolasTokenModel]?
    private var contract: String?
    func getSupportToken(walletID: Int64, walletAddress: String) {
        let group = DispatchGroup.init()
        let quene = DispatchQueue.init(label: "SupportTokenQuene")
        quene.async(group: group, qos: .default, flags: [], execute: {
            self.getViolasTokens(group: group)
        })
        quene.async(group: group, qos: .default, flags: [], execute: {
            self.getWalletEnableTokens(address: walletAddress, group: group)
        })
        group.notify(queue: quene) {
            print("回到该队列中执行")
            DispatchQueue.main.async(execute: {
                guard let state = self.walletTokenEnable else {
                    return
                }
                guard let marketTokens = self.supportTokens else {
                    return
                }
                let tempResult = self.rebuiltData(walletTokenEnable: state, marketTokens: marketTokens)
                let finalResult = self.dealModelWithSelect(walletID: walletID, models: tempResult)
                
                let data = setKVOData(type: "GetTokenList", data: finalResult)
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
                    let json = try response.map(ViolasTokenMainModel.self)
                    if json.code == 2000 {
                        guard let models = json.data?.currencies, models.isEmpty == false else {
                            let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.dataEmpty), type: "GetViolasTokens")
                            self?.setValue(data, forKey: "dataDic")
                            return
                        }
                        self?.supportTokens = models
                        self?.contract = json.data?.module
                        group.leave()
                    } else {
                        print("GetViolasTokens_状态异常")
                        if let message = json.message, message.isEmpty == false {
                            let data = setKVOData(error: LibraWalletError.error(message), type: "GetViolasTokenList")
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
    private func getWalletEnableTokens(address: String, group: DispatchGroup) {
        group.enter()
        let request = mainProvide.request(.GetViolasAccountEnableToken(address)) {[weak self](result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(ViolasAccountEnableTokenResponseMainModel.self)
                    if json.code == 2000 {
                        self?.walletTokenEnable = json.data?.is_published == 1 ? true:false
                        group.leave()
                    } else {
                        print("GetWalletEnableTokens_状态异常")
                        if let message = json.message, message.isEmpty == false {
                            let data = setKVOData(error: LibraWalletError.error(message), type: "GetWalletEnableTokens")
                            self?.setValue(data, forKey: "dataDic")
                        } else {
                            let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.dataCodeInvalid), type: "GetWalletEnableTokens")
                            self?.setValue(data, forKey: "dataDic")
                        }
                    }
                } catch {
                    print("GetWalletEnableTokens_解析异常\(error.localizedDescription)")
                    let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.parseJsonError), type: "GetWalletEnableTokens")
                    self?.setValue(data, forKey: "dataDic")
                }
            case let .failure(error):
                guard error.errorCode != -999 else {
                    print("GetWalletEnableTokens_网络请求已取消")
                    return
                }
                let data = setKVOData(error: LibraWalletError.WalletRequest(reason: .networkInvalid), type: "GetWalletEnableTokens")
                self?.setValue(data, forKey: "dataDic")
            }
        }
        self.requests.append(request)
    }
    private func rebuiltData(walletTokenEnable: Bool, marketTokens: [ViolasTokenModel]) -> [ViolasTokenModel] {
        var tempMarketTokens = [ViolasTokenModel]()
        for var item in marketTokens {
            item.registerState = walletTokenEnable
            item.address = self.contract
            tempMarketTokens.append(item)
        }
        return tempMarketTokens
    }
    func dealModelWithSelect(walletID: Int64, models: [ViolasTokenModel]) -> [ViolasTokenModel] {
        let localSelectModel = try! DataBaseManager.DBManager.getViolasTokens(walletID: walletID)
        var tempDataArray = [ViolasTokenModel]()
        for model in models {
            var tempModel = model
            for item in localSelectModel {
                if tempModel.id == item.id {
                    tempModel.enable = item.enable
                    break
                } else {
                    tempModel.enable = false
                }
            }
            tempDataArray.append(tempModel)
        }
        return tempDataArray
    }
    // MARK: 开启ViolasToken
    func publishViolasToken(sendAddress: String, mnemonic: [String], contact: String) {
        getViolasSequenceNumber(sendAddress: sendAddress, mnemonic: mnemonic, contact: contact)
    }
    private func getViolasSequenceNumber(sendAddress: String, mnemonic: [String], contact: String) {
        let request = mainProvide.request(.GetViolasAccountSequenceNumber(sendAddress)) {[weak self](result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(ViolaSequenceNumberMainModel.self)
                    if json.code == 2000 {
                        self?.makeTransaction(sendAddress: sendAddress, mnemonic: mnemonic, sequenceNumber: json.data ?? 0, contact: contact)
                    } else {
                        print("GetViolasSequenceNumber_状态异常")
                        if let message = json.message, message.isEmpty == false {
                            let data = setKVOData(error: LibraWalletError.error(message), type: "GetViolasSequenceNumber")
                            self?.setValue(data, forKey: "dataDic")
                        } else {
                            let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.dataCodeInvalid), type: "GetViolasSequenceNumber")
                            self?.setValue(data, forKey: "dataDic")
                        }
                    }
                } catch {
                    print("GetViolasSequenceNumber_解析异常\(error.localizedDescription)")
                    let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.parseJsonError), type: "GetViolasSequenceNumber")
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
    private func makeTransaction(sendAddress: String, mnemonic: [String], sequenceNumber: Int, contact: String) {
        do {
            let signature = try ViolasManager.getRegisterTokenTransactionHex(mnemonic: mnemonic,
                                                                              contact: contact,
                                                                              sequenceNumber: sequenceNumber)
            makeViolasTransaction(signature: signature)
        } catch {
            print(error.localizedDescription)
        }
    }
    private func makeViolasTransaction(signature: String) {
        let request = mainProvide.request(.SendViolasTransaction(signature)) {[weak self](result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(ViolaSendTransactionMainModel.self)
                    if json.code == 2000 {
                        let data = setKVOData(type: "SendViolasTransaction")
                        self?.setValue(data, forKey: "dataDic")
                    } else {
                        print("SendViolasTransaction_状态异常")
                        if let message = json.message, message.isEmpty == false {
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
    deinit {
        requests.forEach { cancellable in
            cancellable.cancel()
        }
        requests.removeAll()
        print("AddAssetModel销毁了")
    }
}
