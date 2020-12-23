//
//  DiemTransactionModule.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/4/13.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit

struct DiemTransactionModulePayload {
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
