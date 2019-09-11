//
//  TransactionWriteSet.swift
//  LibraWallet
//
//  Created by palliums on 2019/9/10.
//  Copyright © 2019 palliums. All rights reserved.
//

import Foundation
import BigInt
struct TransactionWriteSet {
    fileprivate let accessPaths: [TransactionAccessPath]
    
    fileprivate let writeHeaderData: Data = Data.init(hex: "01000000")
    
    init(accessPaths: [TransactionAccessPath]) {
        self.accessPaths = accessPaths
    }
    func serialize() -> Data {
        var result = Data()
        // 追加类型
        result += writeHeaderData
        // 追加accessPaths数量
        result += dealData(originData: BigUInt(accessPaths.count).serialize(), appendBytesCount: 4)
        // 追加accessPaths数组数据
        for accessPath in accessPaths {
            result += accessPath.serialize()
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
