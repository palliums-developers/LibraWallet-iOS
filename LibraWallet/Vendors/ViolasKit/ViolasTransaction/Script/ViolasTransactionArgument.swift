//
//  ViolasTransactionArgument.swift
//  LibraWallet
//
//  Created by palliums on 2019/12/13.
//  Copyright © 2019 palliums. All rights reserved.
//

import Foundation
enum ViolasArgumentsCode {
    case U8(String)
    case U64(UInt64)
    case U128(String)
    case Address(String)
    case U8Vector(Data)
    case Bool(Bool)
}
extension ViolasArgumentsCode {
    public var raw: Data {
        switch self {
        case .U8:
            return Data.init(hex: "00")
        case .U64:
            return Data.init(hex: "01")
        case .U128:
            return Data.init(hex: "02")
        case .Address:
            return Data.init(hex: "03")
        case .U8Vector:
            return Data.init(hex: "04")
        case .Bool:
            return Data.init(hex: "05")
        }
    }
}
struct ViolasTransactionArgument {
    fileprivate let code: ViolasArgumentsCode
    
    init(code: ViolasArgumentsCode) {
        self.code = code
    }
    func serialize() -> Data {
        var result = Data()
        result += self.code.raw
        switch self.code {
        case .U8(let value):
            result += ViolasUtils.getLengthData(length: NSDecimalNumber.init(string: value).uint64Value, appendBytesCount: 1)
        case .U64(let value):
            result += ViolasUtils.getLengthData(length: value, appendBytesCount: 8)
        case .U128(let value):
            result += ViolasUtils.getLengthData(length: NSDecimalNumber.init(string: value).uint64Value, appendBytesCount: 16)
        case .Address(let address):
            result += Data.init(Array<UInt8>(hex: address))
        case .U8Vector(let value):
            result += ViolasUtils.uleb128Format(length: value.bytes.count)
            result += value
        case .Bool(let value):
            result += ViolasUtils.getLengthData(length: NSDecimalNumber.init(value: value).uint64Value, appendBytesCount: 1)
        }
        return result
    }
}
