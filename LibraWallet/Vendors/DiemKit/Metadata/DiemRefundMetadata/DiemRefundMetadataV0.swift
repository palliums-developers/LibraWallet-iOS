//
//  DiemRefundMetadataV0.swift
//  LibraWallet
//
//  Created by wangyingdong on 2021/4/2.
//  Copyright © 2021 palliums. All rights reserved.
//

import UIKit

enum RefundReason {
    case OtherReason
    case InvalidSubaddress
    case UserInitiatedPartialRefund
    case UserInitiatedFullRefund
}
extension RefundReason {
    public var raw: Data {
        switch self {
        case .OtherReason:
            return Data.init(Array<UInt8>(hex: "00"))
        case .InvalidSubaddress:
            return Data.init(Array<UInt8>(hex: "01"))
        case .UserInitiatedPartialRefund:
            return Data.init(Array<UInt8>(hex: "02"))
        case .UserInitiatedFullRefund:
            return Data.init(Array<UInt8>(hex: "03"))
        }
    }
}
struct DiemRefundMetadataV0 {
    fileprivate let transaction_version: UInt64
    
    fileprivate let reason: RefundReason

    init(transaction_version: UInt64, reason: RefundReason) {
        
        self.transaction_version = transaction_version
        
        self.reason = reason
    }
    func serialize() -> Data {
        var result = Data()
        //
        result += DiemUtils.getLengthData(length: NSDecimalNumber.init(value: self.transaction_version).uint64Value, appendBytesCount: 8)
        result += self.reason.raw
        return result
    }
}
