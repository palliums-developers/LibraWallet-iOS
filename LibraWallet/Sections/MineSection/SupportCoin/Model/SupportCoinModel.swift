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
        return [["name":localLanguage(keyString: "BTC"),
                 "detail":"Bitcoin",
                 "icon":"btc_icon"],
                ["name":localLanguage(keyString: "Lib"),
                 "detail":"Libra",
                 "icon":"libra_icon"],
                ["name":localLanguage(keyString: "Vtoken"),
                 "detail":"Violas",
                 "icon":"violas_icon"]]
    }
}
