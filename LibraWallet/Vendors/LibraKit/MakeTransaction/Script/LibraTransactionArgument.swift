//
//  LibraTransactionArgument.swift
//  LibraWallet
//
//  Created by palliums on 2019/9/9.
//  Copyright © 2019 palliums. All rights reserved.
//

import Foundation
enum LibraArgumentsCode {
    case U64
    case Address
    case U8Vector
    #warning("待测试")
    case Bool
}
extension LibraArgumentsCode {
    public var raw: Data {
        switch self {
        case .U64:
            return Data.init(hex: "00")
        case .Address:
            return Data.init(hex: "01")
        case .U8Vector:
            return Data.init(hex: "02")
        case .Bool:
            return Data.init(hex: "03")
        }
    }
}
struct LibraTransactionArgument {
    fileprivate let code: LibraArgumentsCode
    
    fileprivate let value: String
    
    init(code: LibraArgumentsCode, value: String) {
        self.code = code
        self.value = value
    }
    func serialize() -> Data {
        var result = Data()
        
        result += self.code.raw
        
        switch self.code {
        case .U64:
            result += LibraUtils.getLengthData(length: Int(self.value)!, appendBytesCount: 8)
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
