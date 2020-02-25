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

    fileprivate let programPrefixData: Data = Data.init(hex: "03000000")
    
    init(code: Data, argruments: [ViolasTransactionArgument]) {
        
        self.code = code
        
    }
    func serialize() -> Data {
        var result = Data()
        // 追加类型
        result += programPrefixData
        // 追加code长度
        result += getLengthData(length: self.code.bytes.count, appendBytesCount: 4)
        // 追加code数据
        result += self.code

        return result
    }
}
