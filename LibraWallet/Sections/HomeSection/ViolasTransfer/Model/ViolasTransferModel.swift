//
//  ViolasTransferModel.swift
//  LibraWallet
//
//  Created by palliums on 2019/11/14.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit
import Moya
struct ViolaSequenceNumberMainModel: Codable {
    /// 错误代码
    var code: Int?
    /// 错误信息
    var message: String?
    /// 数据体
    var data: Int?
}
struct ViolaSendTransactionMainModel: Codable {
    /// 错误代码
    var code: Int?
    /// 错误信息
    var message: String?

}
class ViolasTransferModel: NSObject {
    @objc var dataDic: NSMutableDictionary = [:]
    private var requests: [Cancellable] = []
    private var sequenceNumber: Int?
    
    func getViolasSequenceNumber(sendAddress: String, semaphore: DispatchSemaphore, queue: DispatchQueue) {
        semaphore.wait()
        let request = mainProvide.request(.GetViolasAccountSequenceNumber(sendAddress)) {[weak self](result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(ViolaSequenceNumberMainModel.self)
                    guard json.code == 2000 else {
                        DispatchQueue.main.async(execute: {
                            let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.dataCodeInvalid), type: "GetViolasSequenceNumber")
                            self?.setValue(data, forKey: "dataDic")
                        })
                        return
                    }
//                    let data = setKVOData(type: "GetViolasSequenceNumber", data: json.data)
//                    self?.setValue(data, forKey: "dataDic")
                    self?.sequenceNumber = json.data
                    semaphore.signal()
                    
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
    func sendViolasTransaction(sendAddress: String, receiveAddress: String, amount: Double, fee: Double, mnemonic: [String]) {
        let semaphore = DispatchSemaphore.init(value: 1)
        let queue = DispatchQueue.init(label: "SendQueue")
        queue.async {
            self.getViolasSequenceNumber(sendAddress: sendAddress, semaphore: semaphore, queue: queue)
        }
        queue.async {
            semaphore.wait()
            do {
                let wallet = try ViolasManager.getWallet(mnemonic: mnemonic)
                // 拼接交易
                let request = ViolasTransaction.init(receiveAddress: receiveAddress, amount: amount, sendAddress: wallet.publicKey.toAddress(), sequenceNumber: UInt64(self.sequenceNumber!))
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
            semaphore.signal()
        }
    }
    func sendViolasTokenTransaction(sendAddress: String, receiveAddress: String, amount: Double, fee: Double, mnemonic: [String], contact: String) {
//        "05599ef248e215849cc599f563b4883fc8aff31f1e43dff1e3ebe4de1370e054"
        let semaphore = DispatchSemaphore.init(value: 1)
        let queue = DispatchQueue.init(label: "SendQueue")
        queue.async {
            self.getViolasSequenceNumber(sendAddress: sendAddress, semaphore: semaphore, queue: queue)
        }
        queue.async {
            semaphore.wait()
            do {
                let wallet = try LibraManager.getWallet(mnemonic: mnemonic)

                // 拼接交易
                let request = LibraTransaction.init(sendAddress: sendAddress, receiveAddress: receiveAddress, amount: amount, sequenceNumber: UInt64(self.sequenceNumber!), code: Data.init(Array<UInt8>(hex: ViolasManager().getViolasTransactionCode(content: contact))))
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
            semaphore.signal()
        }
        
    }
    private func makeViolasTransaction(signature: String) {
        let request = mainProvide.request(.SendViolasTransaction(signature)) {[weak self](result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(ViolaSendTransactionMainModel.self)
                    guard json.code == 2000 else {
                        DispatchQueue.main.async(execute: {
                            let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.dataCodeInvalid), type: "SendViolasTransaction")
                            self?.setValue(data, forKey: "dataDic")
                        })
                        return
                    }
                    DispatchQueue.main.async(execute: {
                        let data = setKVOData(type: "SendViolasTransaction")
                        self?.setValue(data, forKey: "dataDic")
                    })
                    // 刷新本地数据
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
        print("ViolasTransferModel销毁了")
    }
}
