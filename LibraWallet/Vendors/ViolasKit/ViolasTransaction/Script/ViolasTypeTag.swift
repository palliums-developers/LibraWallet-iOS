//
//  ViolasTypeTag.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/4/13.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit

enum ViolasTypeTags {
    case Bool
    case U8
    case U64
    case U128
    case Address
    case Vector//Vector(Box<TypeTag>)
    case Struct
}
extension ViolasTypeTags {
    public var data: Data {
        switch self {
        case .Bool:
            return Data.init(hex: "00")
        case .U8:
            return Data.init(hex: "01")
        case .U64:
            return Data.init(hex: "02")
        case .U128:
            return Data.init(hex: "03")
        case .Address:
            return Data.init(hex: "04")
        case .Vector:
            return Data.init(hex: "05")
        case .Struct:
            return Data.init(hex: "06")
        }
    }
}
struct ViolasTypeTag {
    fileprivate let value: String
        
    fileprivate let module: String
        
    fileprivate let name: String
    
    fileprivate let typeParams: [String]
    
    fileprivate let typeTag: ViolasTypeTags
        
    init(typeTag: ViolasTypeTags, value: String, module: String, name: String, typeParams: [String]) {
        self.typeTag = typeTag
        self.value = value
        self.module = module
        self.name = name
        self.typeParams = typeParams
    }
    init(structData: ViolasStructTag) {
        self.typeTag = .Struct
        
        self.value = structData.address
        self.module = structData.module
        self.name = structData.name
        self.typeParams = structData.typeParams
    }
    func serialize() -> Data {
        var result = Data()
        // 追加类型
        result += self.typeTag.data
        
        switch self.typeTag {
        case .Bool:
            result += ViolasUtils.getLengthData(length: Int(self.value)!, appendBytesCount: 1)
        case .U8:
            result += ViolasUtils.getLengthData(length: Int(self.value)!, appendBytesCount: 1)
        case .U64:
            result += ViolasUtils.getLengthData(length: Int(self.value)!, appendBytesCount: 8)
        case .U128:
            result += ViolasUtils.getLengthData(length: Int(self.value)!, appendBytesCount: 16)
        case .Address:
            result += Data.init(Array<UInt8>(hex: self.value))
        case .Vector:
            let data = Data.init(Array<UInt8>(hex: self.value))
            result += ViolasUtils.uleb128Format(length: data.bytes.count)
            result += data
        case .Struct:
            result += Data.init(Array<UInt8>(hex: self.value))
            //
            result += ViolasUtils.uleb128Format(length: self.module.data(using: String.Encoding.utf8)!.bytes.count)
            result += self.module.data(using: String.Encoding.utf8)!
            //
            result += ViolasUtils.uleb128Format(length: self.name.data(using: String.Encoding.utf8)!.bytes.count)
            result += self.name.data(using: String.Encoding.utf8)!
            // 追加argument数量
            result += ViolasUtils.uleb128Format(length: self.typeParams.count)
        }
        return result
    }
}
