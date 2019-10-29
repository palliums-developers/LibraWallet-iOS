//
//  WalletDetailModel.swift
//  LibraWallet
//
//  Created by palliums on 2019/10/28.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit

class WalletDetailModel: NSObject {
    func loadLocalConfig(model: LibraWalletManager) -> [[String: String]]{
        return [["Title": model.walletName ?? "",
                 "Content": model.walletAddress ?? ""],
                ["Title": "导出助记词",
                 "Content": ""]]
        
    }
}
