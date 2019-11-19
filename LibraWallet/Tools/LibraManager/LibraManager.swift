//
//  LibraManager.swift
//  LibraWallet
//
//  Created by palliums on 2019/11/11.
//  Copyright © 2019 palliums. All rights reserved.
//

import Foundation

struct LibraManager {
    /// 获取助词数组
    ///
    /// - Returns: 助词数组
    func getLibraMnemonic() -> [String] {
        do {
            let mnemonic = try LibraMnemonic.generate(strength: .veryHigh, language: .english)
            return mnemonic
        } catch {
            print(error.localizedDescription)
            return []
        }
    }
    /// 获取Libra钱包对象
    ///
    /// - Parameter mnemonic: 助词数组
    /// - Returns: 钱包对象
    func getWallet(mnemonic: [String]) throws -> LibraWallet {
        do {
            let seed = try LibraMnemonic.seed(mnemonic: mnemonic)
            let wallet = try LibraWallet.init(seed: seed, depth: 0)
            return wallet
        } catch {
            throw error
        }
    }
    func isValidLibraAddress(address: String) -> Bool {
        guard address.count == 64 else {
            // 位数异常
            return false
        }
        let email = "^[A-Za-z0-9]+$"
        let regextestmobile = NSPredicate(format: "SELF MATCHES %@",email)
        if (regextestmobile.evaluate(with: address) == true) {
            return true
        } else {
            return false
        }
    }
}
