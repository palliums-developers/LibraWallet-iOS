//
//  ViolasTransactionPayload.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/8/28.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit

enum ViolasTransactionPayloadType {
    case writeSet(ViolasTransactionWriteSetPayload)
    case script(ViolasTransactionScriptPayload)
    case module(ViolasTransactionModulePayload)
}
extension ViolasTransactionPayloadType {
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
struct ViolasTransactionPayload {

    fileprivate var payload: ViolasTransactionPayloadType

    init(payload: ViolasTransactionPayloadType) {
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
