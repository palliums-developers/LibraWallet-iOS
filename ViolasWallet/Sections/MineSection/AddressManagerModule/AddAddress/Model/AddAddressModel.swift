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
    let addressID: Int64
    let address: String
    let addressName: String
    let addressType: String
}
class AddAddressModel: NSObject {
    @objc var dataDic: NSMutableDictionary = [:]
    func addWithdrawAddress(address: String, remarks: String, type: String) {
        let model = AddressModel.init(addressID: 999,
                                      address: address,
                                      addressName: remarks,
                                      addressType: type)
        do {
            try WalletManager.addContact(model: model)
            let data = setKVOData(type: "AddAddress", data: model)
            self.setValue(data, forKey: "dataDic")
        } catch {
            let data = setKVOData(error: LibraWalletError.WalletAddAddress(reason: .addressInsertError), type: "AddAddress")
            self.setValue(data, forKey: "dataDic")
        }
    }
    deinit {
        print("AddAddressModel销毁了")
    }
}
