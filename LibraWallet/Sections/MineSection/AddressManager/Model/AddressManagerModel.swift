//
//  AddressManagerModel.swift
//  HKWallet
//
//  Created by palliums on 2019/7/25.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit
import Moya
class AddressManagerModel: NSObject {
    @objc var dataDic: NSMutableDictionary = [:]
    func getWithdrawAddressHistory(type: String, requestStatus: Int) {
        //requestStatus: 0:第一页，1:更多
        let dataType = requestStatus == 0 ? "TransferAddressOrigin":"TransferAddressMore"
        let dataArray = DataBaseManager.DBManager.getTransferAddress(type: type)
        guard dataArray.count != 0 else {
            let data = setKVOData(error: LibraWalletError.WalletRequest(reason: .dataEmpty), type: dataType)
            self.setValue(data, forKey: "dataDic")
            return
        }
        let data = setKVOData(type: dataType, data: dataArray)
        self.setValue(data, forKey: "dataDic")
    }
    deinit {
        print("AddressManagerModel销毁了")
    }
}
