//
//  ViolasTransactionWriteSetPayload.swift
//  LibraWallet
//
//  Created by palliums on 2019/12/13.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit
enum ViolasWriteSetPayloadCode {
    /// ViolasWriteSet, [ViolasContractEvent]
    case direct(ViolasWriteSet, [ViolasContractEvent])
    /// Address, ViolasTransactionScriptPayload
    case script(String, ViolasTransactionScriptPayload)
}
extension ViolasWriteSetPayloadCode {
    public var raw: Data {
        switch self {
        case .direct:
            return Data.init(Array<UInt8>(hex: "00"))
        case .script:
            return Data.init(Array<UInt8>(hex: "01"))
        }
    }
}
struct ViolasTransactionWriteSetPayload {
    fileprivate let code: ViolasWriteSetPayloadCode

    init(code: ViolasWriteSetPayloadCode) {
        self.code = code
    }
    func serialize() -> Data {
        var result = Data()
        // 追加类型
        result += code.raw
        switch code {
        case .direct(let writeSet, let events):
            // 追加writeSet
            result += writeSet.serialize()
            // 追加events长度
            result += ViolasUtils.uleb128Format(length: events.count)
            // 追加events数组数据
            for event in events {
                result += event.serialize()
            }
            return result
        case .script(let address, let script):
            // 追加address
            result += Data.init(Array<UInt8>(hex: address))
            // 追加script
            result += script.serialize()
            return result
        }
    }
}
