//
//  CreateWalletModel.swift
//  LibraWallet
//
//  Created by palliums on 2019/10/18.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit

class CreateWalletModel: NSObject {
    func createWallet(walletName: String, password: String) {
        do {
            let result = try LibraWalletManager.shared.createLibraWallet()
            print(result)
        } catch {
            print(error.localizedDescription)
        }
    }
}
