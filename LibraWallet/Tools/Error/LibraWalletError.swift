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
        case walletTokenExpired
        /// 解析失败
        case parseJsonError
        /// 数据状态异常
        case dataCodeInvalid
        /// 数据为空
        case dataEmpty
        /// 没有更多数据
        case noMoreData
        /// 钱包版本太老
        case walletVersionExpired
        /// 网络无法访问
        case networkInvalid
        /// 钱包尚未激活
        case walletUnActive
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
        /// 密码无效
        case passwordInvalidError
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
        /// 地址已存在
        case addressExistError
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
        /// 不同意协议
        case notAgreeLegalError
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
    
    public enum CheckPasswordError {
        /// 密码无效
        case passwordInvalidError
        /// 密码为空
        case passwordEmptyError
        /// 密码不正确
        case passwordCheckFailed
        /// 取消密码验证
        case cancel
    }
    case WalletCheckPassword(reason: CheckPasswordError)
    
    public enum TransferError {
        case tokenInvalid
        /// 数量无效
        case amountInvalid
        /// 数量为空
        case amountEmpty
        /// 数量超过自己余额
        case amountOverload
        /// BTC最小转账金额
        case btcAmountLeast
        /// Violas最小转账金额
        case violasAmountLeast
        /// Libra最小转账金额
        case libraAmountLeast
        /// 地址无效
        case addressInvalid
        /// 地址为空
        case addressEmpty
        /// 像自己付款无效
        case transferToSelf
    }
    case WalletTransfer(reason: TransferError)
    
    public enum ScanError {
        /// BTC地址无效
        case btcAddressInvalid
        /// Violas地址无效
        case violasAddressInvalid
        /// Violas稳定币名字为空
        case violasTokenNameEmpty
        /// Violas稳定币合约未开启或不支持
        case violasModuleInvalid
        /// Libra地址无效
        case libraAddressInvalid
        /// Libra稳定币名字为空
        case libraTokenNameEmpty
        /// Libra稳定币合约未开启或不支持
        case libraModuleInvalid
        /// 解析失败，不支持
        case handleInvalid
    }
    case WalletScan(reason: ScanError)
    
    public enum ExchangeMarketError {
        /// 交易所维护中
        case marketOffline
        /// 交易所暂无流动性
        case marketWithoutLiquidity
        /// 未开启不能调换
        case swpUnpublishTokenError
        /// 待兑换金额无效
        case exchangeAmountInvalid
        /// 待兑换金额超限
        case exchangeAmountMaxLimit
        /// 付出金额无效
        case payAmountInvalid
        /// 付出金额超限
        case payAmountMaxLimit
        /// 余额不足
        case payAmountNotEnough
        /// 待兑换稳定币尚未开启
        case exchangeTokenPublishedInvalid
        /// 尚未开启任何稳定币
        case publishedListEmpty
        /// 获取交易所稳定币列表为空
        case marketSupportTokenEmpty
        
        /// 付出稳定币未选择
        case payTokenNotSelect
        /// 待兑换稳定币未选择
        case exchangeTokenNotSelect
        /// 付出稳定币数量为空
        case payAmountEmpty
        /// 兑换稳定币数量为空
        case exchangeAmountEmpty
        
//        /// 尚未选择通证
//        case unselectToken
//        /// 通证不足
//        case tokenAmountNotEnough
//        /// 通证超限
//        case tokenAmountMaxLimit
        
    }
    case WalletMarket(reason: ExchangeMarketError)
    
    public enum MappingError {
        /// 待兑换稳定币尚未开启
        case mappingTokenPublishedInvalid
        /// 映射功能异常
        case mappingFounctionInvalid
        /// 映射稳定币为空
        case mappingCoinDataEmpty
        /// ETH地址为空
        case ethAddressEmpty
        /// ETH无效
        case ethAddressInvalid
    }
    case WalletMapping(reason: MappingError)
    
    public enum DataBaseError {
        /// 数据打开失败
        case openDataBaseError
        /// 默认钱包不存在
        case defaultWalletNotExist
    }
    case WalletDataBase(reason: DataBaseError)
    
    public enum BankDepositError {
        /// 存款未开启
        case tokenUnactivated
        /// 余额为0
        case balanceEmpty
        /// 输入金额无效
        case amountInvalid
        /// 余额不足
        case balanceInsufficient
        /// 金额比最低充值限额低
        case amountTooLittle
        /// 额度不足
        case quotaInsufficient
        /// 数据异常
        case dataInvalid
    }
    case WalletBankDeposit(reason: BankDepositError)
    
    public enum BankLoanError {
        /// 借款币未开启
        case tokenUnactivated
        /// 未输入金额
        case amountEmpty
        /// 输入金额无效
        case amountInvalid
        /// 金额比最低充值限额低
        case amountTooLittle
        /// 额度不足
        case quotaInsufficient
        /// 数据异常
        case dataInvalid
        /// 未同意借款协议
        case disagreeLegal
    }
    case WalletBankLoan(reason: BankLoanError)
    
    public enum BankRepaymentError {
        /// 借款币未开启
        case tokenUnactivated
        /// 未输入金额
        case amountEmpty
        /// 输入金额无效
        case amountInvalid
        /// 金额比最低还贷额低
        case amountTooLittle
        /// 金额太多
        case amountTooLarge
        /// 余额不足
        case balanceInsufficient
        /// 数据异常
        case dataInvalid
    }
    case WalletBankRepayment(reason: BankRepaymentError)
    
    public enum BankWithdrawError {
        /// 提款币未开启
        case tokenUnactivated
        /// 未输入金额
        case amountEmpty
        /// 输入金额无效
        case amountInvalid
        /// 金额太多
        case amountTooLarge
        /// 数据异常
        case dataInvalid
    }
    case WalletBankWithdraw(reason: BankWithdrawError)
    
    public enum VerifyMobilePhoneError {
        /// 区域未选择
        case phoneAreaUnselect
        /// 手机号未输入
        case phoneNumberEmpty
        /// 验证码未输入
        case secureCodeEmpty
    }
    case WalletVerifyMobile(reason: VerifyMobilePhoneError)
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
        case .WalletCheckPassword(let reason):
            return reason.localizedDescription
        case .WalletTransfer(let reason):
            return reason.localizedDescription
        case .WalletScan(let reason):
            return reason.localizedDescription
        case .WalletMarket(let reason):
            return reason.localizedDescription
        case .WalletMapping(let reason):
            return reason.localizedDescription
        case .WalletDataBase(reason: let reason):
            return reason.localizedDescription
        case .WalletBankDeposit(reason: let reason):
            return reason.localizedDescription
        case .WalletBankLoan(reason: let reason):
            return reason.localizedDescription
        case .WalletBankRepayment(reason: let reason):
            return reason.localizedDescription
        case .WalletBankWithdraw(reason: let reason):
            return reason.localizedDescription
        case .WalletVerifyMobile(reason: let reason):
            return reason.localizedDescription
        }
    }
}
extension LibraWalletError.RequestError {
    var localizedDescription: String {
        switch self {
        case .walletTokenExpired:
            return localLanguage(keyString: "wallet_request_token_invalid_error")
        case .parseJsonError:
            return localLanguage(keyString: "wallet_request_parse_json_error")
        case .dataCodeInvalid:
            return localLanguage(keyString: "wallet_request_data_code_error")
        case .dataEmpty:
            return localLanguage(keyString: "wallet_request_data_empty_error")
        case .noMoreData:
            return localLanguage(keyString: "wallet_request_data_no_more_error")
        case .walletVersionExpired:
            return localLanguage(keyString: "wallet_request_version_invalid_error")
        case .networkInvalid:
            return localLanguage(keyString: "wallet_request_network_invalid_error")
        case .walletUnActive:
            return localLanguage(keyString: "wallet_request_wallet_unactive_error")
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
        case .passwordInvalidError:
            return localLanguage(keyString: "wallet_crypto_password_invalid_error")
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
        case .addressExistError:
            return localLanguage(keyString: "wallet_add_address_exist_error")
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
        case .notAgreeLegalError:
            return localLanguage(keyString: "wallet_add_wallet_not_agree_legal_error")

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
extension LibraWalletError.CheckPasswordError {
    var localizedDescription: String {
        switch self {
        case .passwordInvalidError:
            return localLanguage(keyString: "wallet_check_password_invalid_error")
        case .passwordEmptyError:
            return localLanguage(keyString: "wallet_check_password_empty_error")
        case .passwordCheckFailed:
            return localLanguage(keyString: "wallet_check_password_failed_error")
        case .cancel:
            return "Cancel"
        }
    }
}
extension LibraWalletError.TransferError {
    var localizedDescription: String {
        switch self {
        case .tokenInvalid:
            return localLanguage(keyString: "wallet_transfer_token_invalid_error")
        case .amountInvalid:
            return localLanguage(keyString: "wallet_transfer_amount_invalid_error")
        case .amountEmpty:
            return localLanguage(keyString: "wallet_transfer_amount_empty_error")
        case .amountOverload:
            return localLanguage(keyString: "wallet_transfer_amount_overload_error")
        /// BTC最小转账金额
        case .btcAmountLeast:
            return localLanguage(keyString: "wallet_transfer_amount_limit_error") + ":\(transferBTCLeast)"
        /// Violas最小转账金额
        case .violasAmountLeast:
            return localLanguage(keyString: "wallet_transfer_amount_limit_error") + ":\(transferViolasLeast)"
        /// Libra最小转账金额
        case .libraAmountLeast:
            return localLanguage(keyString: "wallet_transfer_amount_limit_error") + ":\(transferLibraLeast)"
        case .addressInvalid:
            return localLanguage(keyString: "wallet_transfer_address_invalid_error")
        case .addressEmpty:
            return localLanguage(keyString: "wallet_transfer_address_empty_error")
        case .transferToSelf:
            return localLanguage(keyString: "wallet_transfer_to_self_error")
        }
    }
}
extension LibraWalletError.ScanError {
    var localizedDescription: String {
        switch self {
        case .btcAddressInvalid:
            return localLanguage(keyString: "wallet_scan_result_address_btc_invalid_error")
        case .violasAddressInvalid:
            return localLanguage(keyString: "wallet_scan_result_address_violas_invalid_error")
        case .violasTokenNameEmpty:
            return localLanguage(keyString: "wallet_scan_result_address_violas_module_empty_error")
        case .violasModuleInvalid:
            return localLanguage(keyString: "wallet_scan_result_address_violas_module_invalid_error")
        case .libraAddressInvalid:
            return localLanguage(keyString: "wallet_scan_result_address_libra_invalid_error")
        case .libraTokenNameEmpty:
            return localLanguage(keyString: "wallet_scan_result_address_libra_module_empty_error")
        case .libraModuleInvalid:
            return localLanguage(keyString: "wallet_scan_result_address_libra_module_invalid_error")
        case .handleInvalid:
            return localLanguage(keyString: "wallet_scan_result_not_support_error")
        }
    }
}
extension LibraWalletError.ExchangeMarketError {
    var localizedDescription: String {
        switch self {
        // 交易所维护中
        case .marketOffline:
            return localLanguage(keyString: "wallet_market_offline")
        // 交易所无流动性
        case .marketWithoutLiquidity:
            return localLanguage(keyString: "wallet_market_exchange_without_liquidity")
        // 未开启不能调换
        case .swpUnpublishTokenError:
            return localLanguage(keyString: "wallet_market_swap_unpublisheda_error")
        // 待兑换金额无效
        case .exchangeAmountInvalid:
            return localLanguage(keyString: "wallet_market_exchange_amount_error")
        // 待兑换金额超限
        case .exchangeAmountMaxLimit:
            return localLanguage(keyString: "wallet_market_exchange_amount_max_limit_error")
        // 付出金额无效
        case .payAmountInvalid:
            return localLanguage(keyString: "wallet_market_pay_amount_invalid_error")
        // 付出金额超限
        case .payAmountMaxLimit:
            return localLanguage(keyString: "wallet_market_pay_amount_max_limit_error")
        // 余额不足
        case .payAmountNotEnough:
            return localLanguage(keyString: "wallet_market_amount_not_enough_error")
        // 待兑换稳定币尚未开启
        case .exchangeTokenPublishedInvalid:
            return localLanguage(keyString: "wallet_market_exchange_token_unpublish_error")
        // 尚未开启任何稳定币
        case .publishedListEmpty:
            return localLanguage(keyString: "wallet_market_published_list_empty_error")
        // 获取交易所稳定币列表为空
        case .marketSupportTokenEmpty:
            return localLanguage(keyString: "wallet_market_token_list_empty_error")
        // 付出稳定币未选择
        case .payTokenNotSelect:
            return localLanguage(keyString: "wallet_market_pay_token_not_select_error")
        // 待兑换稳定币未选择
        case .exchangeTokenNotSelect:
            return localLanguage(keyString: "wallet_market_exchange_token_not_select_error")
        // 付出稳定币数量为空
        case .payAmountEmpty:
            return localLanguage(keyString: "wallet_market_pay_amount_empty_error")
        // 兑换稳定币数量为空
        case .exchangeAmountEmpty:
            return localLanguage(keyString: "wallet_market_exchange_amount_empty_error")
        }
    }
}
extension LibraWalletError.MappingError {
    var localizedDescription: String {
        switch self {
        /// 暂未映射
        case .mappingTokenPublishedInvalid:
            return localLanguage(keyString: "wallet_market_mapping_token_unpublish_error")
        case .mappingFounctionInvalid:
            return localLanguage(keyString: "wallet_mapping_info_alert_content")
        case .mappingCoinDataEmpty:
            return localLanguage(keyString: "wallet_mapping_info_data_empty_alert_content")
        case .ethAddressEmpty:
            return localLanguage(keyString: "wallet_mapping_eth_address_empty")
        case .ethAddressInvalid:
            return localLanguage(keyString: "wallet_mapping_eth_address_invalid")
        }
    }
}
extension LibraWalletError.DataBaseError {
    var localizedDescription: String {
        switch self {
        /// 暂未映射
        case .openDataBaseError:
            #warning("待翻译")
            return localLanguage(keyString: "DataBase Invalid")
        case .defaultWalletNotExist:
            return localLanguage(keyString: "DataBase not exist default wallet")
        }
    }
}
extension LibraWalletError.BankDepositError {
    var localizedDescription: String {
        switch self {
        /// 充值币未开启
        case .tokenUnactivated:
            return localLanguage(keyString: "wallet_bank_deposit_token_unactivated_error")
        /// 余额为0
        case .balanceEmpty:
            return localLanguage(keyString: "wallet_bank_deposit_balance_empty_error")
        /// 输入金额无效
        case .amountInvalid:
            return localLanguage(keyString: "wallet_bank_deposit_amount_invalid_error")
        /// 余额不足
        case .balanceInsufficient:
            return localLanguage(keyString: "wallet_bank_deposit_balance_insufficient_error")
        /// 金额比最低充值限额低
        case .amountTooLittle:
            return localLanguage(keyString: "wallet_bank_deposit_amount_too_little_error")
        /// 额度不足
        case .quotaInsufficient:
            return localLanguage(keyString: "wallet_bank_deposit_quota_insufficient_error")
        case .dataInvalid:
            return localLanguage(keyString: "wallet_bank_deposit_data_invalid_error")
        }
    }
}
extension LibraWalletError.BankLoanError {
    var localizedDescription: String {
        switch self {
        /// 充值币未开启
        case .tokenUnactivated:
            return localLanguage(keyString: "wallet_bank_loan_token_unactivated_error")
        /// 余额为0
        case .amountEmpty:
            return localLanguage(keyString: "wallet_bank_loan_amount_empty_error")
        /// 输入金额无效
        case .amountInvalid:
            return localLanguage(keyString: "wallet_bank_loan_amount_invalid_error")
        /// 金额比最低充值限额低
        case .amountTooLittle:
            return localLanguage(keyString: "wallet_bank_loan_amount_too_little_error")
        /// 额度不足
        case .quotaInsufficient:
            return localLanguage(keyString: "wallet_bank_loan_quota_insufficient_error")
        /// 数据异常
        case .dataInvalid:
            return localLanguage(keyString: "wallet_bank_loan_data_invalid_error")
        /// 余额不足
        case .disagreeLegal:
            return localLanguage(keyString: "wallet_bank_loan_disagree_legal_error")
        }
    }
}
extension LibraWalletError.BankRepaymentError {
    var localizedDescription: String {
        switch self {
        /// 还贷币未开启
        case .tokenUnactivated:
            return localLanguage(keyString: "wallet_bank_repayment_token_unactivated_error")
        /// 余额为0
        case .amountEmpty:
            return localLanguage(keyString: "wallet_bank_repayment_amount_empty_error")
        /// 输入金额无效
        case .amountInvalid:
            return localLanguage(keyString: "wallet_bank_repayment_amount_invalid_error")
        /// 金额比最低还贷额低
        case .amountTooLittle:
            return localLanguage(keyString: "wallet_bank_repayment_amount_too_little_error")
        case .amountTooLarge:
            return localLanguage(keyString: "wallet_bank_repayment_amount_too_large_error")
        /// 余额不足
        case .balanceInsufficient:
            return localLanguage(keyString: "wallet_bank_repayment_balance_insufficient_error")
        /// 数据异常
        case .dataInvalid:
            return localLanguage(keyString: "wallet_bank_repayment_data_invalid_error")
        }
    }
}
extension LibraWalletError.BankWithdrawError {
    var localizedDescription: String {
        switch self {
        /// 还贷币未开启
        case .tokenUnactivated:
            return localLanguage(keyString: "wallet_bank_withdraw_token_unactivated_error")
        /// 余额为0
        case .amountEmpty:
            return localLanguage(keyString: "wallet_bank_withdraw_amount_empty_error")
        /// 输入金额无效
        case .amountInvalid:
            return localLanguage(keyString: "wallet_bank_withdraw_amount_invalid_error")
        /// 金额太多
        case .amountTooLarge:
            return localLanguage(keyString: "wallet_bank_withdraw_amount_too_large_error")
        /// 数据异常
        case .dataInvalid:
            return localLanguage(keyString: "wallet_bank_withdraw_data_invalid_error")
        }
    }
}
extension LibraWalletError.VerifyMobilePhoneError {
    var localizedDescription: String {
        switch self {
        /// 手机区域未选择
        case .phoneAreaUnselect:
            return localLanguage(keyString: "wallet_verify_mobile_phone_area_unselect_error")
        /// 手机号为空
        case .phoneNumberEmpty:
            return localLanguage(keyString: "wallet_verify_mobile_phone_number_empty_error")
        /// 验证码为空
        case .secureCodeEmpty:
            return localLanguage(keyString: "wallet_verify_mobile_secure_code_empty_error")
        }
    }
}
