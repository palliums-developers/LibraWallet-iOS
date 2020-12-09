//
//  LibraTravelRuleMetadata.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/12/8.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit

enum LibraTravelRuleMetadataTypes {
    case TravelRuleMetadataVersion0(LibraTravelRuleMetadataV0)
}
extension LibraTravelRuleMetadataTypes {
    public var raw: Data {
        switch self {
        case .TravelRuleMetadataVersion0:
            return Data.init(Array<UInt8>(hex: "00"))
        }
    }
}
struct LibraTravelRuleMetadata {
    fileprivate let code: LibraTravelRuleMetadataTypes
        
    init(code: LibraTravelRuleMetadataTypes) {
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
