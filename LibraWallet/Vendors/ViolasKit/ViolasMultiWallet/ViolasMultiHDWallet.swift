//
//  ViolasMultiHDWallet.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/4/13.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit
import CryptoSwift
struct ViolasSeedAndDepth {
    var seed:[UInt8]
    var depth: Int
    var sequence: Int
}
struct ViolasMultiHDWallet {
    /// 公钥
    let publicKey: ViolasMultiPublicKey
    /// 私钥
    let privateKey: ViolasMultiPrivateKey
    /// 最少签名数
    let threshold: Int
    /// 通过私钥初始化
    /// - Parameters:
    ///   - privateKeys: 私钥数组
    ///   - threshold: 最少签名数
    init(privateKeys: [ViolasMultiPrivateKeyModel], threshold: Int, multiPublicKey: ViolasMultiPublicKey? = nil) {
//        let tempPrivateKeyData = privateKeys.map {
//            Data.init(Array<UInt8>(hex: $0))
//        }
        self.privateKey = ViolasMultiPrivateKey.init(privateKeys: privateKeys, threshold: threshold)
        if let tempMultiPublicKey = multiPublicKey {
            self.publicKey = tempMultiPublicKey
        } else {
            self.publicKey = self.privateKey.extendedPublicKey()
        }
        self.threshold = threshold
    }
    /// 通过助记词种子初始化
    /// - Parameters:
    ///   - models: 助记词Seed数组
    ///   - threshold: 最少签名数
    /// - Throws: 初始化失败
    init(models: [ViolasSeedAndDepth], threshold: Int, multiPublicKey: ViolasMultiPublicKey? = nil) throws {
        var privateKeys = [ViolasMultiPrivateKeyModel]()
        for model in models {
            let depthData = ViolasUtils.getLengthData(length: model.depth, appendBytesCount: 8)
            let tempInfo = Data() + Array("LIBRA WALLET: derived key$".utf8) + depthData.bytes
            do {
                let privateKey = try HKDF.init(password: model.seed,
                                         salt:Array("LIBRA WALLET: master key salt$".utf8),
                                         info: tempInfo.bytes,
                                         keyLength: 32,
                                         variant: .sha3_256).calculate()
                let privateModel = ViolasMultiPrivateKeyModel.init(raw: Data.init(bytes: privateKey, count: privateKey.count),
                                                             sequence: model.sequence)
                privateKeys.append(privateModel)
            } catch {
                throw error
            }
        }
        self.privateKey = ViolasMultiPrivateKey.init(privateKeys: privateKeys, threshold: threshold)
        if let tempMultiPublicKey = multiPublicKey {
            self.publicKey = tempMultiPublicKey
        } else {
            self.publicKey = self.privateKey.extendedPublicKey()
        }
        self.threshold = threshold
    }
}
