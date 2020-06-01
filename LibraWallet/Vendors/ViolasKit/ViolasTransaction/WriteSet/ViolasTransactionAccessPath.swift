//
//  ViolasTransactionAccessPath.swift
//  LibraWallet
//
//  Created by palliums on 2019/12/13.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit

enum ViolasTransactionWriteType {
    case Delete
    case Write
}
extension ViolasTransactionWriteType {
    public var raw: Data {
        switch self {
        case .Delete:
            return Data.init(hex: "00")
        case .Write:
            return Data.init(hex: "01")
        }
    }
}
struct ViolasTransactionAccessPath {
    fileprivate let address: String
    
    fileprivate let path: String
    
    fileprivate let writeType: ViolasTransactionWriteType
    
    fileprivate let value: Data?
   
    init(address: String, path: String, writeType: ViolasTransactionWriteType, value: Data? = nil) {
        
        self.address = address
        
        self.path = path
        
        self.writeType = writeType
        
        self.value = value
    }
    func serialize() -> Data {
        var result = Data()
        // 添加地址
//        let addressData = Data.init(hex: )
        let addressData = Data.init(Array<UInt8>(hex: self.address))
        result += addressData
        // 添加路径
        let pathData = Data.init(Array<UInt8>(hex: self.path))
        result += ViolasUtils.uleb128Format(length: pathData.bytes.count)
        result += pathData
        // 追加类型
        result += self.writeType.raw
        if let tempValue = self.value {
            result += ViolasUtils.uleb128Format(length: tempValue.bytes.count)
            result += tempValue
        }
        return result
    }
}
