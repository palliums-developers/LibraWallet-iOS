//
//  LibraSeed.swift
//  LibraWallet
//
//  Created by palliums on 2019/9/5.
//  Copyright © 2019 palliums. All rights reserved.
//

import Foundation
import CryptoSwift
public final class LibraSeed {
    let seed: Data
    
    public init (mnemonic: String)  {
        
        let salt: Array<UInt8> = Array("LIBRA WALLET: mnemonic salt prefix$LIBRA".utf8)
        do {
            let dk = try PKCS5.PBKDF2(password: Array(mnemonic.utf8), salt: salt, iterations: 2048, keyLength: 32, variant: .sha3_256).calculate()
            self.seed = Data.init(bytes: dk, count: dk.count)
        } catch {
            self.seed = Data()
        }
    }
}
