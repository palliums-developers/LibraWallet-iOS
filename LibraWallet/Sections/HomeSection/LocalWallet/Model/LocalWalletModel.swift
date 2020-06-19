//
//  LocalWalletModel.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/2/11.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit

class LocalWalletModel: NSObject {
    @objc dynamic var dataDic: NSMutableDictionary = [:]
    func getSupportCoinList() -> [String] {
        return ["wallet_list_total", "violas_icon", "btc_icon", "libra_icon"]
    }
    func loadLocalWallet(walletType: WalletType) {
//        let wallets = DataBaseManager.DBManager.getTokens()//getWalletWithType(walletType: walletType)
//        guard wallets.isEmpty == false else {
//            let data = setKVOData(error: LibraWalletError.error("empty"), type: "LoadLocalWallets")
//            self.setValue(data, forKey: "dataDic")
//            return
//        }
//        let data = setKVOData(type: "LoadLocalWallets", data: wallets)
//        self.setValue(data, forKey: "dataDic")
    }
}
