//
//  LibraTravelRuleMetadataV0.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/12/8.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit

struct LibraTravelRuleMetadataV0 {
    fileprivate let off_chain_reference_id: String

    init(off_chain_reference_id: String) {
        
        self.off_chain_reference_id = off_chain_reference_id
    }
    func serialize() -> Data {
        var result = Data()
        result += Data.init(Array<UInt8>(hex: "01"))
        // 追加code长度
        result += LibraUtils.uleb128Format(length: self.off_chain_reference_id.bytes.count)
        // 追加code数据
        result += self.off_chain_reference_id
        
        return result
    }
}
