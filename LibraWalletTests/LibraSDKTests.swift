//
//  LibraSDKTests.swift
//  LibraWalletTests
//
//  Created by palliums on 2019/9/5.
//  Copyright © 2019 palliums. All rights reserved.
//

import XCTest
import SwiftEd25519
import CryptoSwift
import BigInt
@testable import LibraWallet
class LibraSDKTests: XCTestCase {

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
    func testLibra() {
        // String
        let string = TransactionArgument.init(code: .String, value: "Hello, World!").serialize().toHexString().uppercased()
        XCTAssertEqual(string, "020000000D00000048656C6C6F2C20576F726C6421")
        
        // u64
        let amount = TransactionArgument.init(code: .U64, value: "9213671392124193148").serialize().toHexString().uppercased()
        XCTAssertEqual(amount, "000000007CC9BDA45089DD7F")
        // String
        let address = TransactionArgument.init(code: .Address, value: "2c25991785343b23ae073a50e5fd809a2cd867526b3c1db2b0bf5d1924c693ed").serialize().toHexString().uppercased()
        XCTAssertEqual(address  , "01000000200000002C25991785343B23AE073A50E5FD809A2CD867526B3C1DB2B0BF5D1924C693ED")

        // Byte
        let byte = TransactionArgument.init(code: .Bytes, value: "cafed00d").serialize().toHexString().uppercased()
        XCTAssertEqual(byte  , "0300000004000000CAFED00D")
        
        let accessPath1 = TransactionAccessPath.init(address: "a71d76faa2d2d5c3224ec3d41deb293973564a791e55c6782ba76c2bf0495f9a", path: "01217da6c6b3e19f1825cfb2676daecce3bf3de03cf26647c78df00b371b25cc97", writeType: TransactionWriteType.Delete)
        let accessPath2 = TransactionAccessPath.init(address: "c4c63f80c74b11263e421ebf8486a4e398d0dbc09fa7d4f62ccdb309f3aea81f", path: "01217da6c6b3e19f18", writeType: TransactionWriteType.Write)
        let write = TransactionWriteSet.init(accessPaths: [accessPath1, accessPath2]).serialize().toHexString().uppercased()
        XCTAssertEqual(write, "010000000200000020000000A71D76FAA2D2D5C3224EC3D41DEB293973564A791E55C6782BA76C2BF0495F9A2100000001217DA6C6B3E19F1825CFB2676DAECCE3BF3DE03CF26647C78DF00B371B25CC970000000020000000C4C63F80C74B11263E421EBF8486A4E398D0DBC09FA7D4F62CCDB309F3AEA81F0900000001217DA6C6B3E19F180100000004000000CAFED00D")
        
        
        
        let string1 = TransactionArgument.init(code: .String, value: "CAFE D00D")
        let string2 = TransactionArgument.init(code: .String, value: "cafe d00d")
        let program = TransactionProgram.init(code: "move".data(using: String.Encoding.utf8)!, argruments: [string1, string2], modules: [Data.init(hex: "CA"), Data.init(hex: "FED0"), Data.init(hex: "0D")]).serialize().toHexString().uppercased()
        XCTAssertEqual(program, "00000000040000006D6F766502000000020000000900000043414645204430304402000000090000006361666520643030640300000001000000CA02000000FED0010000000D")

//        {
//            code: "move",
//            args: [{STRING: CAFE D00D}, {STRING: cafe d00d}],
//            modules: [[CA][FED0][0D]],
//        }
    }
    func testDeSerialize() {
        let testData = Data.init(hex: "010000002100000001217da6c6b3e19f1825cfb2676daecce3bf3de03cf26647c78df00b371b25cc978d00000020000000b8c39fc6910816ad21bc2be4f7e804539e7529b7b7d188c80f093e1e61f192cf00a8e6cf00000000000700000000000000200000003b07b78954be13a5bc5cb2e0eaf48312a85d864091d5cb5faee296d5248d89df0400000000000000200000003f486909a2abd12a387797d9d1f78496c95b7d3878767a56dafe8f2260e5144d0400000000000000")
        var account = LibraAccount.init(accountData: testData)
        XCTAssertEqual(account.address, "b8c39fc6910816ad21bc2be4f7e804539e7529b7b7d188c80f093e1e61f192cf")
        XCTAssertEqual(account.sequenceNumber, 4)

    }
}
