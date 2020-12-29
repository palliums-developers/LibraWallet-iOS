//
//  BTCManagerTests.swift
//  LibraWalletTests
//
//  Created by palliums on 2019/11/7.
//  Copyright © 2019 palliums. All rights reserved.
//

import XCTest
@testable import ViolasPay
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
        XCTAssertEqual("f12e202e367bd9b24354b264b347eba79ac325ea429580425cc0a8d74cd9622ac3aeac1c40286b08e7ab7a29ae18c1fc5f15ba1376cbebcdf822d01a81bae503", wallet.seed.toHexString())
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
    func testCaculll(number: String) -> String {
//        let code = Data.init(Array<UInt8>(hex: ViolasPublishScriptCode))
//        print(code.toHexString())
//        let range: Range = code.toHexString().range(of: "7257c2417e4d1038e1817c8f283ace2e1041b3396cdbb099eb357bbee024d614")!
//        let location: Int = code.toHexString().distance(from: code.toHexString().startIndex, to: range.lowerBound)
//        print("location = \((location / 2) - 1)")
//        let location2 = ViolasManager().getViolasTokenContractLocation(code: ViolasPublishScriptCode, contract: "7257c2417e4d1038e1817c8f283ace2e1041b3396cdbb099eb357bbee024d614")
//        print(location2)
//
//        let data = ViolasManager.getCodeData(move: ViolasPublishScriptCode, address: "238adce0d1b40db648145473a7ba42e42d637dfbe8f7dd007c49a85f0e3a5d89")
//        print(data.toHexString())
//        let originNumberString = "f12e202e367bd9b24354b264b347eba79ac325ea429580425cc0a8d74cd9622ac3aeac1c40286b08e7ab7a29ae18c1fc5f15ba1376cbebcdf822d01a81bae5ff"
        var originNumberData = Data.init(Array<UInt8>(hex: number))
        if var lastNumber = originNumberData.bytes.last, lastNumber >= 0 {
            if lastNumber < 255 {
                lastNumber += 1
                originNumberData.removeLast()
                originNumberData.append(Data.init(bytes: &lastNumber, count: 1))
            } else {
                var handleCount = 0
                for i in (0..<(originNumberData.count - 1)).reversed() {
                    if originNumberData[i] >= 255  {
                        handleCount += 1
                    } else {
                        break
                    }
                }
                var lastData = originNumberData.prefix(originNumberData.count - handleCount - 1)
                if var middleLastNumber = lastData.bytes.last, lastNumber >= 0 {
                    lastData.removeLast()
                    middleLastNumber += 1
                    lastData.append(Data.init(bytes: &middleLastNumber, count: 1))
                }
                lastData.append(Data.init(count: (handleCount + 1)))
                originNumberData = lastData
            }
        }
//        let lastBytes = originNumber.bytes.last
        print(originNumberData.toHexString())
//        print("final")
        return originNumberData.toHexString()
    }
    func testCalcuteNumber(origin: String, add: Int) -> String {
        let originNumberData = Data.init(Array<UInt8>(hex: origin))
        if var lastNumber = originNumberData.bytes.last, lastNumber >= 0 {
            // 进位次数
            let main = UInt8(add / 256)
            // 余数
            var remainder = UInt8(add % 256)
            // 减去最后一位数字
            let space: UInt8 = 255 - lastNumber
            var totalMain = main
            var handleCount = 0
            

            // 判断最后一位是否能增加余数
            if remainder > space {
                // 进位加一
                totalMain += 1
                //
                remainder = UInt8(abs(Int32(remainder - space)))
            } else {
                for i in (0..<(originNumberData.count - 1)).reversed() {
                    if (255 - originNumberData[i]) > totalMain {
                        // 足够加
                        break
                    } else {
                        // 不够加
                        handleCount += 1
                    }
                }
            }
            var lastData = originNumberData.prefix(originNumberData.count - handleCount - 1)
            if var middleLastNumber = lastData.bytes.last {
                lastData.removeLast()
                middleLastNumber += UInt8(totalMain)
                lastData.append(Data.init(bytes: &middleLastNumber, count: 1))
            }
            lastData.append(Data.init(count: (handleCount)))
            lastData.append(Data.init(bytes: &remainder, count: 1))
            return lastData.toHexString()
        }
        return ""
    }
    func testCall() {
        let origin = "f12e202e367bd9b24354b264b347eba79ac325ea429580425cc0a8d74cd9622ac3aeac1c40286b08e7ab7a29ae18c1fc5f15ba1376cbebcdf822d01a81bae500"
        // 计算次数
        let total = 200
        // 分组量
        let count = total / 10
        // 分组起始数
        var calculateArray = [String]()
        var tempOrigin = origin
        // 分组
        for i in 0..<count {
            if i != 0 {
                tempOrigin = testCalcuteNumber(origin: tempOrigin, add: 10)
            }
            calculateArray.append(tempOrigin)
        }
        let queue = DispatchQueue.init(label: "SendQueue")
        // 线程数
        let threadLimit = 10
        let semaphore = DispatchSemaphore.init(value: threadLimit)
        while calculateArray.isEmpty == false {
//            for _ in 0..<count {
                queue.async {
                    semaphore.wait()
                    print("currentThread: \(Thread.current)")
                    tempOrigin = calculateArray[0]
                    for _ in 0..<10 {
                        tempOrigin = self.testCaculll(number: tempOrigin)
                        print(tempOrigin)
                    }
                    if calculateArray.isEmpty == false {
                        calculateArray.removeFirst()
                    }
                    semaphore.signal()
                }
//            }
//            if calculateArray.count > threadLimit {
//                calculateArray = calculateArray.suffix(calculateArray.count - threadLimit)
//            } else {
//                calculateArray.removeAll()
//            }
        }
        //59879
        //59884
//        let result = testCalcuteNumber(origin: origin, add: 1000)
//        print(result)
        print("final")
    }
    func testExchange() {
        let originNumberData = Data.init(Array<UInt8>(hex: "f12e202e367bd9b24354b264b347eba79ac325ea429580425cc0a8d74cd9622ac3aeac1c40286b08e7ab7a29ae18c1fc5f15ba1376cbebcdf822d01a81bae500"))
        var tempOrigin = originNumberData
        // 进位次数
        var main = UInt8(10 / 256)
        // 余数
        var remainder = UInt8(10 % 256)
        var realRemainder = (255 - originNumberData.bytes.last! - remainder) < 0 ? (main + 1):main
        for tempData in originNumberData.bytes.reversed() {
            tempOrigin.removeLast()
        }
//        let code = Data.init(Array<UInt8>(hex: ViolasStableCoinScriptWithDataCode))
//        print(code.toHexString())
//        let range: Range = code.toHexString().range(of: "7257c2417e4d1038e1817c8f283ace2e1041b3396cdbb099eb357bbee024d614")!
//        let location: Int = code.toHexString().distance(from: code.toHexString().startIndex, to: range.lowerBound)
//        print("location = \((location / 2) - 1)")
//        let location2 = ViolasManager().getViolasTokenContractLocation(code: ViolasStableCoinScriptWithDataCode, contract: "7257c2417e4d1038e1817c8f283ace2e1041b3396cdbb099eb357bbee024d614")
//        print(location2)
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
