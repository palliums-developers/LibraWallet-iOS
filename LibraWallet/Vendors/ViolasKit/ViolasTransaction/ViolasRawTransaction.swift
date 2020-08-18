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
    
    fileprivate let maxGasAmount: UInt64
    
    fileprivate let gasUnitPrice: UInt64
    
    fileprivate let expirationTime: UInt64
    
    fileprivate let payLoad: Data
    
    fileprivate let module: String
    
    init(senderAddres: String, sequenceNumber: UInt64, maxGasAmount: UInt64, gasUnitPrice: UInt64, expirationTime: UInt64, payLoad: Data, module: String) {
        
        self.senderAddress = senderAddres
        
        self.sequenceNumber = sequenceNumber
        
        self.maxGasAmount = maxGasAmount
        
        self.gasUnitPrice = gasUnitPrice
        
        self.expirationTime = expirationTime
        
        self.payLoad = payLoad
        
        self.module = module
    }
    func serialize() -> Data {
        var result = Data()
        // senderAddress
        result += Data.init(Array<UInt8>(hex: self.senderAddress))
        // sequenceNumber
        result += ViolasUtils.getLengthData(length: sequenceNumber, appendBytesCount: 8)
        // TransactionPayload
        result += self.payLoad
        // maxGasAmount
        result += ViolasUtils.getLengthData(length: maxGasAmount, appendBytesCount: 8)
        // gasUnitPrice
        result += ViolasUtils.getLengthData(length: gasUnitPrice, appendBytesCount: 8)
        // ViolasTypeTag
        result += getModuleType(module: module)
        // expirationTime
        result += ViolasUtils.getLengthData(length: expirationTime, appendBytesCount: 8)
        return result
    }
    func getModuleType(module: String) -> Data {
        var data = Data()
        let LBRData = module.data(using: .utf8)!
        data += ViolasUtils.uleb128Format(length: LBRData.count)
        data += LBRData
        return data
    }
}
