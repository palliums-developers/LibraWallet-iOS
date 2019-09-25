//
//  LibraUtils.swift
//  LibraWallet
//
//  Created by palliums on 2019/9/5.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit
import BigInt
//func bytesToStr(bytes:[UInt8]) -> String {
//    var hexStr = ""
//    for index in 0 ..< bytes.count {
//        var Str = bytes[index].description
//        if Str.count == 1 {
//            Str = "0"+Str;
//        } else {
//            let low = Int(Str)!%16
//            let hight = Int(Str)!/16
//            Str = hexIntToStr(HexInt: hight) + hexIntToStr(HexInt: low)
//        }
//        hexStr += Str
//    }
//    return hexStr.lowercased()
//}
//func hexIntToStr(HexInt:Int) -> String {
//    var Str = ""
//    if HexInt > 9 {
//        switch HexInt{
//        case 10:
//            Str = "A"
//            break
//        case 11:
//            Str = "B"
//            break
//        case 12:
//            Str = "C"
//            break
//        case 13:
//            Str = "D"
//            break
//        case 14:
//            Str = "E"
//            break
//        case 15:
//            Str = "F"
//            break
//        default:
//            Str = "0"
//        }
//    } else {
//        Str = String(HexInt)
//    }
//
//    return Str
//}
func base64Decoding(encodedString: String) -> Data {
    
    let base64Data = Data.init(base64Encoded: encodedString)
    return base64Data!
}
func hw_getInt(_ array: [UInt8]) -> Int {
    var value : UInt8 = 0
    let data = NSData(bytes: array, length: array.count)
    data.getBytes(&value, length: array.count)
    value = UInt8(bigEndian: value)
    return Int(value)
}
func hw_getInt64(_ array: [UInt8]) -> Int {
    var value : Int = 0
    let data = NSData(bytes: array, length: array.count)
    data.getBytes(&value, length: array.count)
//        value = Int(bigEndian: value)
    return Int(value)
}
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
