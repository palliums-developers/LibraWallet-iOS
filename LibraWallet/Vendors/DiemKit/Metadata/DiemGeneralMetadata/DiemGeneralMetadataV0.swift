//
//  DiemGeneralMetadataV0.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/12/8.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit

struct DiemGeneralMetadataV0 {
    
    fileprivate let to_subaddress: String

    fileprivate let from_subaddress: String
        
    fileprivate let referenced_event: String

    init(to_subaddress: String, from_subaddress: String, referenced_event: String) {
        
        self.to_subaddress = to_subaddress
                
        self.from_subaddress = from_subaddress
        
        self.referenced_event = referenced_event
    }
    func serialize() -> Data {
        var result = Data()
        if to_subaddress.isEmpty == true && from_subaddress.isEmpty == true {
            return Data()
        }
        if to_subaddress.isEmpty == false {
            result += Data.init(Array<UInt8>(hex: "01"))
            let data = Data.init(Array<UInt8>(hex: self.to_subaddress))
            // 追加code长度
            result += DiemUtils.uleb128Format(length: data.bytes.count)
            // 追加code数据
            result += data
        } else {
            result += Data.init(Array<UInt8>(hex: "00"))
        }
        if from_subaddress.isEmpty == false {
            result += Data.init(Array<UInt8>(hex: "01"))
            let data = Data.init(Array<UInt8>(hex: self.from_subaddress))
            // 追加code长度
            result += DiemUtils.uleb128Format(length: data.bytes.count)
            // 追加code数据
            result += data
        } else {
            result += Data.init(Array<UInt8>(hex: "00"))
        }
        if referenced_event.isEmpty == false {
            result += Data.init(Array<UInt8>(hex: "01"))
            result += DiemUtils.getLengthData(length: NSDecimalNumber.init(string: self.referenced_event).uint64Value, appendBytesCount: 8)
        } else {
            result += Data.init(Array<UInt8>(hex: "00"))
        }
        return result
    }
}
