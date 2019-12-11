//
//  SettingModel.swift
//  LibraWallet
//
//  Created by palliums on 2019/10/23.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit

class SettingModel: NSObject {
    func getSettingLocalData() -> [[[String: String]]] {
        return [[["name":localLanguage(keyString: "wallet_setting_language_title"),
                 "icon":""],
                ["name":localLanguage(keyString: "wallet_setting_service_legal_title"),
                 "icon":""],
                ["name":localLanguage(keyString: "wallet_private_service_legal_title"),
                 "icon":""]],
                [["name":localLanguage(keyString: "wallet_setting_about_us_title"),
                 "icon":""]],
                [["name":localLanguage(keyString: "wallet_setting_help_center_title"),
                 "icon":""]]]
    }
}
