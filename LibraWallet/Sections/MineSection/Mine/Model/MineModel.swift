//
//  MineModel.swift
//  LibraWallet
//
//  Created by palliums on 2019/10/23.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit

class MineModel: NSObject {
    func getLocalData() -> [[[String: String]]] {
        return [[["name":localLanguage(keyString: "wallet_mine_manager_wallet_title"),
                 "icon":"mine_wallet"]],
                [["name":localLanguage(keyString: "wallet_home_address_manager_title"),
                 "icon":"mine_address_list"]],
                [["name":localLanguage(keyString: "wallet_home_setting_title"),
                 "icon":"mine_setting"]]]
    }
}
