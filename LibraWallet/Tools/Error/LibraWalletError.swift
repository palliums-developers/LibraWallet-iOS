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
        /// 搜寻标示为空
        case searchStringEmptyError
        
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
        /// 解密结果转数组失败
        case decryptStringSplitError
    }
    case WalletCrypto(reason: CryptoError)

    public enum CreateError {
        /// 钱包已存在
        case walletExist
        /// 创建失败
        case walletCreateFailed
        /// 导入失败
        case walletImportFailed
    }
    case WalletCreate(reason: CreateError)
    
    public enum MnemonicError {
        /// 未选择全部
        case checkArrayNotEnough
        /// 顺序不对
        case orderInvalid
    }
    case WalletCheckMnemonic(reason: MnemonicError)
    
    public enum AddAddressError {
        /// 地址无效
        case addressInvalidError
        /// 地址为空
        case addressEmptyError
        /// 比特币地址无效
        case btcAddressInvalidError
        /// Violas地址无效
        case violasAddressInvalidError
        /// Libra地址无效
        case libraAddressInvalidError
        /// 名称无效
        case remarksInvalidError
        /// 名称为空
        case remarksEmptyError
        /// 名称超长
        case remarksLengthInvalidError
        /// 类型未选择
        case addressTypeInvalidError
        /// 地址添加失败
        case addressInsertError
    }
    case WalletAddAddress(reason: AddAddressError)
    
    public enum AddWalletError {
        /// 钱包名字无效
        case walletNameInvalidError
        /// 钱包名字为空
        case walletNameEmptyError
        /// 钱包名字超长
        case walletNameTooLongError
        /// 密码无效
        case passwordInvalidError
        /// 密码为空
        case passwordEmptyError
        /// 确认密码无效
        case passwordCofirmInvalidError
        /// 确认密码为空
        case passwordConfirmEmptyError
        /// 密码不一致
        case passwordCheckFailed
        /// 密码超长
        case passwordTooLongError
        /// 密码太短
        case passwordTooShortError
    }
    case WalletAddWallet(reason: AddWalletError)
    
    public enum ImportWalletError {
        /// 助记词无效
        case mnemonicInvalidError
        /// 助记词为空
        case mnemonicEmptyError
        /// 助记词分隔失败
        case mnemonicSplitFailedError
        /// 助记词数量不支持
        case mnemonicCountUnsupportError
        /// 助记词无效(包含无效词)
        case mnemonicCheckFailed
    }
    case WalletImportWallet(reason: ImportWalletError)
    
    public enum ChangeWalletNameError {
        /// 钱包名称无效
        case walletNameInvalidError
        /// 钱包名称为空
        case walletNameEmptyError
        /// 钱包名称和以前相同
        case walletNameSameAsOld
        /// 改名失败
        case changeWalletNameFailed
    }
    case WalletChangeWalletName(reason: ChangeWalletNameError)
    
    public enum CheckPasswordError {
        /// 密码无效
        case passwordInvalidError
        /// 密码为空
        case passwordEmptyError
        /// 密码不正确
        case passwordCheckFailed
    }
    case WalletCheckPassword(reason: CheckPasswordError)
    
    public enum TransferError {
        /// 数量无效
        case amountInvalid
        /// 数量为空
        case amountEmpty
        /// 数量超过自己余额
        case amountOverload
        /// 金额太小不能转账
        case amountTooSmall
        /// 地址无效
        case addressInvalid
        /// 地址为空
        case addressEmpty
        /// 像自己付款无效
        case transferToSelf
    }
    case WalletTransfer(reason: TransferError)
    
