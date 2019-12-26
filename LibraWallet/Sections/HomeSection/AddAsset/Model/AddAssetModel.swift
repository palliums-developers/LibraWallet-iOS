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
}
struct ViolasTokenMainModel: Codable {
    /// 错误代码
    var code: Int?
    /// 错误信息
    var message: String?
    /// 数据体
    var data: [ViolasTokenModel]?
}
class AddAssetModel: NSObject {
    private var requests: [Cancellable] = []
    @objc var dataDic: NSMutableDictionary = [:]
    private var walletEnableTokens: [String]?
    private var supportTokens: [ViolasTokenModel]?
    func getSupportToken(walletID: Int64, walletAddress: String) {
        let group = DispatchGroup.init()
        let quene = DispatchQueue.init(label: "SupportTokenQuene")
        quene.async(group: group, qos: .default, flags: [], execute: {
//            self.getMarketSupportToken(group: group)
            self.getViolasTokenList(group: group)
        })
        quene.async(group: group, qos: .default, flags: [], execute: {
            self.getWalletEnableToken(address: walletAddress, group: group)
        })
        group.notify(queue: quene) {
            print("回到该队列中执行")
            DispatchQueue.main.async(execute: {
                guard let walletTokens = self.walletEnableTokens else {
                    return
                }
                guard let marketTokens = self.supportTokens else {
                    return
                }
                let tempResult = self.rebuiltData(walletTokens: walletTokens, marketTokens: marketTokens)
                let finalResult = self.dealModelWithSelect(walletID: walletID, models: tempResult)
                
                let data = setKVOData(type: "GetTokenList", data: finalResult)
                self.setValue(data, forKey: "dataDic")
            })
        }
    }
    private func getViolasTokenList(group: DispatchGroup) {
        group.enter()
        let request = mainProvide.request(.GetViolasTokenList) {[weak self](result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(ViolasTokenMainModel.self)
                    guard json.code == 2000 else {
                        let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.dataCodeInvalid), type: "UpdateViolasTokenList")
                        self?.setValue(data, forKey: "dataDic")
                        return
                    }
                    guard let models = json.data, models.isEmpty == false else {
                        let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.dataEmpty), type: "UpdateViolasTokenList")
                        self?.setValue(data, forKey: "dataDic")
                        return
                    }
//                    let result = self?.dealModelWithSelect(walletID: walletID, models: models)
//                    let data = setKVOData(type: "UpdateViolasTokenList", data: result)
//                    self?.setValue(data, forKey: "dataDic")
                    self?.supportTokens = json.data
                } catch {
                    print("解析异常\(error.localizedDescription)")
                    let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.parseJsonError), type: "UpdateViolasTokenList")
                    self?.setValue(data, forKey: "dataDic")
                }
            case let .failure(error):
                guard error.errorCode != -999 else {
                    print("网络请求已取消")
                    return
                }
                let data = setKVOData(error: LibraWalletError.WalletRequest(reason: .networkInvalid), type: "UpdateViolasTokenList")
                self?.setValue(data, forKey: "dataDic")
            }
            group.leave()
        }
        self.requests.append(request)
    }
    private func getWalletEnableToken(address: String, group: DispatchGroup) {
        group.enter()
        let request = mainProvide.request(.GetViolasAccountEnableToken(address)) {[weak self](result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(ViolasAccountEnableTokenResponseModel.self)
                    guard json.code == 2000 else {
                        let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.dataCodeInvalid), type: "GetWalletEnableCoin")
                        self?.setValue(data, forKey: "dataDic")
                        return
                    }
                    self?.walletEnableTokens = json.data
                } catch {
                    print("GetWalletEnableCoin_解析异常\(error.localizedDescription)")
                    let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.parseJsonError), type: "GetWalletEnableCoin")
                    self?.setValue(data, forKey: "dataDic")
                }
            case let .failure(error):
                guard error.errorCode != -999 else {
                    print("GetWalletEnableCoin_网络请求已取消")
                    return
                }
                let data = setKVOData(error: LibraWalletError.WalletRequest(reason: .networkInvalid), type: "GetWalletEnableCoin")
                self?.setValue(data, forKey: "dataDic")
            }
            group.leave()
        }
        self.requests.append(request)
    }
    private func rebuiltData(walletTokens: [String], marketTokens: [ViolasTokenModel]) -> [ViolasTokenModel] {
        var tempMarketTokens = [ViolasTokenModel]()
        for var item in marketTokens {
            for address in walletTokens {
                if address == item.address {
                    item.registerState = true
                    break
                } else {
                    item.registerState = false
                }
            }
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
                if tempModel.address == item.address {
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
                    guard json.code == 2000 else {
                        let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.dataCodeInvalid), type: "GetViolasSequenceNumber")
                        self?.setValue(data, forKey: "dataDic")
                        return
                    }
//                    let data = setKVOData(type: "GetViolasSequenceNumber", data: json.data)
//                    self?.setValue(data, forKey: "dataDic")
                    self?.makeTransaction(sendAddress: sendAddress, mnemonic: mnemonic, sequenceNumber: json.data ?? 0, contact: contact)
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
            let wallet = try ViolasManager.getWallet(mnemonic: mnemonic)

            // 拼接交易
            let request = ViolasTransaction.init(sendAddress: wallet.publicKey.toAddress(), sequenceNumber: UInt64(sequenceNumber), code: Data.init(Array<UInt8>(hex: ViolasManager().getViolasPublishCode(content: contact))))
            // 签名交易
            let signature = try wallet.privateKey.signTransaction(transaction: request.request, wallet: wallet)
            makeViolasTransaction(signature: signature.toHexString())
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
                    guard json.code == 2000 else {
                        let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.dataCodeInvalid), type: "SendViolasTransaction")
                        self?.setValue(data, forKey: "dataDic")
                        return
                    }
                    let data = setKVOData(type: "SendViolasTransaction")
                    self?.setValue(data, forKey: "dataDic")
                    // 刷新本地数据
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
