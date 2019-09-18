//
//  CommonData.swift
//  LibraWallet
//
//  Created by palliums on 2019/9/11.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit
import Hue
import SnapKit
import Toast_Swift
import Localize_Swift
/************* Libra节点 *******************/
let libraMainURL = "ac.testnet.libra.org:8000"

/************* Libra交易盐 *******************/
let libraProgramCode = "4c49425241564d0a010007014a00000004000000034e000000060000000c54000000060000000d5a0000000600000005600000002900000004890000002000000007a90000000f00000000000001000200010300020002040200030003020402063c53454c463e0c4c696272614163636f756e74046d61696e0f7061795f66726f6d5f73656e6465720000000000000000000000000000000000000000000000000000000000000000000100020104000c000c0113010002"
let signTransactionSalt = "46f174df6ca8de5ad29745f91584bb913e7df8dd162e3e921a5c1d8637c88d16"
/***************************************/
/// 待iOS支持最低版本位11的时候启用UIColor.init(named: "DefaultBackgroundColor")
let defaultBackgroundColor = UIColor.white
let DefaultSpaceColor = UIColor.init(hex: "F2F2F2")
let DefaultGreenColor = UIColor.init(hex: "15C794")
/***************************************/
/// 全局设置语言
///
/// - Parameter keyString: 标示
/// - Returns: 对应语言结果
func localLanguage(keyString: String) -> String {
    return keyString.localized()
}
/***************************************/
/// 全局KVO返回字典
///
/// - Parameters:
///   - error: 错误
///   - type: 请求类型
///   - data: 数据
/// - Returns: 字典结果
func setKVOData(error: LibraWalletError? = nil, type: String?, data: Any? = nil) -> NSMutableDictionary {
    let dic = NSMutableDictionary()
    dic.setValue(error, forKey: "error")
    dic.setValue(type, forKey: "type")
    dic.setValue(data, forKey: "data")
    return dic
}
/***************************************/
/// 屏幕宽度
let mainWidth = UIScreen.main.bounds.width
/// 屏幕高度
let mainHeight = UIScreen.main.bounds.height
/// 缩放比例
let ratio = 1
/***************************************/
/// 获取必要信息
private let infoDictionary = Bundle.main.infoDictionary
/// App名称
let appDisplayName = infoDictionary!["CFBundleDisplayName"]
let majorVersion = infoDictionary! ["CFBundleShortVersionString"]
//let minorVersion : AnyObject? = infoDictionary! ["CFBundleVersion"] as AnyObject?
/// App版本号
let appversion = majorVersion as! String
/// iOS版本号
let iosversion : NSString = UIDevice.current.systemVersion as NSString
/// 设备UDID
let identifierNumber = UIDevice.current.identifierForVendor
/// 设备名称
let systemName = UIDevice.current.systemName
/// 设备型号
let model = UIDevice.current.model
/// 设备区域化型号 如 A1533
let localizedModel = UIDevice.current.localizedModel
/// bundle ID
let bundleID = Bundle.main.bundleIdentifier
/// 状态栏高度
let statusBarHeight = UIApplication.shared.statusBarFrame.size.height
/// 导航栏 + 状态栏高度
let navigationBarHeight = statusBarHeight + 44
/***************************************/
/// 字体适配
///
/// - Parameter fontSize: 字号
/// - Returns: 适配字号
func adaptFont(fontSize: CGFloat) -> CGFloat {
    if (mainWidth == 320) {
        return fontSize - 1
    } else if (mainWidth == 375){
        return fontSize
    } else {
        return fontSize + 1
    }
}
/***************************************/
/// 控制器动作
///
/// - update: 刷新
/// - delete: 删除
/// - add: 添加
enum ControllerAction {
    case update
    case delete
    case add
}
/***************************************/
/// 获取登录状态
///
/// - Returns: 如果为0 需要登录
//func getLoginStatus() -> String {
//    let LoginValid = UserDefaults.standard.string(forKey: "LoginValid")
//    //判断UserDefaults中是否已经存在
//    if (LoginValid != nil) {
//        return LoginValid!
//    } else {
//        UserDefaults.standard.set("0", forKey: "LoginValid")
//        return "0"
//    }
//}
//func HKWalletLogin() {
//    UserDefaults.standard.set("1", forKey: "LoginValid")
//}
//func HKWalletLogout() {
//    UserDefaults.standard.set("0", forKey: "LoginValid")
//}

/***************************************/
/// 设置请求Token
///
/// - Parameter token: Token
//func setHKWalletHeaderToken(token: String) {
//    UserDefaults.standard.set(token, forKey: "HeaderToken")
//}
//func getHKWalletHeaderToken() -> String {
//    //判断UserDefaults中是否已经存在
//    guard let token = UserDefaults.standard.string(forKey: "HeaderToken") else {
//        return ""
//    }
//    guard token.isEmpty == false else {
//        return ""
//    }
//    return token
//}

/***************************************/
/// 设置汇率
///
/// - Parameter rate: 汇率
//func setBTCToHKDExchangeRate(rate: String) {
//    UserDefaults.standard.set(rate, forKey: "BTCToHKDRate")
//}
//func getBTCToHKDExchangeRate() -> String {
//    //判断UserDefaults中是否已经存在
//    guard let rate = UserDefaults.standard.string(forKey: "BTCToHKDRate") else {
//        return "0"
//    }
//    guard rate.isEmpty == false else {
//        return "0"
//    }
//    return rate
//}
/***************************************/
/// 设置欢迎页面
///
/// - Parameter show: <#show description#>
//func setWelcomeState(show: String) {
//    UserDefaults.standard.set(show, forKey: "Welcome")
//}
//func getWelcomeState() -> String {
//    //判断UserDefaults中是否已经存在
//    guard let state = UserDefaults.standard.string(forKey: "Welcome") else {
//        return "0"
//    }
//    guard state.isEmpty == false else {
//        return "0"
//    }
//    return state
//}

/***************************************/
//func helpCenterURL() -> String {
//    let current = Localize.currentLanguage()
//    if current == "zh-Hans" {
//        return "https://help.sealpay.io/cn/help.html"
//    } else if current == "zh-HK" {
//        return "https://help.sealpay.io/tw/help.html"
//    } else {
//        return "https://help.sealpay.io/en/help.html"
//    }
//}
//    "https://hobawallet.io/Sealpay_HTML/help.html"
//let helpCenterURL: String = "https://www.sealpay.io"
//let PrivateLegalURL: String = "https://www.baidu.com"


/***************************************/
//let defaultWithdrawFee: Int64 = 100000

/***************************************/
//#warning("待修改")
///// Token失效
//let TokenInvalidErrorCode = 1550
///// 版本太久
//let VersionInvalid = 1650
///// App被篡改
//let AppInvalid = 1990
///************* 指纹面容识别时长 *******************/
//let CheckBiometricTime = 5
//
///************* 添加数据库版本 *******************/
//func getDBVersion() -> String {
//    //判断UserDefaults中是否已经存在
//    guard let state = UserDefaults.standard.string(forKey: "BiometricState") else {
//        return "0"
//    }
//    guard state.isEmpty == false else {
//        return "0"
//    }
//    return state
//}
