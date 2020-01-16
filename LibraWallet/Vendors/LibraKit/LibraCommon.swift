//
//  LibraCommon.swift
//  LibraWallet
//
//  Created by palliums on 2019/12/18.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit

/// Violas签名盐
let LibraSignSalt  = "RawTransaction::libra_types::transaction@@$$LIBRA$$@@"
//let violasSignSalt  = "RawTransaction@@$$LIBRA$$@@"

/// Violas计算助记词盐
let LibraMnemonicSalt = "LIBRA WALLET: mnemonic salt prefix$LIBRA"
//Libra交易盐(libra_peer_to_peer_transfer.mv)
let libraProgramCode = "{\"code\":[161,28,235,11,1,0,7,1,70,0,0,0,4,0,0,0,3,74,0,0,0,6,0,0,0,12,80,0,0,0,6,0,0,0,13,86,0,0,0,6,0,0,0,5,92,0,0,0,41,0,0,0,4,133,0,0,0,32,0,0,0,7,165,0,0,0,15,0,0,0,0,0,0,1,0,2,0,1,3,0,2,0,2,5,3,0,3,2,5,3,3,0,6,60,83,69,76,70,62,12,76,105,98,114,97,65,99,99,111,117,110,116,4,109,97,105,110,15,112,97,121,95,102,114,111,109,95,115,101,110,100,101,114,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,2,0,4,0,11,0,11,1,18,1,1,2],\"args\":[]}"
