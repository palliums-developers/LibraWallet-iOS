//
//  BTCTransferModel.swift
//  LibraWallet
//
//  Created by palliums on 2019/11/14.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit
import Moya
import BitcoinKit
struct BTCUnspentUTXOListModel: Codable {
    var tx_hash: String?
    var tx_output_n: UInt32?
    var tx_output_n2: UInt32?
    var value: UInt64?
    var confirmations: Int64?
}
struct BTCUnspentUTXODataModel: Codable {
    var total_count: Int?
    var page: Int?
    var pagesize: Int?
    var list: [BTCUnspentUTXOListModel]?
}
struct BTCUnspentUTXOMainModel: Codable {
    var err_no: Int?
    var err_msg: String?
    var data: BTCUnspentUTXODataModel?
}

class BTCTransferModel: NSObject {
    @objc var dataDic: NSMutableDictionary = [:]
    private var requests: [Cancellable] = []
    
    var utxos: [BTCUnspentUTXOListModel]?
    
    func getUnspentUTXO(address: String, semaphore: DispatchSemaphore) {
        semaphore.wait()
        let request = mainProvide.request(.GetBTCUnspentUTXO(address)) {[weak self](result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(BTCUnspentUTXOMainModel.self)
                    guard json.err_no == 0 else {
                        DispatchQueue.main.async(execute: {
                            let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.dataCodeInvalid), type: "GetUnspentUTXO")
                            self?.setValue(data, forKey: "dataDic")
                        })
                        return
                    }
                    guard json.data?.list?.isEmpty == false else {
                        DispatchQueue.main.async(execute: {
                            let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.dataEmpty), type: "GetUnspentUTXO")
                            self?.setValue(data, forKey: "dataDic")
                        })
                        
                        return
                    }
