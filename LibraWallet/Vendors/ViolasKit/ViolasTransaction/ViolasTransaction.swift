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
        
    public init(receiveAddress: String, amount: Double, sendAddress: String, sequenceNumber: UInt64, authenticatorKey: String) {

        let argument1 = ViolasTransactionArgument.init(code: .Address, value: receiveAddress)
        let argument2 = ViolasTransactionArgument.init(code: .U64, value: "\(Int(amount * 1000000))")
        let argument3 = ViolasTransactionArgument.init(code: .U8Vector, value: authenticatorKey)
        
        let script = ViolasTransactionScript.init(code: Data.init(hex: libraProgramCode), typeTags: [ViolasTypeTag.init(structData: ViolasStructTag.init(type: .ViolasDefault))], argruments: [argument1, argument3, argument2])
        
        let raw = ViolasRawTransaction.init(senderAddres: sendAddress,
                                            sequenceNumber: sequenceNumber,
                                            maxGasAmount: 400000,
                                            gasUnitPrice: 0,
                                            expirationTime: Int(UInt64(Date().timeIntervalSince1970) + 3600),
                                            programOrWrite: script.serialize())
        self.request = raw
    }
}
extension ViolasTransaction {
    // Violas注册稳定币
    public init(sendAddress: String, sequenceNumber: UInt64, code: Data) {
        
        let program = ViolasTransactionScript.init(code: code,
                                                   typeTags: [ViolasTypeTag](),
                                                   argruments: [ViolasTransactionArgument.init(code: ViolasArgumentsCode.U8Vector, value: "publish".data(using: .utf8)!.toHexString())])
                
        let raw = ViolasRawTransaction.init(senderAddres: sendAddress,
                                            sequenceNumber: sequenceNumber,
                                            maxGasAmount: 400000,
                                            gasUnitPrice: 0,
                                            expirationTime: Int(UInt64(Date().timeIntervalSince1970) + 3600),
                                            programOrWrite: program.serialize())
        self.request = raw
    }
    // Violas转稳定币
    public init(sendAddress: String, receiveAddress: String, amount: Double, sequenceNumber: UInt64, code: Data) {
        // tokenIndex
        let argument0 = ViolasTransactionArgument.init(code: .U64, value: "0")

        let argument1 = ViolasTransactionArgument.init(code: .Address, value: receiveAddress)
        let argument2 = ViolasTransactionArgument.init(code: .U64, value: "\(Int(amount * 1000000))")
        
        let argument3 = ViolasTransactionArgument.init(code: .U8Vector, value: "")

        let program = ViolasTransactionScript.init(code: code,
                                                   typeTags: [ViolasTypeTag](),
                                                   argruments: [argument0, argument1, argument2, argument3])
        
        let raw = ViolasRawTransaction.init(senderAddres: sendAddress,
                                            sequenceNumber: sequenceNumber,
                                            maxGasAmount: 400000,
                                            gasUnitPrice: 0,
                                            expirationTime: Int(UInt64(Date().timeIntervalSince1970) + 3600),
                                            programOrWrite: program.serialize())
        self.request = raw
    }
    public init(sendAddress: String, sequenceNumber: UInt64, code: Data, test: Bool) {
        
        let module = ViolasTransactionModule.init(code: code)
                
        let raw = ViolasRawTransaction.init(senderAddres: sendAddress,
                                            sequenceNumber: sequenceNumber,
                                            maxGasAmount: 400000,
                                            gasUnitPrice: 0,
                                            expirationTime: Int(UInt64(Date().timeIntervalSince1970) + 3600),
                                            programOrWrite: module.serialize())
        self.request = raw
    }
}
extension ViolasTransaction {
    // 取消订单
    public init(sendAddress: String, fee: Double, sequenceNumber: UInt64, code: Data, version: String) {
        
        let argument1 = ViolasTransactionArgument.init(code: .Address, value: MarketAddress)
        let argument2 = ViolasTransactionArgument.init(code: .U64, value: "\(Int(0 * 1000000))")
        
        let data = "{\"type\":\"wd_ex\",\"ver\":\"\(version)\"}".data(using: .utf8)!
        
        let argument3 = ViolasTransactionArgument.init(code: .U8Vector, value: data.toHexString())
        
        let program = ViolasTransactionScript.init(code: code, typeTags: [ViolasTypeTag.init(structData: ViolasStructTag.init(type: .ViolasDefault))], argruments: [argument1, argument2, argument3])
        
        let raw = ViolasRawTransaction.init(senderAddres: sendAddress,
                                            sequenceNumber: sequenceNumber,
                                            maxGasAmount: 280000,
                                            gasUnitPrice: 0,
                                            expirationTime: Int(UInt64(Date().timeIntervalSince1970) + 1000),
                                            programOrWrite: program.serialize())
        self.request = raw
    }
}
extension ViolasTransaction {
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
               
