//
//  WalletManagerModel.swift
//  LibraWallet
//
//  Created by palliums on 2019/10/24.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit

class WalletManagerModel: NSObject {
    @objc var dataDic: NSMutableDictionary = [:]
    func loadLocalWallet() {
        let wallets = DataBaseManager.DBManager.getLocalWallets()
        guard wallets.isEmpty == false else {
            let data = setKVOData(error: LibraWalletError.error("empty"), type: "LoadLocalWallets")
            self.setValue(data, forKey: "dataDic")
            return
        }
        let data = setKVOData(type: "LoadLocalWallets", data: wallets)
        self.setValue(data, forKey: "dataDic")
    }
}
