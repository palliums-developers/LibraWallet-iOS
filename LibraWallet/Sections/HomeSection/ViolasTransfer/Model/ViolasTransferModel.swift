//
//  ViolasTransferModel.swift
//  LibraWallet
//
//  Created by palliums on 2019/11/14.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit
import Moya
class ViolasTransferModel: NSObject {
    @objc var dataDic: NSMutableDictionary = [:]
    private var requests: [Cancellable] = []
    
    func getViolasSequenceNumber(address: String) {
        let request = mainProvide.request(.GetViolasAccountSequenceNumber(address)) {[weak self](result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(ViolaSequenceNumberMainModel.self)
                    guard json.code == 2000 else {
                        let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.dataCodeInvalid), type: "GetViolasSequenceNumber")
                        self?.setValue(data, forKey: "dataDic")
                        return
                    }
                    let data = setKVOData(type: "GetViolasSequenceNumber", data: json.data)
                    self?.setValue(data, forKey: "dataDic")
                    // 刷新本地数据
                } catch {
                    print("解析异常\(error.localizedDescription)")
                    let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.parseJsonError), type: "GetViolasSequenceNumber")
                    self?.setValue(data, forKey: "dataDic")
                }
            case let .failure(error):
                guard error.errorCode != -999 else {
                    print("网络请求已取消")
                    return
                }
                let data = setKVOData(error: LibraWalletError.WalletRequest(reason: .networkInvalid), type: "GetViolasSequenceNumber")
                self?.setValue(data, forKey: "dataDic")
            }
        }
        self.requests.append(request)
    }
    func sendViolasTransaction(sendAddress: String, receiveAddress: String, amount: Double, mnemonic: [String], sequenceNumber: Int) {
        do {
            let seed = try LibraMnemonic.seed(mnemonic: mnemonic)
            let wallet = try LibraWallet.init(seed: seed)
            // 拼接交易
            let request = LibraTransaction.init(receiveAddress: receiveAddress, amount: amount, sendAddress: wallet.publicKey.toAddress(), sequenceNumber: UInt64(sequenceNumber))
            // 签名交易
            let signature = try wallet.privateKey.signTransaction(transaction: request.request, wallet: wallet)
            makeViolasTransaction(signature: signature.toHexString())
        } catch {
            print(error.localizedDescription)
        }
    }
    func sendViolasTokenTransaction(sendAddress: String, receiveAddress: String, amount: Double, mnemonic: [String], sequenceNumber: Int) {
        do {
            let seed = try LibraMnemonic.seed(mnemonic: mnemonic)
            let wallet = try LibraWallet.init(seed: seed)
            // 拼接交易
            let request = LibraTransaction.init(sendAddress: sendAddress, receiveAddress: receiveAddress, amount: amount, sequenceNumber: UInt64(sequenceNumber), code: Data.init(Array<UInt8>(hex: ViolasManager().getViolasTransactionCode(content: "05599ef248e215849cc599f563b4883fc8aff31f1e43dff1e3ebe4de1370e054"))))
            // 签名交易
            let signature = try wallet.privateKey.signTransaction(transaction: request.request, wallet: wallet)
            makeViolasTransaction(signature: signature.toHexString())
        } catch {
            print(error.localizedDescription)
        }
    }
    private func makeViolasTransaction(signature: String) {
        let request = mainProvide.request(.SendViolasTransaction(signature)) {[weak self](result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(ViolaSendTransactionMainModel.self)
                    guard json.code == 2000 else {
                        let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.dataCodeInvalid), type: "SendViolasTransaction")
                        self?.setValue(data, forKey: "dataDic")
                        return
                    }
                    let data = setKVOData(type: "SendViolasTransaction")
                    self?.setValue(data, forKey: "dataDic")
                    // 刷新本地数据
                } catch {
                    print("解析异常\(error.localizedDescription)")
                    let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.parseJsonError), type: "SendViolasTransaction")
                    self?.setValue(data, forKey: "dataDic")
                }
            case let .failure(error):
                guard error.errorCode != -999 else {
                    print("网络请求已取消")
                    return
                }
                let data = setKVOData(error: LibraWalletError.WalletRequest(reason: .networkInvalid), type: "SendViolasTransaction")
                self?.setValue(data, forKey: "dataDic")
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
