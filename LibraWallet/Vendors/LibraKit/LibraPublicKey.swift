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
    
    public init (dk: Data) {
        do {
            let seed = try Seed.init(bytes: dk.bytes)
            let keyChain = KeyPair.init(seed: seed)
            self.raw = Data.init(bytes: keyChain.publicKey.bytes, count: keyChain.publicKey.bytes.count)
        } catch {
            print(error.localizedDescription)
            self.raw = Data()
        }
    }
    func toAddress() -> String {
        return self.raw.bytes.sha3(SHA3.Variant.sha256).toHexString()
    }
}
