//
//  LibraMultiPublicKey.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/4/7.
//  Copyright © 2020 palliums. All rights reserved.
//

import CryptoSwift
import BigInt
struct LibraMultiPublicKey {
    // 公钥数组
    let raw: [Data]
    // 需要多少把解锁
    let threshold: Int
    
    public init (data: [Data], threshold: Int) {
        self.raw = data
        self.threshold = threshold
    }
    func toMultiPublicKey() -> Data {
        var publicKeyData = Data()
        publicKeyData += uleb128Format(length: self.raw.count)
        publicKeyData += self.raw.reduce(Data(), {
            $0 + uleb128Format(length: $1.count) + $1
        })
        publicKeyData += BigUInt(self.threshold).serialize()
        // 多签默认追加
        publicKeyData += Data.init(hex: "1")
        return publicKeyData
    }
    func toAddress() -> String {
        let publicKeyData = toMultiPublicKey()
        let tempAddress = publicKeyData.bytes.sha3(SHA3.Variant.sha256).toHexString()
        //0220c413ea446039d0cd07715ddedb8169393e456b03d05ce67d50a4446ba5e067b020005c135145c60db0253e164a6f9fa396ae7e376761538ac55b40747690e757de01
        let index = tempAddress.index(tempAddress.startIndex, offsetBy: 32)
        let address = tempAddress.suffix(from: index)
        let subStr: String = String(address)
        return subStr
    }
    func authenticationKey() -> String {
        return ""
    }
}
