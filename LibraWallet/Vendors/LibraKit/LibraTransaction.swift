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
    /// Transaction data format version (note, this is signed)
//    public let version: Int32
//    /// If present, always 0001, and indicates the presence of witness data
//    // public let flag: UInt16 // If present, always 0001, and indicates the presence of witness data
//    /// Number of Transaction inputs (never zero)
//    public var txInCount: VarInt {
//        return VarInt(inputs.count)
//    }
//
    fileprivate let defaultData = Data.init(hex: "4c49425241564d0a010007014a00000004000000034e000000060000000c54000000060000000d5a0000000600000005600000002900000004890000002000000007a90000000f00000000000001000200010300020002040200030003020402063c53454c463e0c4c696272614163636f756e74046d61696e0f7061795f66726f6d5f73656e6465720000000000000000000000000000000000000000000000000000000000000000000100020104000c000c0113010002")
    let request: AdmissionControl_SubmitTransactionRequest
    
    public init(receiveAddress: String, amount: Double, wallet: LibraWallet, sequenceNumber: UInt64) {

        var addressArgument = Types_TransactionArgument.init()
        addressArgument.data = Data.init(hex: receiveAddress)
        addressArgument.type = Types_TransactionArgument.ArgType.address


        //        let tempArray = NSMutableArray()//
        var tempArray = ""

        let amoutooo = BigUInt(amount * 1000000).serialize().toHexString()

        for _ in 0..<(16 - amoutooo.count) {
            tempArray.append("0")
        }
        tempArray.append(amoutooo)

        let resultAmount = Data.init(hex: tempArray).bytes.reversed()

        print("---\((Data() + resultAmount).toHexString())")


        var amountArgument = Types_TransactionArgument.init()
        amountArgument.data = (Data() + resultAmount)
        amountArgument.type = Types_TransactionArgument.ArgType.u64

        var program = Types_Program.init()
//        let str = "TElCUkFWTQoBAAcBSgAAAAQAAAADTgAAAAYAAAAMVAAAAAYAAAANWgAAAAYAAAAFYAAAACkAAAAEiQAAACAAAAAHqQAAAA4AAAAAAAABAAIAAQMAAgACBAIAAwADAgQCBjxTRUxGPgxMaWJyYUFjY291bnQEbWFpbg9wYXlfZnJvbV9zZW5kZXIAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABAgEEAAwADAERAQAC"
        program.code = Data.init(hex: libraProgramCode)
        program.arguments = [addressArgument, amountArgument]

        var test = Types_RawTransaction.init()
        test.expirationTime = UInt64(Date().timeIntervalSince1970) + 100
        test.gasUnitPrice = 0
        test.maxGasAmount = 100000
        test.sequenceNumber = sequenceNumber

        test.senderAccount = Data.init(hex: wallet.publicKey().toAddress())
        test.program = program

        let result = try? test.serializedData()

        var sha3Prifix = Data.init(hex: signTransactionSalt)

        sha3Prifix.append(result!.bytes, count: (result?.bytes.count)!)

        let keySeed = try! Seed.init(bytes: wallet.seed.bytes)
        let keyPairrrr = KeyPair.init(seed: keySeed)
        let sign = keyPairrrr.sign(sha3Prifix.sha3(.sha256).bytes)

        var signedTransation = Types_SignedTransaction.init()
        signedTransation.rawTxnBytes = result!
        signedTransation.senderSignature = Data.init(bytes: sign, count: sign.count)
        signedTransation.senderPublicKey = wallet.publicKey().raw
        //        let finalResult = try! signedTransation.serializedData()

        //        print(finalResult.toHexString())
        /// 封装Request
        var mission = AdmissionControl_SubmitTransactionRequest.init()
        mission.signedTxn = signedTransation
        self.request = mission
    }
}
