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
    var privateKey: DiemHDPrivateKey
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
            $0 + DiemUtils.uleb128Format(length: $1.privateKey.raw.count) + $1.privateKey.raw
        })
        privateKeyData += BigUInt(self.threshold).serialize()
        return privateKeyData.toHexString()
    }
    
    /// 获取公钥
    /// - Parameter network: 钱包网络类型
    /// - Returns: 多签公钥
    public func extendedPublicKey(network: DiemNetworkState) -> DiemMultiPublicKey {
        var tempPublicKeys = [DiemMultiPublicKeyModel]()
        for model in self.raw {
            let data = Ed25519.calcPublicKey(secretKey: model.privateKey.raw.bytes)
            let publickKey = DiemMultiPublicKeyModel.init(raw: Data.init(bytes: data, count: data.count),
                                                          sequence: model.sequence)
            tempPublicKeys.append(publickKey)
        }
        return DiemMultiPublicKey.init(data: tempPublicKeys, threshold: threshold, network: network)
    }
    private func setBitmap(bitmap: String, index: Int) -> String {
        var tempBitmap = bitmap
        let range = tempBitmap.index(tempBitmap.startIndex, offsetBy: index)...tempBitmap.index(tempBitmap.startIndex, offsetBy: index)
        tempBitmap.replaceSubrange(range, with: "1")
        return tempBitmap
    }
    func signData(data: Data) -> (Data) {
        var signData = Data()
        var bitmap = "00000000000000000000000000000000"
        for i in 0..<self.threshold {
            let sign = self.raw[i].privateKey.signData(data: data)
            signData.append(sign)
            bitmap = setBitmap(bitmap: bitmap, index: self.raw[i].sequence)
        }
        let bitmapNumber = DiemUtils.binary2dec(num: bitmap)
        let bitmapData = BigUInt(bitmapNumber).serialize()
        signData.append(bitmapData)
        return signData
    }
}
