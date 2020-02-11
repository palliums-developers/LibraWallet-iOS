//
//  TokenMappingModel.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/2/7.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit
import Moya
import BitcoinKit
struct TokenMappingDataModel {
    var pay_name: String?
    var exchange_name: String?
    var exchange_contract: String?
    var exchange_receive_address: String?
    var exchange_rate: Double
}
class TokenMappingModel: NSObject {
    private var requests: [Cancellable] = []
    @objc var dataDic: NSMutableDictionary = [:]
    func getMappingInfo(walletType: WalletType) {
        #warning("缺少获取信息")
        let model = TokenMappingDataModel.init(pay_name: walletType.description,
                                               exchange_name: "VBTC",
                                               exchange_contract: "af955c1d62a74a7543235dbb7fa46ed98948d2041dff67dfdb636a54e84f91fb",
                                               exchange_receive_address: "2MxBZG7295wfsXaUj69quf8vucFzwG35UWh",
                                               exchange_rate: 1)
        
        let data = setKVOData(type: "MappingInfo", data: model)
        self.setValue(data, forKey: "dataDic")
    }
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
    func makeTransaction(wallet: HDWallet, amount: Double, fee: Double, toAddress: String, mappingReceiveAddress: String, mappingContract: String) {
            let semaphore = DispatchSemaphore.init(value: 1)
            let queue = DispatchQueue.init(label: "SendQueue")
            queue.async {
                self.getUnspentUTXO(address: wallet.addresses.first!.description, semaphore: semaphore)
            }
            queue.async {
                semaphore.wait()
                self.selectUTXOMakeBTCToVBTCSignature(utxos: self.utxos!, wallet: wallet, amount: amount, fee: fee, toAddress: toAddress, mappingReceiveAddress: mappingReceiveAddress, mappingContract: mappingContract)
                semaphore.signal()
            }
        }
    func selectUTXOMakeBTCToVBTCSignature(utxos: [BTCUnspentUTXOListModel], wallet: HDWallet, amount: Double, fee: Double, toAddress: String, mappingReceiveAddress: String, mappingContract: String) {
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
        // 添加脚本
        let script = BTCManager().getBTCToVBTCScript(address: mappingReceiveAddress, tokenContract: mappingContract)
        let data = BTCManager().getData(script: script)
        let opReturn = TransactionOutput.init(value: 0, lockingScript: data)
        
        var tempOutputs = transaction.outputs
        tempOutputs.append(opReturn)
        let transactionResult = Transaction.init(version: transaction.version, inputs: transaction.inputs, outputs: tempOutputs, lockTime: transaction.lockTime)
        
        let signature = TransactionSigner.init(unspentTransactions: plan.unspentTransactions, transaction: transactionResult, sighashHelper: BTCSignatureHashHelper(hashType: .ALL))
        let result = try? signature.sign(with: wallet.privKeys)
        print(result!.serialized().toHexString())
        
        self.sendBTCTransaction(signature: result!.serialized().toHexString())
    }
    func sendBTCTransaction(signature: String) {
        let request = mainProvide.request(.SendBTCTransaction(signature)) {[weak self](result) in
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
        print("TokenMappingModel销毁了")
    }
}
