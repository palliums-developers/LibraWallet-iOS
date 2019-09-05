//
//  ViewController.swift
//  LibraWallet
//
//  Created by palliums on 2019/8/29.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit
import CryptoSwift
import SwiftEd25519
import BigInt
import SwiftGRPC
import SwiftProtobuf
class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    @IBOutlet weak var Balance: UILabel!
    @IBAction func Balance(_ sender: Any) {
        getBalance()
    }
    
    @IBAction func test(_ sender: Any) {
        click()
    }
    var sequenceNumber: Int?
    func click() {
//        let seed = LibraSeed.init(mnemonic: "museum liquid spider explain vicious pave silent allow depth you adjust begin")
        let seed = LibraSeed.init(mnemonic: "net dice divide amount stamp flock brave nuclear fox aim father apology")
        
        let publicKey = LibraWallet.init(seed: seed).publicKey()
        print(publicKey.toAddress())
        
        signTransaction(sendAddress: "78349508fbc4e2bd5442c6f3fe340bd2a92c91d56c71e6ac15207d40394ef4a4", amount: 10, receiveAddress: publicKey.toAddress(), seed: seed.seed.bytes, publicKey: publicKey.raw.toHexString())

    }
    func signTransaction(sendAddress:  String, amount: BigUInt, receiveAddress: String, seed: [UInt8], publicKey: String) {
        var addressArgument = Types_TransactionArgument.init()
        addressArgument.data = Data.init(hex: sendAddress)
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
        let str = "TElCUkFWTQoBAAcBSgAAAAQAAAADTgAAAAYAAAAMVAAAAAYAAAANWgAAAAYAAAAFYAAAACkAAAAEiQAAACAAAAAHqQAAAA4AAAAAAAABAAIAAQMAAgACBAIAAwADAgQCBjxTRUxGPgxMaWJyYUFjY291bnQEbWFpbg9wYXlfZnJvbV9zZW5kZXIAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABAgEEAAwADAERAQAC"
        program.code = base64Decoding(encodedString: str)
        program.arguments = [addressArgument, amountArgument]

        var test = Types_RawTransaction.init()
        test.expirationTime = UInt64(Date().timeIntervalSince1970) + 100
        test.gasUnitPrice = 0
        test.maxGasAmount = 1000000
        test.sequenceNumber = UInt64(self.sequenceNumber ?? 0)

        test.senderAccount = Data.init(hex: receiveAddress)
        test.program = program

        let result = try? test.serializedData()

        var sha3Prifix = Data.init(hex: "46f174df6ca8de5ad29745f91584bb913e7df8dd162e3e921a5c1d8637c88d16")

        sha3Prifix.append(result!.bytes, count: (result?.bytes.count)!)


        let keySeed = try! Seed.init(bytes: seed)
        let keyPairrrr = KeyPair.init(seed: keySeed)
        let sign = keyPairrrr.sign(sha3Prifix.sha3(.sha256).bytes)

        var signedTransation = Types_SignedTransaction.init()
        signedTransation.rawTxnBytes = result!
        signedTransation.senderSignature = Data.init(bytes: sign, count: sign.count)
        signedTransation.senderPublicKey = Data.init(hex: publicKey)
//        let finalResult = try! signedTransation.serializedData()

//        print(finalResult.toHexString())
        /// 封装Request
        var mission = AdmissionControl_SubmitTransactionRequest.init()
        mission.signedTxn = signedTransation

//        let channel = Channel.init(address: "ac.testnet.libra.org:8000")
        let channel = Channel.init(address: "18.220.66.235:34042", secure: false)


        let client = AdmissionControl_AdmissionControlServiceClient.init(channel: channel)
        do {
//           _ = try client.submitTransaction(mission, completion: { (Response, request) in
//                print(Response?.acStatus as Any)
//                print(request.resultData ?? "")
//            })
            let response = try client.submitTransaction(mission)
            print(response.acStatus.code)
        } catch {
            print(error.localizedDescription)
        }
    }
    func getTransactionHistory() {
//        do {
//            let channel = Channel.init(address: "ac.testnet.libra.org:8000")
//
//            let client = AdmissionControl_AdmissionControlServiceClient.init(channel: channel)
//            do {
//                var jjj = Types_GetTransactionsRequest()
//                jjj.limit = 10
////                jjj.account = Data.init(hex: "46f174df6ca8de5ad29745f91584bb913e7df8dd162e3e921a5c1d8637c88d16")
//
//                var item = Types_RequestItem()
//                item.getTransactionsRequest = jjj
//
//                var sequenceNumber = Types_UpdateToLatestLedgerRequest()
//                sequenceNumber.requestedItems = [item]
//
//                let gaaa = try client.updateToLatestLedger(sequenceNumber)
//                print(gaaa)
//            } catch {
//                print(error.localizedDescription)
//            }
//        } catch {
//            print(error.localizedDescription)
//        }
    }
    func getBalance() {
//        let channel = Channel.init(address: "ac.testnet.libra.org:8000", secure: false)
        let channel = Channel.init(address: "18.220.66.235:34042", secure:  false)

        
        let client = AdmissionControl_AdmissionControlServiceClient.init(channel: channel)
        do {
            var jjj = Types_GetAccountStateRequest()
            jjj.address = Data.init(hex: "b8c39fc6910816ad21bc2be4f7e804539e7529b7b7d188c80f093e1e61f192cf")
            
            var item = Types_RequestItem()
            item.getAccountStateRequest = jjj
            
            var sequenceNumber = Types_UpdateToLatestLedgerRequest()
            sequenceNumber.requestedItems = [item]
            
            let gaaa = try client.updateToLatestLedger(sequenceNumber)
            
            guard let response = gaaa.responseItems.first else {
                return
            }
            let streamData = response.getAccountStateResponse.accountStateWithProof.blob.blob
//            let streamData = Data.init(hex: "010000002100000001217da6c6b3e19f1825cfb2676daecce3bf3de03cf26647c78df00b371b25cc974500000020000000b8c39fc6910816ad21bc2be4f7e804539e7529b7b7d188c80f093e1e61f192cf004e19de1a09000000030000000000000000000000000000000000000000000000")

            let blobLen = streamData.subdata(in: Range.init(NSRange.init(location: 0, length: 4))!)
            var resultArray = [Data]()
            for _ in 0..<hw_getInt(blobLen.bytes) {
                let keyLength = streamData.subdata(in: Range.init(NSRange.init(location: 4, length: 4))!)
//                let key = streamData.subdata(in: Range.init(NSRange.init(location: 8, length: hw_getInt(keyLength.bytes)))!)
                let dataLength = streamData.subdata(in: Range.init(NSRange.init(location: (hw_getInt(keyLength.bytes) + 4 + 4), length: 4))!)
                
                let data = streamData.subdata(in: Range.init(NSRange.init(location: (hw_getInt(keyLength.bytes) + 4 + 4 + 4), length: hw_getInt(dataLength.bytes)))!)
                print(data.toHexString())
                resultArray.append(data)
            }
            for result in resultArray {
                let addressLength = result.subdata(in: Range.init(NSRange.init(location: 0, length: 4))!)
                let address = result.subdata(in: Range.init(NSRange.init(location: 4, length: hw_getInt(addressLength.bytes)))!)
                print(address.toHexString())
                
                let balance = result.subdata(in: Range.init(NSRange.init(location: (4 + hw_getInt(addressLength.bytes)), length: 8))!)
                print(hw_getInt64(balance.bytes))
                
                let delegatedWithdrawalCapability = result.subdata(in: Range.init(NSRange.init(location: (8 + 4 + hw_getInt(addressLength.bytes)), length: 1))!)
                print(hw_getInt(delegatedWithdrawalCapability.bytes))
                
                let receivedEvents = result.subdata(in: Range.init(NSRange.init(location: (1 + 8 + 4 + hw_getInt(addressLength.bytes)), length: 8))!)
                print(hw_getInt64(receivedEvents.bytes))
                
                let sentEvents = result.subdata(in: Range.init(NSRange.init(location: (8 + 1 + 8 + 4 + hw_getInt(addressLength.bytes)), length: 8))!)
                print(hw_getInt64(sentEvents.bytes))
                
                let sequenceNumber = result.subdata(in: Range.init(NSRange.init(location: (8 + 8 + 1 + 8 + 4 + hw_getInt(addressLength.bytes)), length: 8))!)
                print(hw_getInt64(sequenceNumber.bytes))
                self.Balance.text = "\(hw_getInt64(balance.bytes) / 1000000)"
                self.sequenceNumber = hw_getInt64(sequenceNumber.bytes)
            }
            
        } catch {
            print(error.localizedDescription)
        }
    }
    func hw_getInt(_ array:[UInt8]) -> Int {
        var value : UInt8 = 0
        let data = NSData(bytes: array, length: array.count)
        data.getBytes(&value, length: array.count)
        value = UInt8(bigEndian: value)
        return Int(value)
    }
    func hw_getInt64(_ array:[UInt8]) -> Int {
        var value : Int = 0
        let data = NSData(bytes: array, length: array.count)
        data.getBytes(&value, length: array.count)
//        value = Int(bigEndian: value)
        return Int(value)
    }
}

