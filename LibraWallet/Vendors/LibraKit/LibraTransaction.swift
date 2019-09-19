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

//    let request: AdmissionControl_SubmitTransactionRequest
    let request: Types_RawTransaction

    
    public init(receiveAddress: String, amount: Double, sendAddress: String, sequenceNumber: UInt64) {

        var addressArgument = Types_TransactionArgument.init()
        addressArgument.data = Data.init(hex: receiveAddress)
        addressArgument.type = Types_TransactionArgument.ArgType.address

        var tempArray = ""

        let amoutooo = BigUInt(amount * 1000000).serialize().toHexString()

        for _ in 0..<(16 - amoutooo.count) {
            tempArray.append("0")
        }
        tempArray.append(amoutooo)

        let resultAmount = Data.init(hex: tempArray).bytes.reversed()

        var amountArgument = Types_TransactionArgument.init()
        amountArgument.data = (Data() + resultAmount)
        amountArgument.type = Types_TransactionArgument.ArgType.u64

        var program = Types_Program.init()
        program.code = Data.init(hex: libraProgramCode)
        program.arguments = [addressArgument, amountArgument]

        var raw = Types_RawTransaction.init()
        raw.expirationTime = UInt64(Date().timeIntervalSince1970) + 100
        raw.gasUnitPrice = 0
        raw.maxGasAmount = 100000
        raw.sequenceNumber = sequenceNumber

        raw.senderAccount = Data.init(hex: sendAddress)
        raw.program = program

        self.request = raw
    }
}
