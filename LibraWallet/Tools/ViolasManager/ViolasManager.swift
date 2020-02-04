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
extension ViolasManager {
    public static func getCodeData(move: String, address: String) -> Data {
        // 生成待替换数据
        let replaceData = Data.init(Array<UInt8>(hex: address))
        // 原始数据
        var code = getProgramCode(content: move)
        // 计算位置
        let location = ViolasManager().getViolasTokenContractLocation(code: move, contract: "7257c2417e4d1038e1817c8f283ace2e1041b3396cdbb099eb357bbee024d614")
        // 设置替换区间
        let range = code.index(after: location)..<( code.endIndex - (code.endIndex - (location + 1) - 32))
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
            // 拼接交易
            let request = ViolasTransaction.init(receiveAddress: receiveAddress,
                                                 amount: amount,
                                                 sendAddress: wallet.publicKey.toAddress(),
                                                 sequenceNumber: UInt64(sequenceNumber))
            // 签名交易
            let signature = try wallet.privateKey.signTransaction(transaction: request.request, wallet: wallet)
            return signature.toHexString()
        } catch {
            throw error
        }
    }
    /// 获取注册稳定币交易Hex
    /// - Parameters:
    ///   - mnemonic: 助记词
    ///   - contact: 合约地址
    ///   - sequenceNumber: 序列码
    public static func getRegisterTokenTransactionHex(mnemonic: [String], contact: String, sequenceNumber: Int) throws -> String {
        do {
            let wallet = try ViolasManager.getWallet(mnemonic: mnemonic)
            // 拼接交易
            let request = ViolasTransaction.init(sendAddress: wallet.publicKey.toAddress(),
                                                 sequenceNumber: UInt64(sequenceNumber),
                                                 code: ViolasManager.getCodeData(move: ViolasPublishProgramCode, address: contact))
            // 签名交易
            let signature = try wallet.privateKey.signTransaction(transaction: request.request, wallet: wallet)
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
    public static func getViolasTokenTransactionHex(sendAddress: String, receiveAddress: String, amount: Double, fee: Double, mnemonic: [String], contact: String, sequenceNumber: Int) throws -> String {
        do {
            let wallet = try ViolasManager.getWallet(mnemonic: mnemonic)
            // 拼接交易
            let request = ViolasTransaction.init(sendAddress: sendAddress,
                                                 receiveAddress: receiveAddress,
                                                 amount: amount,
                                                 sequenceNumber: UInt64(sequenceNumber),
                                                 code: ViolasManager.getCodeData(move: ViolasTransactionProgramCode, address: contact))
            // 签名交易
            let signature = try wallet.privateKey.signTransaction(transaction: request.request, wallet: wallet)
            return signature.toHexString()
        } catch {
            throw error
        }
    }
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
    public static func getMarketExchangeTransactionHex(sendAddress: String, amount: Double, fee: Double, mnemonic: [String], contact: String, exchangeTokenContract: String, exchangeTokenAmount: Double, sequenceNumber: Int) throws -> String {
        do {
            let wallet = try ViolasManager.getWallet(mnemonic: mnemonic)
            // 拼接交易
            let request = ViolasTransaction.init(sendAddress: sendAddress,
                                                amount: amount,
                                                fee: fee,
                                                sequenceNumber: UInt64(sequenceNumber),
                                                code: ViolasManager.getCodeData(move: ViolasExchangeTokenProgramCode, address: contact),
                                                receiveTokenAddress: exchangeTokenContract,
                                                exchangeAmount: exchangeTokenAmount)
            // 签名交易
            let signature = try wallet.privateKey.signTransaction(transaction: request.request, wallet: wallet)
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
    public static func getMarketExchangeCancelTransactionHex(sendAddress: String, fee: Double, mnemonic: [String], contact: String, version: String, sequenceNumber: Int) throws -> String {
        do {
            let wallet = try ViolasManager.getWallet(mnemonic: mnemonic)
            // 拼接交易
            let request = ViolasTransaction.init(sendAddress: sendAddress,
                                                 fee: fee,
                                                 sequenceNumber: UInt64(sequenceNumber),
                                                 code: ViolasManager.getCodeData(move: ViolasExchangeTokenProgramCode, address: contact),
                                                 version: version)
            // 签名交易
            let signature = try wallet.privateKey.signTransaction(transaction: request.request, wallet: wallet)
            return signature.toHexString()
        } catch {
            throw error
        }
    }
}
