//
//  TransactionHistoryModel.swift
//  LibraWallet
//
//  Created by palliums on 2019/9/17.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit
import Moya
struct Transaction: Codable {
    let amount: String?
    let fromAddress: String?
    let toAddress: String?
    let date: String?
    let transactionVersion: Int?
    let explorerLink: String?
    let event: String?
    let type: String?
}

struct TransactionsModel: Codable {
    let transactions: [Transaction]?
    
}
class TransactionHistoryModel: NSObject {
    private var requests: [Cancellable] = []
    @objc var dataDic: NSMutableDictionary = [:]
    //requestStatus: 0:第一页，1:更多
    func getTransactionHistory(address: String, offset: Int, requestStatus: Int) {
        let type = requestStatus == 0 ? "TransactionHistoryOrigin":"TransactionHistoryMore"
        let request = mainProvide.request(.GetTransactionHistory(address, 0)) {[weak self](result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(TransactionsModel.self)
                    if let listData = json.transactions, listData.isEmpty == false {
                        let data = setKVOData(type: type, data: listData)
                        self?.setValue(data, forKey: "dataDic")
                    } else {
                        print("解析失败")
//                        let data = setKVOData(error: HKWalletError.error(json.message ?? ""), type: type)
//                        self?.setValue(data, forKey: "dataDic")
                    }
                } catch {
                    print("解析异常\(error.localizedDescription)")
//                    let data = setKVOData(error: HKWalletError.WalletRequestError(reason: .parseJsonError), type: type)
//                    self?.setValue(data, forKey: "dataDic")
                }
            case let .failure(error):
                guard error.errorCode != -999 else {
                    print("网络请求已取消")
                    return
                }
                print(error.localizedDescription)
//                let data = setKVOData(error: HKWalletError.WalletRequestError(reason: .networkInvalid), type: type)
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
        print("BalanceHistoryModel销毁了")
    }
}

