//
//  LibraWallet.swift
//  LibraWallet
//
//  Created by palliums on 2019/9/5.
//  Copyright © 2019 palliums. All rights reserved.
//

import Foundation
import SwiftEd25519
public final class LibraWallet {
    let seed: Seed
    
    let publicKey: LibraPublicKey
    
    let privateKey: LibraPrivateKey
    
    let keyPairManager: KeyPair
    
    public init (seed: Seed) {
        
        self.keyPairManager = KeyPair.init(seed: seed)
        self.seed = seed
        self.publicKey = LibraPublicKey.init(publicKey: self.keyPairManager.publicKey)
        self.privateKey = LibraPrivateKey.init(privateKey: self.keyPairManager.privateKey)
        
    }
}
