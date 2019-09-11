//
//  TransactionProgram.swift
//  LibraWallet
//
//  Created by palliums on 2019/9/10.
//  Copyright © 2019 palliums. All rights reserved.
//

import Foundation
import BigInt
struct TransactionProgram {
    fileprivate let code: Data
    
    fileprivate let argruments: [TransactionArgument]
    
    fileprivate let modules: [Data]
    
    fileprivate let programHeaderData: Data = Data.init(hex: "00000000")

    
    init(code: Data, argruments: [TransactionArgument], modules: [Data]) {
        
        self.code = code
        
        self.argruments = argruments
        
        self.modules = modules
    }
    func serialize() -> Data {
        var result = Data()
        // 追加类型
        result += programHeaderData
        // 追加code长度
        result += dealData(originData: BigUInt(self.code.bytes.count).serialize(), appendBytesCount: 4)
        // 追加code数据
        result += self.code
        // 追加argument数量
        result += dealData(originData: BigUInt(argruments.count).serialize(), appendBytesCount: 4)
        // 追加argument数组数据
        for argument in argruments {
            result += argument.serialize()
        }
        // 追加modules数量
        result += dealData(originData: BigUInt(modules.count).serialize(), appendBytesCount: 4)
        for module in modules {
            // 追加module长度
            result += dealData(originData: BigUInt(module.count).serialize(), appendBytesCount: 4)
            // 追加module数据
            result += module
        }
        return result
    }
    fileprivate func dealData(originData: Data, appendBytesCount: Int) -> Data {
        var newData = Data()
        // 补全长度
        for _ in 0..<(appendBytesCount - originData.count) {
            newData.append(Data.init(hex: "00"))
        }
        // 追加原始数据
        newData.append(originData)
        // 倒序输出
        let reversedAmount = newData.bytes.reversed()
        return Data() + reversedAmount
    }
}
