//
//  LibraWalletTests.swift
//  LibraWalletTests
//
//  Created by palliums on 2019/8/29.
//  Copyright © 2019 palliums. All rights reserved.
//

import XCTest
@testable import ViolasPay

class LibraWalletTests: XCTestCase {

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
    func testHandleFee() {
        let result = ViolasManager.handleGasFee(balances: [ViolasBalanceDataModel.init(amount: 10000, currency: "VLS")])
        XCTAssertEqual(result, 0.01)
        let result2 = ViolasManager.handleGasFee(balances: [ViolasBalanceDataModel.init(amount: 1000000000, currency: "VLS")])
        XCTAssertEqual(result2, 1)
        let result3 = ViolasManager.handleGasFee(balances: [ViolasBalanceDataModel.init(amount: 10500, currency: "VLS")])
        XCTAssertEqual(result3, 0.0105)
    }
}
