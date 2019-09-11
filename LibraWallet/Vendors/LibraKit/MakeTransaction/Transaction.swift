//
//  TransactionWriteOP.swift
//  LibraWallet
//
//  Created by palliums on 2019/9/10.
//  Copyright © 2019 palliums. All rights reserved.
//

import Foundation
import BigInt
struct TransactionWriteSet {
    
    fileprivate let sets: [TransactionWriteSet]

    
    
    init(sets: [TransactionWriteSet]) {
        
        self.sets = sets
        
    }
    func serialize() -> Data {
        var result = Data()

        guard sets.isEmpty == false else {
            return result
        }
        #warning("此处待修改,不知道格式")
        // 追加sets数量
        result += dealData(originData: BigUInt(sets.count).serialize(), appendBytesCount: 4)
        // 追加sets数组数据
        for argument in sets {
            result += argument.serialize()
        }
        return result
    }
    fileprivate func dealData(originData: Data, appendBytesCount: Int) -> Data {
        var newData = Data()
        // 长度序列化
        let dataLenth = BigUInt(originData.bytes.count).serialize()
        // 补全长度
        for _ in 0..<(appendBytesCount - dataLenth.count) {
            newData.append(Data.init(hex: "00"))
        }
        // 追加原始数据
        newData.append(dataLenth)
        // 倒序输出
        let reversedAmount = newData.bytes.reversed()
        return Data() + reversedAmount
    }
}
