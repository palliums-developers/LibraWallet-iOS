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
    case WalletRequestError(reason: RequestError)
}
extension LibraWalletError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .error(let string):
            return "\(string)"
        case .WalletRequestError(let reason):
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
