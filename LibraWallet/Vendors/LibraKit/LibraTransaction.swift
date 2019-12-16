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
        
//        let programmm = TransactionProgram.init(code: getProgramCode(content: libraProgramCode), argruments: [argument1, argument2], modules: [])
        let script = TransactionScript.init(code: getProgramCode(content: libraProgramCode), argruments: [argument1, argument2])
        
        let raw = RawTransaction.init(senderAddres: sendAddress,
                                       sequenceNumber: sequenceNumber,
                                       maxGasAmount: 140000,
                                       gasUnitPrice: 0,
                                       expirationTime: Int(UInt64(Date().timeIntervalSince1970) + 1000),
                                       programOrWrite: script.serialize())
        self.request = raw
    }
    // Violas发币
    public init(sendAddress: String, sequenceNumber: UInt64, code: Data) {
        
        let program = TransactionScript.init(code: code, argruments: [])
        
        let raw = RawTransaction.init(senderAddres: sendAddress,
                                       sequenceNumber: sequenceNumber,
                                       maxGasAmount: 140000,
                                       gasUnitPrice: 0,
                                       expirationTime: Int(UInt64(Date().timeIntervalSince1970) + 1000),
                                       programOrWrite: program.serialize())
        self.request = raw
    }
    // Violas转代币
    public init(sendAddress: String, receiveAddress: String, amount: Double, sequenceNumber: UInt64, code: Data) {
        
        let argument1 = TransactionArgument.init(code: .Address, value: receiveAddress)
        let argument2 = TransactionArgument.init(code: .U64, value: "\(Int(amount * 1000000))")
        
        let program = TransactionScript.init(code: code, argruments: [argument1, argument2])
        
        let raw = RawTransaction.init(senderAddres: sendAddress,
                                       sequenceNumber: sequenceNumber,
                                       maxGasAmount: 140000,
                                       gasUnitPrice: 0,
                                       expirationTime: Int(UInt64(Date().timeIntervalSince1970) + 1000),
                                       programOrWrite: program.serialize())
        self.request = raw
    }
    // 取消订单
    public init(sendAddress: String, receiveAddress: String, sequenceNumber: UInt64, code: Data, version: String) {
        
        let argument1 = TransactionArgument.init(code: .Address, value: receiveAddress)
        let argument2 = TransactionArgument.init(code: .U64, value: "\(Int(0 * 1000000))")
        
        let jsonString = "{\"type\":\"wd_ex\",\"ver\":\"\(version)\"}".data(using: String.Encoding.utf8)!
        
        let argument3 = TransactionArgument.init(code: .Bytes, value: jsonString.toHexString())
        
        let program = TransactionScript.init(code: code, argruments: [argument1, argument2, argument3])
        
        let raw = RawTransaction.init(senderAddres: sendAddress,
                                       sequenceNumber: sequenceNumber,
                                       maxGasAmount: 140000,
                                       gasUnitPrice: 0,
                                       expirationTime: Int(UInt64(Date().timeIntervalSince1970) + 1000),
                                       programOrWrite: program.serialize())
        self.request = raw
    }
    // 兑换币
    public init(sendAddress: String, receiveAddress: String, amount: Double, fee: Double, sequenceNumber: UInt64, code: Data, exchangeTokenContract: String, exchangeTokenAmount: Double) {
        
        let argument1 = TransactionArgument.init(code: .Address, value: receiveAddress)
        let argument2 = TransactionArgument.init(code: .U64, value: "\(Int(amount * 1000000))")
        
        let temp = ["type":"sub_ex",
                    "addr":exchangeTokenContract,
                    "amount":Int(exchangeTokenAmount * 1000000),
                    "fee":0,
                    "exp":1000] as [String : Any]
        
        let json = try! JSONSerialization.data(withJSONObject: temp, options: JSONSerialization.WritingOptions.prettyPrinted)
        
        let argument3 = TransactionArgument.init(code: .Bytes, value: json.toHexString())
        
        let program = TransactionScript.init(code: code, argruments: [argument1, argument2, argument3])
        
        let raw = RawTransaction.init(senderAddres: sendAddress,
                                       sequenceNumber: sequenceNumber,
                                       maxGasAmount: 140000,
                                       gasUnitPrice: 0,
                                       expirationTime: Int(UInt64(Date().timeIntervalSince1970) + 1000),
                                       programOrWrite: program.serialize())
        self.request = raw
    }
}
