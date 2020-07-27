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
    fileprivate let maxGasAmount: UInt64
    /// Gas价格
    fileprivate let gasUnitPrice: UInt64
    /// 交易过期时间
    fileprivate let expirationTime: UInt64
    /// 交易脚本
    fileprivate let payload: LibraTransactionPayload
    /// Module名称
    fileprivate let module: String
    /// 链名字
    fileprivate let chainID: Int
    
    init(senderAddres: String, sequenceNumber: UInt64, maxGasAmount: UInt64, gasUnitPrice: UInt64, expirationTime: UInt64, payload: LibraTransactionPayload, module: String, chainID: Int) {
        self.senderAddress = senderAddres
        
        self.sequenceNumber = sequenceNumber
        
        self.maxGasAmount = maxGasAmount
        
        self.gasUnitPrice = gasUnitPrice
        
        self.expirationTime = expirationTime
        
        self.payload = payload
        
        self.module = module
        
        self.chainID = chainID
    }
    
    func serialize() -> Data {
        var result = Data()
        // senderAddress
        result += Data.init(Array<UInt8>(hex: senderAddress))
        // sequenceNumber(固定8个字节)
        result += LibraUtils.getLengthData(length: sequenceNumber, appendBytesCount: 8)
        // TransactionPayload
        result += payload.serialize()
        // maxGasAmount(固定8个字节)
        result += LibraUtils.getLengthData(length: maxGasAmount, appendBytesCount: 8)
        // gasUnitPrice(固定8个字节)
        result += LibraUtils.getLengthData(length: gasUnitPrice, appendBytesCount: 8)
        // libraModuleTag
        result += getModuleType(module: module)
        // expirationTime(固定8个字节)
        result += LibraUtils.getLengthData(length: expirationTime, appendBytesCount: 8)
        // chainID
        result += LibraUtils.getLengthData(length: UInt64(chainID), appendBytesCount: 1)
        return result
    }
    func getModuleType(module: String) -> Data {
        var data = Data()
        let LBRData = module.data(using: .utf8)!
        data += LibraUtils.uleb128Format(length: LBRData.count)
        data += LBRData
        return data
    }
}
