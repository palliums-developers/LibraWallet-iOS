//
//  LibraWallet.swift
//  LibraWallet
//
//  Created by palliums on 2019/9/5.
//  Copyright © 2019 palliums. All rights reserved.
//

import Foundation

public final class LibraWallet {
    let seed: Data
    
    let LibraBaseURL = "18.220.66.235:34042"
    
    public init (seed: Data)  {
        self.seed = seed
    }
    func publicKey() -> LibraPublicKey {
        return LibraPublicKey.init(dk: self.seed)
    }
    func signTransaction() {
        
    }
}
