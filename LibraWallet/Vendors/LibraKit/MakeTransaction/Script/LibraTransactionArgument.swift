//
//  LibraTransactionArgument.swift
//  LibraWallet
//
//  Created by palliums on 2019/9/9.
//  Copyright © 2019 palliums. All rights reserved.
//

import Foundation
enum LibraArgumentCode {
    case U8
    case U64
    case U128
    case Address
    case U8Vector
    case Bool
}
extension LibraArgumentCode {
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
struct LibraTransactionArgument {
    fileprivate let code: LibraArgumentCode
    
    fileprivate let value: String
    
    init(code: LibraArgumentCode, value: String) {
        self.code = code
        
        self.value = value
    }
    func serialize() -> Data {
        var result = Data()
        result += self.code.raw
        switch self.code {
        case .U8:
            result += LibraUtils.getLengthData(length: Int(self.value)!, appendBytesCount: 1)
        case .U64:
            result += LibraUtils.getLengthData(length: Int(self.value)!, appendBytesCount: 8)
        case .U128:
            result += LibraUtils.getLengthData(length: Int(self.value)!, appendBytesCount: 16)
        case .Address:
            let data = Data.init(Array<UInt8>(hex: self.value))
            result += data
        case .U8Vector:
            let data = Data.init(Array<UInt8>(hex: self.value))
            result += LibraUtils.uleb128Format(length: data.bytes.count)
            result += data
        case .Bool:
            result += LibraUtils.getLengthData(length: Int(self.value)!, appendBytesCount: 1)
        }
        return result
    }
}
