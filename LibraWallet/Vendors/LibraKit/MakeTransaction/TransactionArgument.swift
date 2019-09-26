//
//  TransactionProgram.swift
//  LibraWallet
//
//  Created by palliums on 2019/9/9.
//  Copyright © 2019 palliums. All rights reserved.
//

import Foundation
enum ArgumentsCode {
    case Address
    case U64
    case String
    case Bytes
}
extension ArgumentsCode {
    public var raw: Data {
        switch self {
        case .U64:
            return Data.init(hex: "00000000")
        case .Address:
            return Data.init(hex: "01000000")
        case .String:
            return Data.init(hex: "02000000")
        case .Bytes:
            return Data.init(hex: "03000000")
        }
    }
}
struct TransactionArgument {
    fileprivate let code: ArgumentsCode
    
    fileprivate let value: String
    
    init(code: ArgumentsCode, value: String) {
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
            let data = Data.init(hex: self.value)
            
            result += getLengthData(length: data.bytes.count, appendBytesCount: 4)

            result += data
        case .String:
            let data = self.value.data(using: String.Encoding.utf8)!
            
            result += getLengthData(length: data.bytes.count, appendBytesCount: 4)

            result += data
        case .Bytes:
            let data = Data.init(hex: self.value)

            result += getLengthData(length: data.bytes.count, appendBytesCount: 4)
            
            result += data
        }
        return result
    }
}
