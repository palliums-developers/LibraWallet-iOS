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
        let tempData = self.raw + Data.init(hex: "0")
        let tempAddress = tempData.bytes.sha3(SHA3.Variant.sha256).toHexString()
        let index = tempAddress.index(tempAddress.startIndex, offsetBy: 32)
        let address = tempAddress.suffix(from: index)
        let subStr: String = String(address)
        return subStr
    }
}
