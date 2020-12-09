//
//  ViolasQRCodeTests.swift
//  LibraWalletTests
//
//  Created by wangyingdong on 2020/12/9.
//  Copyright © 2020 palliums. All rights reserved.
//

import XCTest
@testable import ViolasPay

class ViolasQRCodeTests: XCTestCase {

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
    func testBTCQRCodeDecode() {
        do {
            let result = try ScanHandleManager.scanResultHandle(content: "bitcoin:1KZgtUrWZGuAmjRR8HEeuZtMGT3Wqutc1a?amount=1", contracts: [])
            XCTAssertEqual(result.address, "1KZgtUrWZGuAmjRR8HEeuZtMGT3Wqutc1a")
            XCTAssertEqual(result.amount, 1)
            let result2 = try ScanHandleManager.scanResultHandle(content: "bitcoin:1KZgtUrWZGuAmjRR8HEeuZtMGT3Wqutc1a", contracts: [])
            XCTAssertEqual(result2.address, "1KZgtUrWZGuAmjRR8HEeuZtMGT3Wqutc1a")
        } catch {
            print(error.localizedDescription)
        }
        do {
            _ = try ScanHandleManager.scanResultHandle(content: "bitcoin:1KZgtUrWZGuAmjRR8HEeuZtMGT3Wqutc1?amount=1", contracts: [])
            XCTFail()
        } catch {
            print(error.localizedDescription)
        }
        do {
            let result = try ScanHandleManager.scanResultHandle(content: "bitcoin:1KZgtUrWZGuAmjRR8HEeuZtMGT3Wqutc1a?amount=", contracts: [])
            print(result)
            XCTAssertEqual(result.amount, nil)
        } catch {
            print(error.localizedDescription)
        }
        do {
            _ = try ScanHandleManager.scanResultHandle(content: "bitcoin:1KZgtUrWZGuAmjRR8HEeuZtMGT3Wqutc1", contracts: [])
            XCTFail()
        } catch {
            print(error.localizedDescription)
        }
    }
    func testLibraQRCodeDecode() {
        let token = Token.init(tokenID: 999,
                               tokenName: "Coin1",
                               tokenBalance: 0,
                               tokenAddress: "",
                               tokenType: .Libra,
                               tokenIndex: 0,
                               tokenAuthenticationKey: "",
                               tokenActiveState: true,
                               tokenIcon: "",
                               tokenContract: "Coin1",
                               tokenModule: "Coin1",
                               tokenModuleName: "Coin1",
                               tokenEnable: true,
                               tokenPrice: "0")
        do {
            let result = try ScanHandleManager.scanResultHandle(content: "diem://tlb1pgc28wuxspzzmvghzen74dczc8upc3xquq08k7yqu0lwj8?c=Coin1&am=1000000", contracts: [token])
            XCTAssertEqual(result.address, "46147770d00885b622e2ccfd56e0583f")
            XCTAssertEqual(result.amount, 1000000)
            XCTAssertEqual(result.token?.tokenModule, "Coin1")
        } catch {
            print(error.localizedDescription)
            XCTFail()
        }
        do {
            _ = try ScanHandleManager.scanResultHandle(content: "diem://tlb1pgc28wuxspzzmvghzen74dczc8upc3xquq08k7yqu0lwj?c=Coin1&am=1000000", contracts: [token])
            XCTFail()
        } catch {
            print(error.localizedDescription)
            
        }
        // 未激活
        do {
            let result = try ScanHandleManager.scanResultHandle(content: "diem://tlb1pgc28wuxspzzmvghzen74dczc8upc3xquq08k7yqu0lwj8?c=Coin2&am=1000000", contracts: [token])
            XCTAssertEqual(result.address, "46147770d00885b622e2ccfd56e0583f")
            XCTFail()
        } catch {
            print(error.localizedDescription)
            
        }
        // 金额未填写
        do {
            let result = try ScanHandleManager.scanResultHandle(content: "diem://tlb1pgc28wuxspzzmvghzen74dczc8upc3xquq08k7yqu0lwj8?c=Coin1&am=", contracts: [token])
            XCTAssertEqual(result.amount, nil)
        } catch {
            print(error.localizedDescription)
        }
        // 币种未填写
        do {
            _ = try ScanHandleManager.scanResultHandle(content: "diem://tlb1pgc28wuxspzzmvghzen74dczc8upc3xquq08k7yqu0lwj8?c=&am=1000000", contracts: [token])
            XCTFail()
        } catch {
            print(error.localizedDescription)
        }
        // 币种未填写
        do {
            _ = try ScanHandleManager.scanResultHandle(content: "diem://tlb1pgc28wuxspzzmvghzen74dczc8upc3xquq08k7yqu0lwj8", contracts: [token])
            XCTFail()
        } catch {
            print(error.localizedDescription)
        }
    }
    func testViolasQRCodeDecode() {
        let token = Token.init(tokenID: 999,
                               tokenName: "Coin1",
                               tokenBalance: 0,
                               tokenAddress: "",
                               tokenType: .Violas,
                               tokenIndex: 0,
                               tokenAuthenticationKey: "",
                               tokenActiveState: true,
                               tokenIcon: "",
                               tokenContract: "Coin1",
                               tokenModule: "Coin1",
                               tokenModuleName: "Coin1",
                               tokenEnable: true,
                               tokenPrice: "0")
        do {
            let result = try ScanHandleManager.scanResultHandle(content: "violas://tlb1pgc28wuxspzzmvghzen74dczc8upc3xquq08k7yqu0lwj8?c=Coin1&am=1000000", contracts: [token])
            XCTAssertEqual(result.address, "46147770d00885b622e2ccfd56e0583f")
            XCTAssertEqual(result.amount, 1000000)
            XCTAssertEqual(result.token?.tokenModule, "Coin1")
        } catch {
            print(error.localizedDescription)
            XCTFail()
        }
        do {
            _ = try ScanHandleManager.scanResultHandle(content: "violas://tlb1pgc28wuxspzzmvghzen74dczc8upc3xquq08k7yqu0lwj?c=Coin1&am=1000000", contracts: [token])
            XCTFail()
        } catch {
            print(error.localizedDescription)
            
        }
        // 未激活
        do {
            let result = try ScanHandleManager.scanResultHandle(content: "violas://tlb1pgc28wuxspzzmvghzen74dczc8upc3xquq08k7yqu0lwj8?c=Coin2&am=1000000", contracts: [token])
            XCTAssertEqual(result.address, "46147770d00885b622e2ccfd56e0583f")
            XCTFail()
        } catch {
            print(error.localizedDescription)
            
        }
        // 金额未填写
        do {
            let result = try ScanHandleManager.scanResultHandle(content: "violas://tlb1pgc28wuxspzzmvghzen74dczc8upc3xquq08k7yqu0lwj8?c=Coin1&am=", contracts: [token])
            XCTAssertEqual(result.amount, nil)
        } catch {
            print(error.localizedDescription)
        }
        // 币种未填写
        do {
            _ = try ScanHandleManager.scanResultHandle(content: "violas://tlb1pgc28wuxspzzmvghzen74dczc8upc3xquq08k7yqu0lwj8?c=&am=1000000", contracts: [token])
            XCTFail()
        } catch {
            print(error.localizedDescription)
        }
        do {
            _ = try ScanHandleManager.scanResultHandle(content: "violas://tlb1pgc28wuxspzzmvghzen74dczc8upc3xquq08k7yqu0lwj8", contracts: [token])
            XCTFail()
        } catch {
            print(error.localizedDescription)
        }
    }
}
