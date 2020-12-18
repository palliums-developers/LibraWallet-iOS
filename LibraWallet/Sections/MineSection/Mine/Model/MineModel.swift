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
                [["name":localLanguage(keyString: "wallet_mine_address_manager_title"),
                  "icon":"mine_address_list"]],
                [["name":localLanguage(keyString: "wallet_mine_yield_farming_button_title"),
                  "icon":"mine_yield_farming_rule"]],
                [["name":localLanguage(keyString: "wallet_mine_invitation_reward_title"),
                  "icon":"mine_invitation_reward"]],
                [["name":localLanguage(keyString: "wallet_mine_setting_title"),
                  "icon":"mine_setting"]]]
//        return [[["name":localLanguage(keyString: "wallet_mine_manager_wallet_title"),
//                 "icon":"mine_wallet"]],
//                [["name":localLanguage(keyString: "wallet_mine_address_manager_title"),
//                 "icon":"mine_address_list"]],
//                [["name":localLanguage(keyString: "wallet_mine_setting_title"),
//                 "icon":"mine_setting"]],
//                [["name":localLanguage(keyString: "ActiveAccount(Beta)"),"icon":"mine_setting"]]]
        
    }
}

