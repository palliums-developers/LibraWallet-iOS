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
import SwiftGRPC
struct TokenMappingDataModel: Codable {
    /// 待映射币名称
    var pay_name: String?
    /// 映射币名称
    var name: String?
    /// 映射合约
    var module: String?
    /// 待映射币接收地址
    var address: String?
    /// 映射比率
    var rate: Double
}
struct TokenMappingMainModel: Codable {
    var code: Int?
    var message: String?
    var data: TokenMappingDataModel?
}
struct TokenMappingListDataModel: Codable {
    /// 映射币名称
    var mapping_name: String?
    /// 映射合约
    var module: String?
    /// 待映射币接收地址
    var receice_address: String?
    /// 映射比率
    var rate: Double
    /// 反向映射名字
    var mapping_reverse_name: String?
}
struct TokenMappingListMainModel: Codable {
    var code: Int?
    var message: String?
    var data: [TokenMappingListDataModel]?
}
class TokenMappingModel: NSObject {
    private var requests: [Cancellable] = []
    @objc var dataDic: NSMutableDictionary = [:]
    func getMappingInfo(walletType: WalletType) {
//        let model = getLocalModel(walletType: walletType)
//        let data = setKVOData(type: "MappingInfo", data: model)
//        self.setValue(data, forKey: "dataDic")
        
        let request = mainProvide.request(.GetMappingInfo(walletType.description)) {[weak self](result) in
            switch  result {
            case let .success(response):
                do {
                    var json = try response.map(TokenMappingMainModel.self)
                    print(try response.mapString())
                    if json.code != 2000 {
                        let data = setKVOData(error: LibraWalletError.error(json.message ?? ""), type: "MappingInfo")
                        self?.setValue(data, forKey: "dataDic")
                    } else {
                        json.data?.pay_name = walletType.description
                        let data = setKVOData(type: "MappingInfo", data: json.data)
                        self?.setValue(data, forKey: "dataDic")
                    }
                } catch {
                    print("SendBTCTransaction_解析异常\(error.localizedDescription)")
                    let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.parseJsonError), type: "MappingInfo")
                    self?.setValue(data, forKey: "dataDic")
                }
            case let .failure(error):
                guard error.errorCode != -999 else {
                    print("SendBTCTransaction_网络请求已取消")
                    return
                }
                let data = setKVOData(error: LibraWalletError.WalletRequest(reason: .networkInvalid), type: "MappingInfo")
                self?.setValue(data, forKey: "dataDic")
            }
        }
        self.requests.append(request)

    }
