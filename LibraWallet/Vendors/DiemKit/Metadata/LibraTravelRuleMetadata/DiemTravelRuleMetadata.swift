//
//  DiemTravelRuleMetadata.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/12/8.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit

enum DiemTravelRuleMetadataTypes {
    case TravelRuleMetadataVersion0(DiemTravelRuleMetadataV0)
}
extension DiemTravelRuleMetadataTypes {
    public var raw: Data {
        switch self {
        case .TravelRuleMetadataVersion0:
            return Data.init(Array<UInt8>(hex: "00"))
        }
    }
}
struct DiemTravelRuleMetadata {
    fileprivate let code: DiemTravelRuleMetadataTypes
        
    init(code: DiemTravelRuleMetadataTypes) {
        self.code = code
    }
    func serialize() -> Data {
        var result = Data()
        result += self.code.raw
        switch self.code {
        case .TravelRuleMetadataVersion0(let value):
            result += value.serialize()
        }
        return result
    }
}
