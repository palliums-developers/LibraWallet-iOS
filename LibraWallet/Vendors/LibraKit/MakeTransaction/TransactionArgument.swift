//
//  TransactionProgram.swift
//  LibraWallet
//
//  Created by palliums on 2019/9/9.
//  Copyright © 2019 palliums. All rights reserved.
//

import Foundation
import BigInt
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
            #warning("强转,待修改错误提醒")
            let tempData = BigUInt(self.value)!.serialize().bytes.reversed()
            result += tempData
        case .Address:
            #warning("强转,待修改错误提醒")
            let re = Data.init(hex: self.value)
            
            var address = Data()
            //长度4个字节反转
            let dataLenth = BigUInt(re.bytes.count).serialize()
            for _ in 0..<(4 - dataLenth.count) {
                address.append(Data.init(hex: "00"))
            }
            address.append(dataLenth)
            
            let reversedAmount = address.bytes.reversed()
            
            result += reversedAmount
            result += re
        case .String:
            #warning("强转,待修改错误提醒")
            let re = self.value.data(using: String.Encoding.utf8)!
            
            var stringData = Data()
            //长度4个字节反转
            let dataLenth = BigUInt(re.bytes.count).serialize()
            for _ in 0..<(4 - dataLenth.count) {
                stringData.append(Data.init(hex: "00"))
            }
            stringData.append(dataLenth)
            
            let reversedAmount = stringData.bytes.reversed()
            
            result += reversedAmount
            result += re
        case .Bytes:
            #warning("强转,待修改错误提醒")
            let tempData = Data.init(hex: self.value)
            
            var stringData = Data()
            //长度4个字节反转
            let dataLenth = BigUInt(tempData.bytes.count).serialize()
            for _ in 0..<(4 - dataLenth.count) {
                stringData.append(Data.init(hex: "00"))
            }
            stringData.append(dataLenth)
            
            let reversedAmount = stringData.bytes.reversed()
            
            result += reversedAmount
            
            result += tempData
        }
        
        return result
    }
}
