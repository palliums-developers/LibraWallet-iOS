//
//  LibraMultiPrivateKey.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/4/7.
//  Copyright © 2020 palliums. All rights reserved.
//
import CryptoSwift
import BigInt
struct LibraMultiPrivateKey {
    
    let raw: [Data]
    
    // 需要多少把解锁
    let threshold: Int

    public init (privateKeys: [Data], threshold: Int) {
        self.raw = privateKeys
        self.threshold = threshold
    }
    func toHexString() -> String {
        var privateKeyData = Data()
        privateKeyData += uleb128Format(length: self.raw.count)
        privateKeyData += self.raw.reduce(Data(), {
            $0 + uleb128Format(length: $1.count) + $1
        })
        privateKeyData += BigUInt(self.threshold).serialize()
        return privateKeyData.toHexString()
    }

    func signMultiTransaction(transaction: RawTransaction, privateKey: LibraMultiPrivateKey) throws -> Data {
        // 待签名交易
        let transactionRaw = transaction.serialize()
        // 交易第一部分(盐sha3计算结果)

        var sha3Data = Data.init(Array<UInt8>(hex: (LibraSignSalt.sha3(SHA3.Variant.sha256))))
        
        // 交易第二部分(追加带签名交易)
        sha3Data.append(transactionRaw.bytes, count: transactionRaw.bytes.count)
        // 签名数据
        var signData = Data()
//        // 追加签名长度
//        signData += getLengthData(length: sign.count, appendBytesCount: 4)
//
//        // 追加签名
//        signData += Data.init(bytes: sign, count: sign.count)
        for i in 0..<privateKey.raw.count {
            signData += (Ed25519.sign(message: sha3Data.sha3(.sha256).bytes, secretKey: privateKey.raw[i].bytes) + setBitmap(index: i))
        }
        // 公钥数据
        var publicKeyData = Data()
        // 追加MultiPublicKey
        publicKeyData += LibraMultiPublicKey.init(data: privateKey.raw, threshold: self.threshold).toMultiPublicKey()

        let signType = Data.init(Array<UInt8>(hex: "10"))

        let result = transactionRaw + signType + publicKeyData + signData

        return result
    }
    func setBitmap(index: Int) -> Data {
        var bitmap = Data.init(Array<UInt8>(hex: "00000000"))
        let bucket = index / 8
    //        # It's always invoked with index < 32, thus there is no need to check range.
        let bucket_pos = index - (bucket * 8)
        bitmap[bucket] |= 128 >> bucket_pos
        print(bitmap.toHexString())
        return bitmap
    }
}
