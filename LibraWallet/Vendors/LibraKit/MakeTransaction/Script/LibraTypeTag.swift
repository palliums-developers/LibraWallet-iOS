//
//  LibraTypeTag.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/3/27.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit
enum LibraTypeTags {
    case Bool
    case U8
    case U64
    case U128
    case Address
    // 加密签名
    case Signer
    case Vector//Vector(Box<TypeTag>)
    case Struct
}
extension LibraTypeTags {
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
        case .Signer:
            return Data.init(hex: "05")
        case .Vector:
            return Data.init(hex: "06")
        case .Struct:
            return Data.init(hex: "07")
        }
    }
}
struct LibraTypeTag {
    fileprivate let value: String
        
    fileprivate let module: String
        
    fileprivate let name: String
    
    fileprivate let typeParams: [String]
    
    fileprivate let typeTag: LibraTypeTags
        
    init(typeTag: LibraTypeTags, value: String, module: String, name: String, typeParams: [String]) {
        self.typeTag = typeTag
        self.value = value
        self.module = module
        self.name = name
        self.typeParams = typeParams
    }
    init(structData: LibraStructTag) {
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
            result += LibraUtils.getLengthData(length: Int(self.value)!, appendBytesCount: 1)
        case .U8:
            result += LibraUtils.getLengthData(length: Int(self.value)!, appendBytesCount: 1)
        case .U64:
            result += LibraUtils.getLengthData(length: Int(self.value)!, appendBytesCount: 8)
        case .U128:
            result += LibraUtils.getLengthData(length: Int(self.value)!, appendBytesCount: 16)
        case .Address:
            result += Data.init(Array<UInt8>(hex: self.value))
        case .Signer:
            #warning("待验证")
            result += Data.init(Array<UInt8>(hex: self.value))
        case .Vector:
            let data = Data.init(Array<UInt8>(hex: self.value))
            result += LibraUtils.getLengthData(length: data.bytes.count, appendBytesCount: 1)
            result += data
        case .Struct:
            result += Data.init(Array<UInt8>(hex: self.value))
            //
            result += LibraUtils.uleb128Format(length: self.module.data(using: String.Encoding.utf8)!.bytes.count)
            result += self.module.data(using: String.Encoding.utf8)!
            //
            result += LibraUtils.uleb128Format(length: self.name.data(using: String.Encoding.utf8)!.bytes.count)
            result += self.name.data(using: String.Encoding.utf8)!
            // 追加argument数量
            result += LibraUtils.uleb128Format(length: self.typeParams.count)

        }
        return result
    }
}
