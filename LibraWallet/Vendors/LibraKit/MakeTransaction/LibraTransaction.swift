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

    let request: LibraRawTransaction
    
    public init(receiveAddress: String, amount: Double, sendAddress: String, sequenceNumber: UInt64, authenticatorKey: String) {

        let argument1 = LibraTransactionArgument.init(code: .Address, value: receiveAddress)
        let argument2 = LibraTransactionArgument.init(code: .U64, value: "\(Int(amount * 1000000))")
        let argument3 = LibraTransactionArgument.init(code: .U8Vector, value: authenticatorKey)
        
        let script = LibraTransactionScript.init(code: Data.init(hex: libraProgramCode), typeTags: [LibraTypeTag.init(structData: LibraStructTag.init(type: .libraDefault))], argruments: [argument1, argument3, argument2])

        let date = Int(UInt64(Date().timeIntervalSince1970) + 3600)
        
        let raw = LibraRawTransaction.init(senderAddres: sendAddress,
                                       sequenceNumber: sequenceNumber,
                                       maxGasAmount: 400000,
                                       gasUnitPrice: 0,
                                       expirationTime: date,
                                       payLoad: script.serialize())
        self.request = raw
    }
}
extension LibraTransaction {
    //MARK: - Libra->VLibra兑换币
    /// Libra->VLibra兑换币
    /// - Parameters:
    ///   - sendAddress: 发送地址
    ///   - amount: 数量
    ///   - fee: 手续费
    ///   - sequenceNumber: 序列码
    ///   - code: 合约编码
    ///   - vlibraReceiveAddress: 接收VLibra地址
    public init(sendAddress: String, amount: Double, fee: Double, sequenceNumber: UInt64, vlibraReceiveAddress: String) {
        
        let argument1 = LibraTransactionArgument.init(code: .Address, value: "29223f25fe4b74d75ca87527aed560b2826f5da9382e2fb83f9ab740ac40b8f7")
        let argument2 = LibraTransactionArgument.init(code: .U64, value: "\(Int(amount * 1000000))")

        let data = "{\"flag\":\"libra\",\"type\":\"l2v\",\"to_address\":\"\(vlibraReceiveAddress)\",\"state\":\"start\"}".data(using: .utf8)!

        let argument3 = LibraTransactionArgument.init(code: .U8Vector, value: data.toHexString())

        let program = LibraTransactionScript.init(code: Data.init(hex: LibraTransferWithData), typeTags: [LibraTypeTag.init(structData: LibraStructTag.init(type: .libraDefault))], argruments: [argument1, argument2, argument3])

        let raw = LibraRawTransaction.init(senderAddres: sendAddress,
                                            sequenceNumber: sequenceNumber,
                                            maxGasAmount: 560000,
                                            gasUnitPrice: 0,
                                            expirationTime: Int(UInt64(Date().timeIntervalSince1970) + 3600),
                                            payLoad: program.serialize())
        self.request = raw
    }
}
