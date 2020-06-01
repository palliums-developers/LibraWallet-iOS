//
//  ViolasCommon.swift
//  LibraWallet
//
//  Created by palliums on 2019/12/13.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit
/// Violas签名盐
let ViolasSignSalt  = "RawTransaction::libra_types::transaction@@$$LIBRA$$@@"
/// Violas计算助记词盐
let ViolasMnemonicSalt = "LIBRA WALLET: mnemonic salt prefix$LIBRA"
//最新
#if PUBLISH_VERSION
    ////Tag = 9.0
    /// Vtoken转账(libra_peer_to_peer_transfer.mv)
    let ViolasScriptCode = "a11ceb0b010007014600000004000000034a0000000c000000045600000002000000055800000009000000076100000029000000068a00000010000000099a0000001200000000000001010200010101000300010101000203050a020300010900063c53454c463e0c4c696272614163636f756e740f7061795f66726f6d5f73656e646572046d61696e00000000000000000000000000000000010000ffff030005000a000b010a023e0002"
/// 开启代币ProgramCode(publish.mv)
   let ViolasPublishScriptCode = "a11ceb0b010006013d0000000400000003410000000a000000054b00000004000000074f00000020000000066f00000010000000097f0000000e0000000000000101020001000003000100010a0200063c53454c463e0b56696f6c6173546f6b656e077075626c697368046d61696e7257c2417e4d1038e1817c8f283ace2e010000ffff030003000b00120002"
/// Violas代币兑换ProgramCode(transfer_with_data.mv)
   let ViolasStableCoinScriptWithDataCode = "a11ceb0b010006013d0000000400000003410000000a000000054b000000070000000752000000210000000673000000100000000983000000140000000000000101020001000003000100040305030a0200063c53454c463e0b56696f6c6173546f6b656e087472616e73666572046d61696e7257c2417e4d1038e1817c8f283ace2e010000ffff030006000a000a010a020b03120002"
#else
    //Tag = 9.0
    let ViolasScriptCode = "a11ceb0b010007014600000004000000034a0000000c000000045600000002000000055800000009000000076100000029000000068a00000010000000099a0000001200000000000001010200010101000300010101000203050a020300010900063c53454c463e0c4c696272614163636f756e740f7061795f66726f6d5f73656e646572046d61696e00000000000000000000000000000000010000ffff030005000a000b010a023e0002"
    let ViolasPublishScriptCode = "a11ceb0b010006013d0000000400000003410000000a000000054b00000004000000074f00000020000000066f00000010000000097f0000000e0000000000000101020001000003000100010a0200063c53454c463e0b56696f6c6173546f6b656e077075626c697368046d61696e7257c2417e4d1038e1817c8f283ace2e010000ffff030003000b00120002"
    let ViolasStableCoinScriptWithDataCode = "a11ceb0b010006013d0000000400000003410000000a000000054b000000070000000752000000210000000673000000100000000983000000140000000000000101020001000003000100040305030a0200063c53454c463e0b56696f6c6173546f6b656e087472616e73666572046d61696e7257c2417e4d1038e1817c8f283ace2e010000ffff030006000a000a010a020b03120002"
#endif
