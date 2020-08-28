//
//  ViolasNetwork.swift
//  LibraWallet
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
}
extension ViolasNetworkState {
    public var value: Int {
        switch self {
        case .mainnet:
            return 1
        case .testnet:
            return 2
        case .devnet:
            return 3
        case .testing:
            return 4
        }
    }
}
struct ViolasNetwork {
    
}
