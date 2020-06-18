//
//  LibraUtils.swift
//  LibraWallet
//
//  Created by palliums on 2019/9/5.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit
import BigInt
struct LibraUtils {
    static func getLengthData(length: Int, appendBytesCount: Int) -> Data {
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
        //    return uleb128Format(length: length)
    }
    static func uleb128Format(length: Int) -> Data {
        if length == 0 {
            return Data.init(hex: "00")
        }
        let erjinzhi = String.init(BigUInt(length), radix: 2)
        let result = erjinzhi.count / 7
        let remainder = erjinzhi.count % 7
        var tempString = String.init()
        for i in (0...result).reversed() {
            if i == 0 {
                // 倒叙到最后
                if remainder > 0 {
                    // 如果有余数
                    let startIndex = erjinzhi.index(erjinzhi.startIndex, offsetBy: 0)
                    let endIndex = erjinzhi.index(erjinzhi.startIndex, offsetBy: remainder)
                    let aaa = erjinzhi[startIndex..<endIndex]
                    // 补0
                    for _ in 0..<(8 - remainder) {
                        tempString += "0"
                    }
                    tempString += aaa
                }
            } else {
                //倒叙
                let startIndex = erjinzhi.index(erjinzhi.startIndex, offsetBy: remainder + ((i - 1) * 7))
                let endIndex = erjinzhi.index(erjinzhi.startIndex, offsetBy: remainder + ((i - 1) * 7) + 7)
                let aaa = erjinzhi[startIndex..<endIndex]
                if remainder + ((i - 1) * 7) == 0 {
                    //循环到初始位置
                    tempString += "0" + aaa
                } else {
                    tempString += "1" + aaa
                }
            }
        }
        //0、1+1*7、1+2*7、1+3*7
        //1、1+7+6、1+2*7+6
        //1 0000000 0000000 0000000
        let convert = binary2dec(num: tempString)
        //        print(BigUInt(convert).serialize().toHexString())
        return BigUInt(convert).serialize()
    }
    static func binary2dec(num:String) -> Int {
        var sum = 0
        for c in num {
            sum = sum * 2 + Int("\(c)")!
        }
        return sum
    }
    static func uleb128FormatToInt(data: Data) -> Int {
        guard data.isEmpty == false else {
            return 0
        }
        let erjinzhi = String.init(BigUInt.init(data), radix: 2)
        var tempString = String.init()
        if erjinzhi.count >= 8 {
            let result = erjinzhi.count / 8
            for i in (0..<result).reversed() {
                //倒叙
                let startIndex = erjinzhi.index(erjinzhi.startIndex, offsetBy: (i * 8))
                let endIndex = erjinzhi.index(erjinzhi.startIndex, offsetBy: (i * 8) + 8)
                let aaa = erjinzhi[startIndex..<endIndex]
                tempString += (aaa.description.suffix(7))
            }
        } else {
            tempString = erjinzhi
        }
        let convert = binary2dec(num: tempString)
        return convert
    }
}
