//
//  YieldFarmingModel.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/12/4.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit
import Moya

struct ViolasSequenceDataModel: Codable {
    var seqnum: UInt64?
}
struct ViolasSequenceMainDataModel: Codable {
    var code: Int?
    var data: ViolasSequenceDataModel?
    var message: String?
}

class YieldFarmingModel: NSObject {
    private var requests: [Cancellable] = []
    @objc dynamic var dataDic: NSMutableDictionary = [:]
    private var sequenceNumber: UInt64?
    private var maxGasAmount: UInt64 = 600
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
    func sendBankExtractProfit(sendAddress: String, mnemonic: [String]) {
        let semaphore = DispatchSemaphore.init(value: 1)
        let queue = DispatchQueue.init(label: "SendQueue")
        queue.async {
            semaphore.wait()
            self.getAccountSequenceNumber(sendAddress: sendAddress, semaphore: semaphore)
        }
        queue.async {
            semaphore.wait()
            do {
                let signature = try ViolasManager.getBankExtractProfitTransactionHex(sendAddress: sendAddress,
                                                                                     mnemonic: mnemonic,
                                                                                     feeModule: "VLS",
                                                                                     maxGasAmount: self.maxGasAmount,
                                                                                     maxGasUnitPrice: ViolasManager.handleMaxGasUnitPrice(maxGasAmount: self.maxGasAmount),
                                                                                     sequenceNumber: self.sequenceNumber!)
                
                self.makeViolasTransaction(signature: signature, type: "SendBankExtractTransaction", semaphore: semaphore)
            } catch {
                print(error.localizedDescription)
                DispatchQueue.main.async(execute: {
                    let data = setKVOData(error: LibraWalletError.error(error.localizedDescription), type: "SendBankExtractTransaction")
                    self.setValue(data, forKey: "dataDic")
                })
                return
            }
            semaphore.signal()
        }
    }
    private func getAccountSequenceNumber(sendAddress: String, semaphore: DispatchSemaphore) {
        let request = violasModuleProvide.request(.accountInfo(sendAddress)) {[weak self](result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(ViolasAccountMainModel.self)
                    if json.error == nil {
                        self?.sequenceNumber = json.result?.sequence_number ?? 0
                        self?.maxGasAmount = ViolasManager.handleMaxGasAmount(balances: json.result?.balances ?? [ViolasBalanceDataModel.init(amount: 0, currency: "VLS")])
                        semaphore.signal()
                    } else {
                        print("GetAccountSequenceNumber_状态异常")
                        DispatchQueue.main.async(execute: {
                            if let message = json.error?.message, message.isEmpty == false {
                                let data = setKVOData(error: LibraWalletError.error(message), type: "GetAccountSequenceNumber")
                                self?.setValue(data, forKey: "dataDic")
                            } else {
                                let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.dataCodeInvalid), type: "GetAccountSequenceNumber")
                                self?.setValue(data, forKey: "dataDic")
                            }
                        })
                    }
                } catch {
                    print("GetAccountSequenceNumber_解析异常\(error.localizedDescription)")
                    DispatchQueue.main.async(execute: {
                        let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.parseJsonError), type: "GetAccountSequenceNumber")
                        self?.setValue(data, forKey: "dataDic")
                    })
                }
            case let .failure(error):
                guard error.errorCode != -999 else {
                    print("GetAccountSequenceNumber_网络请求已取消")
                    return
                }
                DispatchQueue.main.async(execute: {
                    let data = setKVOData(error: LibraWalletError.WalletRequest(reason: .networkInvalid), type: "GetAccountSequenceNumber")
                    self?.setValue(data, forKey: "dataDic")
                })
            }
        }
        self.requests.append(request)
    }
    private func makeViolasTransaction(signature: String, type: String, semaphore: DispatchSemaphore?) {
        let request = violasModuleProvide.request(.sendTransaction(signature)) {[weak self](result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(LibraTransferMainModel.self)
                    if json.error == nil {
                       DispatchQueue.main.async(execute: {
                           let data = setKVOData(type: type)
                           self?.setValue(data, forKey: "dataDic")
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
extension YieldFarmingModel {
    func sendMarketExtractProfit(sendAddress: String, mnemonic: [String]) {
        let semaphore = DispatchSemaphore.init(value: 1)
        let queue = DispatchQueue.init(label: "SendQueue")
        queue.async {
            semaphore.wait()
            self.getAccountSequenceNumber(sendAddress: sendAddress, semaphore: semaphore)
        }
        queue.async {
            semaphore.wait()
            do {
                let signature = try ViolasManager.getMarketExtractProfitTransactionHex(sendAddress: sendAddress,
                                                                                       mnemonic: mnemonic,
                                                                                       feeModule: "VLS",
                                                                                       maxGasAmount: self.maxGasAmount,
                                                                                       maxGasUnitPrice: ViolasManager.handleMaxGasUnitPrice(maxGasAmount: self.maxGasAmount),
                                                                                       sequenceNumber: self.sequenceNumber!)
                
                self.makeViolasTransaction(signature: signature, type: "SendMarketExtractTransaction", semaphore: semaphore)
            } catch {
                print(error.localizedDescription)
                DispatchQueue.main.async(execute: {
                    let data = setKVOData(error: LibraWalletError.error(error.localizedDescription), type: "SendMarketExtractTransaction")
                    self.setValue(data, forKey: "dataDic")
                })
                return
            }
            semaphore.signal()
        }
    }
}
