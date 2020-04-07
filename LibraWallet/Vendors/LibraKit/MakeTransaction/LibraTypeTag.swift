//
//  LibraTypeTag.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/3/27.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit
enum TypeTag {
    case Bool
    case U8
    case U64
    case U128
    case Address
    case Vector//Vector(Box<TypeTag>)
    case Struct
}
extension TypeTag {
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
struct LibraTypeTag {
    fileprivate let value: String
        
    fileprivate let module: String
        
    fileprivate let name: String
    
    fileprivate let typeParams: [String]
    
    fileprivate let typeTag: TypeTag
        
    init(typeTag: TypeTag, value: String, module: String, name: String, typeParams: [String]) {
        self.typeTag = typeTag
        self.value = value
        self.module = module
        self.name = name
        self.typeParams = typeParams
    }
    init(structData: StructTag) {
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
            result += getLengthData(length: Int(self.value)!, appendBytesCount: 1)
        case .U8:
            result += getLengthData(length: Int(self.value)!, appendBytesCount: 1)
        case .U64:
            result += getLengthData(length: Int(self.value)!, appendBytesCount: 8)
        case .U128:
            result += getLengthData(length: Int(self.value)!, appendBytesCount: 16)
        case .Address:
            result += Data.init(Array<UInt8>(hex: self.value))
        case .Vector:
            let data = Data.init(Array<UInt8>(hex: self.value))
            result += getLengthData(length: data.bytes.count, appendBytesCount: 1)
            result += data
        case .Struct:
            result += Data.init(Array<UInt8>(hex: self.value))
            //
            result += uleb128Format(length: self.module.data(using: String.Encoding.utf8)!.bytes.count)//getLengthData(length: self.module.data(using: String.Encoding.utf8)!.bytes.count, appendBytesCount: 4)
            result += self.module.data(using: String.Encoding.utf8)!
            //
            result += uleb128Format(length: self.name.data(using: String.Encoding.utf8)!.bytes.count)//getLengthData(length: self.name.data(using: String.Encoding.utf8)!.bytes.count, appendBytesCount: 4)
            result += self.name.data(using: String.Encoding.utf8)!
            // 追加argument数量
            result += uleb128Format(length: self.typeParams.count)//getLengthData(length: self.typeParams.count, appendBytesCount: 1)
        }
        return result
    }
}
