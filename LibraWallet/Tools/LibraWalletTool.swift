//
//  LibraWalletTool.swift
//  LibraWallet
//
//  Created by palliums on 2019/9/16.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit

func screenSnapshot() -> UIImage? {
    
    guard let window = UIApplication.shared.keyWindow else { return nil }
    
    // 用下面这行而不是UIGraphicsBeginImageContext()，因为前者支持Retina
    UIGraphicsBeginImageContextWithOptions(window.bounds.size, false, 0.0)
    
    window.layer.render(in: UIGraphicsGetCurrentContext()!)
    
    let image = UIGraphicsGetImageFromCurrentImageContext()
    
    UIGraphicsEndImageContext()
    
    return image
}
extension UIImage {
    func imageWithColor(color:UIColor, width: CGFloat? = 1.0, height: CGFloat? = 1.0) -> UIImage {
        let rect = CGRect(x: 0.0, y: 0.0, width: width ?? 1.0, height: height ?? 1.0)
        UIGraphicsBeginImageContext(rect.size)
        let context:CGContext = UIGraphicsGetCurrentContext()!
        context.setFillColor(color.cgColor);
        context.fill(rect);
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image!
    }
}
extension UIView {
    /// 部分圆角
    ///
    /// - Parameters:
    ///   - corners: 需要实现为圆角的角，可传入多个
    ///   - radii: 圆角半径
    func corner(byRoundingCorners corners: UIRectCorner, radii: CGFloat) {
        let maskPath = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radii, height: radii))
        let maskLayer = CAShapeLayer()
        maskLayer.frame = self.bounds
        maskLayer.path = maskPath.cgPath
        self.layer.mask = maskLayer
    }
}
func colorGradualChange(size: CGSize, cornerRadius: CGFloat = 0) -> CAGradientLayer {
    let gradientLayer = CAGradientLayer.init()
    gradientLayer.frame = CGRect.init(x: 0, y: 0, width: size.width, height: size.height)
    gradientLayer.startPoint = CGPoint.init(x: 0, y: 0)
    gradientLayer.endPoint = CGPoint.init(x: 1, y: 0)
    gradientLayer.locations = [0,1.0]
    gradientLayer.colors = [UIColor.init(hex: "9339F3").cgColor, UIColor.init(hex: "7038FD").cgColor]
    if cornerRadius > 0 {
        gradientLayer.cornerRadius = cornerRadius
    }
    return gradientLayer
}
func checkMnenoicInvalid(mnemonicArray: [String]) -> Bool {
    guard mnemonicArray.count != 0 else {
        return false
    }
    let wordList: [String.SubSequence] =  DiemWordList.english
    for i in 0...mnemonicArray.count - 1 {
        let status = wordList.contains(Substring.init(mnemonicArray[i]))
        if status == false {
            return false
        }
    }
    return true
}
func timestampToDateString(timestamp: Int, dateFormat: String) -> String {
    
    let format = DateFormatter.init()
    //"yyyy-MM-dd"
    format.dateFormat = dateFormat
    let date = Date.init(timeIntervalSince1970: Double(timestamp))
    let str = format.string(from: date)
    return str
}
func isPurnDouble(string: String) -> Bool {
    
    let scan: Scanner = Scanner(string: string)
    
    var val:Double = 0.0
    
    return scan.scanDouble(&val) && scan.isAtEnd
    
}

