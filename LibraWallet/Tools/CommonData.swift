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
let libraProgramCode = "{\"code\":[76,73,66,82,65,86,77,10,1,0,7,1,74,0,0,0,4,0,0,0,3,78,0,0,0,6,0,0,0,13,84,0,0,0,6,0,0,0,14,90,0,0,0,6,0,0,0,5,96,0,0,0,41,0,0,0,4,137,0,0,0,32,0,0,0,8,169,0,0,0,15,0,0,0,0,0,0,1,0,2,0,1,3,0,2,0,2,4,2,0,3,2,4,2,3,0,6,60,83,69,76,70,62,12,76,105,98,114,97,65,99,99,111,117,110,116,4,109,97,105,110,15,112,97,121,95,102,114,111,109,95,115,101,110,100,101,114,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,2,0,4,0,12,0,12,1,19,1,1,2],\"args\":[],\"modules\":[]}"
let signTransactionSalt = "46f174df6ca8de5ad29745f91584bb913e7df8dd162e3e921a5c1d8637c88d16"

let MarketAddress = "07e92f79c67fdd6b80ed9103636a49511363de8c873bc709966fffb2e3fcd095"
func getProgramCode(content: String) -> Data {
    let temp = stringValueDic(content)
    let code = temp!["code"] as! [UInt8]
//    let dataArray = "\(code ?? "")".split(separator: ",")
    
    let data = Data.init(bytes: code, count: code.count)
    
    return data
}
func stringValueDic(_ str: String) -> [String : Any]? {
    let data = str.data(using: String.Encoding.utf8)
    if let dict = try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String : Any] {
        return dict
    }
    return nil
}
/***************************************/
/// 待iOS支持最低版本位11的时候启用UIColor.init(named: "DefaultBackgroundColor")
let defaultBackgroundColor = UIColor.white
let DefaultSpaceColor = UIColor.init(hex: "F7F7F9")
let DefaultGreenColor = UIColor.init(hex: "7038FD")
let DefaultFontColor = UIColor.init(hex: "3D3949")
// 主色50%
let DefaultFontMiddleColor = UIColor.init(hex: "9D9CA3")
///******************* 全局设置语言 *******************/
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
func getVersionCode() -> String {
    var systemInfo = utsname()
    uname(&systemInfo)
    
    let versionCode: String = String(validatingUTF8: NSString(bytes: &systemInfo.machine, length: Int(_SYS_NAMELEN), encoding: String.Encoding.ascii.rawValue)!.utf8String!)!
    
    return versionCode
}
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

///************* 设置欢迎页面 *******************/
/// 设置欢迎页面
///
/// - Parameter show: 展示状态
func setWelcomeState(show: Bool) {
    UserDefaults.standard.set(show, forKey: "Welcome")
}
func getWelcomeState() -> Bool {
    return UserDefaults.standard.bool(forKey: "Welcome")
}
///************* 获取身份钱包 *******************/
func setIdentityWalletState(show: Bool) {
    UserDefaults.standard.set(show, forKey: "IdentityWallet")
}
func getIdentityWalletState() -> Bool {
    return UserDefaults.standard.bool(forKey: "IdentityWallet")
}
///************* 设置同意用户协议 *******************/
func setConfirmPrivateAndUseLegalState(show: Bool) {
    UserDefaults.standard.set(show, forKey: "PrivateAndUseLegal")
}
func getConfirmPrivateAndUseLegalState() -> Bool {
    return UserDefaults.standard.bool(forKey: "PrivateAndUseLegal")
}
/***************************************/
func helpCenterURL() -> String {
    let current = Localize.currentLanguage()
    if current == "zh-Hans" {
        return "https://help.sealpay.io/cn/help.html"
    } else {
        return "https://help.sealpay.io/en/help.html"
    }
}
//    "https://hobawallet.io/Sealpay_HTML/help.html"
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
protocol LoadLocalLanguageProtocol {
    func loadLocalLanguage(keyString: String) -> String
}
extension LoadLocalLanguageProtocol {
    func loadLocalLanguage(keyString: String) -> String {
        return keyString.localized()
    }
}
let transferFeeMax = 0.001
let transferFeeMin = 0.0001
let transferBTCLeast = 0.0001

/************* 限制 *******************/
let privateAndUseLegal = "感谢您选择了SSO APP\n我们极度重视您的用户隐私。您在使用我们的服务时，我们可能会收集和使用您的相关信息。在使用我们的产品前，请务必审慎阅读《隐私政策》和《服务协议》内的所有内容，来了解我们如何收集、使用、储存和分享这些信息，以及我们为您提供的访问、更新、控制和保护这些信息的方式。"
let privateLegalURL = "https://violas.io/violas_service_html/Privacy_Policy.html"
let useLegalURL = "https://violas.io/violas_service_html/Terms_of_Service.html"
let addressRemarksLimit = 20
