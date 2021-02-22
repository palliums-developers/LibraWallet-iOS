//
//  DiemUnstructuredBytesMetadata.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/12/8.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit

enum DiemUnstructuredBytesMetadataTypes {
    case metadata(Data)
}
extension DiemUnstructuredBytesMetadataTypes {
    public var raw: Data {
        switch self {
        case .metadata:
            return Data.init(Array<UInt8>(hex: "00"))
        }
    }
}
struct DiemUnstructuredBytesMetadata {
    fileprivate let code: DiemUnstructuredBytesMetadataTypes
        
    init(code: DiemUnstructuredBytesMetadataTypes) {
        self.code = code
    }
    func serialize() -> Data {
        var result = Data()
        result += self.code.raw
        switch self.code {
        case .metadata(let value):
            result += value
        }
        return result
    }
}
