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
    /// 私钥数组
    let raw: [Data]
    /// 最少签名数
    let threshold: Int
    /// 初始化
    /// - Parameters:
    ///   - privateKeys: 私钥数组
    ///   - threshold: 最少签名数
    public init (privateKeys: [Data], threshold: Int) {
        self.raw = privateKeys
        self.threshold = threshold
    }
    /// 获取私钥
    /// - Returns: Hex私钥
    func toHexString() -> String {
        var privateKeyData = Data()
        privateKeyData += uleb128Format(length: self.raw.count)
        privateKeyData += self.raw.reduce(Data(), {
            $0 + uleb128Format(length: $1.count) + $1
        })
        privateKeyData += BigUInt(self.threshold).serialize()
        return privateKeyData.toHexString()
    }
    /// 获取公钥
    /// - Returns: 多签公钥
    public func extendedPublicKey() -> LibraMultiPublicKey {
        let publicKey = self.raw.map {
            Ed25519.calcPublicKey(secretKey: $0.bytes)
        }
        let publicKeys = publicKey.map {
            LibraHDPublicKey.init(data: Data.init(bytes: $0, count: $0.count)).raw
        }
        return LibraMultiPublicKey.init(data: publicKeys, threshold: threshold)
    }
    /// 签名交易
    /// - Parameter transaction: 交易数据
    /// - Returns: 返回序列化结果
    func signMultiTransaction(transaction: RawTransaction) -> Data {
        // 交易第一部分-原始数据
        let transactionRaw = transaction.serialize()
        
        // 交易第二部分-交易类型
        let signType = Data.init(Array<UInt8>(hex: "01"))
        
        // 交易第三部分-公钥
        var publicKeyData = Data()
        // 追加MultiPublicKey
        let multiPublickKey = self.extendedPublicKey().toMultiPublicKey()
        publicKeyData += uleb128Format(length: multiPublickKey.bytes.count)
        publicKeyData += multiPublickKey
        
        // 交易第四部分-签名
        // 4.1待签数据追加盐
        var sha3Data = Data.init(Array<UInt8>(hex: (LibraSignSalt.sha3(SHA3.Variant.sha256))))
        // 4.2追加待签数据
        sha3Data += transactionRaw
        // 4.3签名数据
        var signData = Data()
        // 4.4追加签名数量1个字节
//        signData += uleb128Format(length: self.threshold)
        // 4.5追加签名
        for i in 0..<self.threshold {
            let sign = Ed25519.sign(message: sha3Data.sha3(.sha256).bytes, secretKey: self.raw[i].bytes)
            signData += sign
        }
        signData += setBitmap(index: 0)
        
        let result = transactionRaw + signType + publicKeyData + uleb128Format(length: signData.count) + signData
        return result
    }
    func setBitmap(index: Int) -> Data {
        var bitmap = Data.init(Array<UInt8>(hex: "00000000"))
        let bucket = index / 8
        // It's always invoked with index < 32, thus there is no need to check range.
        let bucket_pos = index - (bucket * 8)
        bitmap[bucket] |= 128 >> bucket_pos
        return bitmap
    }
}
