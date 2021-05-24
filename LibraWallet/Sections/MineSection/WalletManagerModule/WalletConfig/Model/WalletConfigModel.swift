//
//  WalletConfigModel.swift
//  LibraWallet
//
//  Created by palliums on 2019/10/28.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit
import BiometricAuthentication
class WalletConfigModel: NSObject {
    func loadLocalConfig() -> [[String: String]] {
        var data = [[String: String]]()
        data.append(["Title": localLanguage(keyString: "wallet_manager_detail_export_mnemonic_title"),
                     "Content": "",
                     "CellIdentifier": "CellNormal"])
        if BioMetricAuthenticator.canAuthenticate() == true {
            if BioMetricAuthenticator.shared.faceIDAvailable() == true {
                data.append(["Title": localLanguage(keyString: "wallet_manager_biological_face_id_title"),
                             "Content": "",
                             "CellIdentifier": "CellSwitch"])
            } else {
                data.append(["Title": localLanguage(keyString: "wallet_manager_biological_finger_touch_id_title"),
                             "Content": "",
                             "CellIdentifier": "CellSwitch"])
            }
        }
        return data
    }
    deinit {
        print("WalletConfigModel销毁了")
    }
}
