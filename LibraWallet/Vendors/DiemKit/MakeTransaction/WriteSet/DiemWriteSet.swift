//
//  DiemTransactionWriteSet.swift
//  LibraWallet
//
//  Created by palliums on 2019/9/10.
//  Copyright © 2019 palliums. All rights reserved.
//

import Foundation
struct DiemWriteSet {
    fileprivate let accessPaths: [DiemAccessPath]
        
    init(accessPaths: [DiemAccessPath]) {
        self.accessPaths = accessPaths
    }
    func serialize() -> Data {
        var result = Data()
        // 追加accessPaths数量
        result += DiemUtils.uleb128Format(length: accessPaths.count)
        // 追加accessPaths数组数据
        for accessPath in accessPaths {
            result += accessPath.serialize()
        }
        return result
    }
}
