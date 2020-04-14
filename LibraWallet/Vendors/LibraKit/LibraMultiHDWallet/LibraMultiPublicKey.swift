//
//  LibraMultiPublicKey.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/4/7.
//  Copyright © 2020 palliums. All rights reserved.
//

import CryptoSwift
import BigInt
struct LibraMultiPublicKeyModel {
    var raw: Data
    var sequence: Int
}
struct LibraMultiPublicKey {
    /// 公钥数组
    let raw: [LibraMultiPublicKeyModel]
    /// 需要多少把解锁
    let threshold: Int
    
    public init (data: [LibraMultiPublicKeyModel], threshold: Int) {
        self.raw = data
        self.threshold = threshold
    }
    func toMultiPublicKey() -> Data {
        var publicKeyData = Data()
        for i in 0..<self.raw.count {
            publicKeyData += self.raw[i].raw
        }
        publicKeyData += BigUInt(self.threshold).serialize()
        return publicKeyData
    }
    /// 获取传统地址（32位长度）
    /// - Returns: 地址
    func toLegacy() -> String {
        var publicKeyData = toMultiPublicKey()
        // 多签默认追加
        publicKeyData += Data.init(hex: "1")
        let tempAddress = publicKeyData.bytes.sha3(SHA3.Variant.sha256).toHexString()
        let index = tempAddress.index(tempAddress.startIndex, offsetBy: 32)
        let address = tempAddress.suffix(from: index)
        let subStr: String = String(address)
        return subStr
    }
    /// 获取激活地址
    /// - Returns: 地址
    func toActive() -> String {
        var publicKeyData = toMultiPublicKey()
        // 多签默认追加
        publicKeyData += Data.init(hex: "1")
        let tempAddress = publicKeyData.bytes.sha3(SHA3.Variant.sha256).toHexString()
        return tempAddress
    }
}
