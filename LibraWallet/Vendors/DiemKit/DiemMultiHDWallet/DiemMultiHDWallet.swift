//
//  DiemMultiHDWallet.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/4/9.
//  Copyright © 2020 palliums. All rights reserved.
//
import Foundation
import CryptoSwift
import BigInt

struct DiemSeedAndDepth {
    var seed:[UInt8]
    var depth: UInt64
    var sequence: Int
}

struct DiemMultiHDWallet {
    /// 公钥
    let publicKey: DiemMultiPublicKey
    /// 私钥
    let privateKey: DiemMultiPrivateKey
    /// 最少签名数
    let threshold: Int
    /// 钱包网络
    let network: DiemNetworkState
    
    /// 通过私钥初始化
    /// - Parameters:
    ///   - privateKeys: 私钥数组
    ///   - threshold: 最少签名数
    ///   - multiPublicKey: 公钥
    ///   - network: 钱包网络
    init(privateKeys: [DiemMultiPrivateKeyModel], threshold: Int, multiPublicKey: DiemMultiPublicKey? = nil, network: DiemNetworkState) {
        
        self.privateKey = DiemMultiPrivateKey.init(privateKeys: privateKeys, threshold: threshold)
        
        if let tempMultiPublicKey = multiPublicKey {
            self.publicKey = tempMultiPublicKey
        } else {
            self.publicKey = self.privateKey.extendedPublicKey(network: network)
        }
        
        self.threshold = threshold
        
        self.network = network
    }
    
    /// 通过助记词种子初始化
    /// - Parameters:
    ///   - models: 助记词Seed数组
    ///   - threshold: 最少签名数
    ///   - multiPublicKey: 公钥
    ///   - network: 钱包网络
    /// - Throws: 初始化失败
    init(models: [DiemSeedAndDepth], threshold: Int, multiPublicKey: DiemMultiPublicKey? = nil, network: DiemNetworkState) throws {
        var privateKeys = [DiemMultiPrivateKeyModel]()
        for model in models {
            let depthData = DiemUtils.getLengthData(length: model.depth, appendBytesCount: 8)
            let tempInfo = Data() + Array("DIEM WALLET: derived key$".utf8) + depthData.bytes
            do {
                let privateKey = try HKDF.init(password: model.seed,
                                               salt:Array("DIEM WALLET: main key salt$".utf8),
                                               info: tempInfo.bytes,
                                               keyLength: 32,
                                               variant: .sha3_256).calculate()
                let privateModel = DiemMultiPrivateKeyModel.init(privateKey: DiemHDPrivateKey.init(privateKey: privateKey),
                                                                 sequence: model.sequence)
                privateKeys.append(privateModel)
            } catch {
                throw error
            }
        }
        self.privateKey = DiemMultiPrivateKey.init(privateKeys: privateKeys, threshold: threshold)
        if let tempMultiPublicKey = multiPublicKey {
            self.publicKey = tempMultiPublicKey
        } else {
            self.publicKey = self.privateKey.extendedPublicKey(network: network)
        }
        self.threshold = threshold
        
        self.network = network
    }
    
    /// 组装交易
    /// - Parameter transaction: 交易
    /// - Returns: 上链数据
    func buildTransaction(transaction: DiemRawTransaction) -> Data {
        // 交易第一部分-原始数据
        let transactionRaw = transaction.serialize()
        // 交易第二部分-交易类型
        let signType = Data.init(Array<UInt8>(hex: "01"))
        // 交易第三部分-公钥（n*公钥+最少签名数）
        let publicKeyData = publicKey.toMultiPublicKey()
        // 交易第四部分-签名
        // 4.1待签数据加盐
        var sha3Data = Data.init(Array<UInt8>(hex: (DiemSignSalt.sha3(SHA3.Variant.sha256))))
        // 4.2追加待签数据
        sha3Data.append(transactionRaw)
        // 4.3签名数据
        let signData = privateKey.signData(data: sha3Data)
        // 最后整合数据（transactionRaw + 类型 +（公钥+threshold）长度 +（公钥+threshold）+（签名）长度 +（签名+Bitmap））
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
}
