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
struct BTCSubmitTransactionModel: Codable {
    var err_no: Int?
    var err_msg: String?
    var data: String?
}
struct BlockCypherBTCUnspentUTXOTxsModel: Codable {
//    var txid: String?
//    var output_no: UInt32?
//    var script_asm: String?
//    var script_hex: String?
//    var value: String?
//    var confirmations: Int64?
//    var time: Int64?
}
struct BlockCypherBTCUnspentUTXODataModel: Codable {
    var tx_hash: String?
    var block_height: Int64?
    var tx_input_n: Int32?
    var tx_output_n: UInt32?
    var value: UInt64?
    var ref_balance: Int64?
    var spent: Bool?
    var confirmations: Int64?
    var confirmed: String?
    var double_spend: Bool?
//    var txs: [BlockCypherBTCUnspentUTXOTxsModel]?
}
struct BlockCypherBTCUnspentUTXOMainModel: Codable {
    var address: String?
    var total_received: Int64?
    var total_sent: Int64?
    var balance: Int64?
    var unconfirmed_balance: Int64?
    var final_balance: Int64?
    var n_tx: Int64?
    var unconfirmed_n_tx: Int64?
    var final_n_tx: Int64?
    var txrefs: [BlockCypherBTCUnspentUTXODataModel]?
//    var status: String?
//    var data: BlockCypherBTCUnspentUTXODataModel?
}

class BTCTransferModel: NSObject {
    @objc var dataDic: NSMutableDictionary = [:]
    private var requests: [Cancellable] = []
    
//    var utxos: [BTCUnspentUTXOListModel]?
    var utxos: [BlockCypherBTCUnspentUTXODataModel]?
    
//    func getUnspentUTXO(address: String, semaphore: DispatchSemaphore) {
//        semaphore.wait()
//        let request = mainProvide.request(.GetBTCUnspentUTXO(address)) {[weak self](result) in
//            switch  result {
//            case let .success(response):
//                do {
//                    let json = try response.map(BTCUnspentUTXOMainModel.self)
//                    guard json.err_no == 0 else {
//                        DispatchQueue.main.async(execute: {
//                            let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.dataCodeInvalid), type: "GetUnspentUTXO")
//                            self?.setValue(data, forKey: "dataDic")
//                        })
//                        return
//                    }
//                    guard json.data?.list?.isEmpty == false else {
//                        DispatchQueue.main.async(execute: {
//                            let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.dataEmpty), type: "GetUnspentUTXO")
//                            self?.setValue(data, forKey: "dataDic")
//                        })
//
//                        return
//                    }
//                    self?.utxos = json.data?.list
//                    semaphore.signal()
//                } catch {
//                    print("解析异常\(error.localizedDescription)")
//                    DispatchQueue.main.async(execute: {
//                        let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.parseJsonError), type: "GetUnspentUTXO")
//                        self?.setValue(data, forKey: "dataDic")
//                    })
//                }
//            case let .failure(error):
//                guard error.errorCode != -999 else {
//                    print("网络请求已取消")
//                    return
//                }
//                DispatchQueue.main.async(execute: {
//                    let data = setKVOData(error: LibraWalletError.WalletRequest(reason: .networkInvalid), type: "GetUnspentUTXO")
//                    self?.setValue(data, forKey: "dataDic")
//                })
//
//            }
//        }
//        self.requests.append(request)
//    }
    func getUnspentUTXO(address: String, semaphore: DispatchSemaphore) {
        semaphore.wait()
        let request = mainProvide.request(.BlockCypherBTCUnspentUTXO(address)) {[weak self](result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(BlockCypherBTCUnspentUTXOMainModel.self)
//                    guard json.isEmpty == false else {
//                        DispatchQueue.main.async(execute: {
//                            let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.dataEmpty), type: "GetUnspentUTXO")
//                            self?.setValue(data, forKey: "dataDic")
//                        })
//                        return
//                    }
                    self?.utxos = json.txrefs
                    semaphore.signal()
                } catch {
                    print("GetUnspentUTXO_解析异常\(error.localizedDescription)")
                    DispatchQueue.main.async(execute: {
                        let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.parseJsonError), type: "GetUnspentUTXO")
                        self?.setValue(data, forKey: "dataDic")
                    })
                }
            case let .failure(error):
                guard error.errorCode != -999 else {
                    print("GetUnspentUTXO_网络请求已取消")
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
    
//    func selectUTXOMakeSignature(utxos: [BTCUnspentUTXOListModel], wallet: HDWallet, amount: Double, fee: Double, toAddress: String) {
//        let amountt: UInt64 = UInt64(amount * 100000000)
//        let feee: UInt64 = UInt64(fee * 100000000)
////        let change: UInt64     =  balance - amountt - feee
//
//        // 个人公钥
//        let lockingScript = Script.buildPublicKeyHashOut(pubKeyHash: wallet.pubKeys.first!.pubkeyHash)
//
//        //
//        let inputs = utxos.map { item in
//            UnspentTransaction.init(output: TransactionOutput.init(value: item.value ?? 0, lockingScript: lockingScript),
//                                    outpoint: TransactionOutPoint.init(hash: Data(Data(hex: item.tx_hash!)!.reversed()), index: item.tx_output_n!))
//        }
//        let select = UnspentTransactionSelector.select(from: inputs, targetValue: amountt + feee, feePerByte: 30)
//
//        let allUTXOAmount = select.reduce(0) {
//            $0 + $1.output.value
//        }
//        let change = allUTXOAmount - feee - amountt
//
//        let plan = TransactionPlan.init(unspentTransactions: select, amount: amountt, fee: feee, change: UInt64(change))
//
//        let toAddressResult = try! BitcoinAddress(legacy: toAddress)
//
//        let transaction = TransactionBuilder.build(from: plan, toAddress: toAddressResult, changeAddress: wallet.addresses.first!)
//
//        let signature = TransactionSigner.init(unspentTransactions: plan.unspentTransactions, transaction: transaction, sighashHelper: BTCSignatureHashHelper(hashType: .ALL))
//        let result = try? signature.sign(with: wallet.privKeys)
//        print(result!.serialized().toHexString())
//
//        self.sendBTCTransaction(signature: result!.serialized().toHexString())
//    }
    func selectUTXOMakeSignature(utxos: [BlockCypherBTCUnspentUTXODataModel], wallet: HDWallet, amount: Double, fee: Double, toAddress: String) {
        let amountt: UInt64 = UInt64(amount * 100000000)
        let feee: UInt64 = UInt64(fee * 100000000)
//        let change: UInt64     =  balance - amountt - feee

        // 个人公钥
        let lockingScript = Script.buildPublicKeyHashOut(pubKeyHash: wallet.pubKeys.first!.pubkeyHash)
        
        //
        let inputs = utxos.map { item in
            UnspentTransaction.init(output: TransactionOutput.init(value: item.value!, lockingScript: lockingScript),
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
    func sendBTCTransaction(signature: String) {
        let request = mainProvide.request(.BlockCypherBTCPushTransaction(signature)) {[weak self](result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(BTCSubmitTransactionModel.self)
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
