//
//  LibraWalletError.swift
//  LibraWallet
//
//  Created by palliums on 2019/9/11.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit

public enum LibraWalletError: Error {
    case error(String)
    public enum RequestError {
        /// 没有钱包
        case walletNotExist
        /// 解析失败
        case parseJsonError
        /// 数据状态异常
        case dataCodeInvalid
        /// 数据为空
        case dataEmpty
        /// 没有更多数据
        case noMoreData
        /// 钱包版本太老
        case walletVersionTooOld
        /// 网络无法访问
        case networkInvalid
    }
    case WalletRequest(reason: RequestError)
    
    public enum KeychainError {
        /// 保存失败
        case savePaymentPasswordFailedError
        /// 保存助记词失败
        case saveMnemonicFailedError
        /// 获取支付密码失败
        case getPaymentPasswordFailedError
        /// 获取的支付密码为空
        case getPaymentPasswordEmptyError
        /// 获取助记词失败
        case getMnemonicFailedError
        /// 获取助记词为空
        case getMnemonicEmptyError
        /// 删除支付密码失败
        case deletePaymentPasswordFailedError
        /// 删除助记词失败
        case deleteMnemonicFailedError
        
    }
    case WalletKeychain(reason: KeychainError)
    
    public enum CryptoError {
        /// 密码为空
        case passwordEmptyError
        /// 助记词为空
        case mnemonicEmptyError
        /// 加密结果为空
        case encryptResultEmptyError
        /// 加密结果转Base64失败
        case encryptToBase64FailedError
        /// 加密结果转Base64为空
        case encryptToBase64EmptyError
        /// 待解密字符串为空
        case decryptStringEmptyError
        /// 解密结果为空
        case decryptResultEmptyError
        /// 解密结果转字符串失败
        case decryptToStringFailedError
        
    }
    case WalletCrypto(reason: CryptoError)

}
extension LibraWalletError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .error(let string):
            return "\(string)"
        case .WalletRequest(let reason):
            return reason.localizedDescription
        case .WalletKeychain(let reason):
            return reason.localizedDescription
        case .WalletCrypto(let reason):
            return reason.localizedDescription
        }
    }
}
extension LibraWalletError.RequestError {
    var localizedDescription: String {
        switch self {
        case .walletNotExist:
            return localLanguage(keyString: "wallet_request_token_invalid_error")
        case .parseJsonError:
            return localLanguage(keyString: "wallet_request_parse_json_error")
        case .dataCodeInvalid:
            return localLanguage(keyString: "wallet_request_data_code_invalid_error")
        case .dataEmpty:
            return localLanguage(keyString: "wallet_request_data_empty_error")
        case .noMoreData:
            return localLanguage(keyString: "wallet_request_data_no_more_error")
        case .walletVersionTooOld:
            return localLanguage(keyString: "wallet_request_wallet_version_invalid_error")
        case .networkInvalid:
            return localLanguage(keyString: "wallet_request_network_invalid_error")
        }
    }
}
extension LibraWalletError.KeychainError {
    var localizedDescription: String {
        switch self {
        /// 保存失败
        case .savePaymentPasswordFailedError:
            return localLanguage(keyString: "")
        /// 保存助记词失败
        case .saveMnemonicFailedError:
            return localLanguage(keyString: "")
        /// 获取支付密码失败
        case .getPaymentPasswordFailedError:
            return localLanguage(keyString: "")
        /// 获取的支付密码为空
        case .getPaymentPasswordEmptyError:
            return localLanguage(keyString: "")
        /// 获取助记词失败
        case .getMnemonicFailedError:
            return localLanguage(keyString: "")
        /// 获取助记词为空
        case .getMnemonicEmptyError:
            return localLanguage(keyString: "")
        /// 删除支付密码失败
        case .deletePaymentPasswordFailedError:
            return localLanguage(keyString: "")
        /// 删除助记词失败
        case .deleteMnemonicFailedError:
            return localLanguage(keyString: "")
        }
    }
}
extension LibraWalletError.CryptoError {
    var localizedDescription: String {
        switch self {
        /// 密码为空
        case .passwordEmptyError:
            return localLanguage(keyString: "")
        /// 助记词为空
        case .mnemonicEmptyError:
            return localLanguage(keyString: "")
        /// 加密结果为空
        case .encryptResultEmptyError:
            return localLanguage(keyString: "")
        /// 加密结果转Base64失败
        case .encryptToBase64FailedError:
            return localLanguage(keyString: "")
        /// 加密结果转Base64为空
        case .encryptToBase64EmptyError:
            return localLanguage(keyString: "")
        /// 待解密字符串为空
        case .decryptStringEmptyError:
            return localLanguage(keyString: "")
        /// 解密结果为空
        case .decryptResultEmptyError:
            return localLanguage(keyString: "")
        /// 解密结果转字符串失败
        case .decryptToStringFailedError:
            return localLanguage(keyString: "")
        }
    }
}
