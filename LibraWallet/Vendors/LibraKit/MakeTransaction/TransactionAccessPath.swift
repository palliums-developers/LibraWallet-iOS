//
//  TransactionAccessPath.swift
//  LibraWallet
//
//  Created by palliums on 2019/9/10.
//  Copyright © 2019 palliums. All rights reserved.
//

import Foundation
enum TransactionWriteType {
    case Delete
    case Write
}
extension TransactionWriteType {
    public var raw: Data {
        switch self {
        case .Delete:
            return Data.init(hex: "00")
        case .Write:
            return Data.init(hex: "0100000004000000CAFED00D")
        }
    }
}
struct TransactionAccessPath {
    fileprivate let address: String
    
    fileprivate let path: String
    
    fileprivate let writeType: TransactionWriteType
   
    init(address: String, path: String, writeType: TransactionWriteType) {
        
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
