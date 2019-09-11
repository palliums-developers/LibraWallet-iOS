//
//  TransactionAccessPath.swift
//  LibraWallet
//
//  Created by palliums on 2019/9/10.
//  Copyright © 2019 palliums. All rights reserved.
//

import Foundation
import BigInt
enum TransactionWriteType {
    case Delete
    case Write
}
extension TransactionWriteType {
    public var raw: Data {
        switch self {
        case .Delete:
            return Data.init(hex: "00000000")
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
        let addressData = Data.init(hex: self.address)
        result += dealData(originData: BigUInt(addressData.bytes.count).serialize(), appendBytesCount: 4)
        result += addressData
        // 添加路径
        let pathData = Data.init(hex: self.path)
        result += dealData(originData: BigUInt(pathData.bytes.count).serialize(), appendBytesCount: 4)
        result += pathData
        // 追加类型
        result += self.writeType.raw
        return result
    }
    fileprivate func dealData(originData: Data, appendBytesCount: Int) -> Data {
        var newData = Data()
        // 补全长度
        for _ in 0..<(appendBytesCount - originData.count) {
            newData.append(Data.init(hex: "00"))
        }
        // 追加原始数据
        newData.append(originData)
        // 倒序输出
        let reversedAmount = newData.bytes.reversed()
        return Data() + reversedAmount
    }
    
}
