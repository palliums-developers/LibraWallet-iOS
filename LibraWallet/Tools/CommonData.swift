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

/***************************************/
/// 待iOS支持最低版本位11的时候启用UIColor.init(named: "DefaultBackgroundColor")
let defaultBackgroundColor = UIColor.white
let DefaultSpaceColor = UIColor.init(hex: "DEDEDE")
let DefaultGreenColor = UIColor.init(hex: "9339F3")
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
func setKVOData(error: LibraWalletError? = nil, type: String, data: Any? = nil) -> NSMutableDictionary {
    let dic = NSMutableDictionary()
    dic.setValue(error, forKey: "error")
    dic.setValue(type, forKey: "type")
    dic.setValue(data, forKey: "data")
    return dic
}
struct RequestHandleModel {
    var type: String
    var error: LibraWalletError?
    var data: Any?
}
func setKVOModel(error: LibraWalletError? = nil, type: String, data: Any? = nil) -> RequestHandleModel {
    let model = RequestHandleModel.init(type: type,
                                        error: error,
                                        data: data)
    return model
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
let mobileModel = UIDevice.current.model
/// 设备区域化型号 如 A1533
let localizedModel = UIDevice.current.localizedModel
/// bundle ID
let bundleID = Bundle.main.bundleIdentifier
/// 状态栏高度
let statusBarHeight = UIApplication.shared.statusBarFrame.size.height
/// 导航栏 + 状态栏高度
let navigationBarHeight = statusBarHeight + 44
var isFullScreen: Bool {
    if #available(iOS 11, *) {
          guard let w = UIApplication.shared.delegate?.window, let unwrapedWindow = w else {
              return false
          }
          
          if unwrapedWindow.safeAreaInsets.left > 0 || unwrapedWindow.safeAreaInsets.bottom > 0 {
              print(unwrapedWindow.safeAreaInsets)
              return true
          }
    }
    return false
}
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
///************* 设置WalletConnect *******************/
func setWalletConnectSession(session: Data) {
    UserDefaults.standard.set(session, forKey: "WalletConnectSession")
}
func getWalletConnectSession() -> Data? {
    return UserDefaults.standard.data(forKey: "WalletConnectSession")
}
func removeWalletConnectSession() {
    UserDefaults.standard.removeObject(forKey: "WalletConnectSession")
}

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

/************* 限制 *******************/
let privateLegalURL = "https://violas.io/violas_service_html/Privacy_Policy/"
let useLegalURL = "https://violas.io/violas_service_html/Terms_of_Service/"
let transferFeeMax = 0.001
let transferFeeMin = 0.0001
let transferBTCLeast = 0.0001
let transferViolasLeast = 0.0001
let transferLibraLeast = 0.0001
let addressRemarksLimit = 20
let PasswordMinLimit = 8
let PasswordMaxLimit = 20
let NameMaxLimit = 20
/// 发币数量位数
let ApplyTokenAmountLengthLimit = 12

let officialAddress = "https://violas.io"
let officialEmail = "violas.team@violas.io"
/************* 弹出提示隐藏时间 *******************/
let toastDuration = 0.5
/************* 测试正式环境切换 *******************/
#warning("开发、正式版切换按钮")
let PUBLISH_VERSION = false
