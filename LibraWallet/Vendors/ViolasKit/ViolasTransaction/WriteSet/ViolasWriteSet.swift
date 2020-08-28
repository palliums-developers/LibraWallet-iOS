//
//  ViolasWriteSet.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/8/28.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit

struct ViolasWriteSet {
    fileprivate let accessPaths: [ViolasAccessPath]
        
    init(accessPaths: [ViolasAccessPath]) {
        self.accessPaths = accessPaths
    }
    func serialize() -> Data {
        var result = Data()
        // 追加accessPaths数量
        result += ViolasUtils.uleb128Format(length: accessPaths.count)
        // 追加accessPaths数组数据
        for accessPath in accessPaths {
            result += accessPath.serialize()
        }
        return result
    }
}
