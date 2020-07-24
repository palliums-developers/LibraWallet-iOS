//
//  LibraTransactionPayload.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/7/24.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit

struct LibraTransactionPayload {
    enum transactionPayload {
        case writeSet
        case script
        case module
    }
    fileprivate var type: transactionPayload
    fileprivate var writeSet: LibraTransactionWriteSetPayload?
    
    fileprivate var script: LibraTransactionScriptPayload?
    
    fileprivate var module: LibraTransactionModule?
    
    init(type: transactionPayload, writeSet: LibraTransactionWriteSetPayload? = nil, script: LibraTransactionScriptPayload? = nil, module: LibraTransactionModule? = nil) {
        self.type = type
        switch type {
        case .writeSet:
            self.writeSet = writeSet
        case .script:
            self.script = script
        case .module:
            self.module = module
        }
    }
    func serialize() -> Data {
        var result = Data()
        switch type {
        case .writeSet:
            result += writeSet!.serialize()
        case .script:
            result += script!.serialize()
        case .module:
            result += module!.serialize()
        }
        return result
    }
}
