//
//  ViolasMultiPublicKey.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/4/13.
//  Copyright © 2020 palliums. All rights reserved.
//

import CryptoSwift
import BigInt
import Foundation

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
    
    /// 初始化
    /// - Parameters:
    ///   - data: 公钥数组
    ///   - threshold: 最少签名数
    ///   - network: 钱包网络
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
        publicKeyData += Data.init(hex: "01")
        let tempAddress = publicKeyData.bytes.sha3(SHA3.Variant.sha256).toHexString()
        let index = tempAddress.index(tempAddress.startIndex, offsetBy: 32)
        let address = tempAddress.suffix(from: index)
        let subStr: String = String(address)
        return subStr
    }
    
    /// 获取激活地址
    /// - Returns: 地址
    func toAuthKeyPrefix() -> String {
        var publicKeyData = toMultiPublicKey()
        // 多签默认追加
        publicKeyData += Data.init(hex: "01")
        let tempAddress = publicKeyData.bytes.sha3(SHA3.Variant.sha256).toHexString()
        let index = tempAddress.index(tempAddress.startIndex, offsetBy: 32)
        let address = tempAddress.prefix(upTo: index)
        let subStr: String = String(address)
        return subStr
    }
    
    /// 获取授权Key
    /// - Returns: 授权Key
    func toAuthKey() -> String {
        var publicKeyData = toMultiPublicKey()
        // 多签默认追加
        publicKeyData += Data.init(hex: "01")
        let authKey = publicKeyData.bytes.sha3(SHA3.Variant.sha256).toHexString()
        return authKey
    }
    
    /// 获取二维码地址
    /// - Parameters:
    ///   - rootAccount: 是否是默认根账户地址（默认不是）
    ///   - version: 版本（默认为1）
    /// - Returns: 返回地址
    func toBech32Address(rootAccount: Bool = false, version: UInt8 = 1) -> String {
        let tempData = toMultiPublicKey() + Data.init(hex: "01")
        let tempAddressData = tempData.bytes.sha3(SHA3.Variant.sha256)
        var randomData = Data()
        if rootAccount == false {
            for _ in 0..<8 {
                let randomValue = UInt8.random(in: 0...255)
                let tempData = Data([randomValue])
                randomData.append(tempData)
            }
        } else {
            let tempData = Data.init(count: 8)
            randomData.append(tempData)
        }
        let payload = tempAddressData.dropFirst(16) + randomData
        let address: String = ViolasBech32.encode(payload: Data.init(payload),
                                                  prefix: self.network.addressPrefix,
                                                  version: version,
                                                  separator: "1")
        return address
    }
}
