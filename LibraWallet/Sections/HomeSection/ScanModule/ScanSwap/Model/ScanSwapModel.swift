//
//  ScanSwapModel.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/8/6.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit
import Moya

class ScanSwapModel: NSObject {
    private var requests: [Cancellable] = []
    @objc dynamic var dataDic: NSMutableDictionary = [:]
    private var sequenceNumber: UInt64?
    func sendSwapViolasTransaction(model: WCRawTransaction,  mnemonic: [String], module: String) {
        let semaphore = DispatchSemaphore.init(value: 1)
        let queue = DispatchQueue.init(label: "SendQueue")
        queue.async {
            semaphore.wait()
            self.getViolasSequenceNumber(sendAddress: model.from ?? "", semaphore: semaphore)
        }
        queue.async {
            semaphore.wait()
            do {
                let (_, module1) = ViolasManager.readTypeTags(data: Data.init(hex: model.payload?.tyArgs?[0] ?? "") ?? Data(), typeTagCount: 1)
                
                let (_, module2) = ViolasManager.readTypeTags(data: Data.init(hex: model.payload?.tyArgs?[1] ?? "") ?? Data(), typeTagCount: 1)
                
                let path = Data.init(Array<UInt8>(hex: model.payload?.args?[3].value ?? ""))
                
                let signature = try ViolasManager.getMarketSwapTransactionHex(sendAddress: model.from ?? "",
                                                                              mnemonic: mnemonic,
                                                                              feeModule: model.gasCurrencyCode ?? "LBR",
                                                                              fee: model.gasUnitPrice ?? 0,
                                                                              sequenceNumber: self.sequenceNumber ?? 0,
                                                                              inputAmount: NSDecimalNumber.init(string: model.payload?.args?[1].value ?? "0").uint64Value,
                                                                              outputAmountMin: NSDecimalNumber.init(string: model.payload?.args?[2].value ?? "0").multiplying(by: NSDecimalNumber.init(value: 0.99)).uint64Value,
                                                                              path: path.bytes,
                                                                              inputModule: module1,
                                                                              outputModule: module2)
                self.makeViolasTransaction(signature: signature)
            } catch {
                print(error.localizedDescription)
                DispatchQueue.main.async(execute: {
                    let data = setKVOData(error: LibraWalletError.error(error.localizedDescription), type: "SendViolasTransaction")
                    self.setValue(data, forKey: "dataDic")
                })
            }
            semaphore.signal()
        }
    }
    private func getViolasSequenceNumber(sendAddress: String, semaphore: DispatchSemaphore) {
        let request = violasModuleProvide.request(.accountInfo(sendAddress)) {[weak self](result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(BalanceViolasMainModel.self)
                    if json.result != nil {
                        self?.sequenceNumber = json.result?.sequence_number ?? 0
                        semaphore.signal()
                    } else {
                        print("GetViolasSequenceNumber_状态异常")
                        DispatchQueue.main.async(execute: {
                            if let message = json.error?.message, message.isEmpty == false {
                                let data = setKVOData(error: LibraWalletError.error(message), type: "GetViolasSequenceNumber")
                                self?.setValue(data, forKey: "dataDic")
                            } else {
                                let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.dataCodeInvalid), type: "GetViolasSequenceNumber")
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
    private func makeViolasTransaction(signature: String) {
        let request = violasModuleProvide.request(.sendTransaction(signature)) {[weak self](result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(LibraTransferMainModel.self)
                    if json.result == nil {
                        DispatchQueue.main.async(execute: {
                            let data = setKVOData(type: "SendViolasTransaction")
                            self?.setValue(data, forKey: "dataDic")
                        })
                    } else {
                        print("SendViolasTransaction_状态异常")
                        DispatchQueue.main.async(execute: {
                            if let message = json.error?.message, message.isEmpty == false {
                                let data = setKVOData(error: LibraWalletError.error(message), type: "SendViolasTransaction")
                                self?.setValue(data, forKey: "dataDic")
                            } else {
                                let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.dataCodeInvalid), type: "SendViolasTransaction")
                                self?.setValue(data, forKey: "dataDic")
                            }
                        })
                    }
                } catch {
                    print("SendViolasTransaction_解析异常\(error.localizedDescription)")
                    DispatchQueue.main.async(execute: {
                        let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.parseJsonError), type: "SendViolasTransaction")
                        self?.setValue(data, forKey: "dataDic")
                    })
                }
            case let .failure(error):
                guard error.errorCode != -999 else {
                    print("SendViolasTransaction_网络请求已取消")
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
        print("ScanPublishModel销毁了")
    }
}
extension ScanSwapModel {
    func sendAddLiquidityViolasTransaction(model: WCRawTransaction, mnemonic: [String], feeModule: String) {
        let semaphore = DispatchSemaphore.init(value: 1)
        let queue = DispatchQueue.init(label: "SendQueue")
        queue.async {
            semaphore.wait()
            self.getViolasSequenceNumber(sendAddress: model.from ?? "", semaphore: semaphore)
        }
        queue.async {
            semaphore.wait()
            do {
                let (_, module1) = ViolasManager.readTypeTags(data: Data.init(hex: model.payload?.tyArgs?[0] ?? "") ?? Data(), typeTagCount: 1)
                
                let (_, module2) = ViolasManager.readTypeTags(data: Data.init(hex: model.payload?.tyArgs?[1] ?? "") ?? Data(), typeTagCount: 1)
                
                let signature = try ViolasManager.getMarketAddLiquidityTransactionHex(sendAddress: model.from ?? "",
                                                                                      mnemonic: mnemonic,
                                                                                      feeModule: module1,
                                                                                      fee: 0,
                                                                                      sequenceNumber: self.sequenceNumber ?? 0,
                                                                                      desiredAmountA: NSDecimalNumber.init(string: model.payload?.args?[0].value ?? "0").uint64Value,
                                                                                      desiredAmountB: NSDecimalNumber.init(string: model.payload?.args?[1].value ?? "0").uint64Value,
                                                                                      minAmountA: NSDecimalNumber.init(string: model.payload?.args?[2].value ?? "0").multiplying(by: NSDecimalNumber.init(value: 0.99)).uint64Value,
                                                                                      minAmountB: NSDecimalNumber.init(string: model.payload?.args?[3].value ?? "0").multiplying(by: NSDecimalNumber.init(value: 0.99)).uint64Value,
                                                                                      inputModuleA: module1,
                                                                                      inputModuleB: module2)
                self.makeViolasTransaction(signature: signature)
            } catch {
                print(error.localizedDescription)
                DispatchQueue.main.async(execute: {
                    let data = setKVOData(error: LibraWalletError.error(error.localizedDescription), type: "SendViolasTransaction")
                    self.setValue(data, forKey: "dataDic")
                })
            }
            semaphore.signal()
        }
    }
    func sendRemoveLiquidityViolasTransaction(model: WCRawTransaction, mnemonic: [String], feeModule: String) {
        let semaphore = DispatchSemaphore.init(value: 1)
        let queue = DispatchQueue.init(label: "SendQueue")
        queue.async {
            semaphore.wait()
            self.getViolasSequenceNumber(sendAddress: model.from ?? "", semaphore: semaphore)
        }
        queue.async {
            semaphore.wait()
            do {
                let (_, module1) = ViolasManager.readTypeTags(data: Data.init(hex: model.payload?.tyArgs?[0] ?? "") ?? Data(), typeTagCount: 1)
                
                let (_, module2) = ViolasManager.readTypeTags(data: Data.init(hex: model.payload?.tyArgs?[1] ?? "") ?? Data(), typeTagCount: 1)
                
                let signature = try ViolasManager.getMarketRemoveLiquidityTransactionHex(sendAddress: model.from ?? "",
                                                                                         mnemonic: mnemonic,
                                                                                         feeModule: module1,
                                                                                         fee: 0,
                                                                                         sequenceNumber: self.sequenceNumber ?? 0,
                                                                                         liquidity: NSDecimalNumber.init(string: model.payload?.args?[0].value ?? "0").uint64Value,
                                                                                         minAmountA: NSDecimalNumber.init(string: model.payload?.args?[1].value ?? "0").multiplying(by: NSDecimalNumber.init(value: 0.99)).uint64Value,
                                                                                         minAmountB: NSDecimalNumber.init(string: model.payload?.args?[2].value ?? "0").multiplying(by: NSDecimalNumber.init(value: 0.99)).uint64Value,
                                                                                         inputModuleA: module1,
                                                                                         inputModuleB: module2)
                self.makeViolasTransaction(signature: signature)
            } catch {
                print(error.localizedDescription)
                DispatchQueue.main.async(execute: {
                    let data = setKVOData(error: LibraWalletError.error(error.localizedDescription), type: "SendViolasTransaction")
                    self.setValue(data, forKey: "dataDic")
                })
            }
            semaphore.signal()
        }
    }
}
