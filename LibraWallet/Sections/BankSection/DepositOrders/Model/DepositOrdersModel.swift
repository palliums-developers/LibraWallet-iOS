//
//  DepositOrdersModel.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/8/20.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit
import Moya
struct DepositOrderWithdrawMainDataModel: Codable {
    /// 订单可提取数量
    var available_quantity: UInt64?
    /// 订单币Address
    var token_address: String?
    /// 订单币Module
    var token_module: String?
    /// 订单币Name
    var token_name: String?
    /// 订单展示名字
    var token_show_name: String?
}
struct DepositOrderWithdrawMainModel: Codable {
    var code: Int?
    var message: String?
    var data: DepositOrderWithdrawMainDataModel?
}
struct DepositOrdersMainDataModel: Codable {
    /// 订单可提取数量
    var available_quantity: UInt64?
    /// 订单收益
    var earnings: UInt64?
    /// 订单ID
    var id: String?
    /// 订单币种图片
    var logo: String?
    /// 订单本金
    var principal: UInt64?
    /// 订单收益率
    var rate: Double?
    /// 订单状态
    var status: Int?
    /// 订单币Address
    var token_address: String?
    /// 订单币Name
    var token_name: String?
    /// 订单币种名称
    var currency: String?
    /// 订单展示名字
    var token_show_name: String?
}
struct DepositOrdersMainModel: Codable {
    var code: Int?
    var message: String?
    var data: [DepositOrdersMainDataModel]?
}
class DepositOrdersModel: NSObject {
    private var requests: [Cancellable] = []
    @objc dynamic var dataDic: NSMutableDictionary = [:]
    private var sequenceNumber: UInt64?
    deinit {
        requests.forEach { cancellable in
            cancellable.cancel()
        }
        requests.removeAll()
        print("DepositOrdersModel销毁了")
    }
    func getDepositTransactions(address: String, page: Int, limit: Int, requestStatus: Int) {
        let type = requestStatus == 0 ? "GetBankDepositTransactionsOrigin":"GetBankDepositTransactionsMore"
        let request = mainProvide.request(.depositTransactions(address, page, limit)) {[weak self](result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(DepositOrdersMainModel.self)
                    if json.code == 2000 {
                        guard let models = json.data, models.isEmpty == false else {
                            let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.dataEmpty), type: type)
                            self?.setValue(data, forKey: "dataDic")
                            print("\(type)_状态异常")
                            return
                        }
                        let data = setKVOData(type: type, data: models)
                        self?.setValue(data, forKey: "dataDic")
                    } else {
                        print("\(type)_状态异常")
                        if let message = json.message, message.isEmpty == false {
                            let data = setKVOData(error: LibraWalletError.error(message), type: type)
                            self?.setValue(data, forKey: "dataDic")
                        } else {
                            let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.dataCodeInvalid), type: type)
                            self?.setValue(data, forKey: "dataDic")
                        }
                    }
                } catch {
                    print("\(type)_解析异常\(error.localizedDescription)")
                    let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.parseJsonError), type: type)
                    self?.setValue(data, forKey: "dataDic")
                }
            case let .failure(error):
                guard error.errorCode != -999 else {
                    print("\(type)_网络请求已取消")
                    return
                }
                let data = setKVOData(error: LibraWalletError.WalletRequest(reason: .networkInvalid), type: type)
                self?.setValue(data, forKey: "dataDic")
            }
        }
        self.requests.append(request)
    }
}
// MARK: -获取提款详情
extension DepositOrdersModel {
    func getDepositItemWithdrawDetail(address: String, itemID: String) {
        let request = mainProvide.request(.depositWithdrawDetail(address, itemID)) {[weak self](result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(DepositOrderWithdrawMainModel.self)
                    if json.code == 2000 {
                        guard let model = json.data else {
                            print("GetDepositItemWithdrawDetail_状态异常")
                            let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.dataEmpty), type: "GetDepositItemWithdrawDetail")
                            self?.setValue(data, forKey: "dataDic")
                            return
                        }
                        let data = setKVOData(type: "GetDepositItemWithdrawDetail", data: model)
                        self?.setValue(data, forKey: "dataDic")
                    } else {
                        print("GetDepositItemWithdrawDetail_状态异常")
                        if let message = json.message, message.isEmpty == false {
                            let data = setKVOData(error: LibraWalletError.error(message), type: "GetDepositItemWithdrawDetail")
                            self?.setValue(data, forKey: "dataDic")
                        } else {
                            let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.dataCodeInvalid), type: "GetDepositItemWithdrawDetail")
                            self?.setValue(data, forKey: "dataDic")
                        }
                    }
                } catch {
                    print("GetDepositItemWithdrawDetail解析异常\(error.localizedDescription)")
                    let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.parseJsonError), type: "GetDepositItemWithdrawDetail")
                    self?.setValue(data, forKey: "dataDic")
                }
            case let .failure(error):
                guard error.errorCode != -999 else {
                    print("GetDepositItemWithdrawDetail网络请求已取消")
                    return
                }
                let data = setKVOData(error: LibraWalletError.WalletRequest(reason: .networkInvalid), type: "GetDepositItemWithdrawDetail")
                self?.setValue(data, forKey: "dataDic")
            }
        }
        self.requests.append(request)
    }
}
// MARK: - 提款
extension DepositOrdersModel {
    func sendWithdrawTransaction(sendAddress: String, amount: UInt64, fee: UInt64, mnemonic: [String], module: String, feeModule: String) {
        let semaphore = DispatchSemaphore.init(value: 1)
        let queue = DispatchQueue.init(label: "SendQueue")
        queue.async {
            semaphore.wait()
            self.getViolasSequenceNumber(sendAddress: sendAddress, semaphore: semaphore)
        }
        queue.async {
            semaphore.wait()
            do {
                let signature = try ViolasManager.getBankRedeemTransactionHex(sendAddress: sendAddress,
                                                                            mnemonic: mnemonic,
                                                                            feeModule: feeModule,
                                                                            fee: fee,
                                                                            sequenceNumber: self.sequenceNumber ?? 0,
                                                                            module: module,
                                                                            amount: amount)
                self.makeViolasTransaction(signature: signature, type: "SendViolasBankWithdrawTransaction")
            } catch {
                print(error.localizedDescription)
                DispatchQueue.main.async(execute: {
                    let data = setKVOData(error: LibraWalletError.error(error.localizedDescription), type: "SendViolasBankWithdrawTransaction")
                    self.setValue(data, forKey: "dataDic")
                })
            }
            semaphore.signal()
        }
    }
    private func getViolasSequenceNumber(sendAddress: String, semaphore: DispatchSemaphore) {
        let request = mainProvide.request(.GetViolasAccountInfo(sendAddress)) {[weak self](result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(BalanceViolasMainModel.self)
                    if json.error == nil {
                        self?.sequenceNumber = json.result?.sequence_number ?? 0
                        semaphore.signal()
                    } else {
                        print("GetViolasSequenceNumber_状态异常")
                        DispatchQueue.main.async(execute: {
                            if let message = json.error?.message, message.isEmpty == false {
                                let data = setKVOData(error: LibraWalletError.error(message), type: "GetViolasSequenceNumber")
                                self?.setValue(data, forKey: "dataDic")
                            } else {
                                let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.dataCodeInvalid), type: "SendLibraTransaction")
                                self?.setValue(data, forKey: "dataDic")
                            }
                        })
                    }
                } catch {
                    print("GetViolasSequenceNumber_解析异常\(error.localizedDescription)")
                    DispatchQueue.main.async(execute: {
                        let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.parseJsonError), type: "GetViolasSequenceNumber")
                        self?.setValue(data, forKey: "dataDic")
                    })
                }
            case let .failure(error):
                guard error.errorCode != -999 else {
                    print("GetViolasSequenceNumber_网络请求已取消")
                    return
                }
                DispatchQueue.main.async(execute: {
                    let data = setKVOData(error: LibraWalletError.WalletRequest(reason: .networkInvalid), type: "GetViolasSequenceNumber")
                    self?.setValue(data, forKey: "dataDic")
                })
            }
        }
        self.requests.append(request)
    }
    private func makeViolasTransaction(signature: String, type: String, semaphore: DispatchSemaphore? = nil) {
        let request = mainProvide.request(.SendViolasTransaction(signature)) {[weak self](result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(LibraTransferMainModel.self)
                    if json.result == nil {
                        DispatchQueue.main.async(execute: {
                            if let sema = semaphore {
                                sema.signal()
                            } else {
                                let data = setKVOData(type: type)
                                self?.setValue(data, forKey: "dataDic")
                            }
                        })
                    } else {
                        print("\(type)_状态异常")
                        DispatchQueue.main.async(execute: {
                            if let message = json.error?.message, message.isEmpty == false {
                                let data = setKVOData(error: LibraWalletError.error(message), type: type)
                                self?.setValue(data, forKey: "dataDic")
                            } else {
                                let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.dataCodeInvalid), type: type)
                                self?.setValue(data, forKey: "dataDic")
                            }
                        })
                    }
                } catch {
                    print("\(type)_解析异常\(error.localizedDescription)")
                    DispatchQueue.main.async(execute: {
                        let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.parseJsonError), type: type)
                        self?.setValue(data, forKey: "dataDic")
                    })
                }
            case let .failure(error):
                guard error.errorCode != -999 else {
                    print("\(type)_网络请求已取消")
                    return
                }
                DispatchQueue.main.async(execute: {
                    let data = setKVOData(error: LibraWalletError.WalletRequest(reason: .networkInvalid), type: type)
                    self?.setValue(data, forKey: "dataDic")
                })
                
            }
        }
        self.requests.append(request)
    }
}
