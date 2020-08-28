//
//  ViolasAccessPath.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/8/28.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit

enum ViolasWriteOp {
    case Deletion
    case Value(Data)
}
extension ViolasWriteOp {
    public var raw: Data {
        switch self {
        case .Deletion:
            return Data.init(Array<UInt8>(hex: "00"))
        case .Value:
            return Data.init(Array<UInt8>(hex: "01"))
        }
    }
}
struct ViolasAccessPath {
    fileprivate let address: String

    fileprivate let path: String
    
    fileprivate let writeOp: ViolasWriteOp
    
    init(address: String, path: String, writeOp: ViolasWriteOp) {
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
        result += ViolasUtils.uleb128Format(length: pathData.bytes.count)
        result += pathData
        // 追加类型
        result += writeOp.raw
        switch writeOp {
        case .Deletion:
            return result
        case .Value(let value):
            result += ViolasUtils.uleb128Format(length: value.bytes.count)
            result += value
            return result
        }
    }
}
