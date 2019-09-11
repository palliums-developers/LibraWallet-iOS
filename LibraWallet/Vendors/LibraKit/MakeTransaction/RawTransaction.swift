//
//  RawTransaction.swift
//  LibraWallet
//
//  Created by palliums on 2019/9/9.
//  Copyright © 2019 palliums. All rights reserved.
//

import Foundation
import BigInt

struct RawTransaction {
    
    fileprivate let senderAddress: String
    
    fileprivate let sequenceNumber: Int
    
    fileprivate let maxGasAmount: Int64
    
    fileprivate let gasUnitPrice: Int64
    
    fileprivate let expirationTime: Int
    
    fileprivate let programOrWrite: Data
    
    init(senderAddres: String, sequenceNumber: Int, maxGasAmount: Int64, gasUnitPrice: Int64, expirationTime: Int, programOrWrite: Data) {
        
        self.senderAddress = senderAddres
        
        self.sequenceNumber = sequenceNumber
        
        self.maxGasAmount = maxGasAmount
        
        self.gasUnitPrice = gasUnitPrice
        
        self.expirationTime = expirationTime
        
        self.programOrWrite = programOrWrite
    }
    func serialize() -> Data {
        var result = Data()
        // senderAddress
        let senderAddressData = Data.init(hex: self.senderAddress)
        result += dealData(originData: BigUInt(senderAddressData.bytes.count).serialize(), appendBytesCount: 4)
        // TransactionPayload
        result += senderAddressData
        // sequenceNumber
        result += dealData(originData: BigUInt(sequenceNumber).serialize(), appendBytesCount: 8)
        // programOrWrite
        result += self.programOrWrite
        // maxGasAmount
        result += dealData(originData: BigUInt(maxGasAmount).serialize(), appendBytesCount: 8)
        // gasUnitPrice
        result += dealData(originData: BigUInt(gasUnitPrice).serialize(), appendBytesCount: 8)
        // expirationTime
        result += dealData(originData: BigUInt(expirationTime).serialize(), appendBytesCount: 8)
        return result
    }
    fileprivate func dealData(originData: Data, appendBytesCount: Int) -> Data {
        var newData = Data()
        // 长度序列化
        let dataLenth = BigUInt(originData.bytes.count).serialize()
        // 补全长度
        for _ in 0..<(appendBytesCount - dataLenth.count) {
            newData.append(Data.init(hex: "00"))
        }
        // 追加原始数据
        newData.append(dataLenth)
        // 倒序输出
        let reversedAmount = newData.bytes.reversed()
        return Data() + reversedAmount
    }
}
