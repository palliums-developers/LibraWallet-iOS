//
//  LibraPrivateKey.swift
//  LibraWallet
//
//  Created by palliums on 2019/9/5.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit
import SwiftEd25519
public struct LibraPrivateKey {
    
    let raw: Data
    
    public init (privateKey: PrivateKey) {
        self.raw = Data.init(bytes: privateKey.bytes, count: privateKey.bytes.count)
    }
    
    func signTransaction(transaction: Types_RawTransaction, wallet: LibraWallet) throws -> Types_SignedTransaction {
        do {
            // 待签名交易
            let raw = try transaction.serializedData()
            // 交易第一部分(盐sha3计算结果)
            var sha3Data = Data.init(hex: signTransactionSalt)
            // 交易第二部分(追加带签名交易)
            sha3Data.append(raw.bytes, count: (raw.bytes.count))
            
            let sign = wallet.keyPairManager.sign(sha3Data.sha3(.sha256).bytes)
            
            var signedTransation = Types_SignedTransaction.init()
            signedTransation.rawTxnBytes = raw
            signedTransation.senderSignature = Data.init(bytes: sign, count: sign.count)
            signedTransation.senderPublicKey = wallet.publicKey.raw
            
            return signedTransation

        } catch {
            throw error
        }
    }
}
