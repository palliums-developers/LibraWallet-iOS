//
//  MineModel.swift
//  LibraWallet
//
//  Created by palliums on 2019/10/23.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit

class MineModel: NSObject {
    func getLocalData() -> [[String: String]] {
        return [["name":"钱包管理",
                 "icon":"mine_wallet"],
                ["name":"转账记录",
                 "icon":"mine_transfer_list"],
                ["name":"地址簿",
                 "icon":"mine_address_list"],
                ["name":"设置",
                 "icon":"mine_setting"]]
    }
}
