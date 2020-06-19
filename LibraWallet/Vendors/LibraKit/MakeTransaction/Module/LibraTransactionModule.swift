//
//  LibraTransactionModule.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/4/13.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit

struct LibraTransactionModule {
    fileprivate let code: Data

    fileprivate let programPrefixData: Data = Data.init(hex: "02")
    
    init(code: Data) {
        self.code = code
    }
    func serialize() -> Data {
        var result = Data()
        // 追加类型
        result += programPrefixData
//        // 追加code长度
//        result += LibraUtils.uleb128Format(length: self.code.bytes.count)
        // 追加code数据
        result += self.code
        return result
    }
}
