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
            return Data.init(hex: "00000000")
        case .Write:
            return Data.init(hex: "0100000004000000CAFED00D")
        }
    }
}
struct ViolasTransactionAccessPath {
    fileprivate let address: String
    
    fileprivate let path: String
    
    fileprivate let writeType: ViolasTransactionWriteType
   
    init(address: String, path: String, writeType: ViolasTransactionWriteType) {
        
        self.address = address
        
        self.path = path
        
        self.writeType = writeType
    }
    func serialize() -> Data {
        var result = Data()
        // 添加地址
//        let addressData = Data.init(hex: )
        let addressData = Data.init(Array<UInt8>(hex: self.address))
        
        result += addressData
        // 添加路径
//        let pathData = Data.init(hex: self.path)
        let pathData =  Data.init(Array<UInt8>(hex: self.path))
        result += getLengthData(length: pathData.bytes.count, appendBytesCount: 4)

        result += pathData
        // 追加类型
        result += self.writeType.raw
        return result
    }
}
