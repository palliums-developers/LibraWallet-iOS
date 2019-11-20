//
//  AddWalletModel.swift
//  LibraWallet
//
//  Created by palliums on 2019/10/25.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit
struct CreateWalletModel {
    var password: String?
    var mnemonic: [String]?
    var wallet: LibraWalletManager?
}


class AddWalletModel: NSObject {
    func createViolasWallet(walletName: String) {
        do {
            #warning("主线程阻塞,待处理")
            let mnemonic = try LibraMnemonic.generate(strength: .default, language: .english)
            let seed = try LibraMnemonic.seed(mnemonic: mnemonic)
            let wallet = try LibraWallet.init(seed: seed, depth: 0)
            let walletModel = LibraWalletManager.init(walletID: 999,
                                                      walletBalance: 0,
                                                      walletAddress: wallet.publicKey.toAddress(),
                                                      walletRootAddress: "Violas_" + wallet.publicKey.toAddress(),
                                                      walletCreateTime: Int(NSDate().timeIntervalSince1970),
                                                      walletName: walletName,
                                                      walletCurrentUse: false,
                                                      walletBiometricLock: false,
                                                      walletIdentity: 1,
                                                      walletType: .Violas)
            guard DataBaseManager.DBManager.isExistAddressInWallet(address: wallet.publicKey.toAddress()) == false else {
//                self.view.hideToastActivity()
//                self.view.makeToast("已存在", position: .center)
                return
            }
        } catch {
            
        }
    }
}