//                    let data = setKVOData(type: "GetUnspentUTXO", data: json.data?.list)
//                    self?.setValue(data, forKey: "dataDic")
                    self?.utxos = json.data?.list
                    semaphore.signal()
                } catch {
                    print("解析异常\(error.localizedDescription)")
                    DispatchQueue.main.async(execute: {
                        let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.parseJsonError), type: "GetUnspentUTXO")
                        self?.setValue(data, forKey: "dataDic")
                    })
                }
            case let .failure(error):
                guard error.errorCode != -999 else {
                    print("网络请求已取消")
                    return
                }
                DispatchQueue.main.async(execute: {
                    let data = setKVOData(error: LibraWalletError.WalletRequest(reason: .networkInvalid), type: "GetUnspentUTXO")
                    self?.setValue(data, forKey: "dataDic")
                })
                
            }
        }
        self.requests.append(request)
    }
    func makeTransaction(wallet: HDWallet, amount: Double, fee: Double, toAddress: String) {
        let semaphore = DispatchSemaphore.init(value: 1)
        let queue = DispatchQueue.init(label: "SendQueue")
        queue.async {
            self.getUnspentUTXO(address: wallet.addresses.first!.description, semaphore: semaphore)
        }
        queue.async {
            semaphore.wait()
            self.selectUTXOMakeSignature(utxos: self.utxos!, wallet: wallet, amount: amount, fee: fee, toAddress: toAddress)
            semaphore.signal()
        }
    }
    
    func selectUTXOMakeSignature(utxos: [BTCUnspentUTXOListModel], wallet: HDWallet, amount: Double, fee: Double, toAddress: String) {
        let amountt: UInt64 = UInt64(amount * 100000000)
        let feee: UInt64 = UInt64(fee * 100000000)
//        let change: UInt64     =  balance - amountt - feee


        // 个人公钥
        let lockingScript = Script.buildPublicKeyHashOut(pubKeyHash: wallet.pubKeys.first!.pubkeyHash)
        
        //
        let inputs = utxos.map { item in
            UnspentTransaction.init(output: TransactionOutput.init(value: item.value ?? 0, lockingScript: lockingScript),
                                    outpoint: TransactionOutPoint.init(hash: Data(Data(hex: item.tx_hash!)!.reversed()), index: item.tx_output_n!))
        }
        let select = UnspentTransactionSelector.select(from: inputs, targetValue: amountt + feee, feePerByte: 30)
        
        let allUTXOAmount = select.reduce(0) {
            $0 + $1.output.value
        }
        let change = allUTXOAmount - feee - amountt
            
        let plan = TransactionPlan.init(unspentTransactions: select, amount: amountt, fee: feee, change: UInt64(change))
        
        let toAddressResult = try! BitcoinAddress(legacy: toAddress)

        let transaction = TransactionBuilder.build(from: plan, toAddress: toAddressResult, changeAddress: wallet.addresses.first!)

        let signature = TransactionSigner.init(unspentTransactions: plan.unspentTransactions, transaction: transaction, sighashHelper: BTCSignatureHashHelper(hashType: .ALL))
        let result = try? signature.sign(with: wallet.privKeys)
        print(result!.serialized().toHexString())
        
        self.sendBTCTransaction(signature: result!.serialized().toHexString())
    }
    func selectUTXOMakeBTCToVBTCSignature(utxos: [BTCUnspentUTXOListModel], wallet: HDWallet, amount: Double, fee: Double, toAddress: String) {
        let amountt: UInt64 = UInt64(amount * 100000000)
        let feee: UInt64 = UInt64(fee * 100000000)

        // 个人公钥
        let lockingScript = Script.buildPublicKeyHashOut(pubKeyHash: wallet.pubKeys.first!.pubkeyHash)
        //
        let inputs = utxos.map { item in
            UnspentTransaction.init(output: TransactionOutput.init(value: item.value ?? 0, lockingScript: lockingScript),
                                    outpoint: TransactionOutPoint.init(hash: Data(Data(hex: item.tx_hash!)!.reversed()), index: item.tx_output_n!))
        }
        let select = UnspentTransactionSelector.select(from: inputs, targetValue: amountt + feee, feePerByte: 30)
        
        let allUTXOAmount = select.reduce(0) {
            $0 + $1.output.value
        }
        let change = allUTXOAmount - feee - amountt
            
        let plan = TransactionPlan.init(unspentTransactions: select, amount: amountt, fee: feee, change: UInt64(change))
        
        let toAddressResult = try! BitcoinAddress(legacy: toAddress)

        let transaction = TransactionBuilder.build(from: plan, toAddress: toAddressResult, changeAddress: wallet.addresses.first!)

        let signature = TransactionSigner.init(unspentTransactions: plan.unspentTransactions, transaction: transaction, sighashHelper: BTCSignatureHashHelper(hashType: .ALL))
        let result = try? signature.sign(with: wallet.privKeys)
        print(result!.serialized().toHexString())
        
        self.sendBTCTransaction(signature: result!.serialized().toHexString())
    }
    public static func build(from plan: TransactionPlan, toAddress: Address, changeAddress: Address, script: Script) -> Transaction {
        let toLockScript: Data = Script(address: toAddress)!.data
        var outputs: [TransactionOutput] = [
            TransactionOutput(value: plan.amount, lockingScript: toLockScript)
        ]
        if plan.change > 0 {
            let changeLockScript: Data = Script(address: changeAddress)!.data
            outputs.append(
                TransactionOutput(value: plan.change, lockingScript: changeLockScript)
            )
        }
        outputs.append(
            TransactionOutput(value: 0, lockingScript: script.data)
        )
        let unsignedInputs: [TransactionInput] = plan.unspentTransactions.map {
            TransactionInput(
                previousOutput: $0.outpoint,
                signatureScript: Data(),
                sequence: UInt32.max
            )
        }

        return Transaction(version: 2, inputs: unsignedInputs, outputs: outputs, lockTime: 0)
    }
    func sendBTCTransaction(signature: String) {
        let request = mainProvide.request(.SendBTCTransaction(signature)) {[weak self](result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(BTCUnspentUTXOMainModel.self)
                    print(try response.mapString())
                    guard json.err_no == 0 else {
                        DispatchQueue.main.async(execute: {
                            let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.dataCodeInvalid), type: "SendBTCTransaction")
                            self?.setValue(data, forKey: "dataDic")
                        })
                        return
                    }
                    DispatchQueue.main.async(execute: {
                        let data = setKVOData(type: "SendBTCTransaction")
                        self?.setValue(data, forKey: "dataDic")
                    })
                    // 刷新本地数据
                } catch {
                    print("SendBTCTransaction_解析异常\(error.localizedDescription)")
                    DispatchQueue.main.async(execute: {
                        let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.parseJsonError), type: "SendBTCTransaction")
                        self?.setValue(data, forKey: "dataDic")
                    })
                    
                }
            case let .failure(error):
                guard error.errorCode != -999 else {
                    print("SendBTCTransaction_网络请求已取消")
                    return
                }
                DispatchQueue.main.async(execute: {
                    let data = setKVOData(error: LibraWalletError.WalletRequest(reason: .networkInvalid), type: "SendBTCTransaction")
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
        print("BTCTransferModel销毁了")
    }
}
