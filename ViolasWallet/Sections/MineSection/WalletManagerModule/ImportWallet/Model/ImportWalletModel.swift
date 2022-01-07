//
//  ImportWalletModel.swift
//  ViolasWallet
//
//  Created by palliums on 2019/10/28.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit
class ImportWalletModel: NSObject {
    @objc dynamic var dataDic: NSMutableDictionary = [:]
    func importWallet(password: String, mnemonic: [String]) {
        let quene = DispatchQueue.init(label: "createWalletQuene")
        quene.async {
            do {
                try WalletManager.createWallet(password: password, mnemonic: mnemonic, isImport: true)
                DispatchQueue.main.async(execute: {
                    // 需更新
                    let data = setKVOData(type: "ImportWallet")
                    self.setValue(data, forKey: "dataDic")
                })
            } catch {
                DispatchQueue.main.async(execute: {
                    // 需更新
                    let data = setKVOData(error: LibraWalletError.error(error.localizedDescription), type: "ImportWallet")
                    self.setValue(data, forKey: "dataDic")
                })
            }
        }
    }
    deinit {
        print("ImportWalletModel销毁了")
    }
}
