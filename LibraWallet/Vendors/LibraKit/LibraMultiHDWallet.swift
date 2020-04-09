//
//  LibraMultiHDWallet.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/4/9.
//  Copyright © 2020 palliums. All rights reserved.
//
import Foundation
import CryptoSwift
struct SeedAndDepth {
    var seed:[UInt8]
    var depth: Int
}
struct LibraMultiHDWallet {
    /// 公钥
    let publicKey: LibraMultiPublicKey
    /// 私钥
    let privateKey: LibraMultiPrivateKey
    /// 最少签名数
    let threshold: Int
    /// 通过私钥初始化
    /// - Parameters:
    ///   - privateKeys: 私钥数组
    ///   - threshold: 最少签名数
    init(privateKeys: [String], threshold: Int) {
        let tempPrivateKeyData = privateKeys.map {
            Data.init(Array<UInt8>(hex: $0))
        }
        self.privateKey = LibraMultiPrivateKey.init(privateKeys: tempPrivateKeyData, threshold: threshold)
        self.publicKey = self.privateKey.extendedPublicKey()
        self.threshold = threshold
    }
    /// 通过助记词种子初始化
    /// - Parameters:
    ///   - models: 助记词Seed数组
    ///   - threshold: 最少签名数
    /// - Throws: 初始化失败
    init(models: [SeedAndDepth], threshold: Int) throws {
        var privateKeys = [Data]()
        for model in models {
            let depthData = getLengthData(length: model.depth, appendBytesCount: 8)
            let tempInfo = Data() + Array("LIBRA WALLET: derived key$".utf8) + depthData.bytes
            do {
                let privateKey = try HKDF.init(password: model.seed,
                                         salt:Array("LIBRA WALLET: master key salt$".utf8),
                                         info: tempInfo.bytes,
                                         keyLength: 32,
                                         variant: .sha3_256).calculate()
                privateKeys.append(Data.init(bytes: privateKey, count: privateKey.count))
            } catch {
                throw error
            }
        }
        self.privateKey = LibraMultiPrivateKey.init(privateKeys: privateKeys, threshold: threshold)
        self.publicKey = self.privateKey.extendedPublicKey()
        self.threshold = threshold
    }
}
