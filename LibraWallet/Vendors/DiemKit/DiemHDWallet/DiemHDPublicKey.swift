//
//  DiemHDPublicKey.swift
//  LibraWallet
//
//  Created by palliums on 2019/9/5.
//  Copyright © 2019 palliums. All rights reserved.
//

import Foundation
import CryptoSwift

struct DiemHDPublicKey {
    /// 公钥
    let raw: Data
    /// 初始化公钥对象
    /// - Parameter data: 公钥
    public init (data: Data) {
        self.raw = data
    }
    func toAddress() -> String {
        let tempData = self.raw + Data.init(hex: "00")
        let tempAddress = tempData.bytes.sha3(SHA3.Variant.sha256).toHexString()
        let index = tempAddress.index(tempAddress.startIndex, offsetBy: 32)
        let address = tempAddress.suffix(from: index)
        let subStr: String = String(address)
        return subStr
    }
    /// 获取传统地址（32位长度）
    /// - Returns: 地址
    func toLegacy() -> String {
        let tempData = raw + Data.init(hex: "00")
        let tempAddress = tempData.bytes.sha3(SHA3.Variant.sha256).toHexString()
        let index = tempAddress.index(tempAddress.startIndex, offsetBy: 32)
        let address = tempAddress.suffix(from: index)
        let subStr: String = String(address)
        return subStr
    }
    /// 获取激活地址
    /// - Returns: 地址
    func toActive() -> String {
        let tempData = raw + Data.init(hex: "00")
        let tempAddress = tempData.bytes.sha3(SHA3.Variant.sha256).toHexString()
        let index = tempAddress.index(tempAddress.startIndex, offsetBy: 32)
        let address = tempAddress.prefix(upTo: index)
        let subStr: String = String(address)
        return subStr
    }
    
    /// 获取二维码地址
    /// - Parameters:
    ///   - rootAccount: 是否是默认根账户地址（默认不是）
    ///   - version: 版本（默认为1）
    /// - Returns: 返回地址
    func toQRAddress(rootAccount: Bool = false, version: UInt8 = 1) -> String {
        let tempData = raw + Data.init(hex: "00")
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
        let address: String = DiemBech32.encode(payload: Data.init(payload),
                                                prefix: "lbr",
                                                version: version,
                                                separator: "1")
        return address
    }
}
