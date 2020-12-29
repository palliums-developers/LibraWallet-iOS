//
//  ViolasAccountMainModel.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/12/29.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit

struct ViolasErrorStatusCode: Codable {
    var StatusCode: Int?
}
struct ViolasErrorDataModel: Codable {
    var code: Int?
    var data: ViolasErrorStatusCode?
    var message: String?
}
struct ViolasRoleDataModel: Codable {
    // 通用
    /// Account type（child_vasp、parent_vasp、designated_dealer、unknown）
    var type: String?
    
    // 父VASP专有
    /// base URL for this parent VASP
    var base_url: String?
    /// key of base url key rotation events for this parent VASP
    var base_url_rotation_events_key: String?
    /// compliance key for this parent VASP
    var compliance_key: String?
    /// key of compliance key rotation events for this parent VASP
    var compliance_key_rotation_events_key: String?
    /// expiration time for this parent VASP
    var expiration_time: UInt64?
    /// human-readable name of this parent VASP
    var human_name: String?
    /// number of children of this parent VASP
    var num_children: UInt?

    // 子VASP账户专有
    /// 父VASP账户地址
    var parent_vasp_address: String?
}
struct ViolasBalanceDataModel: Codable {
    var amount: Int64?
    var currency: String?
}
struct ViolasAccountInfoDataModel: Codable {
    /// Account
    var address: String?
    /// Hex-encoded authentication key for the
    var authentication_key: String?
    /// Balances of all the currencies associated with the
    var balances: [ViolasBalanceDataModel]?
    /// If true, another account has the ability to rotate the authentication key
    var delegated_key_rotation_capability: Bool?
    /// If true, another account has the ability to withdraw funds from this
    var delegated_withdrawal_capability: Bool?
    /// Unique key for the received events stream of this
    var received_events_key: String?
    /// Unique key for the sent events stream of this
    var sent_events_key: String?
    /// The next sequence number for the current
    var sequence_number: UInt64?
    /// Whether this account is frozen or
    var is_frozen: Bool?
    /// One of the following
    var role: ViolasRoleDataModel
}
struct ViolasAccountMainModel: Codable {
    /// 链ID For mainnet: \"MAINNET\" or 1, testnet: \"TESTNET\" or 2, devnet: \"DEVNET\" or 3, local swarm: \"TESTING\" or 4
    var diem_chain_id: Int?
    /// server-side latest ledger version number
    var diem_ledger_version: UInt64?
    /// server-side latest ledger timestamp microseconds
    var diem_ledger_timestampusec: UInt64?
    /// 请求ID
    var id: String?
    /// JSON RPC版本
    var jsonrpc: String?
    /// 数据体
    var result: ViolasAccountInfoDataModel?
    /// 错误
    var error: ViolasErrorDataModel?
}
