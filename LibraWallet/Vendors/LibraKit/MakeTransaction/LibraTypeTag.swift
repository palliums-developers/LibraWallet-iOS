//
//  LibraTypeTag.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/3/27.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit

struct LibraTypeTag {
    fileprivate let address: String
        
    fileprivate let module: String
        
    fileprivate let name: String
    
    fileprivate let typeParams: [String]
    
    fileprivate let tagPrefixData: Data = Data.init(hex: "06000000")
    
    init(address: String, module: String, name: String, typeParams: [String]) {
        self.address = address
        self.module = module
        self.name = name
        self.typeParams = typeParams
    }
    func serialize() -> Data {
        var result = Data()
        // 追加类型
        result += tagPrefixData
        result += Data.init(Array<UInt8>(hex: self.address))
        //
        result += getLengthData(length: self.module.data(using: String.Encoding.utf8)!.bytes.count, appendBytesCount: 4)
        result += self.module.data(using: String.Encoding.utf8)!
        //
        result += getLengthData(length: self.name.data(using: String.Encoding.utf8)!.bytes.count, appendBytesCount: 4)
        result += self.name.data(using: String.Encoding.utf8)!
        // 追加argument数量
        result += getLengthData(length: self.typeParams.count, appendBytesCount: 4)
        // 追加argument数组数据
//        for argument in typeParams {
//            result += typeParams.serialize()
//        }
        return result
    }
}
