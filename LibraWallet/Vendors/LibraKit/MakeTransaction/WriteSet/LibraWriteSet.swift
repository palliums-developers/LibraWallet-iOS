//
//  LibraTransactionWriteSet.swift
//  LibraWallet
//
//  Created by palliums on 2019/9/10.
//  Copyright © 2019 palliums. All rights reserved.
//

import Foundation
struct LibraWriteSet {
    fileprivate let accessPaths: [LibraAccessPath]
        
    init(accessPaths: [LibraAccessPath]) {
        self.accessPaths = accessPaths
    }
    func serialize() -> Data {
        var result = Data()
        // 追加accessPaths数量
        result += LibraUtils.uleb128Format(length: accessPaths.count)
        // 追加accessPaths数组数据
        for accessPath in accessPaths {
            result += accessPath.serialize()
        }
        return result
    }
}
