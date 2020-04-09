//
//  LibraHDPublicKey.swift
//  LibraWallet
//
//  Created by palliums on 2019/9/5.
//  Copyright © 2019 palliums. All rights reserved.
//

import Foundation
import CryptoSwift
struct LibraHDPublicKey {
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
        return tempAddress
    }
}
extension LibraHDPublicKey {
    
}
