//
//  AddAddressModel.swift
//  HKWallet
//
//  Created by palliums on 2019/7/25.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit
import Moya

struct AddressModel: Codable {
    let addressID: Int64?
    let address: String?
    let addressName: String?
    let addressType: String?
}
class AddAddressModel: NSObject {
    @objc var dataDic: NSMutableDictionary = [:]
    //requestStatus: 0:第一页，1:更多
    
    func addWithdrawAddress(address: String, remarks: String, type: String) {
        let model = AddressModel.init(addressID: 999,
                                      address: address,
                                      addressName: remarks,
                                      addressType: type)
        let result = DataBaseManager.DBManager.insertTransferAddress(model: model)
        print(result)
    }
//    deinit {
//        requests.forEach { cancellable in
//            cancellable.cancel()
//        }
//        requests.removeAll()
//        print("WalletReceiveHistoryModel销毁了")
//    }
}
