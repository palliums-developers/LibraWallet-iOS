//
//  LibraGeneralMetadata.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/12/8.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit

enum LibraGeneralMetadataTypes {
    case GeneralMetadataVersion0(LibraGeneralMetadataV0)
}
extension LibraGeneralMetadataTypes {
    public var raw: Data {
        switch self {
        case .GeneralMetadataVersion0:
            return Data.init(Array<UInt8>(hex: "00"))
        }
    }
}
struct LibraGeneralMetadata {
    fileprivate let code: LibraGeneralMetadataTypes
        
    init(code: LibraGeneralMetadataTypes) {
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
