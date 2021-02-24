//
//  DiemNetwork.swift
//  LibraWallet
//
//  Created by palliums on 2019/9/5.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit

enum DiemNetworkState {
    case mainnet
    case testnet
    case devnet
    case testing
    case premainnet
}
extension DiemNetworkState {
    public var chainId: Int {
        switch self {
        case .mainnet:
            return 1
        case .testnet:
            return 2
        case .devnet:
            return 3
        case .testing:
            return 4
        case .premainnet:
            return 5
        }
    }
    public var chainURL: String {
        switch self {
        case .mainnet:
            return "https://client.testnet.diem.com"
        case .testnet:
            return "https://client.testnet.diem.com"
        case .devnet:
            return "https://client.testnet.diem.com"
        case .testing:
            return "https://client.testnet.diem.com"
        case .premainnet:
            return "https://client.testnet.diem.com"
        }
    }
    public var addressPrefix: String {
        switch self {
        case .mainnet:
            return "dm"
        case .testnet:
            return "tdm"
        case .devnet:
            return "ddm"
        case .testing:
            return "tdm"
        case .premainnet:
            return "pdm"
        }
    }
}
