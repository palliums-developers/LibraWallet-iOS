//
//  ViolasPrivateKey.swift
//  LibraWallet
//
//  Created by palliums on 2019/12/13.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit
import CryptoSwift

struct ViolasPrivateKey {

    let raw: Data

    public init (privateKey: [UInt8]) {
        self.raw = Data.init(bytes: privateKey, count: privateKey.count)
    }
    
    public func extendedPublicKey() -> ViolasPublicKey {
        let publicKey = Ed25519.calcPublicKey(secretKey: raw.bytes)
        let publicKeyData = Data.init(bytes: publicKey, count: publicKey.count)
        return ViolasPublicKey.init(data: publicKeyData)
    }
    func signTransaction(transaction: ViolasRawTransaction, wallet: ViolasHDWallet) throws -> Data {
        // 待签名交易
        let transactionRaw = transaction.serialize()
        // 交易第一部分(盐sha3计算结果)
//        var sha3Data = Data.init(hex: signTransactionSalt)
        var sha3Data = Data.init(Array<UInt8>(hex: (ViolasSignSalt.sha3(SHA3.Variant.sha256))))

//        var sha3Data = Data.init(Array<UInt8>(hex: ("RawTransaction::libra_types::transaction@@$$LIBRA$$@@".sha3(SHA3.Variant.sha256))))

        
        // 交易第二部分(追加带签名交易)
        sha3Data.append(transactionRaw.bytes, count: transactionRaw.bytes.count)
        
        let sign = Ed25519.sign(message: sha3Data.sha3(.sha256).bytes, secretKey: raw.bytes)
        
        // 公钥数据
        var publicKeyData = Data()
        // 追加publicKey长度
        publicKeyData += getLengthData(length: wallet.publicKey.raw.bytes.count, appendBytesCount: 4)

        // 追加publicKey
        publicKeyData += wallet.publicKey.raw
        
        // 签名数据
        var signData = Data()
        // 追加签名长度
        signData += getLengthData(length: sign.count, appendBytesCount: 4)

        // 追加签名
        signData += Data.init(bytes: sign, count: sign.count)
        
        let result = transactionRaw + publicKeyData + signData

        return result
    }
}
