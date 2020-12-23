//
//  DiemTransactionWrisetPayload.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/7/24.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit
enum DiemWriteSetPayloadCode {
    /// LibraWriteSet, [LibraContractEvent]
    case direct(DiemWriteSet, [DiemContractEvent])
    /// Address, LibraTransactionScriptPayload
    case script(String, DiemTransactionScriptPayload)
}
extension DiemWriteSetPayloadCode {
    public var raw: Data {
        switch self {
        case .direct:
            return Data.init(Array<UInt8>(hex: "00"))
        case .script:
            return Data.init(Array<UInt8>(hex: "01"))
        }
    }
}
struct DiemTransactionWriteSetPayload {
    fileprivate let code: DiemWriteSetPayloadCode

    init(code: DiemWriteSetPayloadCode) {
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
            result += DiemUtils.uleb128Format(length: events.count)
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
