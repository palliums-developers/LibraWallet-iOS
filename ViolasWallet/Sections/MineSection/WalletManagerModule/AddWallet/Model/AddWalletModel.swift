//
//  AddWalletModel.swift
//  ViolasWallet
//
//  Created by palliums on 2019/10/25.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit
struct CreateWalletModel {
    var password: String?
    var mnemonic: [String]?
    var wallet: [Token]?
}
class AddWalletModel: NSObject {
    @objc dynamic var dataDic: NSMutableDictionary = [:]
    func createWallet(password: String){
        let quene = DispatchQueue.init(label: "createWalletQuene")
        quene.async {
            do {
                let mnemonic = try DiemMnemonic.generate(strength: .default, language: .english)
                try WalletManager.createWallet(password: password, mnemonic: mnemonic, isImport: false)
                DispatchQueue.main.async(execute: {
                    //需更新
                    let data = setKVOData(type: "CreateWallet", data: mnemonic)
                    self.setValue(data, forKey: "dataDic")
                })
            } catch {
                DispatchQueue.main.async(execute: {
                    //需更新
                    let data = setKVOData(error: LibraWalletError.error(error.localizedDescription), type: "CreateWallet")
                    self.setValue(data, forKey: "dataDic")
                })
                
            }
        }
    }
    deinit {
        print("CreateIdentityWalletModel销毁了")
    }
}
