//
//  DiemCoinTradeMetadataV0.swift
//  LibraWallet
//
//  Created by wangyingdong on 2021/4/2.
//  Copyright © 2021 palliums. All rights reserved.
//

import UIKit

struct DiemCoinTradeMetadataV0 {
    fileprivate let trade_ids: [String]

    init(trade_ids: [String]) {
        
        self.trade_ids = trade_ids
    }
    func serialize() -> Data {
        var result = Data()
        result += DiemUtils.uleb128Format(length: self.trade_ids.count)
        for item in self.trade_ids {
            let tempData = item.data(using: .utf8)!
            // 追加code长度
            result += DiemUtils.uleb128Format(length: tempData.count)
            // 追加code数据
            result += tempData
        }
        return result
    }
}
