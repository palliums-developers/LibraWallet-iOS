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
        return [[["name":localLanguage(keyString: "多语言"),
                 "icon":""],
                ["name":localLanguage(keyString: "服务协议"),
                 "icon":""]],
                [["name":localLanguage(keyString: "关于我们"),
                 "icon":""]],
                [["name":localLanguage(keyString: "帮助与反馈"),
                 "icon":""]]]
    }
}
