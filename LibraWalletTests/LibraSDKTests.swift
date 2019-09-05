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
        
    }
    func bytesToStr(bytes:[UInt8]) -> String {
        var hexStr = ""
        for index in 0 ..< bytes.count {
            var Str = bytes[index].description
            if Str.count == 1 {
                Str = "0"+Str;
            } else {
                let low = Int(Str)!%16
                let hight = Int(Str)!/16
                Str = hexIntToStr(HexInt: hight) + hexIntToStr(HexInt: low)
            }
            hexStr += Str
        }
        return hexStr.lowercased()
    }
    func hexIntToStr(HexInt:Int) -> String {
        var Str = ""
        if HexInt > 9 {
            switch HexInt{
            case 10:
                Str = "A"
                break
            case 11:
                Str = "B"
                break
            case 12:
                Str = "C"
                break
            case 13:
                Str = "D"
                break
            case 14:
                Str = "E"
                break
            case 15:
                Str = "F"
                break
            default:
                Str = "0"
            }
        } else {
            Str = String(HexInt)
        }
        
        return Str
    }
}
