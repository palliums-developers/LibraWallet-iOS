//
//  ViolasTransactionWriteSet.swift
//  LibraWallet
//
//  Created by palliums on 2019/12/13.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit

struct ViolasTransactionWriteSet {
    fileprivate let accessPaths: [ViolasTransactionAccessPath]
    
    fileprivate let writeHeaderData: Data = Data.init(hex: "01000000")
    
    init(accessPaths: [ViolasTransactionAccessPath]) {
        self.accessPaths = accessPaths
    }
    func serialize() -> Data {
        var result = Data()
        // 追加类型
        result += writeHeaderData
        // 追加accessPaths数量
        result += ViolasUtils.getLengthData(length: accessPaths.count, appendBytesCount: 4)
        // 追加accessPaths数组数据
        for accessPath in accessPaths {
            result += accessPath.serialize()
        }
        return result
    }
}
