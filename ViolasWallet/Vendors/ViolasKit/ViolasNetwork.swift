//
//  ViolasNetwork.swift
//  ViolasWallet
//
//  Created by palliums on 2019/12/13.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit

enum ViolasNetworkState {
    case mainnet
    case testnet
    case devnet
    case testing
    case premainnet
}
extension ViolasNetworkState {
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
            return "https://ac.testnet.violas.io"
        case .testnet:
            return "https://ab.testnet.violas.io"
        case .devnet:
            return "https://ab.testnet.violas.io"
        case .testing:
            return "https://ab.testnet.violas.io"
        case .premainnet:
            return "https://ac.testnet.violas.io"
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
