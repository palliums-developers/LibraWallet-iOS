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
    func imageWithColor(color:UIColor) -> UIImage {
        let rect = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
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
func passowordAlert(rootAddress: String, message: String? = localLanguage(keyString: "wallet_type_in_password_content"), mnemonic: @escaping (([String])->Void), errorContent: @escaping ((String)->Void)) -> UIAlertController {
    let alertContr = UIAlertController(title: localLanguage(keyString: "wallet_type_in_password_title"), message: message, preferredStyle: .alert)
    alertContr.addTextField {
        (textField: UITextField!) -> Void in
        textField.placeholder = localLanguage(keyString: "wallet_type_in_password_textfield_placeholder")
        textField.tintColor = DefaultGreenColor
        textField.isSecureTextEntry = true
    }
    alertContr.addAction(UIAlertAction(title: localLanguage(keyString: "wallet_type_in_password_confirm_button_title"), style: .default) { clickHandler in
        let passwordTextField = alertContr.textFields!.first! as UITextField
        guard let password = passwordTextField.text else {
            errorContent(LibraWalletError.WalletCheckPassword(reason: .passwordInvalidError).localizedDescription)
            return
        }
        guard password.isEmpty == false else {
            errorContent(LibraWalletError.WalletCheckPassword(reason: .passwordEmptyError).localizedDescription)
            return
        }
        NSLog("Password:\(password)")
        do {
            let state = try LibraWalletManager.shared.isValidPaymentPassword(walletRootAddress: rootAddress, password: password)
            guard state == true else {
                errorContent(LibraWalletError.WalletCheckPassword(reason: .passwordCheckFailed).localizedDescription)
                return
            }
            let tempMenmonic = try LibraWalletManager.shared.getMnemonicFromKeychain(walletRootAddress: rootAddress)
            mnemonic(tempMenmonic)
        } catch {
            errorContent(error.localizedDescription)
        }
    })
    alertContr.addAction(UIAlertAction(title: localLanguage(keyString: "wallet_type_in_password_cancel_button_title"), style: .cancel){
        clickHandler in
        NSLog("点击了取消")
        errorContent("Cancel")
    })
    return alertContr
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
    public static func scanResultHandle(content: String, contracts: [ViolasTokenModel]?) throws -> QRCodeHandleResult {
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
         } else if content.hasPrefix("libra:") {
             let (contentPrefix, amount) = handleAmount(content: content)
             let tempAddress = contentPrefix.replacingOccurrences(of: "libra:", with: "")
             guard LibraManager.isValidLibraAddress(address: tempAddress) else {
                throw LibraWalletError.WalletScan(reason: .libraAddressInvalid)
             }
             return QRCodeHandleResult.init(addressType: .Libra,
                                            originContent: content,
                                            address: tempAddress,
                                            amount: amount,
                                            contract: nil,
                                            type: .transfer)
         } else if content.hasPrefix("violas:") {
             let (contentPrefix, amount) = handleAmount(content: content)
             let tempAddress = contentPrefix.replacingOccurrences(of: "violas:", with: "")
             guard ViolasManager.isValidViolasAddress(address: tempAddress) else {
                 throw LibraWalletError.WalletScan(reason: .violasAddressInvalid)
             }
             return QRCodeHandleResult.init(addressType: .Violas,
                                            originContent: content,
                                            address: tempAddress,
                                            amount: amount,
                                            contract: nil,
                                            type: .transfer)
         } else if content.hasPrefix("violas-") {
             let (contentPrefix, amount) = handleAmount(content: content)
             let coinAddress = contentPrefix.split(separator: ":").last?.description
             let addressPrifix = contentPrefix.split(separator: ":").first?.description
             let coinNames = addressPrifix?.split(separator: "-")
             guard coinNames?.count == 2 else {
                 print("token名称为空")
                 throw LibraWalletError.WalletScan(reason: .violasTokenNameEmpty)
             }
             let contract = contracts?.filter({ item in
                 item.name?.lowercased() == coinNames?.last?.description.lowercased()
             })
             guard (contract?.count ?? 0) > 0 else {
                 // 不支持或未开启
                 print("不支持或未开启")
                 throw LibraWalletError.WalletScan(reason: .violasTokenContractInvalid)
             }
             guard ViolasManager.isValidViolasAddress(address: coinAddress ?? "") else {
                 throw LibraWalletError.WalletScan(reason: .violasAddressInvalid)
             }
             return QRCodeHandleResult.init(addressType: .Violas,
                                            originContent: content,
                                            address: coinAddress,
                                            amount: amount,
                                            contract: contract?.first,
                                            type: .transfer)
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
         var contract: ViolasTokenModel?
         var type: QRCodeType
     }
     enum QRCodeType {
         case transfer
         case login
         case others
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
