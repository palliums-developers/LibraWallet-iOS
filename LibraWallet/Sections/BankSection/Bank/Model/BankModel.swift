//
//  BankModel.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/8/19.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit
import Moya
struct BankModelMainDataModel: Codable {
    /// 存款总额
    var amount: Double?
    /// 可借总额度
    var borrow: Double?
    /// 当前限额
    var borrow_limit: Double?
    /// 累计收益
    var total: Double?
    /// 昨日收益
    var yesterday: Double?
}
struct BankModelMainModel: Codable {
    var code: Int?
    var message: String?
    var data: BankModelMainDataModel?
}
class BankModel: NSObject {
    private var requests: [Cancellable] = []
    @objc dynamic var dataDic: NSMutableDictionary = [:]
    deinit {
        requests.forEach { cancellable in
            cancellable.cancel()
        }
        requests.removeAll()
        print("BankModel销毁了")
    }
    func getBankAccountInfo(address: String) {
        let request = mainProvide.request(.bankAccountInfo(address)) {[weak self](result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(BankModelMainModel.self)
                    if json.code == 2000 {
                        guard let models = json.data else {
                            let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.dataEmpty), type: "GetBankAccountInfo")
                            self?.setValue(data, forKey: "dataDic")
                            print("GetBankAccountInfo_状态异常")
                            return
                        }
                        let data = setKVOData(type: "GetBankAccountInfo", data: models)
                        self?.setValue(data, forKey: "dataDic")
                    } else {
                        print("GetBankAccountInfo_状态异常")
                        if let message = json.message, message.isEmpty == false {
                            let data = setKVOData(error: LibraWalletError.error(message), type: "GetBankAccountInfo")
                            self?.setValue(data, forKey: "dataDic")
                        } else {
                            let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.dataCodeInvalid), type: "GetBankAccountInfo")
                            self?.setValue(data, forKey: "dataDic")
                        }
                    }
                } catch {
                    print("GetBankAccountInfo_解析异常\(error.localizedDescription)")
                    let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.parseJsonError), type: "GetBankAccountInfo")
                    self?.setValue(data, forKey: "dataDic")
                }
            case let .failure(error):
                guard error.errorCode != -999 else {
                    print("GetBankAccountInfo_网络请求已取消")
                    return
                }
                let data = setKVOData(error: LibraWalletError.WalletRequest(reason: .networkInvalid), type: "GetBankAccountInfo")
                self?.setValue(data, forKey: "dataDic")
            }
        }
        self.requests.append(request)
    }
}
