//
//  LibraHDPrivateKey.swift
//  LibraWallet
//
//  Created by palliums on 2019/9/5.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit
import CryptoSwift
struct LibraHDPrivateKey {
    /// 私钥
    let raw: Data
    /// 初始化私钥对象
    /// - Parameter privateKey: 私钥
    public init (privateKey: [UInt8]) {
        self.raw = Data.init(bytes: privateKey, count: privateKey.count)
    }
    public func extendedPublicKey() -> LibraHDPublicKey {
        let publicKey = Ed25519.calcPublicKey(secretKey: raw.bytes)
        let publicKeyData = Data.init(bytes: publicKey, count: publicKey.count)
        return LibraHDPublicKey.init(data: publicKeyData)
    }
    func signTransaction(transaction: LibraRawTransaction, wallet: LibraHDWallet) throws -> Data {
        // 交易第一部分-待签名交易
        let transactionRaw = transaction.serialize()
        // 交易第二部分-交易类型（00普通，01多签）
        let signType = Data.init(Array<UInt8>(hex: "00"))
        // 交易第三部分-公钥
        var publicKeyData = Data()
        // 2.1追加publicKey长度
        publicKeyData += LibraUtils.uleb128Format(length: wallet.publicKey.raw.bytes.count)
        // 2.2追加publicKey
        publicKeyData += wallet.publicKey.raw
        // 交易第四部分-签名数据
        // 4.1待签数据追加盐
        var sha3Data = Data.init(Array<UInt8>(hex: (LibraSignSalt.sha3(SHA3.Variant.sha256))))
        // 4.2待签数据追加
        sha3Data.append(transactionRaw.bytes, count: transactionRaw.bytes.count)
        // 4.3签名数据
        let sign = Ed25519.sign(message: sha3Data.sha3(.sha256).bytes, secretKey: raw.bytes)
        
        var signData = Data()
        // 4.4追加签名长度
        signData += LibraUtils.uleb128Format(length: sign.count)
        // 4.5追加签名
        signData += Data.init(bytes: sign, count: sign.count)
        // 最后拼接数据
        let result = transactionRaw + signType + publicKeyData + signData
        return result
    }
}
