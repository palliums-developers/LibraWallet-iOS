//
//  DiemUnstructuredBytesMetadata.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/12/8.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit

struct DiemUnstructuredBytesMetadata {
    fileprivate let code: Data
        
    init(code: Data) {
        self.code = code
    }
    func serialize() -> Data {
        var result = Data()
        if self.code.isEmpty == true {
            result += Data.init(Array<UInt8>(hex: "01"))
            result += DiemUtils.uleb128Format(length: self.code.count)
            result += self.code
        } else {
            result += Data.init(Array<UInt8>(hex: "00"))
        }
        return result
    }
}
