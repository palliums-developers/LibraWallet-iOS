//
//  DiemTravelRuleMetadataV0.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/12/8.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit

struct DiemTravelRuleMetadataV0 {
    fileprivate let off_chain_reference_id: String

    init(off_chain_reference_id: String) {
        
        self.off_chain_reference_id = off_chain_reference_id
    }
    func serialize() -> Data {
        var result = Data()
        if self.off_chain_reference_id.isEmpty == false {
            result += Data.init(Array<UInt8>(hex: "01"))
            let tempData = self.off_chain_reference_id.data(using: .utf8)!
            result += DiemUtils.uleb128Format(length: tempData.count)
            result += tempData
        } else {
            result += Data.init(Array<UInt8>(hex: "00"))
        }
        return result
    }
}
