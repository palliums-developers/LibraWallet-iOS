//
//  WalletDetailModel.swift
//  LibraWallet
//
//  Created by palliums on 2019/10/28.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit
import BiometricAuthentication
class WalletDetailModel: NSObject {
    func loadLocalConfig(model: LibraWalletManager) -> [[[String: String]]] {
        var data = [[[String: String]]]()
        data.append([["Title": model.walletName ?? "",
                      "Content": model.walletAddress ?? "",
                      "CellIdentifier": "CellNormal"]])
        if BioMetricAuthenticator.canAuthenticate() == true {
            if BioMetricAuthenticator.shared.faceIDAvailable() == true {
                data.append([["Title": localLanguage(keyString: "wallet_manager_detail_export_mnemonic_title"),
                              "Content": "",
                              "CellIdentifier": "CellNormal"],
                             ["Title": localLanguage(keyString: "wallet_manager_biological_face_id_title"),
                              "Content": "",
                              "CellIdentifier": "CellSwitch"]])
            } else {
                data.append([["Title": localLanguage(keyString: "wallet_manager_detail_export_mnemonic_title"),
                              "Content": "",
                              "CellIdentifier": "CellNormal"],
                             ["Title": localLanguage(keyString: "wallet_manager_biological_finger_touch_id_title"),
                              "Content": "",
                              "CellIdentifier": "CellSwitch"]])
            }
        } else {
            data.append([["Title": localLanguage(keyString: "wallet_manager_detail_export_mnemonic_title"),
                         "Content": "",
                         "CellIdentifier": "CellNormal"]])
        }
        return data
//        return [["Title": model.walletName ?? "",
//                 "Content": model.walletAddress ?? ""],
//                ["Title": localLanguage(keyString: "wallet_manager_detail_export_mnemonic_title"),
//                 "Content": ""]]
        
    }
    deinit {
        print("WalletDetailModel销毁了")
    }
}
