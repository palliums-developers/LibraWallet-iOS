//
//  TransferModel.swift
//  LibraWallet
//
//  Created by palliums on 2019/9/16.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit
import Moya
struct LibraTransferErrorModel: Codable {
    var code: Int?
    var data: String?
    var message: String?
}
struct LibraTransferMainModel: Codable {
    var id: String?
    var jsonrpc: String?
    var result: String?
    var error: LibraTransferErrorModel?
}

class TransferModel: NSObject {
    @objc dynamic var dataDic: NSMutableDictionary = [:]
    private var requests: [Cancellable] = []
    
    private var sequenceNumber: Int64?
    fileprivate func getLibraSequenceNumber(sendAddress: String, semaphore: DispatchSemaphore) {
        let request = mainProvide.request(.GetLibraAccountBalance(sendAddress)) {[weak self](result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(BalanceLibraMainModel.self)
                    self?.sequenceNumber = json.result?.sequence_number
                    semaphore.signal()
                } catch {
                    print("GetLibraSequenceNumber_解析异常\(error.localizedDescription)")
                    let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.parseJsonError), type: "GetLibraSequenceNumber")
                    self?.setValue(data, forKey: "dataDic")
                }
            case let .failure(error):
                guard error.errorCode != -999 else {
                    print("GetLibraSequenceNumber_网络请求已取消")
                    return
                }
                let data = setKVOData(error: LibraWalletError.WalletRequest(reason: .networkInvalid), type: "GetLibraSequenceNumber")
                self?.setValue(data, forKey: "dataDic")
            }
        }
        self.requests.append(request)
    }
    func sendLibraTransaction(sendAddress: String, receiveAddress: String, amount: Double, fee: Double, mnemonic: [String], module: String) {
        let semaphore = DispatchSemaphore.init(value: 1)
        let queue = DispatchQueue.init(label: "SendQueue")
        queue.async {
            semaphore.wait()
//            self.getLibraSequenceNumber(sendAddress: "cd35f1a78093554f5dc9c61301f204e4", semaphore: semaphore)
            self.getLibraSequenceNumber(sendAddress: sendAddress, semaphore: semaphore)

        }
        queue.async {
            semaphore.wait()
            do {
                let signature = try LibraManager.getNormalTransactionHex(sendAddress: sendAddress,
                                                                         receiveAddress: receiveAddress,
                                                                         amount: amount,
                                                                         fee: fee,
                                                                         mnemonic: mnemonic,
                                                                         sequenceNumber: Int(self.sequenceNumber!),
                                                                         module: module)
//                let signature = try LibraManager.getMultiTransactionHex(sendAddress: "cd35f1a78093554f5dc9c61301f204e4",
//                                                                         receiveAddress: "7f4644ae2b51b65bd3c9d414aa853407",
//                                                                         amount: amount,
//                                                                         fee: fee,
//                                                                         mnemonic: mnemonic,
//                                                                         sequenceNumber: Int(self.sequenceNumber!))
                self.makeViolasTransaction(signature: signature)
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
    private func makeViolasTransaction(signature: String) {
        let request = mainProvide.request(.SendLibraTransaction(signature)) {[weak self](result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(LibraTransferMainModel.self)
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

}
