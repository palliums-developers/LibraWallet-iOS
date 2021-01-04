//
//  BTCManagerTests.swift
//  LibraWalletTests
//
//  Created by palliums on 2019/11/7.
//  Copyright © 2019 palliums. All rights reserved.
//

import XCTest
@testable import ViolasPay
import BigInt
import BitcoinKit

class BTCManagerTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    func testBTC() {
        let mnemonicArray = ["net", "dice", "divide", "amount", "stamp", "flock", "brave", "nuclear", "fox", "aim", "father", "apology"]
        let wallet = try! BTCManager().getWallet(mnemonic: mnemonicArray)
        //BIP39 Seed
        XCTAssertEqual("f12e202e367bd9b24354b264b347eba79ac325ea429580425cc0a8d74cd9622ac3aeac1c40286b08e7ab7a29ae18c1fc5f15ba1376cbebcdf822d01a81bae503", wallet.seed.toHexString())
        //BIP32 Root Key
        XCTAssertEqual("tprv8ZgxMBicQKsPezAPNT5LRtjx51VvYgtTcT4mRZTMLXrLvX6kwnpBWPAY97pbYKPuMBfYTzPLV1ZnFyYSriqf8Lqjq4F37ujEcdpe4t8Rn2D", wallet.rootXPrivKey.qrcodeString)
        print()
        print(wallet.privKeys)
        print(wallet.externalIndex)
    }
    func testPublish() {
//        let result = ViolasManager().getViolasPublishCode(content: "05599ef248e215849cc599f563b4883fc8aff31f1e43dff1e3ebe4de1370e054")
//        XCTAssertEqual("4c49425241564d0a010007014a00000004000000034e000000060000000d54000000040000000e5800000002000000055a0000001b00000004750000004000000008b50000000b00000000000101000200010300020000000300063c53454c463e0644546f6b656e046d61696e077075626c697368000000000000000000000000000000000000000000000000000000000000000005599ef248e215849cc599f563b4883fc8aff31f1e43dff1e3ebe4de1370e0540001000100020013010002", result)
//        let result2 = ViolasManager().getViolasTransactionCode(content: "05599ef248e215849cc599f563b4883fc8aff31f1e43dff1e3ebe4de1370e054")
//        XCTAssertEqual("4c49425241564d0a010007014a00000004000000034e000000060000000d54000000060000000e5a0000000600000005600000002300000004830000004000000008c30000000f00000000000101000200010300020002040200030204020300063c53454c463e0644546f6b656e046d61696e0f7061795f66726f6d5f73656e646572000000000000000000000000000000000000000000000000000000000000000005599ef248e215849cc599f563b4883fc8aff31f1e43dff1e3ebe4de1370e054000100020004000c000c0113010102", result2)
    }
    func testIsValidViolasAddress() {
        let str = "["
        let result = ViolasManager.isValidViolasAddress(address: str)
        XCTAssertEqual(result, false)
        let str2 = "9db71b006cb300c1682e3a1ab3755,52344fa808b2acd4f53340470a5267bf082"
        let result2 = ViolasManager.isValidViolasAddress(address: str2)
        XCTAssertEqual(result2, false)
        let str3 = "9db71b006cb300c1682e3a1ab375552344fa808b2acd4f53340470a5267bf082"
        let result3 = ViolasManager.isValidViolasAddress(address: str3)
        XCTAssertEqual(result3, true)
        let str4 = "9db71b006cb300c1682e3a1ab375552344fa808b2acd4f53340470a5267bf082😊"
        let result4 = ViolasManager.isValidViolasAddress(address: str4)
        XCTAssertEqual(result4, false)
    }
    func testExchange() {
//        let seed = Data.init(Array<UInt8>(hex: "f12e202e367bd9b24354b264b347eba79ac325ea429580425cc0a8d74cd9622ac3aeac1c40286b08e7ab7a29ae18c1fc5f15ba1376cbebcdf822d01a81bae500"))
//        let wallet = HDWallet.init(seed: seed, externalIndex: 0, internalIndex: 0, network: .mainnetBTC)
//        print(wallet.privKeys)
//        let testBigUInt = BigUInt.init(seed) + 256
//        print(testBigUInt.serialize().toHexString())
//        let privateKey = PrivateKey.init()
//        print(privateKey.data.toHexString())
        //998befae8fbe932299e61cab53084be05ca01d7d9a886f5ad20cc218bcaa7c20
        let privateKeyData = Data.init(Array<UInt8>(hex: "998befae8fbe932299e61cab53084be05ca01d7d9a886f5ad20cc218bcaa7c20"))

        let privateKeyNumber = BigUInt.init(Data.init(Array<UInt8>(hex: "998befae8fbe932299e61cab53084be05ca01d7d9a886f5ad20cc218bcaa7c20")))
        let privateKey = PrivateKey.init(data: privateKeyData, network: .mainnetBTC, isPublicKeyCompressed: true)
        let address = privateKey.publicKey().toBitcoinAddress()
        print(address)
        print("final")

    }
    func testPasswordLogic() {
        XCTAssertEqual(false, handlePassword(password: "A"))
        XCTAssertEqual(false, handlePassword(password: "Aa"))
        XCTAssertEqual(false, handlePassword(password: "Aa123"))
        XCTAssertEqual(false, handlePassword(password: "12345678"))
        XCTAssertEqual(false, handlePassword(password: "1234512345678678"))
        XCTAssertEqual(false, handlePassword(password: "Aa123123Aa123123Aa123123Aa123123Aa123123Aa123123Aa123123"))
        XCTAssertEqual(true, handlePassword(password: "As123123"))
        XCTAssertEqual(true, handlePassword(password: "123123LL"))
        XCTAssertEqual(true, handlePassword(password: "As123123As123123As12"))

    }
    func testBTCToVBTC() {
//        let script = BTCManager().getScript(address: "f086b6a2348ac502c708ac41d06fe824c91806cabcd5b2b5fa25ae1c50bed3c6", tokenContract: "cd0476e85ecc5fa71b61d84b9cf2f7fd524689a4f870c46d6a5d901b5ac1fdb2")
//        let data = BTCManager().getData(script: script)
//        print(data.toHexString())
//        XCTAssertEqual("6a4c5276696f6c617300003000f086b6a2348ac502c708ac41d06fe824c91806cabcd5b2b5fa25ae1c50bed3c600000004b4054431cd0476e85ecc5fa71b61d84b9cf2f7fd524689a4f870c46d6a5d901b5ac1fdb2", data.toHexString())
//        data += Data.init(Array<UInt8>(hex: ("f086b6a2348ac502c708ac41d06fe824c91806cabcd5b2b5fa25ae1c50bed3c6")))
//        data += UInt64(20200113201).bigEndian
//        data += Data.init(Array<UInt8>(hex: ("cd0476e85ecc5fa71b61d84b9cf2f7fd524689a4f870c46d6a5d901b5ac1fdb2")))
    }
    func testBank() {
//        let mnemonic1 = ["display", "paddle", "crush", "crowd", "often", "friend", "topple", "agent", "entry", "use", "host", "begin"]
        
        let mnemonic = ["wrist", "post", "hover", "mixed", "like", "update", "salute", "access", "venture", "grant", "another", "team"]
        
//        let signature = try! ViolasManager.getBankFeaturesTransactionHex(sendAddress: "f41799563e5381b693d0885b56ebf19b",
//                                                                         mnemonic: mnemonic,
//                                                                         feeModule: "LBR",
//                                                                         fee: 0,
//                                                                         sequenceNumber: 9,
//                                                                         module: "USD")
        // 存钱
//        let signature = try! ViolasManager.getBankDepositTransactionHex(sendAddress: "f41799563e5381b693d0885b56ebf19b",
//                                                                        mnemonic: mnemonic,
//                                                                        feeModule: "LBR",
//                                                                        fee: 2,
//                                                                        sequenceNumber: 10,
//                                                                        module: "USD",
//                                                                        amount: 20000000)
        // 借钱
//        let signature = try! ViolasManager.getBankLoanTransactionHex(sendAddress: "f41799563e5381b693d0885b56ebf19b",
//                                                                        mnemonic: mnemonic,
//                                                                        feeModule: "LBR",
//                                                                        fee: 2,
//                                                                        sequenceNumber: 11,
//                                                                        module: "USD",
//                                                                        amount: 5000000)
        // 还钱
//        let signature = try! ViolasManager.getBankRepaymentTransactionHex(sendAddress: "f41799563e5381b693d0885b56ebf19b",
//                                                                          mnemonic: mnemonic,
//                                                                          feeModule: "LBR",
//                                                                          fee: 2,
//                                                                          sequenceNumber: 13,
//                                                                          module: "USD",
//                                                                          amount: 1000000)
        // 赎回
//        let signature = try! ViolasManager.getBankRedeemTransactionHex(sendAddress: "f41799563e5381b693d0885b56ebf19b",
//                                                                       mnemonic: mnemonic,
//                                                                       feeModule: "LBR",
//                                                                       fee: 2,
//                                                                       sequenceNumber: 14,
//                                                                       module: "USD",
//                                                                       amount: 20000000)
//
//        print(signature)
    }
}
