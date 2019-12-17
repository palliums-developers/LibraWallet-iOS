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
    public static func getLibraMnemonic() throws -> [String] {
        do {
            let mnemonic = try LibraMnemonic.generate(strength: .veryHigh, language: .english)
            return mnemonic
        } catch {
            print(error.localizedDescription)
            throw error
        }
    }
    /// 获取Violas钱包对象
    ///
    /// - Parameter mnemonic: 助词数组
    /// - Returns: 钱包对象
    public static func getWallet(mnemonic: [String]) throws -> ViolasHDWallet {
        do {
            let seed = try LibraMnemonic.seed(mnemonic: mnemonic)
            let wallet = try ViolasHDWallet.init(seed: seed, depth: 0)
            return wallet
        } catch {
            throw error
        }
    }
    /// 校验地址是否有效
    /// - Parameter address: 地址
    public static func isValidViolasAddress(address: String) -> Bool {
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
        let range = code.index(after: 180)..<( code.endIndex - (code.endIndex - 181 - 32))
        code.replaceSubrange(range, with: replaceData)
        return code.toHexString()
    }
    func getViolasTokenExchangeTransactionCode(content: String) -> String {
        let replaceData = Data.init(Array<UInt8>(hex: content))
        var code = getProgramCode(content: ViolasExchangeTokenProgramCode)
        let range = code.index(after: 167)..<( code.endIndex - (code.endIndex - 168 - 32))
        code.replaceSubrange(range, with: replaceData)
        print(code.toHexString())
        return code.toHexString()
    }
    func getViolasTokenContractLocation(contract: String) -> Int {
        //7257c2417e4d1038e1817c8f283ace2e1041b3396cdbb099eb357bbee024d614
        let code = getProgramCode(content: ViolasTransactionProgramCode)
        let range: Range = code.toHexString().range(of: contract)!
        let location: Int = code.toHexString().distance(from: code.toHexString().startIndex, to: range.lowerBound)
        return location / 2
    }
}
