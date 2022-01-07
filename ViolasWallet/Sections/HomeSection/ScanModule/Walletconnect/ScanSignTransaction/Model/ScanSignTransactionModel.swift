//
//  ScanSignTransactionModel.swift
//  ViolasWallet
//
//  Created by wangyingdong on 2020/5/21.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit
import Moya
class ScanSignTransactionModel: NSObject {
    private var requests: [Cancellable] = []
    @objc dynamic var dataDic: NSMutableDictionary = [:]
    private var sequenceNumber: Int?
    func signMessage(message: String,  mnemonic: [String]) {
        let semaphore = DispatchSemaphore.init(value: 1)
        let queue = DispatchQueue.init(label: "SendQueue")
        queue.async {
            semaphore.wait()
            do {
                let signature = try ViolasManager.getSignMessage(mnemonic: mnemonic, message: Data.init(Array<UInt8>(hex: message)))
                DispatchQueue.main.async(execute: {
                    let data = setKVOData(type: "SignMessage", data: signature)
                    self.setValue(data, forKey: "dataDic")
                })
                
            } catch {
                print(error.localizedDescription)
                DispatchQueue.main.async(execute: {
                    let data = setKVOData(error: LibraWalletError.error(error.localizedDescription), type: "SignMessage")
                    self.setValue(data, forKey: "dataDic")
                })
            }
            semaphore.signal()
        }
    }
    deinit {
        requests.forEach { cancellable in
            cancellable.cancel()
        }
        requests.removeAll()
        print("ScanSendTransactionModel销毁了")
    }
}
