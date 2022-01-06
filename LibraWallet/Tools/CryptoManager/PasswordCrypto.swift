//
//  PasswordCrypto.swift
//  LibraWallet
//
//  Created by palliums on 2019/10/15.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit
import CryptoSwift
struct PasswordCrypto {
    /// 加密密码
    /// - Parameter password: 密码
    static func encryptPassword(content: String, password: String) throws -> String {
        do {
            // 检查密码是否为空
            guard password.isEmpty == false else {
                throw LibraWalletError.WalletCrypto(reason: .passwordEmptyError)
            }
            let contentData = content.data(using: .utf8)!
            //加密密钥: AES_256=32个字节(Hex) = 密码不够补0
//            let key: Array<UInt8> =  [0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00]
            let key: Array<UInt8> = try getPasswordKeyData(password: password)
            //偏移量(Hex):30313030313030313030313030313038
            let iv: Array<UInt8> = [0x30, 0x31, 0x30, 0x30, 0x31, 0x30, 0x30, 0x31, 0x30, 0x30, 0x31, 0x30, 0x30, 0x31, 0x30, 0x38]
            let result = try AES(key: key, blockMode: CBC(iv: iv), padding: .pkcs7).encrypt(contentData.bytes)
            // 检查AES256加密后数据是否为空
            guard result.isEmpty == false else {
                throw LibraWalletError.WalletCrypto(reason: .encryptResultEmptyError)
            }
            // 拆包检查
            let encrypt = result.toBase64()
//            guard let encrypt = result.toBase64() else {
//                throw LibraWalletError.WalletCrypto(reason: .encryptToBase64FailedError)
//            }
            // 检查Base64后数据是否为空
            guard result.toBase64().isEmpty == false else {
                throw LibraWalletError.WalletCrypto(reason: .encryptToBase64EmptyError)
            }
            return encrypt
        } catch {
            throw error
        }
    }
    /// 解密密码
    /// - Parameter cryptString: 加密后Base64字符串
    static func decryptPassword(cryptoString: String, password: String) throws -> String {
        do {
            // 检查加密字符串是否为空
            guard cryptoString.isEmpty == false else {
                throw LibraWalletError.WalletCrypto(reason: .decryptStringEmptyError)
            }
            // Base64解密数据
            let cryptoData = Array.init(base64: cryptoString)
            // 加密密钥: AES_256=32个字节(Hex) = 密码不够补0
            let key: Array<UInt8> = try getPasswordKeyData(password: password)
            // 偏移量(Hex):30313030313030313030313030313038
            let iv: Array<UInt8> = [0x30, 0x31, 0x30, 0x30, 0x31, 0x30, 0x30, 0x31, 0x30, 0x30, 0x31, 0x30, 0x30, 0x31, 0x30, 0x38]
            let result = try AES(key: key, blockMode: CBC(iv: iv), padding: .pkcs7).decrypt(cryptoData)
            // 检查AES256解密后数据是否为空
            guard result.isEmpty == false else {
                throw LibraWalletError.WalletCrypto(reason: .decryptResultEmptyError)
            }
            // 转换数据格式
            let data = Data.init(bytes: result, count: result.count)
            // 检查转换结果是否为空
            guard let resultString = String.init(data: data, encoding: .utf8) else {
                throw LibraWalletError.WalletCrypto(reason: .decryptToStringFailedError)
            }
            return resultString
        } catch {
            throw error
        }
    }
    private static func getPasswordKeyData(password: String) throws -> Array<UInt8> {
        if var tempData = password.data(using: .utf8), tempData.bytes.count > 0 {
            print(tempData.bytes)
            let emptyDataCount = 32 - tempData.bytes.count
            if emptyDataCount > 0 {
                for _ in 0..<emptyDataCount  {
                    tempData.append(0x00)
                }
            }
            return tempData.bytes
        } else {
            throw LibraWalletError.WalletCrypto(reason: .passwordInvalidError)
        }
    }
}
