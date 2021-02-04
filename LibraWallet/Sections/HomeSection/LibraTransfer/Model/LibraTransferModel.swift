//
//  LibraTransferModel.swift
//  LibraWallet
//
//  Created by palliums on 2019/9/16.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit
import Moya

class LibraTransferModel: NSObject {
    @objc dynamic var dataDic: NSMutableDictionary = [:]
    private var requests: [Cancellable] = []
    private var sequenceNumber: UInt64?
    func sendLibraTransaction(sendAddress: String, receiveAddress: String, subAddress: String, amount: UInt64, fee: UInt64, mnemonic: [String], module: String) {
        let semaphore = DispatchSemaphore.init(value: 1)
        let queue = DispatchQueue.init(label: "SendQueue")
        queue.async {
            semaphore.wait()
            self.getLibraSequenceNumber(sendAddress: sendAddress, semaphore: semaphore)

        }
        queue.async {
            semaphore.wait()
            do {
                let signature = try DiemManager.getNormalTransactionHex(sendAddress: sendAddress,
                                                                         receiveAddress: receiveAddress,
                                                                         amount: amount,
                                                                         fee: fee,
                                                                         mnemonic: mnemonic,
                                                                         sequenceNumber: self.sequenceNumber ?? 0,
                                                                         module: module,
                                                                         toSubAddress: subAddress,
                                                                         fromSubAddress: "",
                                                                         referencedEvent: "")
//                let signature = try LibraManager.getMultiTransactionHex(sendAddress: "cd35f1a78093554f5dc9c61301f204e4",
//                                                                         receiveAddress: "7f4644ae2b51b65bd3c9d414aa853407",
//                                                                         amount: amount,
//                                                                         fee: fee,
//                                                                         mnemonic: mnemonic,
//                                                                         sequenceNumber: Int(self.sequenceNumber!))
                self.makeLibraTransaction(signature: signature)
            } catch {
                print(error.localizedDescription)
                DispatchQueue.main.async(execute: {
                    let data = setKVOData(error: LibraWalletError.error(error.localizedDescription), type: "SendLibraTransaction")
                    self.setValue(data, forKey: "dataDic")
                })
            }
            semaphore.signal()
        }
    }
    private func getLibraSequenceNumber(sendAddress: String, semaphore: DispatchSemaphore) {
        let request = libraModuleProvide.request(.accountInfo(sendAddress)) {[weak self](result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(DiemAccountMainModel.self)
                    self?.sequenceNumber = json.result?.sequence_number
                    semaphore.signal()
                } catch {
                    print("GetLibraSequenceNumber_解析异常\(error.localizedDescription)")
                    DispatchQueue.main.async(execute: {
                        let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.parseJsonError), type: "GetLibraSequenceNumber")
                        self?.setValue(data, forKey: "dataDic")
                    })
                }
            case let .failure(error):
                guard error.errorCode != -999 else {
                    print("GetLibraSequenceNumber_网络请求已取消")
                    return
                }
                DispatchQueue.main.async(execute: {
                    let data = setKVOData(error: LibraWalletError.WalletRequest(reason: .networkInvalid), type: "GetLibraSequenceNumber")
                    self?.setValue(data, forKey: "dataDic")
                })
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
                    if json.result == nil {
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
        print("LibraTransferModel销毁了")
    }
}
