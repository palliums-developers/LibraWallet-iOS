//
//  ViolasTransactionModule.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/2/25.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit

struct ViolasTransactionModule {
    fileprivate let code: Data

    fileprivate let programPrefixData: Data = Data.init(hex: "02")

    init(code: Data) {
        
        self.code = code
        
    }
    func serialize() -> Data {
        var result = Data()
        // 追加类型
        result += programPrefixData
        // 追加code长度
        result += ViolasUtils.uleb128Format(length: self.code.bytes.count)//ViolasUtils.getLengthData(length: self.code.bytes.count, appendBytesCount: 4)
        // 追加code数据
        result += self.code
        
        return result
    }
}
