//
//  LibraPrivateKey.swift
//  LibraWallet
//
//  Created by palliums on 2019/9/5.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit
//import SwiftEd25519
import CryptoSwift
struct LibraPrivateKey {
    
//    let raw: Data
//
//    public init (privateKey: PrivateKey) {
//        self.raw = Data.init(bytes: privateKey.bytes, count: privateKey.bytes.count)
//    }
//    func toPublicKey() -> Data {
//        let publicKey = Ed25519.calcPublicKey(secretKey: raw.bytes)
//        return Data.init(bytes: publicKey, count: publicKey.count)
//    }
    // MasterKey
    
    
    let raw: Data

    public init (privateKey: [UInt8]) {
        self.raw = Data.init(bytes: privateKey, count: privateKey.count)
    }
    
    public func extendedPublicKey() -> LibraPublicKey {
        let publicKey = Ed25519.calcPublicKey(secretKey: raw.bytes)
        let publicKeyData = Data.init(bytes: publicKey, count: publicKey.count)
        return LibraPublicKey.init(data: publicKeyData)
    }
    func signTransaction(transaction: RawTransaction, wallet: LibraWallet) throws -> Types_SignedTransaction {
        // 待签名交易
        let transactionRaw = transaction.serialize()
        // 交易第一部分(盐sha3计算结果)
        var sha3Data = Data.init(hex: signTransactionSalt)
        // 交易第二部分(追加带签名交易)
        sha3Data.append(transactionRaw.bytes, count: transactionRaw.bytes.count)
        
//        let sign = wallet.keyPairManager.sign(sha3Data.sha3(.sha256).bytes)
        //
        let sign = Ed25519.sign(message: sha3Data.sha3(.sha256).bytes, secretKey: raw.bytes)
        var signedTransation = Types_SignedTransaction.init()
        
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
        
        signedTransation.signedTxn = transactionRaw + publicKeyData + signData

        return signedTransation
    }
}
