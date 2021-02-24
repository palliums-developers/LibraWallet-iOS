//
//  ViolasMultiPrivateKey.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/4/13.
//  Copyright © 2020 palliums. All rights reserved.
//

import CryptoSwift
import BigInt
struct ViolasMultiPrivateKeyModel {
    var raw: Data
    var sequence: Int
}
struct ViolasMultiPrivateKey {
    /// 私钥数组
    let raw: [ViolasMultiPrivateKeyModel]
    /// 最少签名数
    let threshold: Int
    /// 初始化
    /// - Parameters:
    ///   - privateKeys: 私钥数组
    ///   - threshold: 最少签名数
    public init (privateKeys: [ViolasMultiPrivateKeyModel], threshold: Int) {
        self.raw = privateKeys
        self.threshold = threshold
    }
    /// 获取私钥
    /// - Returns: Hex私钥
    func toHexString() -> String {
        var privateKeyData = Data()
        privateKeyData += ViolasUtils.uleb128Format(length: self.raw.count)
        privateKeyData += self.raw.reduce(Data(), {
            $0 + ViolasUtils.uleb128Format(length: $1.raw.count) + $1.raw
        })
        privateKeyData += BigUInt(self.threshold).serialize()
        return privateKeyData.toHexString()
    }
    /// 获取公钥
    /// - Returns: 多签公钥
    public func extendedPublicKey(network: ViolasNetworkState) -> ViolasMultiPublicKey {
        var tempPublicKeys = [ViolasMultiPublicKeyModel]()
        for model in self.raw {
            let data = Ed25519.calcPublicKey(secretKey: model.raw.bytes)
            let publickKey = ViolasMultiPublicKeyModel.init(raw: Data.init(bytes: data, count: data.count),
                                                      sequence: model.sequence)
            tempPublicKeys.append(publickKey)
        }
        return ViolasMultiPublicKey.init(data: tempPublicKeys, threshold: threshold, network: network)
    }
    /// 签名多签交易
    /// - Parameters:
    ///   - transaction: 交易数据
    ///   - publicKey: 所有公钥
    /// - Throws: 报错
    /// - Returns: 返回序列化结果
    func signMultiTransaction(transaction: ViolasRawTransaction, publicKey: ViolasMultiPublicKey) -> Data {
        // 交易第一部分-原始数据
        let transactionRaw = transaction.serialize()
        // 交易第二部分-交易类型
        let signType = Data.init(Array<UInt8>(hex: "01"))
        // 交易第三部分-公钥（n*公钥+最少签名数）
        let publicKeyData = publicKey.toMultiPublicKey()
        // 交易第四部分-签名
        // 4.1待签数据追加盐
        var sha3Data = Data.init(Array<UInt8>(hex: (ViolasSignSalt.sha3(SHA3.Variant.sha256))))
        // 4.2追加待签数据
        sha3Data.append(transactionRaw)
        // 4.3签名数据
        var signData = Data()
        // 4.4追加签名
        var bitmap = "00000000000000000000000000000000"
        // 4.5追加签名+计算Bitmap
        for i in 0..<self.threshold {
            let sign = Ed25519.sign(message: sha3Data.bytes, secretKey: self.raw[i].raw.bytes)
            signData.append(sign, count: sign.count)
            bitmap = setBitmap(bitmap: bitmap, index: self.raw[i].sequence)
        }
        let bitmapNumber = ViolasUtils.binary2dec(num: bitmap)
        let bitmapData = BigUInt(bitmapNumber).serialize()
        // 4.6签名追加Bitmap
        signData.append(bitmapData)
        // 最后整合数据
        var result = transactionRaw
        // 签名类型（1个字节）
        result.append(signType)
        // 公钥+最少签名数长度（2个字节）
        result.append(DiemUtils.uleb128Format(length: publicKeyData.count))
        // 公钥+最少签名数据
        result.append(publicKeyData)
        // 签名+Bitmap长度（2个字节）
        result.append(DiemUtils.uleb128Format(length: signData.count))
        // 签名+Bitmap数据
        result.append(signData)
        return result
    }
    private func setBitmap(bitmap: String, index: Int) -> String {
        var tempBitmap = bitmap
        let range = tempBitmap.index(tempBitmap.startIndex, offsetBy: index)...tempBitmap.index(tempBitmap.startIndex, offsetBy: index)
        tempBitmap.replaceSubrange(range, with: "1")
        return tempBitmap
    }
}
