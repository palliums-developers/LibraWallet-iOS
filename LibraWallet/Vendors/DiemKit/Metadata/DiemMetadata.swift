//
//  DiemMetadata.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/12/8.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit

enum DiemMetadataTypes {
    case Undefined
    case GeneralMetadata(DiemGeneralMetadata)
    case TravelRuleMetadata(DiemTravelRuleMetadata)
    case UnstructuredBytesMetadata(DiemUnstructuredBytesMetadata)
}
extension DiemMetadataTypes {
    public var raw: Data {
        switch self {
        case .Undefined:
            return Data.init(Array<UInt8>(hex: "00"))
        case .GeneralMetadata:
            return Data.init(Array<UInt8>(hex: "01"))
        case .TravelRuleMetadata:
            return Data.init(Array<UInt8>(hex: "02"))
        case .UnstructuredBytesMetadata:
            return Data.init(Array<UInt8>(hex: "02"))
        }
    }
}
struct DiemMetadata {
    fileprivate let code: DiemMetadataTypes
        
    init(code: DiemMetadataTypes) {
        self.code = code
        
    }
    func serialize() -> Data {
        var result = Data()
        result += self.code.raw
        switch self.code {
        case .Undefined:
            break
        case .GeneralMetadata(let value):
            result += value.serialize()
        case .TravelRuleMetadata(let value):
            result += value.serialize()
        case .UnstructuredBytesMetadata(let value):
            result += value.serialize()
        }
        return result
    }
}




