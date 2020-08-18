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
//import SwiftGRPC
struct TokenMappingListAssertDataModel: Codable {
    var address: String?
    var icon: String?
    var module: String?
    var name: String?
    var show_name: String?
    /// 是否激活（自行添加）
    var active_state: Bool?
    /// 数量（自行添加）
    var amount: Int64?
}
struct TokenMappingListTokenDataModel: Codable {
    var assert: TokenMappingListAssertDataModel?
    var coin_type: String?
}
struct TokenMappingListDataModel: Codable {
    var from_coin: TokenMappingListTokenDataModel?
    var lable: String?
    var receiver_address: String?
    var to_coin: TokenMappingListTokenDataModel?
    /// 兑换比例（自行添加）
    var mapping_rate: Double?
}
struct TokenMappingListMainModel: Codable {
    var code: Int?
    var message: String?
    var data: [TokenMappingListDataModel]?
}
class TokenMappingModel: NSObject {
    private var requests: [Cancellable] = []
    @objc dynamic var dataDic: NSMutableDictionary = [:]
    private var sequenceNumber: UInt64?
    private var accountViolasTokens: [ViolasBalanceModel]?
    private var accountLibraTokens: [LibraBalanceModel]?
    private var accountBTCAmount: String?
    private var mappingTokenList: [TokenMappingListDataModel]?
//    var utxos: [BTCUnspentUTXOListModel]?
    var utxos: [TrezorBTCUTXOMainModel]?
//    private var sequenceNumber: Int?
    deinit {
        requests.forEach { cancellable in
            cancellable.cancel()
        }
        requests.removeAll()
        print("TokenMappingModel销毁了")
    }
}
//MARK: - BTC跨链映射
extension TokenMappingModel {
    func sendBTCMappingTransaction(wallet: HDWallet, amountIn: UInt64, amountOut: UInt64, fee: Double, mnemonic: [String], moduleOutput: String, mappingReceiveAddress: String, outputModuleActiveState: Bool, moduleAddress: String, type: String, centerAddress: String, chainType: String) {
        let semaphore = DispatchSemaphore.init(value: 1)
        let queue = DispatchQueue.init(label: "SendQueue")
        if outputModuleActiveState == false {
            queue.async {
                semaphore.wait()
                if chainType == "libra" {
                    self.getLibraSequenceNumber(sendAddress: mappingReceiveAddress, semaphore: semaphore)
                } else {
                    self.getViolasSequenceNumber(sendAddress: mappingReceiveAddress, semaphore: semaphore)
                }
            }
            queue.async {
                semaphore.wait()
                if chainType == "libra" {
                    do {
                        let signature = try LibraManager.getPublishTokenTransactionHex(mnemonic: mnemonic,
                                                                                       sequenceNumber: self.sequenceNumber ?? 0,
                                                                                       fee: 0,
                                                                                       module: moduleOutput)
                        self.makeLibraTransaction(signature: signature, type: "SendPublishOutputModuleLibraTransaction", semaphore: semaphore)
                    } catch {
                        print(error.localizedDescription)
                        DispatchQueue.main.async(execute: {
                            let data = setKVOData(error: LibraWalletError.error(error.localizedDescription), type: "SendPublishOutputModuleLibraTransaction")
                            self.setValue(data, forKey: "dataDic")
                        })
                    }
                } else {
                    do {
                        let signature = try ViolasManager.getPublishTokenTransactionHex(mnemonic: mnemonic,
                                                                                        fee: 0,
                                                                                        sequenceNumber: self.sequenceNumber ?? 0,
                                                                                        inputModule: moduleOutput)
                        self.makeViolasTransaction(signature: signature, type: "SendPublishOutputModuleViolasTransaction", semaphore: semaphore)
                    } catch {
                        print(error.localizedDescription)
                        DispatchQueue.main.async(execute: {
                            let data = setKVOData(error: LibraWalletError.error(error.localizedDescription), type: "SendPublishOutputModuleViolasTransaction")
                            self.setValue(data, forKey: "dataDic")
                        })
                    }
                }
            }
        }
        queue.async {
            self.getUnspentUTXO(address: wallet.addresses.first!.description, semaphore: semaphore)
        }
        queue.async {
            semaphore.wait()
            self.selectUTXOWithScriptSignature(utxos: self.utxos!,
                                               wallet: wallet,
                                               amountIn: amountIn,
                                               amountOut: amountOut,
                                               fee: fee,
                                               toAddress: centerAddress,
                                               mappingReceiveAddress: mappingReceiveAddress,
                                               mappingContract: moduleAddress,
                                               type: type)
            semaphore.signal()
        }
    }
    private func getUnspentUTXO(address: String, semaphore: DispatchSemaphore) {
        semaphore.wait()
        let request = mainProvide.request(.TrezorBTCUnspentUTXO(address)) {[weak self](result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map([TrezorBTCUTXOMainModel].self)
                    self?.utxos = json
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
    private func selectUTXOWithScriptSignature(utxos: [TrezorBTCUTXOMainModel], wallet: HDWallet, amountIn: UInt64, amountOut: UInt64, fee: Double, toAddress: String, mappingReceiveAddress: String, mappingContract: String, type: String) {
        let feee: UInt64 = UInt64(fee * 100000000)
        
        // 个人公钥
        let lockingScript = Script.buildPublicKeyHashOut(pubKeyHash: wallet.pubKeys.first!.pubkeyHash)
        //
        let inputs = utxos.map { item in
            UnspentTransaction.init(output: TransactionOutput.init(value: NSDecimalNumber.init(string: item.value ?? "0").uint64Value, lockingScript: lockingScript),
                                    outpoint: TransactionOutPoint.init(hash: Data(Data(hex: item.txid!)!.reversed()), index: item.vout!))
        }
        let select = UnspentTransactionSelector.select(from: inputs, targetValue: amountIn + feee, feePerByte: 30)
        
        let allUTXOAmount = select.reduce(0) {
            $0 + $1.output.value
        }
        let change = allUTXOAmount - feee - amountIn
        
        let plan = TransactionPlan.init(unspentTransactions: select, amount: amountIn, fee: feee, change: UInt64(change))
        
        let toAddressResult = try! BitcoinAddress(legacy: toAddress)
        
        let transaction = customBuild(from: plan, toAddress: toAddressResult, changeAddress: wallet.addresses.first!)
        // 添加脚本
        let script = BTCManager().getBTCScript(address: mappingReceiveAddress, type: type, tokenContract: mappingContract, amount: amountOut)
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
    private func customBuild(from plan: TransactionPlan, toAddress: Address, changeAddress: Address) -> Transaction {
        let toLockScript: Data = Script(address: toAddress)!.data
        var outputs: [TransactionOutput] = [
            TransactionOutput(value: plan.amount, lockingScript: toLockScript)
        ]
        if plan.change > 0 {
            let changeLockScript: Data = Script(address: changeAddress)!.data
            outputs.insert(TransactionOutput(value: plan.change, lockingScript: changeLockScript), at: 0)
        }
        
        let unsignedInputs: [TransactionInput] = plan.unspentTransactions.map {
            TransactionInput(
                previousOutput: $0.outpoint,
                signatureScript: Data(),
                sequence: UInt32.max
            )
        }
        
        return Transaction(version: 2, inputs: unsignedInputs, outputs: outputs, lockTime: 0)
    }
    private func sendBTCTransaction(signature: String) {
        let request = mainProvide.request(.TrezorBTCPushTransaction(signature)) {[weak self](result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(TrezorBTCSendTransactionMainModel.self)
                    guard json.result?.isEmpty == false else {
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
}

//MARK: - Libra映射Violas、BTC
extension TokenMappingModel {
    func sendLibraMappingTransaction(sendAddress: String, receiveAddress: String, module: String, moduleOutput: String, amountIn: UInt64, amountOut: UInt64, fee: UInt64, mnemonic: [String], type: String, centerAddress: String, outputModuleActiveState: Bool) {
        let semaphore = DispatchSemaphore.init(value: 1)
        let queue = DispatchQueue.init(label: "SendQueue")
        if outputModuleActiveState == false {
            queue.async {
                semaphore.wait()
                self.getViolasSequenceNumber(sendAddress: receiveAddress, semaphore: semaphore)
            }
            queue.async {
                semaphore.wait()
                do {
                    let signature = try ViolasManager.getPublishTokenTransactionHex(mnemonic: mnemonic,
                                                                                    fee: 0,
                                                                                    sequenceNumber: self.sequenceNumber ?? 0,
                                                                                    inputModule: moduleOutput)
                    self.makeViolasTransaction(signature: signature, type: "SendPublishOutputModuleViolasTransaction", semaphore: semaphore)
                } catch {
                    print(error.localizedDescription)
                    DispatchQueue.main.async(execute: {
                        let data = setKVOData(error: LibraWalletError.error(error.localizedDescription), type: "SendPublishOutputModuleViolasTransaction")
                        self.setValue(data, forKey: "dataDic")
                    })
                }
            }
        }
        queue.async {
            semaphore.wait()
           self.getLibraSequenceNumber(sendAddress: sendAddress, semaphore: semaphore)
        }
        queue.async {
            semaphore.wait()
            do {
                let signature = try LibraManager.getLibraMappingTransactionHex(sendAddress: sendAddress,
                                                                               mnemonic: mnemonic,
                                                                               feeModule: module,
                                                                               fee: fee,
                                                                               sequenceNumber: self.sequenceNumber ?? 0,
                                                                               inputModule: module,
                                                                               inputAmount: amountIn,
                                                                               outputAmount: amountOut,
                                                                               centerAddress: centerAddress,
                                                                               receiveAddress: receiveAddress,
                                                                               mappingType: type)
                self.makeLibraTransaction(signature: signature, type: "SendLibraTransaction")
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
    private func makeLibraTransaction(signature: String, type: String, semaphore: DispatchSemaphore? = nil) {
        let request = mainProvide.request(.SendLibraTransaction(signature)) {[weak self](result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(LibraTransferMainModel.self)
                    if json.result == nil {
                        DispatchQueue.main.async(execute: {
                            if let sema = semaphore {
                                sema.signal()
                            } else {
                                let data = setKVOData(type: type)
                                self?.setValue(data, forKey: "dataDic")
                            }
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
//MARK: - Viola映射Libra、BTC
extension TokenMappingModel {
    func sendViolasMappingTransaction(sendAddress: String, receiveAddress: String, module: String, moduleOutput: String, amountIn: UInt64, amountOut: UInt64, fee: UInt64, mnemonic: [String], type: String, centerAddress: String, outputModuleActiveState: Bool) {
        let semaphore = DispatchSemaphore.init(value: 1)
        let queue = DispatchQueue.init(label: "SendQueue")
        if outputModuleActiveState == false {
            queue.async {
                semaphore.wait()
                self.getLibraSequenceNumber(sendAddress: receiveAddress, semaphore: semaphore)
            }
            queue.async {
                semaphore.wait()
                do {
                    let signature = try LibraManager.getPublishTokenTransactionHex(mnemonic: mnemonic,
                                                                                   sequenceNumber: self.sequenceNumber ?? 0,
                                                                                   fee: 0,
                                                                                   module: moduleOutput)
                    self.makeLibraTransaction(signature: signature, type: "SendPublishOutputModuleLibraTransaction", semaphore: semaphore)
                } catch {
                    print(error.localizedDescription)
                    DispatchQueue.main.async(execute: {
                        let data = setKVOData(error: LibraWalletError.error(error.localizedDescription), type: "SendPublishOutputModuleViolasTransaction")
                        self.setValue(data, forKey: "dataDic")
                    })
                }
            }
        }
        queue.async {
            semaphore.wait()
            self.getViolasSequenceNumber(sendAddress: sendAddress, semaphore: semaphore)
        }
        queue.async {
            semaphore.wait()
            do {
                let signature = try ViolasManager.getViolasMappingTransactionHex(sendAddress: sendAddress,
                                                                                 mnemonic: mnemonic,
                                                                                 feeModule: module,
                                                                                 fee: fee,
                                                                                 sequenceNumber: self.sequenceNumber ?? 0,
                                                                                 inputModule: module,
                                                                                 inputAmount: amountIn,
                                                                                 outputAmount: amountOut,
                                                                                 centerAddress: centerAddress,
                                                                                 receiveAddress: receiveAddress,
                                                                                 mappingType: type)
                self.makeViolasTransaction(signature: signature, type: "SendViolasTransaction")
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
    private func getViolasSequenceNumber(sendAddress: String, semaphore: DispatchSemaphore) {
        let request = mainProvide.request(.GetViolasAccountInfo(sendAddress)) {[weak self](result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(BalanceViolasMainModel.self)
                    if json.error == nil {
                        self?.sequenceNumber = json.result?.sequence_number ?? 0
                        semaphore.signal()
                    } else {
                        print("GetViolasSequenceNumber_状态异常")
                        DispatchQueue.main.async(execute: {
                            if let message = json.error?.message, message.isEmpty == false {
                                let data = setKVOData(error: LibraWalletError.error(message), type: "GetViolasSequenceNumber")
                                self?.setValue(data, forKey: "dataDic")
                            } else {
                                let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.dataCodeInvalid), type: "SendLibraTransaction")
                                self?.setValue(data, forKey: "dataDic")
                            }
                        })
                    }
                } catch {
                    print("GetViolasSequenceNumber_解析异常\(error.localizedDescription)")
                    DispatchQueue.main.async(execute: {
                        let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.parseJsonError), type: "GetViolasSequenceNumber")
                        self?.setValue(data, forKey: "dataDic")
                    })
                }
            case let .failure(error):
                guard error.errorCode != -999 else {
                    print("GetViolasSequenceNumber_网络请求已取消")
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
    private func makeViolasTransaction(signature: String, type: String, semaphore: DispatchSemaphore? = nil) {
        let request = mainProvide.request(.SendViolasTransaction(signature)) {[weak self](result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(LibraTransferMainModel.self)
                    if json.result == nil {
                        DispatchQueue.main.async(execute: {
                            if let sema = semaphore {
                                sema.signal()
                            } else {
                                let data = setKVOData(type: type)
                                self?.setValue(data, forKey: "dataDic")
                            }
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
//MARK: - 获取映射币列表
extension TokenMappingModel {
    func getMappingTokenList(btcAddress: String, violasAddress: String, libraAddress: String) {
        let group = DispatchGroup.init()
        let quene = DispatchQueue.init(label: "SupportMappingTokenQuene")
        quene.async(group: group, qos: .default, flags: [], execute: {
            group.enter()
            self.getSupportMappingList(group: group)
        })
        quene.async(group: group, qos: .default, flags: [], execute: {
            group.enter()
            self.getBTCBalance(address: btcAddress, group: group)
        })
        quene.async(group: group, qos: .default, flags: [], execute: {
            group.enter()
            self.getViolasBalance(address: violasAddress, group: group)
        })
        quene.async(group: group, qos: .default, flags: [], execute: {
            group.enter()
            self.getLibraBalance(address: libraAddress, group: group)
        })
        group.notify(queue: quene) {
            print("回到该队列中执行")
            print("\(Thread.current)")
            self.handleMappingTokens()
        }
    }
    private func getSupportMappingList(group: DispatchGroup) {
        let request = mainProvide.request(.GetMappingInfo) {[weak self](result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(TokenMappingListMainModel.self)
                    if json.code == 2000 {
                        guard let tokens = json.data, tokens.isEmpty == false else {
                            let data = setKVOData(error: LibraWalletError.WalletRequest(reason: .dataEmpty), type: "MappingInfo")
                            self?.setValue(data, forKey: "dataDic")
                            return
                        }
                        self?.mappingTokenList = tokens
                        group.leave()
                    } else {
                        print("MappingInfo_状态异常")
                        if let message = json.message, message.isEmpty == false {
                            let data = setKVOData(error: LibraWalletError.error(message), type: "MappingInfo")
                            self?.setValue(data, forKey: "dataDic")
                        } else {
                            let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.dataCodeInvalid), type: "MappingInfo")
                            self?.setValue(data, forKey: "dataDic")
                        }
                    }
                } catch {
                    print("MappingInfo_解析异常\(error.localizedDescription)")
                    let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.parseJsonError), type: "MappingInfo")
                    self?.setValue(data, forKey: "dataDic")
                }
            case let .failure(error):
                guard error.errorCode != -999 else {
                    print("MappingInfo_网络请求已取消")
                    return
                }
                let data = setKVOData(error: LibraWalletError.WalletRequest(reason: .networkInvalid), type: "MappingInfo")
                self?.setValue(data, forKey: "dataDic")
            }
        }
        self.requests.append(request)
    }
    private func getBTCBalance(address: String, group: DispatchGroup) {
        let request = mainProvide.request(.TrezorBTCBalance(address)) {[weak self](result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(TrezorBTCBalanceMainModel.self)
                    self?.accountBTCAmount = json.balance
                    group.leave()
                } catch {
                    print("UpdateBTCBalance_解析异常\(error.localizedDescription)")
                    let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.parseJsonError), type: "UpdateBTCBalance")
                    self?.setValue(data, forKey: "dataDic")
                }
            case let .failure(error):
                guard error.errorCode != -999 else {
                    print("UpdateBTCBalance_网络请求已取消")
                    return
                }
                let data = setKVOData(error: LibraWalletError.WalletRequest(reason: .networkInvalid), type: "UpdateBTCBalance")
                self?.setValue(data, forKey: "dataDic")
            }
        }
        self.requests.append(request)
    }
    private func getViolasBalance(address: String, group: DispatchGroup) {
        let request = mainProvide.request(.GetViolasAccountInfo(address)) {[weak self](result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(BalanceViolasMainModel.self)
                    if json.result == nil {
                        self?.accountViolasTokens = [ViolasBalanceModel.init(amount: 0, currency: "LBR")]
                        group.leave()
                    } else {
                        self?.accountViolasTokens = json.result?.balances
                        group.leave()
                    }
                } catch {
                    print("UpdateViolasBalance_解析异常\(error.localizedDescription)")
                    let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.parseJsonError), type: "UpdateViolasBalance")
                    self?.setValue(data, forKey: "dataDic")
                }
            case let .failure(error):
                guard error.errorCode != -999 else {
                    print("UpdateViolasBalance_网络请求已取消")
                    return
                }
                let data = setKVOData(error: LibraWalletError.WalletRequest(reason: .networkInvalid), type: "UpdateViolasBalance")
                self?.setValue(data, forKey: "dataDic")
            }
        }
        self.requests.append(request)
    }
    private func getLibraBalance(address: String, group: DispatchGroup) {
        let request = mainProvide.request(.GetLibraAccountBalance(address)) {[weak self](result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(BalanceLibraMainModel.self)
                    if json.result == nil {
                        self?.accountLibraTokens = [LibraBalanceModel.init(amount: 0, currency: "LBR")]
                        group.leave()
                    } else {
                        self?.accountLibraTokens = json.result?.balances
                        group.leave()
                    }
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
    private func handleMappingTokens() {
        var tempDatas = [TokenMappingListDataModel]()
        for data in self.mappingTokenList! {
            var tempItem = data
            if data.from_coin?.coin_type?.lowercased() == "violas" {
                // 1.首先判断付出币是否激活
                tempItem.from_coin?.assert?.active_state = false
                for item in self.accountViolasTokens! {
                    if item.currency == data.from_coin?.assert?.module {
                        tempItem.from_coin?.assert?.active_state = true
                        tempItem.from_coin?.assert?.amount = item.amount
                        break
                    }
                }
                // 2.判断映射币是否激活
                if data.to_coin?.coin_type?.lowercased() == "libra" {
                    tempItem.to_coin?.assert?.active_state = false
                    for item in self.accountLibraTokens! {
                        if item.currency == data.to_coin?.assert?.module {
                            tempItem.to_coin?.assert?.active_state = true
                            break
                        }
                    }
                } else if data.to_coin?.coin_type?.lowercased() == "btc" {
                    tempItem.to_coin?.assert?.active_state = true
                } else {
                    tempItem.to_coin?.assert?.active_state = false
                }
                tempDatas.append(tempItem)
            } else if data.from_coin?.coin_type?.lowercased() == "libra" {
                // 1.首先判断付出币是否激活
                tempItem.from_coin?.assert?.active_state = false
                for item in self.accountLibraTokens! {
                    if item.currency == data.from_coin?.assert?.module {
                        tempItem.from_coin?.assert?.active_state = true
                        tempItem.from_coin?.assert?.amount = item.amount
                        break
                    }
                }
                // 2.判断映射币是否激活
                if data.to_coin?.coin_type?.lowercased() == "violas" {
                    tempItem.to_coin?.assert?.active_state = false
                    for item in self.accountViolasTokens! {
                        if item.currency == data.to_coin?.assert?.module {
                            tempItem.to_coin?.assert?.active_state = true
                            break
                        }
                    }
                } else if data.to_coin?.coin_type?.lowercased() == "btc" {
                    tempItem.to_coin?.assert?.active_state = true
                } else {
                    tempItem.to_coin?.assert?.active_state = false
                }
                tempDatas.append(tempItem)
            } else if data.from_coin?.coin_type?.lowercased() == "btc" {
                // 1.首先判断付出币是否激活
                tempItem.from_coin?.assert?.active_state = true
                tempItem.from_coin?.assert?.amount = NSDecimalNumber.init(string: self.accountBTCAmount ?? "0").int64Value
                // 2.判断映射币是否激活
                if data.to_coin?.coin_type?.lowercased() == "libra" {
                    tempItem.to_coin?.assert?.active_state = false
                    for item in self.accountLibraTokens! {
                        if item.currency == data.to_coin?.assert?.module {
                            tempItem.to_coin?.assert?.active_state = true
                            break
                        }
                    }
                } else if data.to_coin?.coin_type?.lowercased() == "violas" {
                    tempItem.to_coin?.assert?.active_state = false
                    for item in self.accountViolasTokens! {
                        if item.currency == data.to_coin?.assert?.module {
                            tempItem.to_coin?.assert?.active_state = true
                            break
                        }
                    }
                } else {
                    tempItem.to_coin?.assert?.active_state = false
                }
                tempDatas.append(tempItem)
            } else {
                continue
            }
        }
        DispatchQueue.main.async(execute: {
            let data = setKVOData(type: "MappingInfo", data: tempDatas)
            self.setValue(data, forKey: "dataDic")
        })
    }
}
