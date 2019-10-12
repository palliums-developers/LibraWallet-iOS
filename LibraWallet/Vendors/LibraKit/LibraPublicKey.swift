//
//  PublicKey.swift
//  LibraWallet
//
//  Created by palliums on 2019/9/5.
//  Copyright © 2019 palliums. All rights reserved.
//

import Foundation
import CryptoSwift
struct LibraPublicKey {
    
    let raw: Data

    public init (data: Data) {
        self.raw = data
    }
    
    func toAddress() -> String {
        return self.raw.bytes.sha3(SHA3.Variant.sha256).toHexString()
    }
}
