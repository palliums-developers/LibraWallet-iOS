//
//  ViolasWalletTests.swift
//  ViolasWalletTests
//
//  Created by palliums on 2019/8/29.
//  Copyright © 2019 palliums. All rights reserved.
//

import XCTest
@testable import ViolasPay

class ViolasWalletTests: XCTestCase {

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
        XCTAssertEqual(result2, 2000000)
        let result3 = ViolasManager.handleMaxGasAmount(balances: [ViolasBalanceDataModel.init(amount: 10500, currency: "VLS")])
        XCTAssertEqual(result3, 10500)
        let result4 = ViolasManager.handleMaxGasAmount(balances: [ViolasBalanceDataModel.init(amount: 450, currency: "VLS")])
        XCTAssertEqual(result4, 601)
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
    func testRatio() {
        print(ratio(number: 220))
    }
    func testETHAddress() {
        XCTAssertEqual(isValidETHAddress(address: "0x00fe1b8a035b5c5e42249627ea62f75e5a071cb3"), true)
        XCTAssertEqual(isValidETHAddress(address: "00fe1b8a035b5c5e42249627ea62f75e5a071cb3"), false)
        XCTAssertEqual(isValidETHAddress(address: "0x00fe1b8a035b5c5e42249627ea62f75e]a071cb3"), false)
        XCTAssertEqual(isValidETHAddress(address: "0x00fe1b8a035b5c5e42249627ea62f75e5a071cp3"), false)

    }
    func testMarketCalculate() {
        let paths = [PoolLiquidityDataModel.init(coina: PoolLiquidityCoinADataModel.init(index: 0, name: "vBTC", value: 4274276),
                                                 coinb: PoolLiquidityCoinBDataModel.init(index: 1, name: "vUSDT", value: 17911084),
                                                 liquidity_total_supply: 8646794)]
        let model = ExchangeModel()
        let result = model.fliterBestInput(outputAAmount: 99999999999000000, outputCoinA: 1, paths: [paths])
//        let result = model.fliterBestOutput(inputAAmount: 99999999999000000, inputCoinA: 0, paths: [paths])
        print(result.input)
        print("success")
    }
}
