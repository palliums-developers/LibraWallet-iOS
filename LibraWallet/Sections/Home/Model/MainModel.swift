//
//  MainModel.swift
//  LibraWallet
//
//  Created by palliums on 2019/9/11.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit
import SwiftGRPC
import Moya
class MainModel: NSObject {
    private var requests: [Cancellable] = []
    @objc var dataDic: NSMutableDictionary = [:]
    func getLocalUserInfo() {
//        let result = DataBaseManager.DBManager.loadCurrentUseWallet()
//        if result == false {
//            // 需要创建钱包
//            let data = setKVOData(error: LibraWalletError.WalletRequest(reason: .walletNotExist), type: "LoadLocalWallet")
//            self.setValue(data, forKey: "dataDic")
//        } else {
//            let data = setKVOData(type: "LoadLocalWallet")
//            self.setValue(data, forKey: "dataDic")
//            // 更新本地数据
//            updateLocalInfo(walletAddress: LibraWalletManager.shared.walletAddress!)
//        }
    }
    func updateLocalInfo(walletAddress: String) {
        
        let channel = Channel.init(address: libraMainURL, secure:  false)
        
        let client = AdmissionControl_AdmissionControlServiceClient.init(channel: channel)
        do {
            var jjj = Types_GetAccountStateRequest()
            jjj.address = Data.init(hex: walletAddress)
            
            var item = Types_RequestItem()
            item.getAccountStateRequest = jjj
            
            var sequenceNumber = Types_UpdateToLatestLedgerRequest()
            sequenceNumber.requestedItems = [item]
            
            let gaaa = try client.updateToLatestLedger(sequenceNumber)
            
            guard let response = gaaa.responseItems.first else {
                return
            }
            let streamData = response.getAccountStateResponse.accountStateWithProof.blob.blob
            
            let balance = LibraAccount.init(accountData: streamData).balance
            updateLocalWalletData(walletID: LibraWalletManager.shared.walletID!, model: LibraAccount.init(accountData: streamData))
            let data = setKVOData(type: "UpdateLocalWallet", data: balance)
            self.setValue(data, forKey: "dataDic")
            
        } catch {
            print(error.localizedDescription)
        }
    }
    func updateLocalWalletData(walletID: Int64,model: LibraAccount) {
        // 更新内存中数据
        LibraWalletManager.shared.changeWalletBalance(banlance: model.balance ?? 0)
        
        // 刷新本地缓存数据
        _ = DataBaseManager.DBManager.updateWalletBalance(walletID: walletID, balance: model.balance ?? 0)
    }
    func getTestCoin(address: String, amount: Int64) {
        let request = mainProvide.request(.GetTestCoin(address, amount)) {[weak self](result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.mapString()
                    print(json)
                    let data = setKVOData(type: "GetTestCoin")
                    self?.setValue(data, forKey: "dataDic")
                } catch {
                    print("解析异常\(error.localizedDescription)")
//                    let data = setKVOData(error: HKWalletError.WalletRequestError(reason: .parseJsonError), type: "UserInfoOnline")
//                    self?.setValue(data, forKey: "dataDic")
                }
            case let .failure(error):
                guard error.errorCode != -999 else {
                    print("网络请求已取消")
                    return
                }
                print(error.localizedDescription)
//                let data = setKVOData(error: HKWalletError.WalletRequestError(reason: .networkInvalid), type: "GetTestCoin")
//                self?.setValue(data, forKey: "dataDic")
            }
        }
        self.requests.append(request)
    }
    deinit {
        requests.forEach { cancellable in
            cancellable.cancel()
        }
        requests.removeAll()
        print("MainModel销毁了")
    }
}
