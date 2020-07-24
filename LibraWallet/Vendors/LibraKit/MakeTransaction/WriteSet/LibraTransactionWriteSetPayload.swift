//
//  LibraTransactionWrisetPayload.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/7/24.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit
enum LibraWriteSetPayloadCode {
    case direct
    case script
}
extension LibraWriteSetPayloadCode {
    public var raw: Data {
        switch self {
        case .direct:
            return Data.init(hex: "00")
        case .script:
            return Data.init(hex: "01")
        }
    }
}
struct LibraTransactionWriteSetPayload {
    fileprivate let code: LibraWriteSetPayloadCode
    
    fileprivate let address: String
    
    fileprivate let script: LibraTransactionScriptPayload
    
    fileprivate let writeSet: LibraWriteSet
    
    fileprivate let events: [LibraContractEvent]
    
    init(code: LibraWriteSetPayloadCode, address: String, script: LibraTransactionScriptPayload) {
        self.code = code
        
        self.address = address
        
        self.script = script
        
        self.writeSet = LibraWriteSet.init(accessPaths: [LibraAccessPath]())
        
        self.events = [LibraContractEvent]()
    }
    init(code: LibraWriteSetPayloadCode, writeSet: LibraWriteSet, events: [LibraContractEvent]) {
        self.code = code
        
        self.address = ""
        
        self.script = LibraTransactionScriptPayload.init(code: Data(), typeTags: [LibraTypeTag](), argruments: [LibraTransactionArgument]())
        
        self.writeSet = writeSet
        
        self.events = events
    }
    func serialize() -> Data {
        var result = Data()
        // 追加类型
        result += code.raw
        if code == .direct {
            // 追加writeSet
            result += writeSet.serialize()
            // 追加events长度
            result += LibraUtils.uleb128Format(length: events.count)
            // 追加events数组数据
            for event in events {
                result += event.serialize()
            }
            return result
        } else {
            // 追加address
            result += Data.init(Array<UInt8>(hex: address))
            // 追加script
            result += script.serialize()
            
            
            return result
        }
    }
}
