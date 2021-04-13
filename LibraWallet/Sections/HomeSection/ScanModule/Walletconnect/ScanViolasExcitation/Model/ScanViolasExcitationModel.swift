//
//  ScanViolasExcitationModel.swift
//  LibraWallet
//
//  Created by wangyingdong on 2021/4/13.
//  Copyright © 2021 palliums. All rights reserved.
//

import UIKit
import Moya

class ScanViolasExcitationModel: NSObject {
    private var requests: [Cancellable] = []
    private var maxGasAmount: UInt64 = 600
    deinit {
        requests.forEach { cancellable in
            cancellable.cancel()
        }
        requests.removeAll()
        print("ScanViolasExcitationModel销毁了")
    }
}
// MARK: 提取数字银行激励
extension ScanViolasExcitationModel {
    func sendBankExtractProfit(sendAddress: String, mnemonic: [String], completion: @escaping (Result<Bool, LibraWalletError>) -> Void) {
        let semaphore = DispatchSemaphore.init(value: 1)
        let queue = DispatchQueue.init(label: "SendQueue")
        var sequenceNumber: UInt64?
        queue.async {
            semaphore.wait()
            self.getViolasSequenceNumber(sendAddress: sendAddress) { (result) in
                switch result {
                case let .success(sequence):
                    sequenceNumber = sequence
                    semaphore.signal()
                case let .failure(error):
                    DispatchQueue.main.async(execute: {
                        completion(.failure(error))
                    })
                }
            }
        }
        queue.async {
            semaphore.wait()
            do {
                let signature = try ViolasManager.getBankExtractProfitTransactionHex(sendAddress: sendAddress,
                                                                                     mnemonic: mnemonic,
                                                                                     feeModule: "VLS",
                                                                                     maxGasAmount: self.maxGasAmount,
                                                                                     maxGasUnitPrice: ViolasManager.handleMaxGasUnitPrice(maxGasAmount: self.maxGasAmount),
                                                                                     sequenceNumber: sequenceNumber!)
                self.makeViolasTransaction(signature: signature, type: "SendBankExtractTransaction") { (result) in
                    switch result {
                    case .success(_):
                        DispatchQueue.main.async(execute: {
                            completion(.success(true))
                        })
                    case let .failure(error):
                        DispatchQueue.main.async(execute: {
                            completion(.failure(error))
                        })
                    }
                }
            } catch {
                print(error.localizedDescription)
                DispatchQueue.main.async(execute: {
                    completion(.failure(LibraWalletError.error(error.localizedDescription)))
                })
            }
            semaphore.signal()
        }
    }

}
// MARK: 提取资金池激励
extension ScanViolasExcitationModel {
    func sendMarketExtractProfit(sendAddress: String, mnemonic: [String], completion: @escaping (Result<Bool, LibraWalletError>) -> Void) {
        let semaphore = DispatchSemaphore.init(value: 1)
        let queue = DispatchQueue.init(label: "SendQueue")
        var sequenceNumber: UInt64?
        queue.async {
            semaphore.wait()
            self.getViolasSequenceNumber(sendAddress: sendAddress) { (result) in
                switch result {
                case let .success(sequence):
                    sequenceNumber = sequence
                    semaphore.signal()
                case let .failure(error):
                    DispatchQueue.main.async(execute: {
                        completion(.failure(error))
                    })
                }
            }
        }
        queue.async {
            semaphore.wait()
            do {
                let signature = try ViolasManager.getMarketExtractProfitTransactionHex(sendAddress: sendAddress,
                                                                                       mnemonic: mnemonic,
                                                                                       feeModule: "VLS",
                                                                                       maxGasAmount: self.maxGasAmount,
                                                                                       maxGasUnitPrice: ViolasManager.handleMaxGasUnitPrice(maxGasAmount: self.maxGasAmount),
                                                                                       sequenceNumber: sequenceNumber!)
                self.makeViolasTransaction(signature: signature, type: "SendMarketExtractTransaction") { (result) in
                    switch result {
                    case .success(_):
                        DispatchQueue.main.async(execute: {
                            completion(.success(true))
                        })
                    case let .failure(error):
                        DispatchQueue.main.async(execute: {
                            completion(.failure(error))
                        })
                    }
                }
            } catch {
                print(error.localizedDescription)
                DispatchQueue.main.async(execute: {
                    completion(.failure(LibraWalletError.error(error.localizedDescription)))
                })
            }
            semaphore.signal()
        }
    }
}
// MARK: 通用模块
extension ScanViolasExcitationModel {
    private func getViolasSequenceNumber(sendAddress: String, completion: @escaping (Result<UInt64, LibraWalletError>) -> Void) {
        let request = violasModuleProvide.request(.accountInfo(sendAddress)) {[weak self](result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(ViolasAccountMainModel.self)
                    if json.error == nil {
                        self?.maxGasAmount = ViolasManager.handleMaxGasAmount(balances: json.result?.balances ?? [ViolasBalanceDataModel.init(amount: 0, currency: "VLS")])
                        completion(.success(json.result?.sequence_number ?? 0))
                    } else {
                        print("GetViolasSequenceNumber_状态异常")
                        if let message = json.error?.message, message.isEmpty == false {
                            completion(.failure(LibraWalletError.error(message)))
                        } else {
                            completion(.failure(LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.dataCodeInvalid)))
                        }
                    }
                } catch {
                    print("GetViolasSequenceNumber_解析异常\(error.localizedDescription)")
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
    private func makeViolasTransaction(signature: String, type: String, semaphore: DispatchSemaphore? = nil, completion: @escaping (Result<Bool, LibraWalletError>) -> Void) {
        let request = violasModuleProvide.request(.sendTransaction(signature)) { (result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(ViolasAccountMainModel.self)
                    if json.error == nil {
                        completion(.success(true))
                    } else {
                        print("\(type)_状态异常")
                        if let message = json.error?.message, message.isEmpty == false {
                            completion(.failure(LibraWalletError.error(message)))
                        } else {
                            completion(.failure(LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.dataCodeInvalid)))
                        }
                    }
                } catch {
                    print("\(type)_解析异常\(error.localizedDescription)")
                    completion(.failure(LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.parseJsonError)))
                }
            case let .failure(error):
                guard error.errorCode != -999 else {
                    print("\(type)_网络请求已取消")
                    return
                }
                completion(.failure(LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.networkInvalid)))
            }
        }
        self.requests.append(request)
    }
}
