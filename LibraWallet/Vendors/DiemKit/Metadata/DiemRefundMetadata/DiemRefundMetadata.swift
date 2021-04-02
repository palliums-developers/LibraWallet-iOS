//
//  DiemRefundMetadata.swift
//  LibraWallet
//
//  Created by wangyingdong on 2021/4/2.
//  Copyright © 2021 palliums. All rights reserved.
//

import UIKit

enum DiemRefundMetadataTypes {
    case RefundMetadataV0(DiemRefundMetadataV0)
}
extension DiemRefundMetadataTypes {
    public var raw: Data {
        switch self {
        case .RefundMetadataV0:
            return Data.init(Array<UInt8>(hex: "00"))
        }
    }
}
struct DiemRefundMetadata {
    fileprivate let code: DiemRefundMetadataTypes
        
    init(code: DiemRefundMetadataTypes) {
        self.code = code
    }
    func serialize() -> Data {
        var result = Data()
        result += self.code.raw
        switch self.code {
        case .RefundMetadataV0(let value):
            result += value.serialize()
        }
        return result
    }
}
