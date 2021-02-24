//
//  ViolasMultiPublicKey.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/4/13.
//  Copyright © 2020 palliums. All rights reserved.
//

import CryptoSwift
import BigInt
struct ViolasMultiPublicKeyModel {
    var raw: Data
    var sequence: Int
}
struct ViolasMultiPublicKey {
    /// 公钥数组
    let raw: [ViolasMultiPublicKeyModel]
    /// 需要多少把解锁
    let threshold: Int
    /// 钱包网络
    let network: ViolasNetworkState
    
    public init (data: [ViolasMultiPublicKeyModel], threshold: Int, network: ViolasNetworkState) {
        
        self.raw = data
        
        self.threshold = threshold
        
        self.network = network
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
