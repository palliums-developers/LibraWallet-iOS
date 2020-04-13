//
//  LibraTransactionScript.swift
//  LibraWallet
//
//  Created by palliums on 2019/11/14.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit

class LibraTransactionScript: NSObject {
    fileprivate let code: Data
    
    fileprivate let typeTags: [LibraTypeTag]
        
    fileprivate let argruments: [LibraTransactionArgument]
        
    fileprivate let programPrefixData: Data = Data.init(hex: "02")
    
    init(code: Data, typeTags: [LibraTypeTag], argruments: [LibraTransactionArgument]) {
        
        self.code = code
        
        self.typeTags = typeTags
        
        self.argruments = argruments
        
    }
    func serialize() -> Data {
        var result = Data()
        // 追加类型
        result += programPrefixData
        // 追加code长度
        result += LibraUtils.uleb128Format(length: self.code.bytes.count)
        // 追加code数据
        result += self.code
        // 追加TypeTag长度
        result += LibraUtils.uleb128Format(length: typeTags.count)
        // 追加argument数组数据
        for typeTag in typeTags {
            result += typeTag.serialize()
        }
        // 追加argument数量
        result += LibraUtils.uleb128Format(length: argruments.count)
        // 追加argument数组数据
        for argument in argruments {
            result += argument.serialize()
        }
        return result
    }
}

