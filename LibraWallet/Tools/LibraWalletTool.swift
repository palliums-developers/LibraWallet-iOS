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
func colorGradualChange(size: CGSize) -> CAGradientLayer {
    let gradientLayer = CAGradientLayer.init()
    gradientLayer.frame = CGRect.init(x: 0, y: 0, width: size.width, height: size.height)
    gradientLayer.startPoint = CGPoint.init(x: 0, y: 0)
    gradientLayer.endPoint = CGPoint.init(x: 1, y: 0)
    gradientLayer.locations = [0,1.0]
    gradientLayer.colors = [UIColor.init(hex: "9339F3").cgColor, UIColor.init(hex: "7038FD").cgColor]
    return gradientLayer
}
func checkMnenoicInvalid(mnemonicArray: [String]) -> Bool {
    guard mnemonicArray.count != 0 else {
        return false
    }
    let wordList: [String.SubSequence] =  LibraWordList.english
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
struct libraWalletTool {
    public static func scanResultHandle(content: String, contracts: [Token]?) throws -> QRCodeHandleResult {
         if content.hasPrefix("bitcoin:") {
            let (contentPrefix, amount) = self.handleAmount(content: content)
             let tempAddress = contentPrefix.replacingOccurrences(of: "bitcoin:", with: "")
             guard BTCManager.isValidBTCAddress(address: tempAddress) else {
                 throw LibraWalletError.WalletScan(reason: .btcAddressInvalid)
             }
             return QRCodeHandleResult.init(addressType: .BTC,
                                            originContent: content,
                                            address: tempAddress,
                                            amount: amount,
                                            contract: nil,
                                            type: .transfer)
         } else if content.hasPrefix("libra-") {
            let (contentPrefix, amount) = handleAmount(content: content)
            let coinAddress = contentPrefix.split(separator: ":").last?.description ?? ""
            let addressPrifix = contentPrefix.split(separator: ":").first?.description
            // 匹配已有Module
            let coinName = addressPrifix?.replacingOccurrences(of: "libra-", with: "")
            guard coinName?.isEmpty == false else {
                print("token名称为空")
                throw LibraWalletError.WalletScan(reason: .libraTokenNameEmpty)
            }
            // 检测地址是否合法
            guard LibraManager.isValidLibraAddress(address: coinAddress) else {
                throw LibraWalletError.WalletScan(reason: .libraAddressInvalid)
            }
            if contracts?.isEmpty == false {
                let tokens = contracts?.filter({ item in
                    item.tokenModule.lowercased() == coinName?.lowercased() && item.tokenType == .Libra
                })
                guard (tokens?.count ?? 0) > 0 else {
                    // 不支持或未开启
                    print("不支持或未开启")
                    throw LibraWalletError.WalletScan(reason: .libraModuleInvalid)
                }
                return QRCodeHandleResult.init(addressType: .Libra,
                                               originContent: content,
                                               address: coinAddress,
                                               amount: amount,
                                               contract: tokens?.first,
                                               type: .transfer)
            } else {
                return QRCodeHandleResult.init(addressType: .Libra,
                                               originContent: content,
                                               address: coinAddress,
                                               amount: amount,
                                               contract: nil,
                                               type: .transfer)
            }
         } else if content.hasPrefix("violas-") {
            let (contentPrefix, amount) = handleAmount(content: content)
            let coinAddress = contentPrefix.split(separator: ":").last?.description
            let addressPrifix = contentPrefix.split(separator: ":").first?.description
            // 匹配已有Module
            let coinName = addressPrifix?.replacingOccurrences(of: "violas-", with: "")
            guard coinName?.isEmpty == false else {
                print("token名称为空")
                throw LibraWalletError.WalletScan(reason: .violasTokenNameEmpty)
            }
            // 检测地址是否合法
            guard ViolasManager.isValidViolasAddress(address: coinAddress ?? "") else {
                throw LibraWalletError.WalletScan(reason: .violasAddressInvalid)
            }
            if contracts?.isEmpty == false {
                let tokens = contracts?.filter({ item in
                    item.tokenModule.lowercased() == coinName?.lowercased() && item.tokenType == .Violas
                })
                guard (tokens?.count ?? 0) > 0 else {
                    // 不支持或未开启
                    print("不支持或未开启")
                    throw LibraWalletError.WalletScan(reason: .violasModuleInvalid)
                }
                return QRCodeHandleResult.init(addressType: .Violas,
                                               originContent: content,
                                               address: coinAddress,
                                               amount: amount,
                                               contract: tokens?.first,
                                               type: .transfer)
            } else {
                return QRCodeHandleResult.init(addressType: .Violas,
                                               originContent: content,
                                               address: coinAddress,
                                               amount: amount,
                                               contract: nil,
                                               type: .transfer)
            }
         } else if content.hasPrefix("wc:") {
            return QRCodeHandleResult.init(addressType: nil,
                                           originContent: content,
                                           address: nil,
                                           amount: nil,
                                           contract: nil,
                                           type: .walletConnect)
         } else {
            do {
                let model = try JSONDecoder().decode(ScanLoginDataModel.self, from: content.data(using: .utf8)!)
                guard model.type == 2 else {
                    return QRCodeHandleResult.init(addressType: nil,
                                                   originContent: content,
                                                   address: nil,
                                                   amount: nil,
                                                   contract: nil,
                                                   type: .others)
                }
                return QRCodeHandleResult.init(addressType: nil,
                                               originContent: content,
                                               address: model.session_id,
                                               amount: nil,
                                               contract: nil,
                                               type: .login)
            } catch {
                return QRCodeHandleResult.init(addressType: nil,
                                               originContent: content,
                                               address: nil,
                                               amount: nil,
                                               contract: nil,
                                               type: .others)
            }
        }
    }
    struct QRCodeHandleResult {
        var addressType: WalletType?
        var originContent: String
        var address: String?
        var amount: Int64?
        var contract: Token?
        var type: QRCodeType
    }
    enum QRCodeType {
        case transfer
        case login
        case others
        case walletConnect
    }
    private static func handleAmount(content: String) -> (String, Int64?) {
        let contentArray = content.split(separator: "?")
        if contentArray.count == 2 {
            let amountContent = contentArray[1].split(separator: "&")
            let amountString = amountContent[0].replacingOccurrences(of: "amount=", with: "")
            let amount = NSDecimalNumber.init(string: amountString)
            return (contentArray.first!.description, amount.int64Value)
        } else {
            return (content, nil)
        }
    }
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
}
