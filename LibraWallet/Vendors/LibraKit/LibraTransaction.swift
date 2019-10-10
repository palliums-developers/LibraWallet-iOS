//
//  LibraTransaction.swift
//  LibraWallet
//
//  Created by palliums on 2019/9/5.
//  Copyright © 2019 palliums. All rights reserved.
//

import Foundation
import CryptoSwift
struct LibraTransaction {

    let request: RawTransaction
    
    public init(receiveAddress: String, amount: Double, sendAddress: String, sequenceNumber: UInt64) {

        let argument1 = TransactionArgument.init(code: .Address, value: receiveAddress)
        let argument2 = TransactionArgument.init(code: .U64, value: "\(Int(amount * 1000000))")
        
        let programmm = TransactionProgram.init(code: getProgramCode(), argruments: [argument1, argument2], modules: [])
        
        let raw = RawTransaction.init(senderAddres: sendAddress,
                                       sequenceNumber: sequenceNumber,
                                       maxGasAmount: 140000,
                                       gasUnitPrice: 0,
                                       expirationTime: Int(UInt64(Date().timeIntervalSince1970) + 100),
                                       programOrWrite: programmm.serialize())
        self.request = raw
    }
}
