//
//  LibraUtils.swift
//  LibraWallet
//
//  Created by palliums on 2019/9/5.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit
import BigInt
//func base64Decoding(encodedString: String) -> Data {
//
//    let base64Data = Data.init(base64Encoded: encodedString)
//    return base64Data!
//}
//func hw_getInt(_ array: [UInt8]) -> Int {
//    var value : UInt8 = 0
//    let data = NSData(bytes: array, length: array.count)
//    data.getBytes(&value, length: array.count)
//    value = UInt8(bigEndian: value)
//    return Int(value)
//}
//func hw_getInt64(_ array: [UInt8]) -> Int {
//    var value : Int = 0
//    let data = NSData(bytes: array, length: array.count)
//    data.getBytes(&value, length: array.count)
////        value = Int(bigEndian: value)
//    return Int(value)
//}
func getLengthData(length: Int, appendBytesCount: Int) -> Data {
    var newData = Data()
    let lengthData = BigUInt(length).serialize()
    // 补全长度
    for _ in 0..<(appendBytesCount - lengthData.count) {
        newData.append(Data.init(hex: "00"))
    }
    // 追加原始数据
    newData.append(lengthData)
    // 倒序输出
    let reversedAmount = newData.bytes.reversed()
    return Data() + reversedAmount
}
func uleb128Format(length: Int) -> Data {
    let erjinzhi = String.init(BigUInt(length), radix: 2)
    let result = erjinzhi.count / 7
    let remainder = erjinzhi.count % 7
    var tempArray = [String]()
    for i in 0...result {
        if i == 0 {
            if remainder > 0 {
                let startIndex = erjinzhi.index(erjinzhi.startIndex, offsetBy: 0)
                let endIndex = erjinzhi.index(erjinzhi.startIndex, offsetBy: remainder)
                let aaa = erjinzhi[startIndex..<endIndex]
                print("\(i)=\(aaa)")
                tempArray.append("\(aaa)")
            }
        } else {
            let startIndex = erjinzhi.index(erjinzhi.startIndex, offsetBy: remainder + ((i - 1) * 7))
            let endIndex = erjinzhi.index(erjinzhi.startIndex, offsetBy: remainder + ((i - 1) * 7) + 7)
            let aaa = erjinzhi[startIndex..<endIndex]
            print("\(i)=\(aaa)")
            tempArray.append("\(aaa)")
        }
    }
    //0、1+1*7、1+2*7、1+3*7
    //1、1+7+6、1+2*7+6
    //1 0000000 0000000 0000000
    print(tempArray)
    var tempString = String.init()
    for i in (0..<tempArray.count).reversed() {
        if i == 0 {
            if remainder > 0 {
                for _ in 0..<(8 - remainder) {
                    tempString += "0"
                }
                tempString += tempArray[i]
            } else {
                tempString += "0" + tempArray[i]
            }
        } else {
            tempString += "1" + tempArray[i]
        }
    }
    let convert = Int64.init(bitPattern: UInt64.init(tempString, radix: 2)!)
    return BigUInt(convert).serialize()
}
