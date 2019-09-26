//
//  TransactionProgram.swift
//  LibraWallet
//
//  Created by palliums on 2019/9/10.
//  Copyright © 2019 palliums. All rights reserved.
//

import Foundation
struct TransactionProgram {
    fileprivate let code: Data
    
    fileprivate let argruments: [TransactionArgument]
    
    fileprivate let modules: [Data]
    
    fileprivate let programPrefixData: Data = Data.init(hex: "00000000")
    
    init(code: Data, argruments: [TransactionArgument], modules: [Data]) {
        
        self.code = code
        
        self.argruments = argruments
        
        self.modules = modules
    }
    func serialize() -> Data {
        var result = Data()
        // 追加类型
        result += programPrefixData
        // 追加code长度
        result += getLengthData(length: self.code.bytes.count, appendBytesCount: 4)
        // 追加code数据
        result += self.code
        // 追加argument数量
        result += getLengthData(length: argruments.count, appendBytesCount: 4)
        // 追加argument数组数据
        for argument in argruments {
            result += argument.serialize()
        }
        // 追加modules数量
        result += getLengthData(length: modules.count, appendBytesCount: 4)
        // 追加modules数据
        for module in modules {
            // 追加module长度
            result += getLengthData(length: module.count, appendBytesCount: 4)
            // 追加module数据
            result += module
        }
        return result
    }
}
