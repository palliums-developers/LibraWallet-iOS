//
//  PhoneAreaModel.swift
//  HKWallet
//
//  Created by palliums on 2019/8/16.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit
import Localize_Swift
struct PhoneAreaDataModel: Codable {
    var code: String?
    var name: String?
    var dial_code: String?
}
class PhoneAreaModel: NSObject {
    func getLocalAreaData() -> NSArray {
        let bundle = Bundle(for: PhoneAreaModel.self)
        let path = "Countries.bundle/Data/CountryCodes"
        guard let jsonPath = bundle.path(forResource: path, ofType: "json"), let jsonData = try? Data(contentsOf: URL(fileURLWithPath: jsonPath)) else {
            return NSArray()
        }
        do {
            let data = try JSONDecoder().decode([PhoneAreaDataModel].self, from: jsonData)
            let resultArray = NSMutableArray()
            let letterArray = NSMutableArray()
            let dataArray = NSMutableArray()
            for item in data {
                let tempDataArray = NSMutableArray()
                let letter = getFirstLetterFromString(aString: item.name ?? "")
                if letterArray.contains(letter) == false {
                    //初始化第一次添加
                    letterArray.add(letter)
                    tempDataArray.add(item)
                    dataArray.add(tempDataArray)
                } else {
                    // 增加
                    // 获取Letter位置
                    let index = letterArray.index(of: letter)
                    // 获取Letter位置对应数组
                    let tempArray = dataArray.object(at: index)
                    
                    (tempArray as! NSMutableArray).add(item)
                    dataArray.replaceObject(at: index, with: tempArray)
                }
            }
            resultArray.add(letterArray)
            resultArray.add(dataArray)
//            print(resultArray)
            return resultArray
        } catch {
            return NSArray()
        }
    }
    // MARK: - 获取联系人姓名首字母(传入汉字字符串, 返回大写拼音首字母)
    func getFirstLetterFromString(aString: String) -> String {
        // 注意,这里一定要转换成可变字符串
        let mutableString = NSMutableString.init(string: aString)
        // 将中文转换成带声调的拼音
        CFStringTransform(mutableString as CFMutableString, nil, kCFStringTransformToLatin, false)
        // 去掉声调(用此方法大大提高遍历的速度)
        let pinyinString = mutableString.folding(options: String.CompareOptions.diacriticInsensitive, locale: NSLocale.current)
        // 将拼音首字母装换成大写
        let strPinYin = pinyinString.uppercased()
        // 截取大写首字母
//        let firstString = strPinYin.substring(to: strPinYin.index(strPinYin.startIndex, offsetBy:1))
        let firstString = String(strPinYin.prefix(1))
        // 判断姓名首位是否为大写字母
        let regexA = "^[A-Z]$"
        let predA = NSPredicate.init(format: "SELF MATCHES %@", regexA)
        return predA.evaluate(with: firstString) ? firstString : "#"
    }
    
    deinit {
        print("PhoneAreaModel销毁了")
    }
}
