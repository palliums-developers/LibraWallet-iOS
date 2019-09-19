//
//  TransferModel.swift
//  LibraWallet
//
//  Created by palliums on 2019/9/16.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit
import SwiftGRPC
class TransferModel: NSObject {
    @objc var dataDic: NSMutableDictionary = [:]
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
    func transfer(address: String, amount: Double, wallet: LibraWallet)  {
        // 创建通道
        let channel = Channel.init(address: libraMainURL, secure: false)
        // 创建请求端
        let client = AdmissionControl_AdmissionControlServiceClient.init(channel: channel)
        
        let queue = DispatchQueue.init(label: "TransferQueue")
        queue.async {
            do {
                // 获取SequenceNumber
                let sequenceNumber = try self.getSequenceNumber(client: client, wallet: wallet)
                // 拼接交易
                let request = LibraTransaction.init(receiveAddress: address, amount: amount, sendAddress: wallet.publicKey.toAddress(), sequenceNumber: sequenceNumber)
                // 签名交易
                let aaa = try wallet.privateKey.signTransaction(transaction: request.request, wallet: wallet)
                // 组装请求
                var mission = AdmissionControl_SubmitTransactionRequest.init()
                mission.signedTxn = aaa
                // 发送请求
                let response = try client.submitTransaction(mission)
                if response.acStatus.code == AdmissionControl_AdmissionControlStatusCode.accepted {
                    DispatchQueue.main.async(execute: {
                        let data = setKVOData(type: "Transfer")
                        self.setValue(data, forKey: "dataDic")
                    })
                } else {
                    DispatchQueue.main.async(execute: {
                        let data = setKVOData(error: LibraWalletError.error("转账失败"), type: "Transfer")
                        self.setValue(data, forKey: "dataDic")
                    })
                }
            } catch {
                print(error.localizedDescription)
            }
        }
        
    }
}
