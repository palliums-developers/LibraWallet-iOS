//
//  LibraTransactionAccessPath.swift
//  LibraWallet
//
//  Created by palliums on 2019/9/10.
//  Copyright © 2019 palliums. All rights reserved.
//

import Foundation
enum LibraWriteType {
    case Deletion
    case Value
}
extension LibraWriteType {
    public var raw: Data {
        switch self {
        case .Deletion:
            return Data.init(hex: "00")
        case .Value:
            return Data.init(hex: "01")
        }
    }
}
struct LibraAccessPath {
    fileprivate let address: String
    
    fileprivate let path: String
    
    fileprivate let writeType: LibraWriteType
    
    fileprivate let value: Data?
   
    init(address: String, path: String, writeType: LibraWriteType, value: Data? = nil) {
        self.address = address
        
        self.path = path
        
        self.writeType = writeType
        
        self.value = value
    }
    func serialize() -> Data {
        var result = Data()
        // 添加地址
        let addressData = Data.init(Array<UInt8>(hex: address))
        result += addressData
        // 添加路径
        let pathData = Data.init(Array<UInt8>(hex: path))
        result += LibraUtils.uleb128Format(length: pathData.bytes.count)
        result += pathData
        // 追加类型
        result += writeType.raw
        if let tempValue = value {
            result += LibraUtils.uleb128Format(length: tempValue.bytes.count)
            result += tempValue
        }
        return result
    }
}
