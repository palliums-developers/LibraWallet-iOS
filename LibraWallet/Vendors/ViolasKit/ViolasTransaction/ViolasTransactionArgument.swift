//
//  ViolasTransactionArgument.swift
//  LibraWallet
//
//  Created by palliums on 2019/12/13.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit

enum ViolasArgumentsCode {
    case Address
    case U64
    case Bytes
    #warning("待测试")
    case Bool
}
extension ViolasArgumentsCode {
    public var raw: Data {
        switch self {
        case .U64:
            return Data.init(hex: "00000000")
        case .Address:
            return Data.init(hex: "01000000")
        case .Bytes:
            return Data.init(hex: "02000000")
        case .Bool:
            return Data.init(hex: "03000000")
        }
    }
}
struct ViolasTransactionArgument {
    fileprivate let code: ViolasArgumentsCode
    
    fileprivate let value: String
    
    init(code: ViolasArgumentsCode, value: String) {
        self.code = code
        self.value = value
    }
    func serialize() -> Data {
        var result = Data()
        
        result += self.code.raw
        
        switch self.code {
        case .U64:
            result += getLengthData(length: Int(self.value)!, appendBytesCount: 8)

        case .Address:
//            let data = Data.init(hex: )
            let data = Data.init(Array<UInt8>(hex: self.value))
            
//            result += getLengthData(length: data.bytes.count, appendBytesCount: 4)

            result += data
        case .Bytes:
//            let data = Data.init(hex: self.value)
            let data = Data.init(Array<UInt8>(hex: self.value))
            
            result += getLengthData(length: data.bytes.count, appendBytesCount: 4)
            
            result += data
        case .Bool:
            
            result += getLengthData(length: Int(self.value)!, appendBytesCount: 1)
            
        }
        return result
    }
}
