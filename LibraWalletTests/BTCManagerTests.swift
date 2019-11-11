//
//  BTCManagerTests.swift
//  LibraWalletTests
//
//  Created by palliums on 2019/11/7.
//  Copyright © 2019 palliums. All rights reserved.
//

import XCTest
@testable import LibraWallet
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
        let wallet = BTCManager().getWallet(mnemonic: mnemonicArray)
        XCTAssertEqual("f12e202e367bd9b24354b264b347eba79ac325ea429580425cc0a8d74cd9622ac3aeac1c40286b08e7ab7a29ae18c1fc5f15ba1376cbebcdf822d01a81bae503", wallet.seed.toHexString())
        
        XCTAssertEqual("tprv8ZgxMBicQKsPezAPNT5LRtjx51VvYgtTcT4mRZTMLXrLvX6kwnpBWPAY97pbYKPuMBfYTzPLV1ZnFyYSriqf8Lqjq4F37ujEcdpe4t8Rn2D", wallet.rootXPrivKey.qrcodeString)
        print()
        print(wallet.externalPrivKeys)
        print(wallet.externalIndex)

    }
}
