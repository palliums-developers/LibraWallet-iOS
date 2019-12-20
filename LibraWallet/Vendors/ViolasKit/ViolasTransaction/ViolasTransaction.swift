//
//  ViolasTransaction.swift
//  LibraWallet
//
//  Created by palliums on 2019/12/13.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit
import CryptoSwift
struct ViolasTransaction {
    let request: ViolasRawTransaction
        
    public init(receiveAddress: String, amount: Double, sendAddress: String, sequenceNumber: UInt64) {

        let argument1 = ViolasTransactionArgument.init(code: .Address, value: receiveAddress)
        let argument2 = ViolasTransactionArgument.init(code: .U64, value: "\(Int(amount * 1000000))")
        
//        let programmm = TransactionProgram.init(code: getProgramCode(content: libraProgramCode), argruments: [argument1, argument2], modules: [])
        let script = ViolasTransactionScript.init(code: getProgramCode(content: libraProgramCode), argruments: [argument1, argument2])
        
        let raw = ViolasRawTransaction.init(senderAddres: sendAddress,
                                            sequenceNumber: sequenceNumber,
                                            maxGasAmount: 280000,
                                            gasUnitPrice: 0,
                                            expirationTime: Int(UInt64(Date().timeIntervalSince1970) + 1000),
                                            programOrWrite: script.serialize())
        self.request = raw
    }
    // Violas发币
    public init(sendAddress: String, sequenceNumber: UInt64, code: Data) {
        
        let program = ViolasTransactionScript.init(code: code, argruments: [])
        
        let raw = ViolasRawTransaction.init(senderAddres: sendAddress,
                                            sequenceNumber: sequenceNumber,
                                            maxGasAmount: 280000,
                                            gasUnitPrice: 0,
                                            expirationTime: Int(UInt64(Date().timeIntervalSince1970) + 1000),
                                            programOrWrite: program.serialize())
        self.request = raw
    }
    // Violas转代币
    public init(sendAddress: String, receiveAddress: String, amount: Double, sequenceNumber: UInt64, code: Data) {
        
        let argument1 = ViolasTransactionArgument.init(code: .Address, value: receiveAddress)
        let argument2 = ViolasTransactionArgument.init(code: .U64, value: "\(Int(amount * 1000000))")
        
        let program = ViolasTransactionScript.init(code: code, argruments: [argument1, argument2])
        
        let raw = ViolasRawTransaction.init(senderAddres: sendAddress,
                                            sequenceNumber: sequenceNumber,
                                            maxGasAmount: 280000,
                                            gasUnitPrice: 0,
                                            expirationTime: Int(UInt64(Date().timeIntervalSince1970) + 1000),
                                            programOrWrite: program.serialize())
        self.request = raw
    }
    // 取消订单
    public init(sendAddress: String, fee: Double, sequenceNumber: UInt64, code: Data, version: String) {
        
        let argument1 = ViolasTransactionArgument.init(code: .Address, value: MarketAddress)
        let argument2 = ViolasTransactionArgument.init(code: .U64, value: "\(Int(0 * 1000000))")
        
//        let temp = ["type":"wd_ex",
//                    "ver":version] as [String : Any]
        
//        let json = try! JSONSerialization.data(withJSONObject: temp, options: JSONSerialization.WritingOptions.prettyPrinted)
//        let argument3 = ViolasTransactionArgument.init(code: .Bytes, value: json.toHexString())
        let data = "{\"type\":\"wd_ex\",\"ver\":\"\(version)\"}".data(using: .utf8)!
        
        let argument3 = ViolasTransactionArgument.init(code: .Bytes, value: data.toHexString())
        
        let program = ViolasTransactionScript.init(code: code, argruments: [argument1, argument2, argument3])
        
        let raw = ViolasRawTransaction.init(senderAddres: sendAddress,
                                            sequenceNumber: sequenceNumber,
                                            maxGasAmount: 280000,
                                            gasUnitPrice: 0,
                                            expirationTime: Int(UInt64(Date().timeIntervalSince1970) + 1000),
                                            programOrWrite: program.serialize())
        self.request = raw
    }
    // 兑换币
    public init(sendAddress: String, amount: Double, fee: Double, sequenceNumber: UInt64, code: Data, receiveTokenAddress: String, exchangeAmount: Double) {
        
        let argument1 = ViolasTransactionArgument.init(code: .Address, value: MarketAddress)
        let argument2 = ViolasTransactionArgument.init(code: .U64, value: "\(Int(amount * 1000000))")
        
//        let temp = ["type":"sub_ex",
//                    "addr":receiveTokenAddress,
//                    "amount":Int(exchangeAmount * 1000000),
//                    "fee":0,
//                    "exp":1000] as [String : Any]
//
//        let json = try! JSONSerialization.data(withJSONObject: temp, options: JSONSerialization.WritingOptions.prettyPrinted)
//
//        let argument3 = ViolasTransactionArgument.init(code: .Bytes, value: json.toHexString())
        let data = "{\"type\":\"sub_ex\",\"addr\":\"\(receiveTokenAddress)\",\"amount\":\(Int(exchangeAmount * 1000000)),\"fee\":0,\"exp\":1000}".data(using: .utf8)!
               
        let argument3 = ViolasTransactionArgument.init(code: .Bytes, value: data.toHexString())
        
        let program = ViolasTransactionScript.init(code: code, argruments: [argument1, argument2, argument3])
        
        let raw = ViolasRawTransaction.init(senderAddres: sendAddress,
                                            sequenceNumber: sequenceNumber,
                                            maxGasAmount: 280000,
                                            gasUnitPrice: 0,
                                            expirationTime: Int(UInt64(Date().timeIntervalSince1970) + 1000),
                                            programOrWrite: program.serialize())
        self.request = raw
//        return raw
    }
}
