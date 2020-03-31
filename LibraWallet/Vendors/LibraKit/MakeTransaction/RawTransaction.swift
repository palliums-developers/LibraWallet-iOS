//
//  RawTransaction.swift
//  LibraWallet
//
//  Created by palliums on 2019/9/9.
//  Copyright © 2019 palliums. All rights reserved.
//

import Foundation
import CryptoSwift
struct RawTransaction {
    
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
        // senderAddress
        result += Data.init(Array<UInt8>(hex: self.senderAddress))
        // sequenceNumber
        result += getLengthData(length: Int(sequenceNumber), appendBytesCount: 8)
        // TransactionPayload
        result += self.programOrWrite
        // maxGasAmount
        result += getLengthData(length: Int(maxGasAmount), appendBytesCount: 8)
        // gasUnitPrice
        result += getLengthData(length: Int(gasUnitPrice), appendBytesCount: 8)
        //1e7d12e8a75683776012faf9987028061409fc67d04cddf259240703809b6d12 验证KEY
        //f47df986f4e7421a125e87e7b49137461254a67333a0d9b8dea9472724f0c67d 公钥
        //21b2c824302901d6c1058dbeee4cf5b1e2c2883fae29512095d6396434a8c0d1 地址
        result += LibraTypeTag.init(typeTag: .Struct, value: "00000000000000000000000000000000", module: "LBR", name: "T", typeParams: [String]()).serialize()
        // expirationTime
//        00000000000000000000000000000000
//        00000000000000000000000000000000
        result += getLengthData(length: expirationTime, appendBytesCount: 8)
        return result
    }
}
