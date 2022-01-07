//
//  ViolasTransactionModulePayload.swift
//  ViolasWallet
//
//  Created by wangyingdong on 2020/2/25.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit

struct ViolasTransactionModulePayload {
    fileprivate let code: Data
    
    init(code: Data) {
        self.code = code
    }
    func serialize() -> Data {
        var result = Data()
        // 追加code数据
        result += self.code
        return result
    }
}
