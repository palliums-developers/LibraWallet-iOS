//
//  ViolasPublicKey.swift
//  LibraWallet
//
//  Created by palliums on 2019/12/13.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit
import CryptoSwift

struct ViolasPublicKey {
    
    let raw: Data

    public init (data: Data) {
        self.raw = data
    }
    
    func toAddress() -> String {
        return self.raw.bytes.sha3(SHA3.Variant.sha256).toHexString()
    }
}