func handlePassword(password: String) -> Bool {
    guard (password.count >= PasswordMinLimit) && (password.count <= PasswordMaxLimit) else {
        return false
    }
    guard isContainAlphabet(content: password) else {
        return false
    }
    guard isContainNumber(content: password) else {
        return false
    }
    return true
}
fileprivate func isContainAlphabet(content: String) -> Bool {
    let email = ".*[A-Za-z]+.*$"
    let regextestmobile = NSPredicate(format: "SELF MATCHES %@",email)
    if (regextestmobile.evaluate(with: content) == true) {
        return true
    } else {
        return false
    }
}
fileprivate func isContainNumber(content: String) -> Bool {
    let email = "^.*[0-9]+.*$"
    let regextestmobile = NSPredicate(format: "SELF MATCHES %@",email)
    if (regextestmobile.evaluate(with: content) == true) {
        return true
    } else {
        return false
    }
}
func getDecimalNumberAmount(amount: NSDecimalNumber, scale: Int16, unit: Int) -> String {
//    NSRoundPlain:四舍五入
//    NSRoundDown:只舍不入
//    NSRoundUp：只入不舍
//    NSRoundBankers: 在四舍五入的基础上加了一个判断：当最后一位为5的时候，只会舍入成偶数。比如：1.25不会返回1.3而是1.2，因为1.3不是偶数。
    let numberConfig = NSDecimalNumberHandler.init(roundingMode: .down,
                                                   scale: scale,
                                                   raiseOnExactness: false,
                                                   raiseOnOverflow: false,
                                                   raiseOnUnderflow: false,
                                                   raiseOnDivideByZero: false)
    let number = amount.dividing(by: NSDecimalNumber.init(value: unit), withBehavior: numberConfig)
    return number.stringValue
}
func getDecimalNumber(amount: NSDecimalNumber, scale: Int16, unit: Int) -> NSDecimalNumber {
//    NSRoundPlain:四舍五入
//    NSRoundDown:只舍不入
//    NSRoundUp：只入不舍
//    NSRoundBankers: 在四舍五入的基础上加了一个判断：当最后一位为5的时候，只会舍入成偶数。比如：1.25不会返回1.3而是1.2，因为1.3不是偶数。
    let numberConfig = NSDecimalNumberHandler.init(roundingMode: .down,
                                                   scale: scale,
                                                   raiseOnExactness: false,
                                                   raiseOnOverflow: false,
                                                   raiseOnUnderflow: false,
                                                   raiseOnDivideByZero: false)
    let number = amount.dividing(by: NSDecimalNumber.init(value: unit), withBehavior: numberConfig)
    return number
}
// MARK: 二维码解析相关模块
struct libraWalletTool {
    
}
// MARK: 计算文字宽高
extension libraWalletTool {
    static func ga_heightForComment(content: String, fontSize: CGFloat, width: CGFloat) -> CGFloat {
        let rect = NSString(string: content).boundingRect(with: CGSize(width: width, height: CGFloat(MAXFLOAT)),
                                                          options: .usesLineFragmentOrigin,
                                                          attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: fontSize)],
                                                          context: nil)
        return ceil(rect.height)
    }
    static func ga_widthForComment(content: String, fontSize: CGFloat, height: CGFloat) -> CGFloat {
        let rect = NSString(string: content).boundingRect(with: CGSize(width: CGFloat(MAXFLOAT), height: height),
                                                          options: .usesLineFragmentOrigin,
                                                          attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: fontSize)],
                                                          context: nil)
        return ceil(rect.width)
    }
}
// MARK: 密码验证
extension libraWalletTool {
    /// 验证密码获取助记词
    /// - Parameters:
    ///   - message: 提示内容
    ///   - completion: 返回结果
    /// - Returns: UIAlertController
    static func passowordAlert(message: String? = localLanguage(keyString: "wallet_type_in_password_content"), completion: @escaping (Result<[String], Error>)-> Void) -> UIAlertController {
        let alertController = UIAlertController(title: localLanguage(keyString: "wallet_type_in_password_title"), message: message, preferredStyle: .alert)
        alertController.addTextField {
            (textField: UITextField!) -> Void in
            textField.placeholder = localLanguage(keyString: "wallet_type_in_password_textfield_placeholder")
            textField.tintColor = DefaultGreenColor
            textField.isSecureTextEntry = true
        }
        alertController.addAction(UIAlertAction(title: localLanguage(keyString: "wallet_type_in_password_confirm_button_title"), style: .default) { clickHandler in
            guard let password = alertController.textFields?.first?.text else {
                completion(.failure(LibraWalletError.WalletCheckPassword(reason: .passwordInvalidError)))
                return
            }
            guard password.isEmpty == false else {
                completion(.failure(LibraWalletError.WalletCheckPassword(reason: .passwordEmptyError)))
                return
            }
            NSLog("Password:\(password)")
            do {
                let mnemonic = try WalletManager.getMnemonicFromKeychain(password: password)
                completion(.success(mnemonic))
            } catch {
                completion(.failure(error))
            }
        })
        alertController.addAction(UIAlertAction(title: localLanguage(keyString: "wallet_type_in_password_cancel_button_title"), style: .cancel){
            clickHandler in
            NSLog("点击了取消")
            completion(.failure(LibraWalletError.WalletCheckPassword(reason: .cancel)))
        })
        return alertController
    }
    /// 验证密码
    /// - Parameters:
    ///   - message: 提示内容
    ///   - completion: 返回结果
    /// - Returns: UIAlertController
    static func passowordCheckAlert(message: String? = localLanguage(keyString: "wallet_type_in_password_content"),  completion: @escaping (Result<String, Error>)-> Void) -> UIAlertController {
        let alertController = UIAlertController(title: localLanguage(keyString: "wallet_type_in_password_title"), message: message, preferredStyle: .alert)
        alertController.addTextField {
            (textField: UITextField!) -> Void in
            textField.placeholder = localLanguage(keyString: "wallet_type_in_password_textfield_placeholder")
            textField.tintColor = DefaultGreenColor
            textField.isSecureTextEntry = true
        }
        alertController.addAction(UIAlertAction(title: localLanguage(keyString: "wallet_type_in_password_confirm_button_title"), style: .default) { clickHandler in
            guard let password = alertController.textFields?.first?.text else {
                completion(.failure(LibraWalletError.WalletCheckPassword(reason: .passwordInvalidError)))
                return
            }
            guard password.isEmpty == false else {
                completion(.failure(LibraWalletError.WalletCheckPassword(reason: .passwordEmptyError)))
                return
            }
            NSLog("Password:\(password)")
            do {
                _ = try WalletManager.getMnemonicFromKeychain(password: password)
                completion(.success(password))
            } catch {
                completion(.failure(error))
            }
        })
        alertController.addAction(UIAlertAction(title: localLanguage(keyString: "wallet_type_in_password_cancel_button_title"), style: .cancel){
            clickHandler in
            NSLog("点击了取消")
            completion(.failure(LibraWalletError.WalletCheckPassword(reason: .cancel)))
        })
        return alertController
    }
    static func deleteWalletAlert(confirm: @escaping ()-> Void) -> UIAlertController {
        let alert = UIAlertController.init(title: localLanguage(keyString: "wallet_alert_delete_wallet_title"), message: localLanguage(keyString: "wallet_alert_delete_wallet_content"), preferredStyle: UIAlertController.Style.alert)
        let confirmAction = UIAlertAction.init(title: localLanguage(keyString: "wallet_alert_delete_wallet_confirm_button_title"), style: UIAlertAction.Style.destructive) { (UIAlertAction) in
            confirm()
        }
        let cancelAction = UIAlertAction.init(title: localLanguage(keyString: "wallet_alert_delete_wallet_cancel_button_title"), style: UIAlertAction.Style.cancel) { (UIAlertAction) in
            print("Delete Wallet Cancel")
        }
        alert.addAction(cancelAction)
        alert.addAction(confirmAction)
        return alert
    }
    static func currencyUnactivatedAlert(confirm: @escaping ()->Void, cancel: @escaping ()->Void) -> UIAlertController {
        let alert = UIAlertController.init(title: localLanguage(keyString: "wallet_add_asset_alert_title"),
                                               message: localLanguage(keyString: "wallet_add_asset_alert_content"),
                                               preferredStyle: .alert)
        let cancelAction = UIAlertAction.init(title:localLanguage(keyString: "wallet_add_asset_alert_cancel_button_title"), style: .default) { okAction in
            cancel()
        }
        let confirmAction = UIAlertAction.init(title:localLanguage(keyString: "wallet_add_asset_alert_confirm_button_title"), style: .default) { okAction in
            confirm()
        }
        alert.addAction(cancelAction)
        alert.addAction(confirmAction)
        return alert
    }
}
