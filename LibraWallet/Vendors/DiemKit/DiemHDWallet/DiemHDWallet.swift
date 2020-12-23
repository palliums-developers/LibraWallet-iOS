//
//  DiemHDWallet.swift
//  LibraWallet
//
//  Created by palliums on 2019/9/5.
//  Copyright © 2019 palliums. All rights reserved.
//

import Foundation
import CryptoSwift

public final class DiemHDWallet {
    /// 助记词生成种子
    let seed: [UInt8]
    /// 公钥
    let publicKey: DiemHDPublicKey
    /// 私钥
    let privateKey: DiemHDPrivateKey
    /// 深度
    let depth: UInt64
    /// 通过种子私钥创建钱包
    /// - Parameters:
    ///   - seed: 种子
    ///   - privateKey: 私钥Data
    ///   - depth: 深度
    private init (seed: [UInt8], privateKey: [UInt8], depth: UInt64) {
        self.seed = seed
        
        self.depth = depth
        
        self.privateKey = DiemHDPrivateKey.init(privateKey: privateKey)
        
        self.publicKey = self.privateKey.extendedPublicKey()
        
    }
    /// 通过种子创建钱包
    /// - Parameters:
    ///   - seed: 种子
    ///   - depth: 深度
    /// - Throws: 创建失败
    public convenience init(seed: [UInt8], depth: UInt64 = 0) throws {
        
        let depthData = DiemUtils.getLengthData(length: depth, appendBytesCount: 8)
        
        let tempInfo = Data() + Array("DIEM WALLET: derived key$".utf8) + depthData.bytes
        do {
            let privateKey = try HKDF.init(password: seed,
                                           salt:Array("DIEM WALLET: main key salt$".utf8),
                                           info: tempInfo.bytes,
                                           keyLength: 32,
                                           variant: .sha3_256).calculate()
            self.init(seed: seed, privateKey: privateKey, depth: depth)
        } catch {
            throw error
        }
    }
    func getMasterKey() throws -> Data {
        do {
            let masterKey = try HMAC.init(key: "DIEM WALLET: main key salt$", variant: .sha3_256).authenticate(seed)
            return Data.init(bytes: masterKey, count: masterKey.count)

        } catch {
            throw error
        }
    }
}
