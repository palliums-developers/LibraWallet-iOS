//
//  DiemTransactionArgument.swift
//  LibraWallet
//
//  Created by palliums on 2019/9/9.
//  Copyright © 2019 palliums. All rights reserved.
//

import Foundation

enum DiemArgumentCode {
    case U8(String)
    case U64(String)
    case U128(String)
    case Address(String)
    case U8Vector(Data)
    case Bool(Bool)
}
extension DiemArgumentCode {
    public var raw: Data {
        switch self {
        case .U8:
            return Data.init(Array<UInt8>(hex: "00"))
        case .U64:
            return Data.init(Array<UInt8>(hex: "01"))
        case .U128:
            return Data.init(Array<UInt8>(hex: "02"))
        case .Address:
            return Data.init(Array<UInt8>(hex: "03"))
        case .U8Vector:
            return Data.init(Array<UInt8>(hex: "04"))
        case .Bool:
            return Data.init(Array<UInt8>(hex: "05"))
        }
    }
}
struct DiemTransactionArgument {
    fileprivate let code: DiemArgumentCode
        
    init(code: DiemArgumentCode) {
        self.code = code
        
    }
    func serialize() -> Data {
        var result = Data()
        result += self.code.raw
        switch self.code {
        case .U8(let value):
            result += DiemUtils.getLengthData(length: NSDecimalNumber.init(string: value).uint64Value, appendBytesCount: 1)
        case .U64(let value):
            result += DiemUtils.getLengthData(length: NSDecimalNumber.init(string: value).uint64Value, appendBytesCount: 8)
        case .U128(let value):
            result += DiemUtils.getLengthData(length: NSDecimalNumber.init(string: value).uint64Value, appendBytesCount: 16)
        case .Address(let address):
            result += Data.init(Array<UInt8>(hex: address))
        case .U8Vector(let value):
            result += DiemUtils.uleb128Format(length: value.bytes.count)
            result += value
        case .Bool(let value):
            result += DiemUtils.getLengthData(length: NSDecimalNumber.init(value: value).uint64Value, appendBytesCount: 1)
        }
        return result
    }
}
