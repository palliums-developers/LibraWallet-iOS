//
//  SupportCoinModel.swift
//  LibraWallet
//
//  Created by palliums on 2019/10/24.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit

class SupportCoinModel: NSObject {
    func getSupportCoinData() -> [[String: String]] {
        return [["name":localLanguage(keyString: "vtoken"),
                 "detail":"Violas",
                 "icon":"violas_icon"],
                ["name":localLanguage(keyString: "BTC"),
                 "detail":"Bitcoin",
                 "icon":"btc_icon"],
                ["name":localLanguage(keyString: "Libra"),
                 "detail":"Libra",
                 "icon":"libra_icon"]
                ]
    }
    deinit {
        print("SupportCoinModel销毁了")
    }
}
