//
//  Network.swift
//  LibraWallet
//
//  Created by palliums on 2019/9/5.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit
enum NetworkState {
    case mainnet
    case testnet
    case devnet
    case testing
}
extension NetworkState {
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
struct Network {
    
}
