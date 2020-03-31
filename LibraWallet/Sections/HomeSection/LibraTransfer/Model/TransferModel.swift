//
//  TransferModel.swift
//  LibraWallet
//
//  Created by palliums on 2019/9/16.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit
import SwiftGRPC
import Moya
class TransferModel: NSObject {
    @objc var dataDic: NSMutableDictionary = [:]
    private var requests: [Cancellable] = []
    
    private var sequenceNumber: Int64?
    fileprivate func getLibraSequenceNumber(sendAddress: String, semaphore: DispatchSemaphore) {
        let request = mainProvide.request(.GetLibraAccountBalance("1409fc67d04cddf259240703809b6d12")) {[weak self](result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(BalanceLibraMainModel.self)
                    self?.sequenceNumber = json.result?.sequence_number
                    semaphore.signal()
                } catch {
                    print("解析异常\(error.localizedDescription)")
                    let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.parseJsonError), type: "UpdateLibraBalance")
                    self?.setValue(data, forKey: "dataDic")
                }
            case let .failure(error):
                guard error.errorCode != -999 else {
                    print("网络请求已取消")
                    return
                }
                let data = setKVOData(error: LibraWalletError.WalletRequest(reason: .networkInvalid), type: "UpdateLibraBalance")
                self?.setValue(data, forKey: "dataDic")
            }
        }
        self.requests.append(request)
    }
    func sendLibraTransaction(sendAddress: String, receiveAddress: String, amount: Double, fee: Double, mnemonic: [String]) {
        let semaphore = DispatchSemaphore.init(value: 1)
        let queue = DispatchQueue.init(label: "SendQueue")
        queue.async {
            semaphore.signal()
           self.getLibraSequenceNumber(sendAddress: sendAddress, semaphore: semaphore)
        }
        queue.async {
            semaphore.wait()
            do {
                let wallet = try LibraManager.getWallet(mnemonic: mnemonic)

                // 拼接交易
                //1e7d12e8a75683776012faf998702806
                // 首次必须
                let request = LibraTransaction.init(receiveAddress: receiveAddress, amount: amount, sendAddress: wallet.publicKey.toAddress(), sequenceNumber: UInt64(self.sequenceNumber!), authenticatorKey: "")//d943f6333b7995da537a66133fc72d5f
                //e92e6c91e33f0ec5fc70425c99c5df5cfa279f2615270daed6061313a48360f7
//                d943f6333b7995da537a66133fc72d5f9b2842c5678ad43e2111840b13572f4d
                // 签名交易
                let signature = try wallet.privateKey.signTransaction(transaction: request.request, wallet: wallet)
                self.makeViolasTransaction(signature: signature.toHexString())
            } catch {
                print(error.localizedDescription)
                DispatchQueue.main.async(execute: {
                    let data = setKVOData(error: LibraWalletError.error(error.localizedDescription), type: "SendViolasTransaction")
                    self.setValue(data, forKey: "dataDic")
                })
            }
//            // 创建通道
//            let channel = Channel.init(address: libraMainURL, secure: false)
//            // 创建请求端
//            let client = AdmissionControl_AdmissionControlServiceClient.init(channel: channel)
//            
//            do {
//                let wallet = try LibraManager.getWallet(mnemonic: mnemonic)
//                
//                // 获取SequenceNumber
////                    let sequenceNumber = try self.getSequenceNumber(client: client, wallet: wallet)
//                // 拼接交易
//                let request = LibraTransaction.init(receiveAddress: receiveAddress, amount: amount, sendAddress: wallet.publicKey.toAddress(), sequenceNumber: UInt64(self.sequenceNumber!), authenticatorKey: "1e7d12e8a75683776012faf998702806")
//                //e92e6c91e33f0ec5fc70425c99c5df5cfa279f2615270daed6061313a48360f7
//                // 签名交易
//                let aaa = try wallet.privateKey.signTransaction(transaction: request.request, wallet: wallet)
//                print(aaa.toHexString())
//                // 拼接签名请求
//                var signedTransation = Types_SignedTransaction.init()
//                signedTransation.txnBytes = aaa
//                // 组装请求
//                var mission = AdmissionControl_SubmitTransactionRequest.init()
//                mission.transaction = signedTransation
//                // 发送请求
//                let response = try client.submitTransaction(mission)
//                if response.acStatus.code == AdmissionControl_AdmissionControlStatusCode.accepted {
//                    DispatchQueue.main.async(execute: {
//                        let data = setKVOData(type: "Transfer")
//                        self.setValue(data, forKey: "dataDic")
//                    })
//                } else {
//                    DispatchQueue.main.async(execute: {
//                        print(response.acStatus.message)
//                        let data = setKVOData(error: LibraWalletError.error("转账失败"), type: "Transfer")
//                        self.setValue(data, forKey: "dataDic")
//                    })
//                }
//            } catch {
////                print(error)
//                print(error.localizedDescription)
//            }
            semaphore.signal()
        }
//            semaphore.signal()
    }
    private func makeViolasTransaction(signature: String) {
        let request = mainProvide.request(.SendLibraTransaction(signature)) {[weak self](result) in
            switch  result {
            case let .success(response):
                do {
                    print(try? response.mapString())
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

}
