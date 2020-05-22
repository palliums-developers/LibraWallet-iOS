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
    public static func getLibraMnemonic() throws -> [String] {
        do {
            let mnemonic = try LibraMnemonic.generate(strength: .default, language: .english)
            return mnemonic
        } catch {
            print(error.localizedDescription)
            throw error
        }
    }
    /// 获取Libra钱包对象
    ///
    /// - Parameter mnemonic: 助词数组
    /// - Returns: 钱包对象
    public static func getWallet(mnemonic: [String]) throws -> LibraHDWallet {
        do {
            let seed = try LibraMnemonic.seed(mnemonic: mnemonic)
            let wallet = try LibraHDWallet.init(seed: seed, depth: 0)
            return wallet
        } catch {
            throw error
        }
    }
    /// 校验地址是否有效
    /// - Parameter address: 地址
    public static func isValidLibraAddress(address: String) -> Bool {
        guard (address.count == 32 || address.count == 64)  else {
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
    /// 分割地址
    /// - Parameter address: 原始地址
    /// - Throws: 分割错误
    /// - Returns: （授权KEY， 地址）
    public static func splitAddress(address: String) throws -> (String, String) {
        guard isValidLibraAddress(address: address) else {
            throw LibraWalletError.error("Invalid Address")
        }
        if address.count == 64 {
            let authenticatorKey = address.prefix(address.count / 2)
            let shortAddress = address.suffix(address.count / 2)
            return ("\(authenticatorKey)", "\(shortAddress)")
        } else {
            return ("", address)
        }
    }
}
extension LibraManager {
    /// 获取Libra交易Hex
    /// - Parameters:
    ///   - sendAddress: 发送地址
    ///   - receiveAddress: 接收地址
    ///   - amount: 数量
    ///   - fee: 手续费
    ///   - mnemonic: 助记词
    ///   - sequenceNumber: 序列码
    public static func getNormalTransactionHex(sendAddress: String, receiveAddress: String, amount: Double, fee: Double, mnemonic: [String], sequenceNumber: Int) throws -> String {
        do {
            let wallet = try LibraManager.getWallet(mnemonic: mnemonic)
            let (authenticatorKey, address) = try LibraManager.splitAddress(address: receiveAddress)
            // 拼接交易
            let argument0 = LibraTransactionArgument.init(code: .Address,
                                                          value: address)
            let argument1 = LibraTransactionArgument.init(code: .U8Vector,
                                                          value: authenticatorKey)
            let argument2 = LibraTransactionArgument.init(code: .U64,
                                                          value: "\(Int(amount * 1000000))")
            let argument3 = LibraTransactionArgument.init(code: .U8Vector,
                                                          value: "")
            let argument4 = LibraTransactionArgument.init(code: .U8Vector,
                                                          value: "")
            let script = LibraTransactionScript.init(code: Data.init(hex: LibraScriptCodeWithData),
                                                     typeTags: [LibraTypeTag.init(structData: LibraStructTag.init(type: .libraDefault))],
                                                     argruments: [argument0, argument1, argument2, argument3, argument4])
            let rawTransaction = LibraRawTransaction.init(senderAddres: sendAddress,
                                                          sequenceNumber: UInt64(sequenceNumber),
                                                          maxGasAmount: 1000000,
                                                          gasUnitPrice: 0,
                                                          expirationTime: Int(UInt64(Date().timeIntervalSince1970) + 3600),
                                                          payLoad: script.serialize())

            // 签名交易
            let signature = try wallet.privateKey.signTransaction(transaction: rawTransaction, wallet: wallet)
            return signature.toHexString()
        } catch {
            throw error
        }
    }
    public static func getMultiTransactionHex(sendAddress: String, receiveAddress: String, amount: Double, fee: Double, sequenceNumber: Int, wallet: LibraMultiHDWallet) throws -> String {
        do {
            let (authenticatorKey, address) = try LibraManager.splitAddress(address: receiveAddress)
            // 拼接交易
            let argument1 = LibraTransactionArgument.init(code: .Address,
                                                          value: address)
            let argument2 = LibraTransactionArgument.init(code: .U64,
                                                          value: "\(Int(amount * 1000000))")
            let argument3 = LibraTransactionArgument.init(code: .U8Vector,
                                                          value: authenticatorKey)
            let script = LibraTransactionScript.init(code: Data.init(hex: libraScriptCode),
                                                     typeTags: [LibraTypeTag.init(structData: LibraStructTag.init(type: .libraDefault))],
                                                     argruments: [argument1, argument3, argument2])
            let rawTransaction = LibraRawTransaction.init(senderAddres: sendAddress,
                                                          sequenceNumber: UInt64(sequenceNumber),
                                                          maxGasAmount: 1000000,
                                                          gasUnitPrice: 0,
                                                          expirationTime: Int(UInt64(Date().timeIntervalSince1970) + 3600),
                                                          payLoad: script.serialize())
            // 签名交易
            let multiSignature = wallet.privateKey.signMultiTransaction(transaction: rawTransaction, publicKey: wallet.publicKey)
            return multiSignature.toHexString()
        } catch {
            throw error
        }
    }

}
extension LibraManager {
    /// 获取Libra映射VLibra交易Hex
    /// - Parameters:
    ///   - sendAddress: 发送地址
    ///   - amount: 数量
    ///   - fee: 手续费
    ///   - mnemonic: 助记词
    ///   - contact: 合约
    ///   - sequenceNumber: 序列码
    ///   - libraReceiveAddress: 接收地址
    /// - Throws: 报错
    /// - Returns: 返回结果
    public static func getLibraToVLibraTransactionHex(sendAddress: String, amount: Double, fee: Double, mnemonic: [String], sequenceNumber: Int, vlibraReceiveAddress: String) throws -> String {
        do {
            let wallet = try LibraManager.getWallet(mnemonic: mnemonic)
            // 拼接交易
            let argument0 = LibraTransactionArgument.init(code: .Address,
                                                          value: "0a82179351b8ecb6c5e68ab7b08622de")
            let argument1 = LibraTransactionArgument.init(code: .U8Vector,
                                                          value: "")
            let argument2 = LibraTransactionArgument.init(code: .U64,
                                                          value: "\(Int(amount * 1000000))")
            let data = "{\"flag\":\"libra\",\"type\":\"l2v\",\"to_address\":\"\(vlibraReceiveAddress)\",\"state\":\"start\"}".data(using: .utf8)!
            let argument3 = LibraTransactionArgument.init(code: .U8Vector,
                                                          value: data.toHexString())

            let script = LibraTransactionScript.init(code: Data.init(hex: LibraScriptCodeWithData),
                                                      typeTags: [LibraTypeTag.init(structData: LibraStructTag.init(type: .libraDefault))],
                                                      argruments: [argument0, argument1, argument2, argument3])

            let rawTransaction = LibraRawTransaction.init(senderAddres: sendAddress,
                                                sequenceNumber: UInt64(sequenceNumber),
                                                maxGasAmount: 560000,
                                                gasUnitPrice: 0,
                                                expirationTime: Int(UInt64(Date().timeIntervalSince1970) + 3600),
                                                payLoad: script.serialize())
            // 签名交易
            let signature = try wallet.privateKey.signTransaction(transaction: rawTransaction, wallet: wallet)
            return signature.toHexString()
        } catch {
            throw error
        }
    }
}
