//
//  DiemCoinTradeMetadata.swift
//  LibraWallet
//
//  Created by wangyingdong on 2021/4/2.
//  Copyright © 2021 palliums. All rights reserved.
//

import UIKit

enum DiemCoinTradeMetadataTypes {
    case CoinTradeMetadataV0(DiemCoinTradeMetadataV0)
}
extension DiemCoinTradeMetadataTypes {
    public var raw: Data {
        switch self {
        case .CoinTradeMetadataV0:
            return Data.init(Array<UInt8>(hex: "00"))
        }
    }
}
struct DiemCoinTradeMetadata {
    fileprivate let code: DiemCoinTradeMetadataTypes
        
    init(code: DiemCoinTradeMetadataTypes) {
        self.code = code
    }
    func serialize() -> Data {
        var result = Data()
        result += self.code.raw
        switch self.code {
        case .CoinTradeMetadataV0(let value):
            result += value.serialize()
        }
        return result
    }
}
