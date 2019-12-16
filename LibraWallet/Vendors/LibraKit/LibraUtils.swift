//
//  LibraUtils.swift
//  LibraWallet
//
//  Created by palliums on 2019/9/5.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit
import BigInt
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
