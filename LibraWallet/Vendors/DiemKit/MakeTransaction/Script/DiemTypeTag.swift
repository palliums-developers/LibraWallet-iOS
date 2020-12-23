//
//  DiemTypeTag.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/3/27.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit

enum DiemTypeTags {
    case Bool(Bool)
    case U8(Int)
    case U64(UInt64)
    case U128(String)
    case Address(String)
    // 加密签名
    case Signer(String)
    case Vector(String)//Vector(Box<TypeTag>)
    case Struct(DiemStructTag)
}
extension DiemTypeTags {
    public var data: Data {
        switch self {
        case .Bool:
            return Data.init(Array<UInt8>(hex: "00"))
        case .U8:
            return Data.init(Array<UInt8>(hex: "01"))
        case .U64:
            return Data.init(Array<UInt8>(hex: "02"))
        case .U128:
            return Data.init(Array<UInt8>(hex: "03"))
        case .Address:
            return Data.init(Array<UInt8>(hex: "04"))
        case .Signer:
            return Data.init(Array<UInt8>(hex: "05"))
        case .Vector:
            return Data.init(Array<UInt8>(hex: "06"))
        case .Struct:
            return Data.init(Array<UInt8>(hex: "07"))
        }
    }
}
struct DiemTypeTag {
    
    fileprivate let typeTag: DiemTypeTags
    
    init(typeTag: DiemTypeTags) {
        self.typeTag = typeTag
    }
    func serialize() -> Data {
        var result = Data()
        // 追加类型
        result += self.typeTag.data
        switch self.typeTag {
        case .Bool(let value):
            result += DiemUtils.getLengthData(length: NSDecimalNumber.init(value: value).uint64Value, appendBytesCount: 1)
        case .U8(let value):
            result += DiemUtils.getLengthData(length: NSDecimalNumber.init(value: value).uint64Value, appendBytesCount: 1)
        case .U64(let value):
            result += DiemUtils.getLengthData(length: value, appendBytesCount: 8)
        case .U128(let value):
            result += DiemUtils.getLengthData(length: NSDecimalNumber.init(string: value).uint64Value, appendBytesCount: 16)
        case .Address(let value):
            result += Data.init(Array<UInt8>(hex: value))
        case .Signer(let value):
            #warning("待验证")
            result += Data.init(Array<UInt8>(hex: value))
        case .Vector(let value):
            #warning("待验证")
            let data = Data.init(Array<UInt8>(hex: value))
            result += DiemUtils.getLengthData(length: UInt64(data.bytes.count), appendBytesCount: 1)
            result += data
        case .Struct(let value):
            result += Data.init(Array<UInt8>(hex: value.address))
            //
            result += DiemUtils.uleb128Format(length: value.module.data(using: String.Encoding.utf8)!.bytes.count)
            result += value.module.data(using: String.Encoding.utf8)!
            //
            result += DiemUtils.uleb128Format(length: value.name.data(using: String.Encoding.utf8)!.bytes.count)
            result += value.name.data(using: String.Encoding.utf8)!
            // 追加argument数量
            result += DiemUtils.uleb128Format(length: value.typeParams.count)
        }
        return result
    }
}
