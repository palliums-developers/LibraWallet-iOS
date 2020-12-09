//
//  LibraUnstructuredBytesMetadata.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/12/8.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit

enum LibraUnstructuredBytesMetadataTypes {
    case metadata(Data)
}
extension LibraUnstructuredBytesMetadataTypes {
    public var raw: Data {
        switch self {
        case .metadata:
            return Data.init(Array<UInt8>(hex: "00"))
        }
    }
}
struct LibraUnstructuredBytesMetadata {
    fileprivate let code: LibraUnstructuredBytesMetadataTypes
        
    init(code: LibraUnstructuredBytesMetadataTypes) {
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
