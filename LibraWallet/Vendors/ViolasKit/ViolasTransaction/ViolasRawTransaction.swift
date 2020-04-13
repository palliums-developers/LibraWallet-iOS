//
//  ViolasRawTransaction.swift
//  LibraWallet
//
//  Created by palliums on 2019/12/13.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit

struct ViolasRawTransaction {
    
    fileprivate let senderAddress: String
    
    fileprivate let sequenceNumber: UInt64
    
    fileprivate let maxGasAmount: Int64
    
    fileprivate let gasUnitPrice: Int64
    
    fileprivate let expirationTime: Int
    
    fileprivate let programOrWrite: Data
    
    init(senderAddres: String, sequenceNumber: UInt64, maxGasAmount: Int64, gasUnitPrice: Int64, expirationTime: Int, programOrWrite: Data) {
        
        self.senderAddress = senderAddres
        
        self.sequenceNumber = sequenceNumber
        
        self.maxGasAmount = maxGasAmount
        
        self.gasUnitPrice = gasUnitPrice
        
        self.expirationTime = expirationTime
        
        self.programOrWrite = programOrWrite
    }
    func serialize() -> Data {
        var result = Data()
        // senderAddressCount
//        let senderAddressData = Data.init(hex: self.senderAddress)
        let senderAddressData = Data.init(Array<UInt8>(hex: self.senderAddress))
//        result += getLengthData(length: senderAddressData.bytes.count, appendBytesCount: 4)
        // senderAddress
        result += senderAddressData
        // sequenceNumber
        result += ViolasUtils.getLengthData(length: Int(sequenceNumber), appendBytesCount: 8)//getLengthData(length: Int(sequenceNumber), appendBytesCount: 8)
        // TransactionPayload
        result += self.programOrWrite
        // maxGasAmount
        result += ViolasUtils.getLengthData(length: Int(maxGasAmount), appendBytesCount: 8)//getLengthData(length: Int(maxGasAmount), appendBytesCount: 8)
        // gasUnitPrice
        result += ViolasUtils.getLengthData(length: Int(gasUnitPrice), appendBytesCount: 8)//getLengthData(length: Int(gasUnitPrice), appendBytesCount: 8)
        // expirationTime
        result += ViolasUtils.getLengthData(length: expirationTime, appendBytesCount: 8)//getLengthData(length: expirationTime, appendBytesCount: 8)
        return result
    }
}
