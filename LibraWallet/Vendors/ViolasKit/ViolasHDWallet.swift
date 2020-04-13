//
//  ViolasHDWallet.swift
//  LibraWallet
//
//  Created by palliums on 2019/12/13.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit
import CryptoSwift
public final class ViolasHDWallet {
    
    let seed: [UInt8]
    
    let publicKey: ViolasPublicKey
    
    let privateKey: ViolasPrivateKey
    
    let depth: Int
    
    // 通过种子创建钱包
    public init (seed: [UInt8], privateKey: [UInt8], depth: Int) {
        self.seed = seed
        
        self.depth = depth
        
        self.privateKey = ViolasPrivateKey.init(privateKey: privateKey)
        
        self.publicKey = self.privateKey.extendedPublicKey()
        
    }
    public convenience init(seed: [UInt8], depth: Int = 0) throws {
        
        let depthData = ViolasUtils.getLengthData(length: depth, appendBytesCount: 8)//getLengthData(length: depth, appendBytesCount: 8)
        
        let tempInfo = Data() + Array("LIBRA WALLET: derived key$".utf8) + depthData.bytes
        do {
            let privateKey = try HKDF.init(password: seed,
                                     salt:Array("LIBRA WALLET: master key salt$".utf8),
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
            let masterKey = try HMAC.init(key: "LIBRA WALLET: master key salt$", variant: .sha3_256).authenticate(seed)
            return Data.init(bytes: masterKey, count: masterKey.count)

        } catch {
            throw error
        }
    }
}
