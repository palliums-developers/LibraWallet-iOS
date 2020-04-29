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
            let mnemonic = try LibraMnemonic.generate(strength: .default, language: .english)
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
        guard isValidViolasAddress(address: address) else {
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
extension ViolasManager {
    public static func getCodeData(move: String, address: String) -> Data {
        // 生成待替换数据
        let replaceData = Data.init(Array<UInt8>(hex: address))
        // 原始数据
        var code = getProgramCode(content: move)
        // 计算位置
        let location = ViolasManager().getViolasTokenContractLocation(code: move, contract: "7257c2417e4d1038e1817c8f283ace2e")
        // 设置替换区间
        let range = code.index(after: location)..<( code.endIndex - (code.endIndex - (location + 1) - 16))
        // 替换指定区间数据
        code.replaceSubrange(range, with: replaceData)
        return code
    }
    /// 计算位置
    /// - Parameter contract: 合约地址
    func getViolasTokenContractLocation(code: String, contract: String) -> Int {
        //7257c2417e4d1038e1817c8f283ace2e1041b3396cdbb099eb357bbee024d614
        //位置-1所得正好
        let code = getProgramCode(content: code)
        let range: Range = code.toHexString().range(of: contract)!
        let location: Int = code.toHexString().distance(from: code.toHexString().startIndex, to: range.lowerBound)
        return (location / 2) - 1
        
    }
}
//MARK: - 平台币
extension ViolasManager {
    /// 获取Violas交易Hex
    /// - Parameters:
    ///   - sendAddress: 发送地址
    ///   - receiveAddress: 接受地址
    ///   - amount: 数量
    ///   - fee: 手续费
    ///   - mnemonic: 助记词
    ///   - sequenceNumber: 序列码
    public static func getNormalTransactionHex(sendAddress: String, receiveAddress: String, amount: Double, fee: Double, mnemonic: [String], sequenceNumber: Int) throws -> String {
        do {
            let wallet = try ViolasManager.getWallet(mnemonic: mnemonic)
            let (authenticatorKey, address) = try ViolasManager.splitAddress(address: receiveAddress)

            let argument0 = ViolasTransactionArgument.init(code: .Address,
                                                           value: address)
            let argument1 = ViolasTransactionArgument.init(code: .U8Vector,
                                                           value: authenticatorKey)
            let argument2 = ViolasTransactionArgument.init(code: .U64,
                                                           value: "\(Int(amount * 1000000))")
            let script = ViolasTransactionScript.init(code: Data.init(hex: ViolasScriptCode),
                                                      typeTags: [ViolasTypeTag.init(structData: ViolasStructTag.init(type: .ViolasDefault))],
                                                      argruments: [argument0, argument1, argument2])
            let rawTransaction = ViolasRawTransaction.init(senderAddres: sendAddress,
                                                           sequenceNumber: UInt64(sequenceNumber),
                                                           maxGasAmount: 400000,
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
//MARK: - 稳定币
extension ViolasManager {
    /// 获取注册稳定币交易Hex
    /// - Parameters:
    ///   - mnemonic: 助记词
    ///   - contact: 合约地址
    ///   - sequenceNumber: 序列码
    public static func getRegisterTokenTransactionHex(mnemonic: [String], contact: String, sequenceNumber: Int) throws -> String {
        do {
            let wallet = try ViolasManager.getWallet(mnemonic: mnemonic)
            // 拼接交易
            let argument0 = ViolasTransactionArgument.init(code: .U8Vector,
                                                           value: "publish".data(using: .utf8)!.toHexString())
            let script = ViolasTransactionScript.init(code: ViolasManager.getCodeData(move: ViolasPublishScriptCode, address: contact),
                                                      typeTags: [ViolasTypeTag](),
                                                      argruments: [argument0])
            let rawTransaction = ViolasRawTransaction.init(senderAddres: wallet.publicKey.toLegacy(),
                                                sequenceNumber: UInt64(sequenceNumber),
                                                maxGasAmount: 400000,
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
    /// 获取稳定币交易Hex
    /// - Parameters:
    ///   - sendAddress: 发送地址
    ///   - receiveAddress: 接收地址
    ///   - amount: 数量
    ///   - fee: 手续费
    ///   - mnemonic: 助记词
    ///   - contact: 合约地址
    ///   - sequenceNumber: 序列码
    public static func getViolasTokenTransactionHex(sendAddress: String, receiveAddress: String, amount: Double, fee: Double, mnemonic: [String], contact: String, sequenceNumber: Int, tokenIndex: String) throws -> String {
        do {
            let wallet = try ViolasManager.getWallet(mnemonic: mnemonic)
    
            let argument0 = ViolasTransactionArgument.init(code: .U64,
                                                           value: tokenIndex)
            let argument1 = ViolasTransactionArgument.init(code: .Address,
                                                           value: receiveAddress)
            let argument2 = ViolasTransactionArgument.init(code: .U64,
                                                           value: "\(Int(amount * 1000000))")
            let argument3 = ViolasTransactionArgument.init(code: .U8Vector, value: "")
            let script = ViolasTransactionScript.init(code: ViolasManager.getCodeData(move: ViolasStableCoinScriptWithDataCode, address: contact),
                                                       typeTags: [ViolasTypeTag](),
                                                       argruments: [argument0, argument1, argument2, argument3])
            let rawTransaction = ViolasRawTransaction.init(senderAddres: sendAddress,
                                                sequenceNumber: UInt64(sequenceNumber),
                                                maxGasAmount: 400000,
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
//MARK: - 交易所
extension ViolasManager {
    /// 获取交易所兑换交易Hex
    /// - Parameters:
    ///   - sendAddress: 发送地址
    ///   - amount: 付出数量
    ///   - fee: 手续费
    ///   - mnemonic: 助记词
    ///   - contact: 合约地址
    ///   - exchangeTokenContract: 兑换合约地址
    ///   - exchangeTokenAmount: 兑换数量
    ///   - sequenceNumber: 序列码
    public static func getMarketExchangeTransactionHex(sendAddress: String, amount: Double, fee: Double, mnemonic: [String], contact: String, exchangeTokenContract: String, exchangeTokenAmount: Double, sequenceNumber: Int, tokenIndex: String) throws -> String {
        do {
            let wallet = try ViolasManager.getWallet(mnemonic: mnemonic)
            // 拼接交易
            let argument0 = ViolasTransactionArgument.init(code: .U64,
                                                           value: tokenIndex)
            let argument1 = ViolasTransactionArgument.init(code: .Address,
                                                           value: MarketAddress)
            let argument2 = ViolasTransactionArgument.init(code: .U64,
                                                           value: "\(Int(amount * 1000000))")
            let data = "{\"type\":\"sub_ex\",\"tokenid\":\"\(exchangeTokenContract)\",\"amount\":\(Int(exchangeTokenAmount * 1000000)),\"fee\":0,\"exp\":1000}".data(using: .utf8)!
            let argument3 = ViolasTransactionArgument.init(code: .U8Vector,
                                                           value: data.toHexString())
            let script = ViolasTransactionScript.init(code: ViolasManager.getCodeData(move: ViolasStableCoinScriptWithDataCode, address: contact),
                                                       typeTags: [ViolasTypeTag](),
                                                       argruments: [argument0, argument1, argument2, argument3])
            
            let rawTransaction = ViolasRawTransaction.init(senderAddres: sendAddress,
                                                sequenceNumber: UInt64(sequenceNumber),
                                                maxGasAmount: 400000,
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
    /// 获取交易所取消交易Hex
    /// - Parameters:
    ///   - sendAddress: 发送地址
    ///   - fee: 手续费
    ///   - mnemonic: 助记词
    ///   - contact: 合约地址
    ///   - version: 位置（暂翻译）
    ///   - sequenceNumber: 序列码
    ///   - tokenIndex: 稳定币序号
    /// - Throws: 返回错误
    /// - Returns: 返回签名
    public static func getMarketExchangeCancelTransactionHex(sendAddress: String, fee: Double, mnemonic: [String], contact: String, version: String, sequenceNumber: Int, tokenIndex: String) throws -> String {
        do {
            let wallet = try ViolasManager.getWallet(mnemonic: mnemonic)
            // 拼接交易
            let argument0 = ViolasTransactionArgument.init(code: .U64,
                                                           value: tokenIndex)
            let argument1 = ViolasTransactionArgument.init(code: .Address,
                                                           value: MarketAddress)
            let argument2 = ViolasTransactionArgument.init(code: .U64,
                                                           value: "\(Int(0 * 1000000))")
            let data = "{\"type\":\"wd_ex\",\"ver\":\"\(version)\"}".data(using: .utf8)!
            let argument3 = ViolasTransactionArgument.init(code: .U8Vector,
                                                           value: data.toHexString())
            let script = ViolasTransactionScript.init(code: ViolasManager.getCodeData(move: ViolasStableCoinScriptWithDataCode, address: contact),
                                                      typeTags: [ViolasTypeTag](),
                                                      argruments: [argument0, argument1, argument2, argument3])
            let rawTransaction = ViolasRawTransaction.init(senderAddres: sendAddress,
                                                           sequenceNumber: UInt64(sequenceNumber),
                                                           maxGasAmount: 400000,
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
//MARK: - 映射
#warning("模块待测试")
extension ViolasManager {
    public static func getVBTCToBTCTransactionHex(sendAddress: String, amount: Double, fee: Double, mnemonic: [String], contact: String, sequenceNumber: Int, btcAddress: String) throws -> String {
        do {
            let wallet = try ViolasManager.getWallet(mnemonic: mnemonic)
            // 拼接交易
            let argument1 = ViolasTransactionArgument.init(code: .Address,
                                                           value: "cae5f8464c564aabb684ecbcc19153e9")
            let argument2 = ViolasTransactionArgument.init(code: .U64,
                                                           value: "\(Int(amount * 1000000))")
            let data = "{\"flag\":\"violas\",\"type\":\"v2b\",\"to_address\":\"\(btcAddress)\",\"state\":\"start\"}".data(using: .utf8)!
            let argument3 = ViolasTransactionArgument.init(code: .U8Vector,
                                                           value: data.toHexString())
            let script = ViolasTransactionScript.init(code: ViolasManager.getCodeData(move: ViolasStableCoinScriptWithDataCode, address: contact),
                                                       typeTags: [ViolasTypeTag](),
                                                       argruments: [argument1, argument2, argument3])

            let rawTransaction = ViolasRawTransaction.init(senderAddres: sendAddress,
                                                           sequenceNumber: UInt64(sequenceNumber),
                                                           maxGasAmount: 400000,
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
    public static func getVLibraToLibraTransactionHex(sendAddress: String, amount: Double, fee: Double, mnemonic: [String], contact: String, sequenceNumber: Int, libraReceiveAddress: String) throws -> String {
        do {
            let wallet = try ViolasManager.getWallet(mnemonic: mnemonic)
            // 拼接交易
            let argument0 = ViolasTransactionArgument.init(code: .U64,
                                                           value: "3")
            let argument1 = ViolasTransactionArgument.init(code: .Address,
                                                           value: "ee1e24e8fc664894709c947b74823b2f")
            let argument2 = ViolasTransactionArgument.init(code: .U64,
                                                           value: "\(Int(amount * 1000000))")
            let data = "{\"flag\":\"violas\",\"type\":\"v2l\",\"to_address\":\"\(libraReceiveAddress)\",\"state\":\"start\"}".data(using: .utf8)!
            let argument3 = ViolasTransactionArgument.init(code: .U8Vector,
                                                           value: data.toHexString())
            let script = ViolasTransactionScript.init(code: ViolasManager.getCodeData(move: ViolasStableCoinScriptWithDataCode, address: contact),
                                                      typeTags: [ViolasTypeTag](),
                                                      argruments: [argument0, argument1, argument2, argument3])
            let rawTransaction = ViolasRawTransaction.init(senderAddres: sendAddress,
                                                           sequenceNumber: UInt64(sequenceNumber),
                                                           maxGasAmount: 600000,
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
