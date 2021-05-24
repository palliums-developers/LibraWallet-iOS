//
//  DiemHDWallet.swift
//  LibraWallet
//
//  Created by palliums on 2019/9/5.
//  Copyright © 2019 palliums. All rights reserved.
//

import Foundation
import CryptoSwift

public struct DiemHDWallet {
    /// 助记词生成种子
    let seed: [UInt8]
    /// 公钥
    let publicKey: DiemHDPublicKey
    /// 私钥
    let privateKey: DiemHDPrivateKey
    /// 深度
    let depth: UInt64
    /// 钱包网络
    let network: DiemNetworkState
    
    /// 通过种子私钥创建钱包
    /// - Parameters:
    ///   - seed: 种子
    ///   - privateKey: 私钥Data
    ///   - depth: 深度
    ///   - network: 钱包网络
    private init (seed: [UInt8], privateKey: [UInt8], depth: UInt64, network: DiemNetworkState) {
        
        self.seed = seed
        
        self.depth = depth
        
        self.privateKey = DiemHDPrivateKey.init(privateKey: privateKey)
        
        self.publicKey = self.privateKey.extendedPublicKey(network: network)
        
        self.network = network
    }
    
    /// 通过种子创建钱包
    /// - Parameters:
    ///   - seed: 种子
    ///   - depth: 深度
    ///   - network: 钱包网络
    /// - Throws: 创建失败
    init(seed: [UInt8], depth: UInt64 = 0, network: DiemNetworkState) throws {
        
        let depthData = DiemUtils.getLengthData(length: depth, appendBytesCount: 8)
        
        let tempInfo = Data() + Array("DIEM WALLET: derived key$".utf8) + depthData.bytes
        do {
            let privateKey = try HKDF.init(password: seed,
                                           salt:Array("DIEM WALLET: main key salt$".utf8),
                                           info: tempInfo.bytes,
                                           keyLength: 32,
                                           variant: .sha3_256).calculate()
            self.init(seed: seed, privateKey: privateKey, depth: depth, network: network)
        } catch {
            throw error
        }
    }
    public func getMasterKey() throws -> Data {
        do {
            let masterKey = try HMAC.init(key: "DIEM WALLET: main key salt$", variant: .sha3_256).authenticate(seed)
            return Data.init(bytes: masterKey, count: masterKey.count)
            
        } catch {
            throw error
        }
    }
    
    /// 组装交易
    /// - Parameter transaction: 交易
    /// - Returns: 上链数据
    func buildTransaction(transaction: DiemRawTransaction) -> Data {
        // 交易第一部分-待签名交易
        let transactionRaw = transaction.serialize()
        // 交易第二部分-交易类型（00普通，01多签）
        let signType = Data.init(Array<UInt8>(hex: "00"))
        // 交易第三部分-公钥
        // 3.1追加publicKey长度
        var publicKeyData = DiemUtils.uleb128Format(length: self.publicKey.raw.count)
        // 3.2追加publicKey
        publicKeyData.append(self.publicKey.raw)
        // 交易第四部分-签名数据
        // 4.1待签数据追加盐
        var sha3Data = Data.init(Array<UInt8>(hex: (DiemSignSalt.sha3(SHA3.Variant.sha256))))
        // 4.2待签数据追加
        sha3Data.append(transactionRaw.bytes, count: transactionRaw.bytes.count)
        // 4.3签名数据
        let sign = self.privateKey.signData(data: sha3Data)
        // 4.4追加签名长度
        var signData = DiemUtils.uleb128Format(length: sign.count)
        // 4.5追加签名
        signData.append(sign)
        // 最后拼接数据
        // 交易原始数据
        var result = transactionRaw
        // 交易类型
        result.append(signType)
        // 公钥
        result.append(publicKeyData)
        // 签名
        result.append(signData)
        return result
    }
}
