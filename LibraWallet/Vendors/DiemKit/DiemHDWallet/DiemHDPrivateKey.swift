//
//  DiemHDPrivateKey.swift
//  LibraWallet
//
//  Created by palliums on 2019/9/5.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit
import CryptoSwift

struct DiemHDPrivateKey {
    /// 私钥
    let raw: Data
    
    /// 初始化私钥对象
    /// - Parameter privateKey: 私钥
    public init (privateKey: [UInt8]) {
        self.raw = Data.init(bytes: privateKey, count: privateKey.count)
    }
    
    /// 获取公钥
    /// - Parameter network: 钱包网络类型
    /// - Returns: 公钥
    public func extendedPublicKey(network: DiemNetworkState) -> DiemHDPublicKey {
        let publicKey = Ed25519.calcPublicKey(secretKey: raw.bytes)
        let publicKeyData = Data.init(bytes: publicKey, count: publicKey.count)
        return DiemHDPublicKey.init(data: publicKeyData, network: network)
    }
    
    /// 签名数据
    /// - Parameter data: 待签数据
    /// - Returns: 签名数据
    func signData(data: Data) -> Data {
        let sign = Ed25519.sign(message: data.bytes, secretKey: raw.bytes)
        return Data.init(bytes: sign, count: sign.count)
    }
}