//    func getLocalModel(walletType: WalletType) -> TokenMappingDataModel {
//        switch walletType {
//        case .BTC:
//            // 兑换VBTC
//            let model = TokenMappingDataModel.init(pay_name: walletType.description,
//                                                   exchange_name: "VBTC",
//                                                   exchange_contract: "af955c1d62a74a7543235dbb7fa46ed98948d2041dff67dfdb636a54e84f91fb",
//                                                   exchange_receive_address: "2MxBZG7295wfsXaUj69quf8vucFzwG35UWh",
//                                                   exchange_rate: 1)
//            return model
//        case .Violas:
//            #warning("待定")
////            let model = TokenMappingDataModel.init(pay_name: walletType.description,
////                                                   exchange_name: "BTC",
////                                                   exchange_contract: "af955c1d62a74a7543235dbb7fa46ed98948d2041dff67dfdb636a54e84f91fb",
////                                                   exchange_receive_address: "fd0426fa9a3ba4fae760d0f614591c61bb53232a3b1138d5078efa11ef07c49c",
////                                                   exchange_rate: 1)
////            return model
//            let model = TokenMappingDataModel.init(pay_name: walletType.description,
//                                                   exchange_name: "Libra",
//                                                   exchange_contract: "61b578c0ebaad3852ea5e023fb0f59af61de1a5faf02b1211af0424ee5bbc410",
//                                                   exchange_receive_address: "fd0426fa9a3ba4fae760d0f614591c61bb53232a3b1138d5078efa11ef07c49c",
//                                                   exchange_rate: 1)
//            return model
//        case .Libra:
//            // 兑换VLibra
//            let model = TokenMappingDataModel.init(pay_name: walletType.description,
//                                                   exchange_name: "VLibra",
//                                                   exchange_contract: "61b578c0ebaad3852ea5e023fb0f59af61de1a5faf02b1211af0424ee5bbc410",
//                                                   exchange_receive_address: "29223f25fe4b74d75ca87527aed560b2826f5da9382e2fb83f9ab740ac40b8f7",
//                                                   exchange_rate: 1)
//            return model
//        }
//    }
    func getWalletEnableToken(address: String, contract: String) {
        let request = mainProvide.request(.GetViolasAccountEnableToken(address)) {[weak self](result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(ViolasAccountEnableTokenResponseModel.self)
                    if json.code != 2000 {
                        let data = setKVOData(error: LibraWalletError.error(json.message ?? ""), type: "GetWalletEnableCoin")
                        self?.setValue(data, forKey: "dataDic")
                    } else {
                        guard let models = json.data, models.isEmpty == false else {
                            let data = setKVOData(type: "GetWalletEnableCoin", data: false)
                            self?.setValue(data, forKey: "dataDic")
                            return
                        }
                        let tempResult = models.filter { item in
                            item == contract
                        }
                        if tempResult.isEmpty == true {
                            let data = setKVOData(type: "GetWalletEnableCoin", data: false)
                            self?.setValue(data, forKey: "dataDic")
                        } else {
                            let data = setKVOData(type: "GetWalletEnableCoin", data: true)
                            self?.setValue(data, forKey: "dataDic")
                        }
                    }
                } catch {
                    print("GetWalletEnableCoin_解析异常\(error.localizedDescription)")
                    let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.parseJsonError), type: "GetWalletEnableCoin")
                    self?.setValue(data, forKey: "dataDic")
                }
            case let .failure(error):
                guard error.errorCode != -999 else {
                    print("GetWalletEnableCoin_网络请求已取消")
                    return
                }
                let data = setKVOData(error: LibraWalletError.WalletRequest(reason: .networkInvalid), type: "GetWalletEnableCoin")
                self?.setValue(data, forKey: "dataDic")
            }
        }
        self.requests.append(request)
    }
    var utxos: [BTCUnspentUTXOListModel]?
    private var sequenceNumber: Int?
    deinit {
        requests.forEach { cancellable in
            cancellable.cancel()
        }
        requests.removeAll()
        print("TokenMappingModel销毁了")
    }
}
//MARK: - BTC
extension TokenMappingModel {
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
}
//MARK: - Libra
extension TokenMappingModel {
    fileprivate func getSequenceNumber(client: AdmissionControl_AdmissionControlServiceClient, wallet: LibraWallet) throws -> UInt64 {
            do {
                var stateRequest = Types_GetAccountStateRequest()
                stateRequest.address = Data.init(hex: wallet.publicKey.toAddress())
                
                var sequenceRequest = Types_RequestItem()
                sequenceRequest.getAccountStateRequest = stateRequest
                
                var requests = Types_UpdateToLatestLedgerRequest()
                requests.requestedItems = [sequenceRequest]
                
                let result = try client.updateToLatestLedger(requests)

                guard let response = result.responseItems.first else {
                    throw LibraWalletError.error("Data empty")
                }
                let streamData = response.getAccountStateResponse.accountStateWithProof.blob.blob
                
                guard let sequenceNumber = LibraAccount.init(accountData: streamData).sequenceNumber else {
                    throw LibraWalletError.error("Sequence number error")
                }
                return UInt64(sequenceNumber)
            } catch {
                throw error
            }
        }
    func transfer(address: String, amount: Double, mnemonic: [String])  {
        // 创建通道
        let channel = Channel.init(address: libraMainURL, secure: false)
        // 创建请求端
        let client = AdmissionControl_AdmissionControlServiceClient.init(channel: channel)
        
        let queue = DispatchQueue.init(label: "TransferQueue")
        queue.async {
            do {
                let wallet = try LibraManager.getWallet(mnemonic: mnemonic)
                
                // 获取SequenceNumber
                let sequenceNumber = try self.getSequenceNumber(client: client, wallet: wallet)
                // 拼接交易
                let request = LibraTransaction.init(sendAddress: wallet.publicKey.toAddress(),
                                                    amount: amount,
                                                    fee: 0,
                                                    sequenceNumber: sequenceNumber,
                                                    libraReceiveAddress: address)
                // 签名交易
                let aaa = try wallet.privateKey.signTransaction(transaction: request.request, wallet: wallet)
                print(aaa.toHexString())
                // 拼接签名请求
                var signedTransation = Types_SignedTransaction.init()
                signedTransation.txnBytes = aaa
                // 组装请求
                var mission = AdmissionControl_SubmitTransactionRequest.init()
                mission.transaction = signedTransation
                // 发送请求
                let response = try client.submitTransaction(mission)
                if response.acStatus.code == AdmissionControl_AdmissionControlStatusCode.accepted {
                    DispatchQueue.main.async(execute: {
                        let data = setKVOData(type: "Transfer")
                        self.setValue(data, forKey: "dataDic")
                    })
                } else {
                    DispatchQueue.main.async(execute: {
                        print(response.acStatus.message)
                        let data = setKVOData(error: LibraWalletError.error("转账失败"), type: "Transfer")
                        self.setValue(data, forKey: "dataDic")
                    })
                }
            } catch {
//                print(error)
                print(error.localizedDescription)
            }
        }
        
    }
}
//MARK: - VLibra
extension TokenMappingModel {
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
    func sendVLibraTransaction(sendAddress: String, receiveAddress: String, amount: Double, fee: Double, mnemonic: [String], contact: String) {
        let semaphore = DispatchSemaphore.init(value: 1)
        let queue = DispatchQueue.init(label: "SendQueue")
        queue.async {
            self.getViolasSequenceNumber(sendAddress: sendAddress, semaphore: semaphore, queue: queue)
        }
        queue.async {
            semaphore.wait()
            do {
                let signature = try ViolasManager.getVLibraToLibraTransactionHex(sendAddress: sendAddress,
                                                                             amount: amount,
                                                                             fee: fee,
                                                                             mnemonic: mnemonic,
                                                                             contact: contact,
                                                                             sequenceNumber: self.sequenceNumber!,
                                                                             libraReceiveAddress: receiveAddress)
                self.makeViolasTransaction(signature: signature, type: "SendVLibraTransaction")
            } catch {
                print(error.localizedDescription)
                DispatchQueue.main.async(execute: {
                    let data = setKVOData(error: LibraWalletError.error(error.localizedDescription), type: "SendVLibraTransaction")
                    self.setValue(data, forKey: "dataDic")
                })
            }
            semaphore.signal()
        }
        
    }
    private func makeViolasTransaction(signature: String, type: String) {
        let request = mainProvide.request(.SendViolasTransaction(signature)) {[weak self](result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(ViolaSendTransactionMainModel.self)
                    guard json.code == 2000 else {
                        DispatchQueue.main.async(execute: {
                            let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.dataCodeInvalid), type: type)
                            self?.setValue(data, forKey: "dataDic")
                        })
                        return
                    }
                    DispatchQueue.main.async(execute: {
                        let data = setKVOData(type: type)
                        self?.setValue(data, forKey: "dataDic")
                    })
                    // 刷新本地数据
                } catch {
                    print("解析异常\(error.localizedDescription)")
                    DispatchQueue.main.async(execute: {
                        let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.parseJsonError), type: type)
                        self?.setValue(data, forKey: "dataDic")
                    })
                }
            case let .failure(error):
                guard error.errorCode != -999 else {
                    print("网络请求已取消")
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
//MARK: - VBTC
extension TokenMappingModel {
    func sendVBTCTransaction(sendAddress: String, receiveAddress: String, amount: Double, fee: Double, mnemonic: [String], contact: String) {
        let semaphore = DispatchSemaphore.init(value: 1)
        let queue = DispatchQueue.init(label: "SendQueue")
        queue.async {
            self.getViolasSequenceNumber(sendAddress: sendAddress, semaphore: semaphore, queue: queue)
        }
        queue.async {
            semaphore.wait()
            do {
                let signature = try ViolasManager.getVBTCToBTCTransactionHex(sendAddress: sendAddress,
                                                                             amount: amount,
                                                                             fee: fee,
                                                                             mnemonic: mnemonic,
                                                                             contact: contact,
                                                                             sequenceNumber: self.sequenceNumber!,
                                                                             btcAddress: receiveAddress)
                self.makeViolasTransaction(signature: signature, type: "SendVBTCTransaction")
            } catch {
                print(error.localizedDescription)
                DispatchQueue.main.async(execute: {
                    let data = setKVOData(error: LibraWalletError.error(error.localizedDescription), type: "SendVBTCTransaction")
                    self.setValue(data, forKey: "dataDic")
                })
            }
            semaphore.signal()
        }
    }
}
extension TokenMappingModel {
    func publishViolasToken(sendAddress: String, mnemonic: [String], contact: String) {
        let semaphore = DispatchSemaphore.init(value: 1)
        let queue = DispatchQueue.init(label: "SendQueue")
        queue.async {
            self.getViolasSequenceNumber(sendAddress: sendAddress, semaphore: semaphore, queue: queue)
        }
        queue.async {
            semaphore.wait()
            do {
                let signature = try ViolasManager.getRegisterTokenTransactionHex(mnemonic: mnemonic,
                                                                                  contact: contact,
                                                                                  sequenceNumber: self.sequenceNumber!)
                self.makeViolasTransaction(signature: signature, type: "SendPublishTransaction")
            } catch {
                print(error.localizedDescription)
                DispatchQueue.main.async(execute: {
                    let data = setKVOData(error: LibraWalletError.error(error.localizedDescription), type: "SendPublishTransaction")
                    self.setValue(data, forKey: "dataDic")
                })
            }
            semaphore.signal()
        }
    }
}
extension TokenMappingModel {
    func getMappingTokenList(walletAddress: String) {
        let request = mainProvide.request(.GetMappingTokenList(walletAddress)) {[weak self](result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(TokenMappingListMainModel.self)
                    guard json.code == 2000 else {
                        let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.dataCodeInvalid), type: "MappingTokenList")
                        self?.setValue(data, forKey: "dataDic")
                        return
                    }
                    let data = setKVOData(type: "MappingTokenList", data: json.data)
                    self?.setValue(data, forKey: "dataDic")
                    // 刷新本地数据
                } catch {
                    print("解析异常\(error.localizedDescription)")
                    let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.parseJsonError), type: "MappingTokenList")
                    self?.setValue(data, forKey: "dataDic")
                }
            case let .failure(error):
                guard error.errorCode != -999 else {
                    print("网络请求已取消")
                    return
                }
                let data = setKVOData(error: LibraWalletError.WalletRequest(reason: .networkInvalid), type: "MappingTokenList")
                self?.setValue(data, forKey: "dataDic")
            }
        }
        self.requests.append(request)
    }
}
