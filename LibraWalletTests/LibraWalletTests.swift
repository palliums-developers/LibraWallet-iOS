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
        let result = ViolasManager.handleMaxGasAmount(balances: [ViolasBalanceDataModel.init(amount: 10000, currency: "VLS")])
        XCTAssertEqual(result, 10000)
        let result2 = ViolasManager.handleMaxGasAmount(balances: [ViolasBalanceDataModel.init(amount: 1000_000_000, currency: "VLS")])
        XCTAssertEqual(result2, 4000000)
        let result3 = ViolasManager.handleMaxGasAmount(balances: [ViolasBalanceDataModel.init(amount: 10500, currency: "VLS")])
        XCTAssertEqual(result3, 10500)
        let result4 = ViolasManager.handleMaxGasAmount(balances: [ViolasBalanceDataModel.init(amount: 450, currency: "VLS")])
        XCTAssertEqual(result4, 600)
        let result5 = ViolasManager.handleMaxGasAmount(balances: [ViolasBalanceDataModel.init(amount: 1_000_000, currency: "VLS")])
        XCTAssertEqual(result5, 1_000_000)
    }
    func testHandleGasUnitPrice() {
        let result = ViolasManager.handleMaxGasUnitPrice(maxGasAmount: 600)
        XCTAssertEqual(result, 0)
        let result2 = ViolasManager.handleMaxGasUnitPrice(maxGasAmount: 540)
        XCTAssertEqual(result2, 0)
        let result3 = ViolasManager.handleMaxGasUnitPrice(maxGasAmount: 10000)
        XCTAssertEqual(result3, 1)
        let result4 = ViolasManager.handleMaxGasUnitPrice(maxGasAmount: 1000)
        XCTAssertEqual(result4, 1)
    }
}