        let argument3 = ViolasTransactionArgument.init(code: .U8Vector, value: data.toHexString())
        
        let program = ViolasTransactionScript.init(code: code, typeTags: [ViolasTypeTag.init(structData: ViolasStructTag.init(type: .ViolasDefault))], argruments: [argument1, argument2, argument3])
        
        let raw = ViolasRawTransaction.init(senderAddres: sendAddress,
                                            sequenceNumber: sequenceNumber,
                                            maxGasAmount: 280000,
                                            gasUnitPrice: 0,
                                            expirationTime: Int(UInt64(Date().timeIntervalSince1970) + 1000),
                                            programOrWrite: program.serialize())
        self.request = raw
    }
}
extension ViolasTransaction {
    //MARK: - vBTC->BTC兑换币
    /// VBTC->BTC兑换币
    /// - Parameters:
    ///   - sendAddress: 发送地址
    ///   - amount: 数量
    ///   - fee: 手续费
    ///   - sequenceNumber: 序列码
    ///   - code: 合约编码
    ///   - btcReceiveAddress: 接收BTC地址
    public init(sendAddress: String, amount: Double, fee: Double, sequenceNumber: UInt64, code: Data, btcReceiveAddress: String) {
        
        let argument1 = ViolasTransactionArgument.init(code: .Address, value: "fd0426fa9a3ba4fae760d0f614591c61bb53232a3b1138d5078efa11ef07c49c")
        let argument2 = ViolasTransactionArgument.init(code: .U64, value: "\(Int(amount * 1000000))")

        let data = "{\"flag\":\"violas\",\"type\":\"v2b\",\"to_address\":\"\(btcReceiveAddress)\",\"state\":\"start\"}".data(using: .utf8)!

        let argument3 = ViolasTransactionArgument.init(code: .U8Vector, value: data.toHexString())

        let program = ViolasTransactionScript.init(code: code, typeTags: [ViolasTypeTag.init(structData: ViolasStructTag.init(type: .ViolasDefault))], argruments: [argument1, argument2, argument3])

        let raw = ViolasRawTransaction.init(senderAddres: sendAddress,
                                            sequenceNumber: sequenceNumber,
                                            maxGasAmount: 280000,
                                            gasUnitPrice: 0,
                                            expirationTime: Int(UInt64(Date().timeIntervalSince1970) + 1000),
                                            programOrWrite: program.serialize())
        self.request = raw
    }
}
extension ViolasTransaction {
    //MARK: - VLibra->Libra兑换币
    /// VLibra->Libra兑换币
    /// - Parameters:
    ///   - sendAddress: 发送地址
    ///   - amount: 数量
    ///   - fee: 手续费
    ///   - sequenceNumber: 序列码
    ///   - code: 合约编码
    ///   - receiveAddress: 接收Libra地址
    public init(sendAddress: String, amount: Double, fee: Double, sequenceNumber: UInt64, code: Data, libraReceiveAddress: String) {
        
        let argument1 = ViolasTransactionArgument.init(code: .Address, value: "fd0426fa9a3ba4fae760d0f614591c61bb53232a3b1138d5078efa11ef07c49c")
        let argument2 = ViolasTransactionArgument.init(code: .U64, value: "\(Int(amount * 1000000))")

        let data = "{\"flag\":\"violas\",\"type\":\"v2l\",\"to_address\":\"\(libraReceiveAddress)\",\"state\":\"start\"}".data(using: .utf8)!

        let argument3 = ViolasTransactionArgument.init(code: .U8Vector, value: data.toHexString())

        let program = ViolasTransactionScript.init(code: code, typeTags: [ViolasTypeTag.init(structData: ViolasStructTag.init(type: .ViolasDefault))], argruments: [argument1, argument2, argument3])

        let raw = ViolasRawTransaction.init(senderAddres: sendAddress,
                                            sequenceNumber: sequenceNumber,
                                            maxGasAmount: 280000,
                                            gasUnitPrice: 0,
                                            expirationTime: Int(UInt64(Date().timeIntervalSince1970) + 1000),
                                            programOrWrite: program.serialize())
        self.request = raw
    }
}
