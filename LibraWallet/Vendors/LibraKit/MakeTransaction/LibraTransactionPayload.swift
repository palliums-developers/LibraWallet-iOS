//
//  LibraTransactionPayload.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/7/24.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit
enum transactionPayload {
    case writeSet(LibraTransactionWriteSetPayload)
    case script(LibraTransactionScriptPayload)
    case module(LibraTransactionModulePayload)
}
extension transactionPayload {
    public var raw: Data {
        switch self {
        case .writeSet:
            return Data.init(Array<UInt8>(hex: "00"))
        case .script:
            return Data.init(Array<UInt8>(hex: "01"))
        case .module:
            return Data.init(Array<UInt8>(hex: "02"))
        }
    }
}
struct LibraTransactionPayload {

    fileprivate var payload: transactionPayload

    init(payload: transactionPayload) {
        self.payload = payload
    }
    func serialize() -> Data {
        var result = Data()
        result += payload.raw
        switch payload {
        case .writeSet(let writeSet):
            result += writeSet.serialize()
        case .script(let script):
            result += script.serialize()
        case .module(let module):
            result += module.serialize()
        }
        return result
    }
}
