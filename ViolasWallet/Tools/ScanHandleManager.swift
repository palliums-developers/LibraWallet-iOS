//
//  ScanHandleManager.swift
//  ViolasWallet
//
//  Created by wangyingdong on 2020/12/9.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit

struct QRCodeHandleResult {
    var addressType: WalletType?
    var originContent: String
    var address: String?
    var subAddress: String?
    var amount: UInt64?
    var token: Token?
    var type: QRCodeType
}
enum QRCodeType {
    case transfer
    case login
    case others
    case walletConnect
}
struct ScanHandleManager {
    public static func scanResultHandle(content: String, contracts: [Token]?) throws -> QRCodeHandleResult {
        if content.hasPrefix("bitcoin:") {
            do {
                let result = try handleBTCScanResult(content: content)
                return result
            } catch {
                throw error
            }
        } else if content.hasPrefix("diem://") {
            do {
                let result = try handleLibraScanResult(content: content, tokens: contracts)
                return result
            } catch {
                throw error
            }
        } else if content.hasPrefix("violas://") {
            do {
                let result = try handleViolasScanResult(content: content, tokens: contracts)
                return result
            } catch {
                throw error
            }
        } else if content.hasPrefix("wc:") {
            return QRCodeHandleResult.init(addressType: nil,
                                           originContent: content,
                                           address: nil,
                                           amount: nil,
                                           token: nil,
                                           type: .walletConnect)
        } else {
            do {
                let model = try JSONDecoder().decode(ScanLoginDataModel.self, from: content.data(using: .utf8)!)
                guard model.type == 2 else {
                    return QRCodeHandleResult.init(addressType: nil,
                                                   originContent: content,
                                                   address: nil,
                                                   amount: nil,
                                                   token: nil,
                                                   type: .others)
                }
                return QRCodeHandleResult.init(addressType: nil,
                                               originContent: content,
                                               address: model.session_id,
                                               amount: nil,
                                               token: nil,
                                               type: .login)
            } catch {
                return QRCodeHandleResult.init(addressType: nil,
                                               originContent: content,
                                               address: nil,
                                               amount: nil,
                                               token: nil,
                                               type: .others)
            }
        }
    }
}
// MARK: BTC二维码解析逻辑
extension ScanHandleManager {
    /// 解析BTC二维码
    /// - Parameters:
    ///   - content: 二维码内容
    /// - Throws: 解析异常
    /// - Returns: 解析结果
    private static func handleBTCScanResult(content: String) throws -> QRCodeHandleResult {
        let (contentPrefix, amount) = self.handleBTCAmount(content: content)
        let tempAddress = contentPrefix.replacingOccurrences(of: "bitcoin:", with: "")
        guard BTCManager.isValidBTCAddress(address: tempAddress) else {
            throw LibraWalletError.WalletScan(reason: .btcAddressInvalid)
        }
        return QRCodeHandleResult.init(addressType: .BTC,
                                       originContent: content,
                                       address: tempAddress,
                                       amount: amount,
                                       token: nil,
                                       type: .transfer)
    }
    private static func handleBTCAmount(content: String) -> (String, UInt64?) {
        let contentArray = content.split(separator: "?")
        if contentArray.count == 2 {
            let amountContent = contentArray[1].split(separator: "&")
            let amountString = amountContent[0].replacingOccurrences(of: "amount=", with: "")
            guard amountString.isEmpty == false else {
                return (contentArray.first!.description, nil)
            }
            let amount = NSDecimalNumber.init(string: amountString)
            return (contentArray.first!.description, amount.uint64Value)
        } else {
            return (content, nil)
        }
    }
}
// MARK: Libra二维码解析逻辑
extension ScanHandleManager {
    /// 解析Libra二维码
    /// - Parameters:
    ///   - content: 二维码内容
    ///   - tokens: 已打卡币
    /// - Throws: 解析异常
    /// - Returns: 解析结果
    private static func handleLibraScanResult(content: String, tokens: [Token]?) throws -> QRCodeHandleResult {
        do {
            let (contentPrefix, currency, amount) = try self.handleLibraAmount(content: content)
            let qrAddress = contentPrefix.replacingOccurrences(of: "diem://", with: "")
            // 检测地址是否合法
            let (address, subAddress) = try DiemManager.isValidTransferAddress(address: qrAddress)
            if tokens?.isEmpty == false {
                let tempTokens = tokens?.filter({ item in
                    item.tokenModule.lowercased() == currency.lowercased() && item.tokenType == .Libra
                })
                guard (tempTokens?.count ?? 0) > 0 else {
                    // 不支持或未开启
                    print("不支持或未开启")
                    throw LibraWalletError.WalletScan(reason: .libraModuleInvalid)
                }
                return QRCodeHandleResult.init(addressType: .Libra,
                                               originContent: content,
                                               address: address,
                                               subAddress: subAddress,
                                               amount: amount,
                                               token: tempTokens?.first,
                                               type: .transfer)
            } else {
                return QRCodeHandleResult.init(addressType: .Libra,
                                               originContent: content,
                                               address: address,
                                               subAddress: subAddress,
                                               amount: amount,
                                               token: nil,
                                               type: .transfer)
            }
        } catch {
            throw error
        }
    }
    /// 解析Libra二维码内容
    /// - Parameter content: 二维码内容
    /// - Throws: 解析异常
    /// - Returns: 地址、Module、数量
    private static func handleLibraAmount(content: String) throws -> (String, String, UInt64?) {
        // 分离地址、内容
        let contentArray = content.split(separator: "?")
        guard contentArray.count == 2 else {
            throw LibraWalletError.WalletScan(reason: .handleInvalid)
        }
        // 分离内容数据
        guard let dataArray = contentArray.last?.split(separator: "&"), dataArray.isEmpty == false else {
            throw LibraWalletError.WalletScan(reason: .handleInvalid)
        }
        guard let address = contentArray.first?.description, address.isEmpty == false else {
            throw LibraWalletError.WalletScan(reason: .libraAddressInvalid)
        }
        var tempCurrency = ""
        var tempAmount: UInt64?
        for data in dataArray {
            let tempData = data
            if tempData.hasPrefix("c=") {
                tempCurrency = tempData.replacingOccurrences(of: "c=", with: "")
            }
            if tempData.hasPrefix("am=") {
                let amount = tempData.replacingOccurrences(of: "am=", with: "")
                if amount.isEmpty == false {
                    tempAmount = NSDecimalNumber.init(string: amount).uint64Value
                }
            }
        }
        guard tempCurrency.isEmpty == false else {
            throw LibraWalletError.WalletScan(reason: .libraTokenNameEmpty)
        }
        return (address, tempCurrency, tempAmount)
    }

}
// MARK: Violas二维码解析逻辑
extension ScanHandleManager {
    /// 解析Violas二维码
    /// - Parameters:
    ///   - content: 二维码内容
    ///   - tokens: 已打卡币
    /// - Throws: 解析异常
    /// - Returns: 解析结果
    private static func handleViolasScanResult(content: String, tokens: [Token]?) throws -> QRCodeHandleResult {
        do {
            let (contentPrefix, currency, amount) = try self.handleViolasAmount(content: content)
            let qrAddress = contentPrefix.replacingOccurrences(of: "violas://", with: "")
            // 检测地址是否合法
            let (address, subAddress) = try ViolasManager.isValidTransferAddress(address: qrAddress)
            if tokens?.isEmpty == false {
                let tempTokens = tokens?.filter({ item in
                    item.tokenModule.lowercased() == currency.lowercased() && item.tokenType == .Violas
                })
                guard (tempTokens?.count ?? 0) > 0 else {
                    // 不支持或未开启
                    print("不支持或未开启")
                    throw LibraWalletError.WalletScan(reason: .violasModuleInvalid)
                }
                return QRCodeHandleResult.init(addressType: .Violas,
                                               originContent: content,
                                               address: address,
                                               subAddress: subAddress,
                                               amount: amount,
                                               token: tempTokens?.first,
                                               type: .transfer)
            } else {
                return QRCodeHandleResult.init(addressType: .Violas,
                                               originContent: content,
                                               address: address,
                                               subAddress: subAddress,
                                               amount: amount,
                                               token: nil,
                                               type: .transfer)
            }
        } catch {
            throw error
        }
    }
    /// 解析Violas二维码内容
    /// - Parameter content: 二维码内容
    /// - Throws: 解析异常
    /// - Returns: 地址、Module、数量
    private static func handleViolasAmount(content: String) throws -> (String, String, UInt64?) {
        // 分离地址、内容
        let contentArray = content.split(separator: "?")
        guard contentArray.count == 2 else {
            throw LibraWalletError.WalletScan(reason: .handleInvalid)
        }
        // 分离内容数据
        guard let dataArray = contentArray.last?.split(separator: "&"), dataArray.isEmpty == false else {
            throw LibraWalletError.WalletScan(reason: .handleInvalid)
        }
        guard let address = contentArray.first?.description, address.isEmpty == false else {
            throw LibraWalletError.WalletScan(reason: .violasAddressInvalid)
        }
        var tempCurrency = ""
        var tempAmount: UInt64?
        for data in dataArray {
            let tempData = data
            if tempData.hasPrefix("c=") {
                tempCurrency = tempData.replacingOccurrences(of: "c=", with: "")
            }
            if tempData.hasPrefix("am=") {
                let amount = tempData.replacingOccurrences(of: "am=", with: "")
                if amount.isEmpty == false {
                    tempAmount = NSDecimalNumber.init(string: amount).uint64Value
                }
            }
        }
        guard tempCurrency.isEmpty == false else {
            throw LibraWalletError.WalletScan(reason: .violasTokenNameEmpty)
        }
        return (address, tempCurrency, tempAmount)
    }
}
