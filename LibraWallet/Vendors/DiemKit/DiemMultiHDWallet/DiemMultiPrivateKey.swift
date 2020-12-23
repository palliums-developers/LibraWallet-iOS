//
//  DiemMultiPrivateKey.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/4/7.
//  Copyright © 2020 palliums. All rights reserved.
//
import CryptoSwift
import BigInt
struct DiemMultiPrivateKeyModel {
    var raw: Data
    var sequence: Int
}
struct DiemMultiPrivateKey {
    /// 私钥数组
    let raw: [DiemMultiPrivateKeyModel]
    /// 最少签名数
    let threshold: Int
    /// 初始化
    /// - Parameters:
    ///   - privateKeys: 私钥数组
    ///   - threshold: 最少签名数
    public init (privateKeys: [DiemMultiPrivateKeyModel], threshold: Int) {
        self.raw = privateKeys
        self.threshold = threshold
    }
    /// 获取私钥
    /// - Returns: Hex私钥
    func toHexString() -> String {
        var privateKeyData = Data()
        privateKeyData += DiemUtils.uleb128Format(length: self.raw.count)
        privateKeyData += self.raw.reduce(Data(), {
            $0 + DiemUtils.uleb128Format(length: $1.raw.count) + $1.raw
        })
        privateKeyData += BigUInt(self.threshold).serialize()
        return privateKeyData.toHexString()
    }
    /// 获取公钥
    /// - Returns: 多签公钥
    public func extendedPublicKey() -> DiemMultiPublicKey {
        var tempPublicKeys = [DiemMultiPublicKeyModel]()
        for model in self.raw {
            let data = Ed25519.calcPublicKey(secretKey: model.raw.bytes)
            let publickKey = DiemMultiPublicKeyModel.init(raw: Data.init(bytes: data, count: data.count),
                                                      sequence: model.sequence)
            tempPublicKeys.append(publickKey)
        }
        return DiemMultiPublicKey.init(data: tempPublicKeys, threshold: threshold)
    }
    /// 签名交易
    /// - Parameter transaction: 交易数据
    /// - Returns: 返回序列化结果
    func signMultiTransaction(transaction: DiemRawTransaction, publicKey: DiemMultiPublicKey) -> Data {
        // 交易第一部分-原始数据
        let transactionRaw = transaction.serialize()
        
        // 交易第二部分-交易类型
        let signType = Data.init(Array<UInt8>(hex: "01"))
        
        // 交易第三部分-公钥
        var publicKeyData = Data()
        // 追加MultiPublicKey
        let multiPublickKey = publicKey.toMultiPublicKey()

        publicKeyData += DiemUtils.uleb128Format(length: multiPublickKey.bytes.count)
        publicKeyData += multiPublickKey
        
        // 交易第四部分-签名
        // 4.1待签数据追加盐
        var sha3Data = Data.init(Array<UInt8>(hex: (DiemSignSalt.sha3(SHA3.Variant.sha256))))
        // 4.2追加待签数据
        sha3Data += transactionRaw
        // 4.3签名数据
        var signData = Data()
        // 4.4追加签名
        var bitmap = "00000000000000000000000000000001"
        for i in 0..<self.threshold {
            let sign = Ed25519.sign(message: sha3Data.sha3(.sha256).bytes, secretKey: self.raw[i].raw.bytes)
            signData += sign
            bitmap = setBitmap(bitmap: bitmap, index: self.raw[i].sequence)
        }
        let convert = DiemUtils.binary2dec(num: bitmap)
        signData += BigUInt(convert).serialize()
        print("bitmap = \(BigUInt(convert).serialize().toHexString())")
        let result = transactionRaw + signType + publicKeyData + DiemUtils.uleb128Format(length: signData.count) + signData//uleb128Format(length: signData.count) + signData
        return result
    }
    func setBitmap(bitmap: String, index: Int) -> String {
//        var tempBitmap = bitmap
//        let bucket = index / 8
//        // It's always invoked with index < 32, thus there is no need to check range.
//        let bucket_pos = index - (bucket * 8)
//        tempBitmap[bucket] |= 128 >> bucket_pos
//        return tempBitmap
        var tempBitmap = bitmap
        let range = tempBitmap.index(tempBitmap.startIndex, offsetBy: index)...tempBitmap.index(tempBitmap.startIndex, offsetBy: index)
        tempBitmap.replaceSubrange(range, with: "1")
        return tempBitmap
    }
}
