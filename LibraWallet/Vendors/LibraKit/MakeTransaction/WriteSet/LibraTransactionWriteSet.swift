//
//  LibraTransactionWriteSet.swift
//  LibraWallet
//
//  Created by palliums on 2019/9/10.
//  Copyright © 2019 palliums. All rights reserved.
//

import Foundation
struct LibraTransactionWriteSet {
    fileprivate let accessPaths: [LibraTransactionAccessPath]
    
    fileprivate let writeHeaderData: Data = Data.init(hex: "01")
    
    init(accessPaths: [LibraTransactionAccessPath]) {
        self.accessPaths = accessPaths
    }
    func serialize() -> Data {
        var result = Data()
        // 追加类型
        result += writeHeaderData
        // 追加accessPaths数量
        result += LibraUtils.uleb128Format(length: accessPaths.count)//LibraUtils.getLengthData(length: accessPaths.count, appendBytesCount: 4)
        // 追加accessPaths数组数据
        for accessPath in accessPaths {
            result += accessPath.serialize()
        }
        return result
    }
}
