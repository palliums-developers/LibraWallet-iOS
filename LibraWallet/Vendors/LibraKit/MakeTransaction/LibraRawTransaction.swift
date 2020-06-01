//
//  LibraRawTransaction.swift
//  LibraWallet
//
//  Created by palliums on 2019/9/9.
//  Copyright © 2019 palliums. All rights reserved.
//

import Foundation
import CryptoSwift
struct LibraRawTransaction {
    /// 发送地址
    fileprivate let senderAddress: String
    /// 发送序列号
    fileprivate let sequenceNumber: UInt64
    /// Gas最大数量
    fileprivate let maxGasAmount: Int64
    /// Gas价格
    fileprivate let gasUnitPrice: Int64
    /// 交易过期时间
    fileprivate let expirationTime: Int
    /// 交易脚本
    fileprivate let payLoad: Data
    
    init(senderAddres: String, sequenceNumber: UInt64, maxGasAmount: Int64, gasUnitPrice: Int64, expirationTime: Int, payLoad: Data) {
        
        self.senderAddress = senderAddres
        
        self.sequenceNumber = sequenceNumber
        
        self.maxGasAmount = maxGasAmount
        
        self.gasUnitPrice = gasUnitPrice
        
        self.expirationTime = expirationTime
        
        self.payLoad = payLoad
    }
    func serialize() -> Data {
        var result = Data()
        // senderAddress
        result += Data.init(Array<UInt8>(hex: self.senderAddress))
        // sequenceNumber(固定8个字节)
        result += LibraUtils.getLengthData(length: Int(sequenceNumber), appendBytesCount: 8)
        // TransactionPayload
        result += self.payLoad
        // maxGasAmount(固定8个字节)
        result += LibraUtils.getLengthData(length: Int(maxGasAmount), appendBytesCount: 8)
        // gasUnitPrice(固定8个字节)
        result += LibraUtils.getLengthData(length: Int(gasUnitPrice), appendBytesCount: 8)
        // libraTypeTag
        result += getLBRType()
        // expirationTime(固定8个字节)
        result += LibraUtils.getLengthData(length: expirationTime, appendBytesCount: 8)
        return result
    }
    func getLBRType() -> Data {
        var data = Data()
        let LBRData = "LBR".data(using: .utf8)!
        data += LibraUtils.uleb128Format(length: LBRData.count)
        data += LBRData
        return data
    }
}
