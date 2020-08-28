//
//  ViolasTypeTag.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/4/13.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit

enum ViolasTypeTags {
    case Bool(Bool)
    case U8(Int)
    case U64(UInt64)
    case U128(String)
    case Address(String)
    // 加密签名
    case Signer(String)
    case Vector(String)//Vector(Box<TypeTag>)
    case Struct(ViolasStructTag)
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
        case .Signer:
            return Data.init(hex: "05")
        case .Vector:
            return Data.init(hex: "06")
        case .Struct:
            return Data.init(hex: "07")
        }
    }
}
struct ViolasTypeTag {
    fileprivate let typeTag: ViolasTypeTags
    
    init(typeTag: ViolasTypeTags) {
        self.typeTag = typeTag
    }
    func serialize() -> Data {
         var result = Data()
        // 追加类型
        result += self.typeTag.data
        switch self.typeTag {
        case .Bool(let value):
            result += ViolasUtils.getLengthData(length: NSDecimalNumber.init(value: value).uint64Value, appendBytesCount: 1)
        case .U8(let value):
            result += ViolasUtils.getLengthData(length: NSDecimalNumber.init(value: value).uint64Value, appendBytesCount: 1)
        case .U64(let value):
            result += ViolasUtils.getLengthData(length: value, appendBytesCount: 8)
        case .U128(let value):
            result += ViolasUtils.getLengthData(length: NSDecimalNumber.init(string: value).uint64Value, appendBytesCount: 16)
        case .Address(let value):
            result += Data.init(Array<UInt8>(hex: value))
        case .Signer(let value):
            #warning("待验证")
            result += Data.init(Array<UInt8>(hex: value))
        case .Vector(let value):
            #warning("待验证")
            let data = Data.init(Array<UInt8>(hex: value))
            result += ViolasUtils.getLengthData(length: UInt64(data.bytes.count), appendBytesCount: 1)
            result += data
        case .Struct(let value):
            result += Data.init(Array<UInt8>(hex: value.address))
            //
            result += ViolasUtils.uleb128Format(length: value.module.data(using: String.Encoding.utf8)!.bytes.count)
            result += value.module.data(using: String.Encoding.utf8)!
            //
            result += ViolasUtils.uleb128Format(length: value.name.data(using: String.Encoding.utf8)!.bytes.count)
            result += value.name.data(using: String.Encoding.utf8)!
            // 追加argument数量
            result += ViolasUtils.uleb128Format(length: value.typeParams.count)
        }
        return result
    }

}
