//
//  LibraTransaction.swift
//  LibraWallet
//
//  Created by palliums on 2019/9/5.
//  Copyright © 2019 palliums. All rights reserved.
//

import Foundation
import BigInt
import CryptoSwift
import SwiftEd25519
public struct LibraTransaction {

//    let request: Types_RawTransaction
    let request: RawTransaction

    
    public init(receiveAddress: String, amount: Double, sendAddress: String, sequenceNumber: UInt64) {

//        var addressArgument = Types_TransactionArgument.init()
//        addressArgument.data = Data.init(hex: receiveAddress)
//        addressArgument.type = Types_TransactionArgument.ArgType.address
//
//        var tempString = ""
//
//        let amoutooo = BigUInt(amount * 1000000).serialize().toHexString()
//
//        for _ in 0..<(16 - amoutooo.count) {
//            tempString.append("0")
//        }
//        tempString.append(amoutooo)
//
//        let resultAmount = Data.init(hex: tempString).bytes.reversed()
//
//        var amountArgument = Types_TransactionArgument.init()
//        amountArgument.data = (Data() + resultAmount)
//        amountArgument.type = Types_TransactionArgument.ArgType.u64
//
//        var program = Types_Program.init()
////        program.code = Data.init(hex: libraProgramCode)
//        program.code = getProgramCode()
//
//        program.arguments = [addressArgument, amountArgument]
//
//        var raw = Types_RawTransaction.init()
//        raw.expirationTime = UInt64(Date().timeIntervalSince1970) + 100
//        raw.gasUnitPrice = 0
//        raw.maxGasAmount = 100000
//        raw.sequenceNumber = sequenceNumber
//
//        raw.senderAccount = Data.init(hex: sendAddress)
//        raw.program = program

//        self.request = raw
        
        
        let argument1 = TransactionArgument.init(code: .Address, value: receiveAddress)
        let argument2 = TransactionArgument.init(code: .U64, value: "\(Int(amount * 1000000))")
        
        let programmm = TransactionProgram.init(code: getProgramCode(), argruments: [argument2, argument1], modules: [])
        
        let temp = RawTransaction.init(senderAddres: sendAddress,
                                       sequenceNumber: Int(sequenceNumber),
                                       maxGasAmount: 140000,
                                       gasUnitPrice: 0,
                                       expirationTime: Int(UInt64(Date().timeIntervalSince1970) + 100),
                                       programOrWrite: programmm.serialize())
        
        self.request = temp
    }
}
