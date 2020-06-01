//
//  OrderProcessingModel.swift
//  LibraWallet
//
//  Created by palliums on 2019/12/10.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit
import Moya
struct AllProcessingOrderMainModel: Codable {
    var orders: [MarketOrderDataModel]?
}
struct CancelOrderMainModel: Codable {
    var code: Int?
    var message: String?
}
class OrderProcessingModel: NSObject {
    private var requests: [Cancellable] = []
    @objc var dataDic: NSMutableDictionary = [:]
    private var sequenceNumber: Int?
    private var orderModels: [MarketOrderDataModel]?
    private var priceModels: [MarketSupportCoinDataModel]?
    func getAllProcessingOrders(address: String, version: String) {
        let type = version.isEmpty == true ? "GetAllProcessingOrderOrigin":"GetAllProcessingOrderMore"
        let request = mainProvide.request(.GetAllProcessingOrder(address, version)) {[weak self](result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(AllProcessingOrderMainModel.self)
                    guard json.orders?.isEmpty == false else {
                        let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.dataEmpty), type: type)
                        self?.setValue(data, forKey: "dataDic")
                        return
                    }
                    let data = setKVOData(type: type, data: json.orders)
                    self?.setValue(data, forKey: "dataDic")
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
    func cancelTransaction(sendAddress: String, fee: Double, mnemonic: [String], contact: String, version: String, tokenIndex: String) {
        let semaphore = DispatchSemaphore.init(value: 1)
        let queue = DispatchQueue.init(label: "SendQueue")
        var signature = ""
        queue.async {
            self.getViolasSequenceNumber(sendAddress: sendAddress, semaphore: semaphore)
        }
        queue.async {
            semaphore.wait()
            do {
                signature = try ViolasManager.getMarketExchangeCancelTransactionHex(sendAddress: sendAddress,
                                                                                    fee: fee,
                                                                                    mnemonic: mnemonic,
                                                                                    contact: contact,
                                                                                    version: version,
                                                                                    sequenceNumber: self.sequenceNumber!,
                                                                                    tokenIndex: tokenIndex)
    //                self.makeViolasTransaction(signature: signature)
                self.submitCancelOrder(signature: signature, version: version, semaphore: semaphore)
            } catch {
                print(error.localizedDescription)
                DispatchQueue.main.async(execute: {
                    let data = setKVOData(error: LibraWalletError.error(error.localizedDescription), type: "SendViolasTransaction")
                    self.setValue(data, forKey: "dataDic")
                })
            }
    //            semaphore.signal()
        }
        queue.async {
            semaphore.wait()
            self.makeViolasTransaction(signature: signature)
            semaphore.signal()
        }
        
    }
    private func submitCancelOrder(signature: String, version: String, semaphore: DispatchSemaphore) {
        let request = mainProvide.request(.CancelOrder(signature, version)) {[weak self](result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(CancelOrderMainModel.self)
                    if json.code == 2000 {
                        semaphore.signal()
                    } else {
                        if let message = json.message, message.isEmpty == false {
                            DispatchQueue.main.async(execute: {
                                let data = setKVOData(error: LibraWalletError.error(message), type: "SubmitCancelOrder")
                                self?.setValue(data, forKey: "dataDic")
                            })
                        } else {
                            DispatchQueue.main.async(execute: {
                                let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.dataCodeInvalid), type: "SubmitCancelOrder")
                                self?.setValue(data, forKey: "dataDic")
                            })
                        }
                    }
                } catch {
                    print("SubmitCancelOrder_解析异常\(error.localizedDescription)")
                    DispatchQueue.main.async(execute: {
                        let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.parseJsonError), type: "SubmitCancelOrder")
                        self?.setValue(data, forKey: "dataDic")
                    })
                }
            case let .failure(error):
                guard error.errorCode != -999 else {
                    print("SubmitCancelOrder_网络请求已取消")
                    return
                }
                DispatchQueue.main.async(execute: {
                    let data = setKVOData(error: LibraWalletError.WalletRequest(reason: .networkInvalid), type: "SubmitCancelOrder")
                    self?.setValue(data, forKey: "dataDic")
                })
            }
        }
        self.requests.append(request)
    }
    func getViolasSequenceNumber(sendAddress: String, semaphore: DispatchSemaphore) {
        semaphore.wait()
        let request = mainProvide.request(.GetViolasAccountSequenceNumber(sendAddress)) {[weak self](result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(ViolaSequenceNumberMainModel.self)
                    if json.code == 2000 {
                        self?.sequenceNumber = json.data
                        semaphore.signal()
                    } else {
                        print("GetViolasSequenceNumber_状态异常")
                        if let message = json.message, message.isEmpty == false {
                            DispatchQueue.main.async(execute: {
                                let data = setKVOData(error: LibraWalletError.error(message), type: "GetViolasSequenceNumber")
                                self?.setValue(data, forKey: "dataDic")
                            })
                        } else {
                            DispatchQueue.main.async(execute: {
                                let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.dataCodeInvalid), type: "GetViolasSequenceNumber")
                                self?.setValue(data, forKey: "dataDic")
                            })
                        }
                    }
                } catch {
                    print("解析异常\(error.localizedDescription)")
                    DispatchQueue.main.async(execute: {
                        let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.parseJsonError), type: "GetViolasSequenceNumber")
                        self?.setValue(data, forKey: "dataDic")
                    })
                    
                }
            case let .failure(error):
                guard error.errorCode != -999 else {
                    print("网络请求已取消")
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
    private func makeViolasTransaction(signature: String) {
        let request = mainProvide.request(.SendViolasTransaction(signature)) {[weak self](result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(ViolaSendTransactionMainModel.self)
                    if json.code == 2000 {
                        DispatchQueue.main.async(execute: {
                            let data = setKVOData(type: "SendViolasTransaction")
                            self?.setValue(data, forKey: "dataDic")
                        })
                    } else {
                        print("SendViolasTransaction_状态异常")
                        DispatchQueue.main.async(execute: {
                            if let message = json.message, message.isEmpty == false {
                                let data = setKVOData(error: LibraWalletError.error(message), type: "SendViolasTransaction")
                                self?.setValue(data, forKey: "dataDic")
                            } else {
                                let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.dataCodeInvalid), type: "SendViolasTransaction")
                                self?.setValue(data, forKey: "dataDic")
                            }
                        })
                    }
                } catch {
                    print("解析异常\(error.localizedDescription)")
                    DispatchQueue.main.async(execute: {
                        let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.parseJsonError), type: "SendViolasTransaction")
                        self?.setValue(data, forKey: "dataDic")
                    })
                }
            case let .failure(error):
                guard error.errorCode != -999 else {
                    print("网络请求已取消")
                    return
                }
                DispatchQueue.main.async(execute: {
                    let data = setKVOData(error: LibraWalletError.WalletRequest(reason: .networkInvalid), type: "SendViolasTransaction")
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
        print("OrderProcessingModel销毁了")
    }
}
