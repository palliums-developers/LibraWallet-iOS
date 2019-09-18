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
    fileprivate func getSequenceNumber(channel: Channel, client: AdmissionControl_AdmissionControlServiceClient) throws -> UInt64 {
        do {
            var stateRequest = Types_GetAccountStateRequest()
            stateRequest.address = Data.init(hex: LibraWalletManager.wallet.walletAddress ?? "")
            
            var sequenceRequest = Types_RequestItem()
            sequenceRequest.getAccountStateRequest = stateRequest
            
            var requests = Types_UpdateToLatestLedgerRequest()
            requests.requestedItems = [sequenceRequest]
            
            let gaaa = try client.updateToLatestLedger(requests)

            guard let response = gaaa.responseItems.first else {
                throw LibraWalletError.error("error")
            }
            let streamData = response.getAccountStateResponse.accountStateWithProof.blob.blob
            return UInt64(LibraAccount.init(accountData: streamData).sequenceNumber ?? 0)
//            let data = setKVOData(type: "UpdateLocalWallet", data: balance)
//            self.setValue(data, forKey: "dataDic")
        } catch {
            throw error
//            print(error.localizedDescription)
        }
    }
    func transfer(address: String, amount: Double)  {
        // 创建通道
        let channel = Channel.init(address: libraMainURL, secure: false)
        // 创建请求端
        let client = AdmissionControl_AdmissionControlServiceClient.init(channel: channel)
        
        let queue = DispatchQueue.init(label: "TransferQueue")
        queue.async {
            do {
                let sequenceNumber = try self.getSequenceNumber(channel: channel, client: client)
                
                let request = LibraTransaction.init(receiveAddress: address, amount: amount, wallet: LibraWalletManager.wallet.wallet!, sequenceNumber: sequenceNumber)
                
                let response = try client.submitTransaction(request.request)
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
