//
//  ViolasManager.swift
//  LibraWallet
//
//  Created by palliums on 2019/11/7.
//  Copyright © 2019 palliums. All rights reserved.
//

import Foundation

struct ViolasManager {
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
    /// 获取Violas钱包对象
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
    func isValidViolasAddress(address: String) -> Bool {
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
    func getViolasPublishCode(content: String) -> String {
        let replaceData = Data.init(Array<UInt8>(hex: content))
        var code = getProgramCode(content: ViolasPublishProgramCode)
        let range = code.index(after: 148)..<( code.endIndex - (code.endIndex - 149 - 32))
        code.replaceSubrange(range, with: replaceData)
        return code.toHexString()
    }
    func getViolasTransactionCode(content: String) -> String {
        let replaceData = Data.init(Array<UInt8>(hex: content))
        var code = getProgramCode(content: ViolasTransactionProgramCode)
        let range = code.index(after: 155)..<( code.endIndex - (code.endIndex - 156 - 32))
        code.replaceSubrange(range, with: replaceData)
        return code.toHexString()
    }
}
