//
//  ManageCurrencyModel.swift
//  DiemWallet
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
    /// 币钱包地址
    var walletAddress: String
    /// 币AuthKey
    var authKey: String
    /// 是否已展示
    var enable: Bool
    /// 注册状态
    var registerState: Bool
    /// 币类型
    var type: WalletType
    /// 钱包激活状态
    var walletActiveState: Bool
    
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
struct DiemTokensCurrenciesModel: Codable {
    var address: String?
    var module: String?
    var name: String?
    var show_icon: String?
    var show_name: String?
}
struct DiemTokensDataModel: Codable {
    var currencies: [DiemTokensCurrenciesModel]?
}
struct DiemTokensMainModel: Codable {
    var code: Int?
    var message: String?
    var data: DiemTokensDataModel?
}
class ManageCurrencyModel: NSObject {
    private var requests: [Cancellable] = []
    private var maxGasAmount: UInt64 = 600
    func getSupportToken(localTokens: [Token], completion: @escaping (Result<[AssetsModel], LibraWalletError>) -> Void) {
        let group = DispatchGroup.init()
        let quene = DispatchQueue.init(label: "SupportTokenQuene")
        var violasTokens = [ViolasTokensCurrenciesModel]()
        var diemTokens = [DiemTokensCurrenciesModel]()
        var violasAccount: ViolasAccountInfoDataModel?
        var diemAccount: DiemAccountInfoDataModel?
        quene.async(group: group, qos: .default, flags: [], execute: {
            group.enter()
            self.getViolasTokens() { (result) in
                group.leave()
                switch result {
                case let .success(tokens):
                    violasTokens = tokens
                case let .failure(error):
                    print(error.localizedDescription)
                }
            }
        })
        quene.async(group: group, qos: .default, flags: [], execute: {
            group.enter()
            self.getViolasAccountInfo(address: Wallet.shared.violasAddress ?? "") { (result) in
                group.leave()
                switch result {
                case let .success(account):
                    violasAccount = account
                case let .failure(error):
                    print(error.localizedDescription)
                }
            }
        })
        quene.async(group: group, qos: .default, flags: [], execute: {
            group.enter()
            self.getDiemTokens() { (result) in
                group.leave()
                switch result {
                case let .success(tokens):
                    diemTokens = tokens
                case let .failure(error):
                    print(error.localizedDescription)
                }
            }
        })
        quene.async(group: group, qos: .default, flags: [], execute: {
            group.enter()
            self.getDiemAccountInfo(address: Wallet.shared.libraAddress ?? "") { (result) in
                group.leave()
                switch result {
                case let .success(account):
                    diemAccount = account
                case let .failure(error):
                    print(error.localizedDescription)
                }
            }
        })
        group.notify(queue: quene) {
            print("回到该队列中执行")
            DispatchQueue.main.async(execute: {
                let violasResult = self.rebuiltViolasData(violasAccount: violasAccount, violasTotalTokens: violasTokens, localTokens: localTokens)
                let diemResult = self.rebuiltDiemData(diemAccount: diemAccount, diemTotalTokens: diemTokens, localTokens: localTokens)
                completion(.success(violasResult + diemResult))
            })
        }
    }
    private func rebuiltViolasData(violasAccount: ViolasAccountInfoDataModel?, violasTotalTokens: [ViolasTokensCurrenciesModel], localTokens: [Token]) -> [AssetsModel] {
        var tempViolasLocalTokens = localTokens
        var tempViolasEnableTokens = violasAccount?.balances ?? [ViolasBalanceDataModel]()
        var result = [AssetsModel]()
        for item in violasTotalTokens {
            var model = AssetsModel.init(icon: item.show_icon,
                                         show_name: item.show_name,
                                         name: item.name,
                                         address: item.address,
                                         module: item.module,
                                         description: "",
                                         walletAddress: violasAccount?.address ?? "",
                                         authKey: violasAccount?.authentication_key ?? "",
                                         enable: false,
                                         registerState: false,
                                         type: .Violas,
                                         walletActiveState: false)
            // 判断是否已注册
            for i in 0..<tempViolasEnableTokens.count {
                if item.module == tempViolasEnableTokens[i].currency {
                    // 已注册
                    model.registerState = true
                    tempViolasEnableTokens.remove(at: i)
                    break
                }
            }
            // 判断是否已开启
            for j in 0..<tempViolasLocalTokens.count {
                guard tempViolasLocalTokens[j].tokenType == .Violas else {
                    continue
                }
                if item.module == tempViolasLocalTokens[j].tokenModule {
                    model.enable = model.registerState == true ? true:false
                    tempViolasLocalTokens.remove(at: j)
                    break
                }
            }
            model.walletActiveState = violasAccount?.authentication_key?.isEmpty == false ? true:false
            result.append(model)
        }
        return result
    }
    private func rebuiltDiemData(diemAccount: DiemAccountInfoDataModel?, diemTotalTokens: [DiemTokensCurrenciesModel], localTokens: [Token]) -> [AssetsModel] {
        var tempDiemLocalTokens = localTokens
        var tempDiemEnableTokens = diemAccount?.balances ?? [DiemBalanceDataModel]()
        var result = [AssetsModel]()
        for item in diemTotalTokens {
            var model = AssetsModel.init(icon: item.show_icon,
                                         show_name: item.show_name,
                                         name: item.name,
                                         address: item.address,
                                         module: item.module,
                                         description: "",
                                         walletAddress: diemAccount?.address ?? "",
                                         authKey: diemAccount?.authentication_key ?? "",
                                         enable: false,
                                         registerState: false,
                                         type: .Libra,
                                         walletActiveState: false)
            // 判断是否已注册
            for i in 0..<tempDiemEnableTokens.count {
                if item.module == tempDiemEnableTokens[i].currency {
                    // 已注册
                    model.registerState = true
                    tempDiemEnableTokens.remove(at: i)
                    continue
                }
            }
            // 判断是否已开启
            for j in 0..<tempDiemLocalTokens.count {
                guard tempDiemLocalTokens[j].tokenType == .Libra else {
                    continue
                }
                if item.module == tempDiemLocalTokens[j].tokenModule {
                    model.enable = model.registerState == true ? true:false
                    tempDiemLocalTokens.remove(at: j)
                    break
                }
            }
            model.walletActiveState = diemAccount?.authentication_key?.isEmpty == false ? true:false
            result.append(model)
        }
        return result
    }
    func getAddress(authKey: String) -> String {
        guard authKey.count == 64 else {
            return ""
        }
        let index = authKey.index(authKey.startIndex, offsetBy: 32)
        let address = authKey.suffix(from: index)
        let subStr: String = String(address)
        return subStr
    }
    deinit {
        requests.forEach { cancellable in
            cancellable.cancel()
        }
        requests.removeAll()
        print("ManageCurrencyModel销毁了")
    }
}
// MARK: - Publish
extension ManageCurrencyModel {
    func publishToken(sendAddress: String, mnemonic: [String], model: AssetsModel, completion: @escaping (Result<Bool, LibraWalletError>) -> Void) {
        switch model.type {
        case .Libra:
            self.activeDiemToken(sendAddress: sendAddress, mnemonic: mnemonic, module: model.module!) { (result) in
                switch result {
                case let .success(sendResult):
                    completion(.success(sendResult))
                case let .failure(error):
                    completion(.failure(error))
                }
            }
        case .Violas:
            self.activeViolasToken(sendAddress: sendAddress, mnemonic: mnemonic, module: model.module!) { (result) in
                switch result {
                case let .success(sendResult):
                    completion(.success(sendResult))
                case let .failure(error):
                    completion(.failure(error))
                }
            }
        case .BTC:
            completion(.failure(LibraWalletError.error("Not Support")))
        }
    }
    private func activeViolasToken(sendAddress: String, mnemonic: [String], module: String, completion: @escaping (Result<Bool, LibraWalletError>) -> Void) {
        var sequence: UInt64?
        let quene = DispatchQueue.init(label: "ActiveTokenQuene")
        let semaphore = DispatchSemaphore.init(value: 1)
        quene.async {
            semaphore.wait()
            self.getViolasSequenceNumber(sendAddress: sendAddress) { (result) in
                semaphore.signal()
                switch result {
                case let .success(sequenceNumber):
                    sequence = sequenceNumber
                case let .failure(error):
                    DispatchQueue.main.async(execute: {
                        completion(.failure(error))
                    })
                }
            }
        }
        quene.async {
            semaphore.wait()
            guard let tempSequence = sequence else {
                semaphore.signal()
                return
            }
            do {
                let signature = try ViolasManager.getPublishTokenTransactionHex(mnemonic: mnemonic,
                                                                                maxGasAmount: self.maxGasAmount,
                                                                                maxGasUnitPrice: ViolasManager.handleMaxGasUnitPrice(maxGasAmount: self.maxGasAmount),
                                                                                sequenceNumber: tempSequence,
                                                                                inputModule: module)
                self.makeViolasTransaction(signature: signature) { (result) in
                    switch result {
                    case let .success(sendResult):
                        DispatchQueue.main.async(execute: {
                            completion(.success(sendResult))
                        })
                    case let .failure(error):
                        DispatchQueue.main.async(execute: {
                            completion(.failure(error))
                        })
                    }
                }
            } catch {
                DispatchQueue.main.async(execute: {
                    completion(.failure(LibraWalletError.error(error.localizedDescription)))
                })
            }
            semaphore.signal()
        }
    }
    private func activeDiemToken(sendAddress: String, mnemonic: [String], module: String, completion: @escaping (Result<Bool, LibraWalletError>) -> Void) {
        var sequence: UInt64?
        let quene = DispatchQueue.init(label: "ActiveTokenQuene")
        let semaphore = DispatchSemaphore.init(value: 1)
        quene.async {
            semaphore.wait()
            self.getDiemSequenceNumber(sendAddress: sendAddress) { (result) in
                semaphore.signal()
                switch result {
                case let .success(sequenceNumber):
                    sequence = sequenceNumber
                case let .failure(error):
                    DispatchQueue.main.async(execute: {
                        completion(.failure(error))
                    })
                }
            }
        }
        quene.async {
            semaphore.wait()
            guard let tempSequence = sequence else {
                semaphore.signal()
                return
            }
            do {
                let signature = try DiemManager.getPublishTokenTransactionHex(mnemonic: mnemonic,
                                                                              sequenceNumber: tempSequence,
                                                                              fee: 0,
                                                                              module: module,
                                                                              feeModule: module)
                self.makeDiemTransaction(signature: signature) { (result) in
                    switch result {
                    case let .success(sendResult):
                        DispatchQueue.main.async(execute: {
                            completion(.success(sendResult))
                        })
                    case let .failure(error):
                        DispatchQueue.main.async(execute: {
                            completion(.failure(LibraWalletError.error(error.localizedDescription)))
                        })
                    }
                }
                
            } catch {
                DispatchQueue.main.async(execute: {
                    completion(.failure(LibraWalletError.error(error.localizedDescription)))
                })
            }
            semaphore.signal()
        }
    }
}
// MARK: - Violas
extension ManageCurrencyModel {
    private func getViolasTokens(completion: @escaping (Result<[ViolasTokensCurrenciesModel], LibraWalletError>) -> Void) {
        let request = violasModuleProvide.request(.currencyList) { (result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(ViolasTokensMainModel.self)
                    if json.code == 2000 {
                        completion(.success(json.data?.currencies ?? [ViolasTokensCurrenciesModel]()))
                    } else {
                        print("GetViolasTokens_状态异常")
                        if let message = json.message, message.isEmpty == false {
                            completion(.failure(LibraWalletError.error(message)))
                        } else {
                            completion(.failure(LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.dataCodeInvalid)))
                        }
                    }
                } catch {
                    print("GetViolasTokens_解析异常\(error.localizedDescription)")
                    completion(.failure(LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.parseJsonError)))
                }
            case let .failure(error):
                guard error.errorCode != -999 else {
                    print("网络请求已取消")
                    return
                }
                completion(.failure(LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.networkInvalid)))
            }
        }
        self.requests.append(request)
    }
    private func getViolasAccountInfo(address: String, completion: @escaping (Result<ViolasAccountInfoDataModel, LibraWalletError>) -> Void) {
        let request = violasModuleProvide.request(.accountInfo(address)) { (result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(ViolasAccountMainModel.self)
                    if let result = json.result {
                        completion(.success(result))
                    } else {
                        completion(.failure(LibraWalletError.WalletRequest(reason: .walletUnActive)))
                    }
                } catch {
                    print("GetViolasAccountInfo_解析异常\(error.localizedDescription)")
                    completion(.failure(LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.parseJsonError)))
                }
            case let .failure(error):
                guard error.errorCode != -999 else {
                    print("GetViolasAccountInfo_网络请求已取消")
                    return
                }
                completion(.failure(LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.networkInvalid)))
            }
        }
        self.requests.append(request)
    }
    private func getViolasSequenceNumber(sendAddress: String, completion: @escaping (Result<UInt64, LibraWalletError>) -> Void) {
        let request = violasModuleProvide.request(.accountInfo(sendAddress)) { (result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(ViolasAccountMainModel.self)
                    guard json.result != nil else {
                        completion(.failure(LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.walletUnActive)))
                        return
                    }
                    guard let sequence = json.result?.sequence_number else {
                        completion(.failure(LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.parseJsonError)))
                        return
                    }
                    completion(.success(sequence))
                } catch {
                    print("GetViolasSequenceNumber__解析异常\(error.localizedDescription)")
                    completion(.failure(LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.parseJsonError)))
                }
            case let .failure(error):
                guard error.errorCode != -999 else {
                    print("GetViolasSequenceNumber_网络请求已取消")
                    return
                }
                completion(.failure(LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.networkInvalid)))
            }
        }
        self.requests.append(request)
    }
    private func makeViolasTransaction(signature: String, completion: @escaping (Result<Bool, LibraWalletError>) -> Void) {
        let request = violasModuleProvide.request(.sendTransaction(signature)) { (result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(ViolasAccountMainModel.self)
                    if json.error == nil {
                        completion(.success(true))
                    } else {
                        print("SendViolasTransaction_状态异常")
                        if let message = json.error?.message, message.isEmpty == false {
                            completion(.failure(LibraWalletError.error(message)))
                        } else {
                            completion(.failure(LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.dataCodeInvalid)))
                        }
                    }
                } catch {
                    print("SendViolasTransaction_解析异常\(error.localizedDescription)")
                    completion(.failure(LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.parseJsonError)))
                }
            case let .failure(error):
                guard error.errorCode != -999 else {
                    print("SendViolasTransaction_网络请求已取消")
                    return
                }
                completion(.failure(LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.networkInvalid)))
            }
        }
        self.requests.append(request)
    }
    
}
// MARK: - Diem
extension ManageCurrencyModel {
    private func getDiemTokens(completion: @escaping (Result<[DiemTokensCurrenciesModel], LibraWalletError>) -> Void) {
        let request = libraModuleProvide.request(.currencyList) { (result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(DiemTokensMainModel.self)
                    if json.code == 2000 {
                        completion(.success(json.data?.currencies ?? [DiemTokensCurrenciesModel]()))
                    } else {
                        print("GetDiemTokens_状态异常")
                        if let message = json.message, message.isEmpty == false {
                            completion(.failure(LibraWalletError.error(message)))
                        } else {
                            completion(.failure(LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.dataCodeInvalid)))
                        }
                    }
                } catch {
                    print("GetDiemTokens_解析异常\(error.localizedDescription)")
                    completion(.failure(LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.parseJsonError)))
                }
            case let .failure(error):
                guard error.errorCode != -999 else {
                    print("网络请求已取消")
                    return
                }
                completion(.failure(LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.networkInvalid)))
            }
        }
        self.requests.append(request)
    }
    private func getDiemAccountInfo(address: String, completion: @escaping (Result<DiemAccountInfoDataModel, LibraWalletError>) -> Void) {
        let request = libraModuleProvide.request(.accountInfo(address)) {[weak self](result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(DiemAccountMainModel.self)
                    if let result = json.result {
                        completion(.success(result))
                    } else {
                        completion(.failure(LibraWalletError.WalletRequest(reason: .walletUnActive)))
                    }
                } catch {
                    print("解析异常\(error.localizedDescription)")
                    completion(.failure(LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.parseJsonError)))
                }
            case let .failure(error):
                guard error.errorCode != -999 else {
                    print("网络请求已取消")
                    return
                }
                completion(.failure(LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.networkInvalid)))
            }
        }
        self.requests.append(request)
    }
    private func getDiemSequenceNumber(sendAddress: String, completion: @escaping (Result<UInt64, LibraWalletError>) -> Void) {
        let request = libraModuleProvide.request(.accountInfo(sendAddress)) { (result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(DiemAccountMainModel.self)
                    guard json.result != nil else {
                        completion(.failure(LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.walletUnActive)))
                        return
                    }
                    guard let sequence = json.result?.sequence_number else {
                        completion(.failure(LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.parseJsonError)))
                        return
                    }
                    completion(.success(sequence))
                } catch {
                    print("GetDiemSequenceNumber_解析异常\(error.localizedDescription)")
                    completion(.failure(LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.parseJsonError)))
                }
            case let .failure(error):
                guard error.errorCode != -999 else {
                    print("GetDiemSequenceNumber_网络请求已取消")
                    return
                }
                completion(.failure(LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.networkInvalid)))
            }
        }
        self.requests.append(request)
    }
    private func makeDiemTransaction(signature: String, completion: @escaping (Result<Bool, LibraWalletError>) -> Void) {
        let request = libraModuleProvide.request(.sendTransaction(signature)) { (result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(DiemAccountMainModel.self)
                    if json.error == nil {
                        completion(.success(true))
                    } else {
                        print("SendDiemTransaction_状态异常")
                        if let message = json.error?.message, message.isEmpty == false {
                            completion(.failure(LibraWalletError.error(message)))
                        } else {
                            completion(.failure(LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.dataCodeInvalid)))
                        }
                    }
                } catch {
                    print("SendDiemTransaction_解析异常\(error.localizedDescription)")
                    completion(.failure(LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.parseJsonError)))
                }
            case let .failure(error):
                guard error.errorCode != -999 else {
                    print("网络请求已取消")
                    return
                }
                completion(.failure(LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.networkInvalid)))
            }
        }
        self.requests.append(request)
    }
    
}
