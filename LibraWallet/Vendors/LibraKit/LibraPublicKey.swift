//
//  PublicKey.swift
//  LibraWallet
//
//  Created by palliums on 2019/9/5.
//  Copyright © 2019 palliums. All rights reserved.
//

import Foundation
import SwiftEd25519
import CryptoSwift
class LibraPublicKey {
    
    let raw: Data
    
    public init (publicKey: PublicKey) {
        self.raw = Data.init(bytes: publicKey.bytes, count: publicKey.bytes.count)
    }
    func toAddress() -> String {
        return self.raw.bytes.sha3(SHA3.Variant.sha256).toHexString()
    }
}
