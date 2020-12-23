//
//  DiemGeneralMetadata.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/12/8.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit

enum DiemGeneralMetadataTypes {
    case GeneralMetadataVersion0(DiemGeneralMetadataV0)
}
extension DiemGeneralMetadataTypes {
    public var raw: Data {
        switch self {
        case .GeneralMetadataVersion0:
            return Data.init(Array<UInt8>(hex: "00"))
        }
    }
}
struct DiemGeneralMetadata {
    fileprivate let code: DiemGeneralMetadataTypes
        
    init(code: DiemGeneralMetadataTypes) {
        self.code = code
    }
    func serialize() -> Data {
        var result = Data()
        result += self.code.raw
        switch self.code {
        case .GeneralMetadataVersion0(let value):
            result += value.serialize()
        }
        return result
    }
}
