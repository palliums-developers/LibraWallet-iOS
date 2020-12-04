//
//  YieldFarmingModel.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/12/4.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit
import Moya

class YieldFarmingModel: NSObject {
    private var requests: [Cancellable] = []
    @objc dynamic var dataDic: NSMutableDictionary = [:]
    private var sequenceNumber: UInt64?
    deinit {
        requests.forEach { cancellable in
            cancellable.cancel()
        }
        requests.removeAll()
        print("YieldFarmingModel销毁了")
    }
}
// MARK: 开启ViolasToken
extension YieldFarmingModel {
//    func publishToken(sendAddress: String, mnemonic: [String], modules: [String]) {
//        let semaphore = DispatchSemaphore.init(value: 1)
//        let queue = DispatchQueue.init(label: "SendQueue")
//        for i in 0..<modules.count {
//            queue.async {
//                semaphore.wait()
//                self.getAccountSequenceNumber(sendAddress: sendAddress, semaphore: semaphore)
//            }
//            queue.async {
//                semaphore.wait()
//                do {
//                    let signature = try ViolasManager.getPublishTokenTransactionHex(mnemonic: mnemonic,
//                                                                                    fee: 0,
//                                                                                    sequenceNumber: self.sequenceNumber ?? 0,
//                                                                                    inputModule: modules[i])
//
//                    self.makeViolasTransaction(signature: signature, next: (i == (modules.count - 1) ? false:true), type: "PublishToken", semaphore: semaphore)
//                } catch {
//                    print(error.localizedDescription)
//                    DispatchQueue.main.async(execute: {
//                        let data = setKVOData(error: LibraWalletError.error(error.localizedDescription), type: "PublishToken")
//                        self.setValue(data, forKey: "dataDic")
//                    })
//                    return
//                }
//            }
//        }
//    }
//    private func getAccountSequenceNumber(sendAddress: String, semaphore: DispatchSemaphore) {
//        let request = mainProvide.request(.getAccountSequenceNumber(sendAddress)) {[weak self](result) in
//            switch  result {
//            case let .success(response):
//                do {
//                    let json = try response.map(AccountSequenceNumberMainModel.self)
//                    if json.code == 2000 {
//                        self?.sequenceNumber = json.data?.seqnum ?? 0
//                        semaphore.signal()
//                    } else {
//                        print("GetAccountSequenceNumber_状态异常")
//                        DispatchQueue.main.async(execute: {
//                            if let message = json.message, message.isEmpty == false {
//                                let data = setKVOData(error: LibraWalletError.error(message), type: "GetAccountSequenceNumber")
//                                self?.setValue(data, forKey: "dataDic")
//                            } else {
//                                let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.dataCodeInvalid), type: "GetAccountSequenceNumber")
//                                self?.setValue(data, forKey: "dataDic")
//                            }
//                        })
//                    }
//                } catch {
//                    print("GetAccountSequenceNumber_解析异常\(error.localizedDescription)")
//                    DispatchQueue.main.async(execute: {
//                        let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.parseJsonError), type: "GetAccountSequenceNumber")
//                        self?.setValue(data, forKey: "dataDic")
//                    })
//                }
//            case let .failure(error):
//                guard error.errorCode != -999 else {
//                    print("GetAccountSequenceNumber_网络请求已取消")
//                    return
//                }
//                DispatchQueue.main.async(execute: {
//                    let data = setKVOData(error: LibraWalletError.WalletRequest(reason: .networkInvalid), type: "GetAccountSequenceNumber")
//                    self?.setValue(data, forKey: "dataDic")
//                })
//            }
//        }
//        self.requests.append(request)
//    }
//    private func makeViolasTransaction(signature: String, next: Bool, type: String, semaphore: DispatchSemaphore?) {
//        let request = mainProvide.request(.SendTransaction(signature)) {[weak self](result) in
//            switch  result {
//            case let .success(response):
//                do {
//                    let json = try response.map(AccountSendTransactionMainModel.self)
//                    if json.code == 2000 {
//                        if next == false {
//                            DispatchQueue.main.async(execute: {
//                                let data = setKVOData(type: type)
//                                self?.setValue(data, forKey: "dataDic")
//                            })
//                            if let se = semaphore {
//                                se.signal()
//                            }
//                        } else {
//                            if let se = semaphore {
//                                se.signal()
//                            }
//                        }
//                    } else {
//                        print("\(type)_状态异常")
//                        DispatchQueue.main.async(execute: {
//                            if let message = json.message, message.isEmpty == false {
//                                let data = setKVOData(error: LibraWalletError.error(message), type: type)
//                                self?.setValue(data, forKey: "dataDic")
//                            } else {
//                                let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.dataCodeInvalid), type: type)
//                                self?.setValue(data, forKey: "dataDic")
//                            }
//                        })
//                    }
//                } catch {
//                    print("\(type)_解析异常\(error.localizedDescription)")
//                    DispatchQueue.main.async(execute: {
//                        let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.parseJsonError), type: type)
//                        self?.setValue(data, forKey: "dataDic")
//                    })
//                }
//            case let .failure(error):
//                guard error.errorCode != -999 else {
//                    print("\(type)_网络请求已取消")
//                    return
//                }
//                DispatchQueue.main.async(execute: {
//                    let data = setKVOData(error: LibraWalletError.WalletRequest(reason: .networkInvalid), type: type)
//                    self?.setValue(data, forKey: "dataDic")
//                })
//
//            }
//        }
//        self.requests.append(request)
//    }
}
extension YieldFarmingModel {
//    func sendTransaction(sendAddress: String, receiveAddress: String, amount: UInt64, fee: UInt64, mnemonic: [String], module: String) {
//        let semaphore = DispatchSemaphore.init(value: 1)
//        let queue = DispatchQueue.init(label: "SendQueue")
//        queue.async {
//            semaphore.wait()
//            self.getAccountSequenceNumber(sendAddress: sendAddress, semaphore: semaphore)
//        }
//        queue.async {
//            semaphore.wait()
//            do {
//                let signature = try ViolasManager.getDefaultTransactionHex(sendAddress: sendAddress,
//                                                                           receiveAddress: receiveAddress,
//                                                                           amount: amount,
//                                                                           fee: fee,
//                                                                           mnemonic: mnemonic,
//                                                                           sequenceNumber: self.sequenceNumber ?? 0,
//                                                                           module: module)
//                self.makeViolasTransaction(signature: signature,
//                                           next: false,
//                                           type: "SendPayTokenTransaction",
//                                           semaphore: nil)
//            } catch {
//                print(error.localizedDescription)
//                DispatchQueue.main.async(execute: {
//                    let data = setKVOData(error: LibraWalletError.error(error.localizedDescription), type: "SendPayTokenTransaction")
//                    self.setValue(data, forKey: "dataDic")
//                })
//            }
//            semaphore.signal()
//        }
//    }
}