//    public enum WalletEnableToken {
//        /// 数量无效
//        case amountInvalid
//        /// 数量为空
//        case amountEmpty
//        /// 数量超过自己余额
//        case amountOverload
//        /// 金额太小不能转账
//        case amountTooSmall
//        /// 地址无效
//        case addressInvalid
//        /// 地址为空
//        case addressEmpty
//        /// 像自己付款无效
//        case transferToSelf
//    }
//    case WalletTransfer(reason: TransferError)
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
        case .WalletCreate(let reason):
            return reason.localizedDescription
        case .WalletCheckMnemonic(let reason):
            return reason.localizedDescription
        case .WalletAddAddress(let reason):
            return reason.localizedDescription
        case .WalletAddWallet(let reason):
            return reason.localizedDescription
        case .WalletImportWallet(let reason):
            return reason.localizedDescription
        case .WalletChangeWalletName(let reason):
            return reason.localizedDescription
        case .WalletCheckPassword(let reason):
            return reason.localizedDescription
        case .WalletTransfer(let reason):
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
            return localLanguage(keyString: "wallet_request_data_code_error")
        case .dataEmpty:
            return localLanguage(keyString: "wallet_request_data_empty_error")
        case .noMoreData:
            return localLanguage(keyString: "wallet_request_data_no_more_error")
        case .walletVersionTooOld:
            return localLanguage(keyString: "wallet_request_version_invalid_error")
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
            return localLanguage(keyString: "wallet_keychain_set_password_failed_error")
        /// 保存助记词失败
        case .saveMnemonicFailedError:
            return localLanguage(keyString: "wallet_keychain_set_mnemonic_failed_error")
        /// 获取支付密码失败
        case .getPaymentPasswordFailedError:
            return localLanguage(keyString: "wallet_keychain_get_password_failed_error")
        /// 获取的支付密码为空
        case .getPaymentPasswordEmptyError:
            return localLanguage(keyString: "wallet_keychain_get_password_empty_error")
        /// 获取助记词失败
        case .getMnemonicFailedError:
            return localLanguage(keyString: "wallet_keychain_get_mnemonic_failed_error")
        /// 获取助记词为空
        case .getMnemonicEmptyError:
            return localLanguage(keyString: "wallet_keychain_get_mnemonic_empty_error")
        /// 删除支付密码失败
        case .deletePaymentPasswordFailedError:
            return localLanguage(keyString: "wallet_keychain_delete_password_failed_error")
        /// 删除助记词失败
        case .deleteMnemonicFailedError:
            return localLanguage(keyString: "wallet_keychain_delete_mnemonic_failed_error")
        /// 搜寻标示为空
        case .searchStringEmptyError:
            return localLanguage(keyString: "wallet_keychain_search_sign_empty_error")
        }
    }
}
extension LibraWalletError.CryptoError {
    var localizedDescription: String {
        switch self {
        /// 密码为空
        case .passwordEmptyError:
            return localLanguage(keyString: "wallet_crypto_password_empty_error")
        /// 助记词为空
        case .mnemonicEmptyError:
            return localLanguage(keyString: "wallet_crypto_mnemonic_empty_error")
        /// 加密结果为空
        case .encryptResultEmptyError:
            return localLanguage(keyString: "wallet_crypto_result_empty_error")
        /// 加密结果转Base64失败
        case .encryptToBase64FailedError:
            return localLanguage(keyString: "wallet_crypto_result_to_base64_failed_error")
        /// 加密结果转Base64为空
        case .encryptToBase64EmptyError:
            return localLanguage(keyString: "wallet_crypto_result_to_base64_empty_error")
        /// 待解密字符串为空
        case .decryptStringEmptyError:
            return localLanguage(keyString: "wallet_crypto_decrypt_content_empty_error")
        /// 解密结果为空
        case .decryptResultEmptyError:
            return localLanguage(keyString: "wallet_crypto_decrypt_result_empty_error")
        /// 解密结果转字符串失败
        case .decryptToStringFailedError:
            return localLanguage(keyString: "wallet_crypto_decrypt_result_failed_error")
        /// 解密结果转数组失败
        case .decryptStringSplitError:
            return localLanguage(keyString: "wallet_crypto_decrypt_result_to_mnemonic_array_failed_error")
        }
    }
}
extension LibraWalletError.CreateError {
    var localizedDescription: String {
        switch self {
        /// 密码为空
        case .walletExist:
            return localLanguage(keyString: "wallet_create_wallet_exist_error")
        /// 创建失败
        case .walletCreateFailed:
            return localLanguage(keyString: "wallet_create_wallet_failed_error")
        /// 导入失败
        case .walletImportFailed:
            return localLanguage(keyString: "wallet_import_wallet_failed_error")
        }
    }
}
extension LibraWalletError.MnemonicError {
    var localizedDescription: String {
        switch self {
        /// 未选择全部
        case .checkArrayNotEnough:
            return localLanguage(keyString: "wallet_mnemonic_check_array_not_enough_error")
        /// 顺序不对
        case .orderInvalid:
            return localLanguage(keyString: "wallet_mnemonic_order_invalid_error")
        }
    }
}
extension LibraWalletError.AddAddressError {
    var localizedDescription: String {
        switch self {
        case .addressInsertError:
            return localLanguage(keyString: "wallet_add_address_insert_error")
        case .addressInvalidError:
            return localLanguage(keyString: "wallet_add_address_invalid_error")
        case .addressEmptyError:
            return localLanguage(keyString: "wallet_add_address_empty_error")
        case .btcAddressInvalidError:
            return localLanguage(keyString: "wallet_add_address_btc_address_invalid_error")
        case .violasAddressInvalidError:
            return localLanguage(keyString: "wallet_add_address_violas_address_invalid_error")
        case .libraAddressInvalidError:
            return localLanguage(keyString: "wallet_add_address_libra_address_invalid_error")
        case .remarksInvalidError:
            return localLanguage(keyString: "wallet_add_address_remarks_invalid_error")
        case .remarksEmptyError:
            return localLanguage(keyString: "wallet_add_address_remarks_empty_error")
        case .remarksLengthInvalidError:
            return localLanguage(keyString: "wallet_add_address_remarks_length_invalid_error")
        case .addressTypeInvalidError:
            return localLanguage(keyString: "wallet_add_address_type_invalid_error")
        }
    }
}
extension LibraWalletError.AddWalletError {
    var localizedDescription: String {
        switch self {
        case .walletNameInvalidError:
            return localLanguage(keyString: "wallet_add_wallet_name_invalid_error")
        case .walletNameEmptyError:
            return localLanguage(keyString: "wallet_add_wallet_name_empty_error")
        case .walletNameTooLongError:
            return localLanguage(keyString: "wallet_add_wallet_name_too_long_error")
        case .passwordInvalidError:
            return localLanguage(keyString: "wallet_add_wallet_password_invalid_error")
        case .passwordEmptyError:
            return localLanguage(keyString: "wallet_add_wallet_password_empty_error")
        case .passwordCofirmInvalidError:
            return localLanguage(keyString: "wallet_add_wallet_password_cofirm_invalid_error")
        case .passwordConfirmEmptyError:
            return localLanguage(keyString: "wallet_add_wallet_password_cofirm_empty_error")
        case .passwordCheckFailed:
            return localLanguage(keyString: "wallet_add_wallet_password_check_failed_error")
        case .passwordTooLongError:
            return localLanguage(keyString: "wallet_add_wallet_password_length_limit_long_error")
        case .passwordTooShortError:
            return localLanguage(keyString: "wallet_add_wallet_password_length_limit_short_error")
        }
    }
}
extension LibraWalletError.ImportWalletError {
    var localizedDescription: String {
        switch self {
        case .mnemonicInvalidError:
            return localLanguage(keyString: "wallet_mnemonic_invalid_error")
        case .mnemonicEmptyError:
            return localLanguage(keyString: "wallet_mnemonic_empty_error")
        case .mnemonicSplitFailedError:
            return localLanguage(keyString: "wallet_mnemonic_split_failed_error")
        case .mnemonicCountUnsupportError:
            return localLanguage(keyString: "wallet_mnemonic_count_unsupport_error")
        case .mnemonicCheckFailed:
            return localLanguage(keyString: "wallet_mnemonic_check_failed_error")
        }
    }
}
extension LibraWalletError.ChangeWalletNameError {
    var localizedDescription: String {
        switch self {
        case .walletNameInvalidError:
            return localLanguage(keyString: "wallet_change_name_invalid_error")
        case .walletNameEmptyError:
            return localLanguage(keyString: "wallet_change_name_empty_error")
        case .walletNameSameAsOld:
            return localLanguage(keyString: "wallet_change_name_same_as_old_error")
        case .changeWalletNameFailed:
            return localLanguage(keyString: "wallet_change_name_failed_error")
        }
    }
}
extension LibraWalletError.CheckPasswordError {
    var localizedDescription: String {
        switch self {
        case .passwordInvalidError:
            return localLanguage(keyString: "wallet_check_password_invalid_error")
        case .passwordEmptyError:
            return localLanguage(keyString: "wallet_check_password_empty_error")
        case .passwordCheckFailed:
            return localLanguage(keyString: "wallet_check_password_failed_error")
        }
    }
}
extension LibraWalletError.TransferError {
    var localizedDescription: String {
        switch self {
        case .amountInvalid:
            return localLanguage(keyString: "wallet_transfer_amount_invalid_error")
        case .amountEmpty:
            return localLanguage(keyString: "wallet_transfer_amount_empty_error")
        case .amountOverload:
            return localLanguage(keyString: "wallet_transfer_amount_overload_error")
        case .amountTooSmall:
            return localLanguage(keyString: "wallet_transfer_amount_limit_error") + ":\(transferBTCLeast)"
        case .addressInvalid:
            return localLanguage(keyString: "wallet_transfer_address_invalid_error")
        case .addressEmpty:
            return localLanguage(keyString: "wallet_transfer_address_empty_error")
        case .transferToSelf:
            return localLanguage(keyString: "wallet_transfer_to_self_error")
        }
    }
}
