//
//  LibraTransactionAccessPath.swift
//  LibraWallet
//
//  Created by palliums on 2019/9/10.
//  Copyright © 2019 palliums. All rights reserved.
//

import Foundation
enum LibraWriteOp {
    case Deletion
    case Value(Data)
}
extension LibraWriteOp {
    public var raw: Data {
        switch self {
        case .Deletion:
            return Data.init(Array<UInt8>(hex: "00"))
        case .Value:
            return Data.init(Array<UInt8>(hex: "01"))
        }
    }
}
struct LibraAccessPath {
    fileprivate let address: String

    fileprivate let path: String
    
    fileprivate let writeOp: LibraWriteOp
    
    init(address: String, path: String, writeOp: LibraWriteOp) {
        self.address = address

        self.path = path
        
        self.writeOp = writeOp
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
        result += writeOp.raw
        switch writeOp {
        case .Deletion:
            return result
        case .Value(let value):
            result += LibraUtils.uleb128Format(length: value.bytes.count)
            result += value
            return result
        }
    }
}
