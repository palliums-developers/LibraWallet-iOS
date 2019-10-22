//
//  BTCManager.swift
//  PalliumsWallet
//
//  Created by palliums on 2019/5/7.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit
//import BitcoinKit
import Moya
struct txsData: Codable {
    var txid: String?
    var output_no: Int?
    var script_asm: String?
    var script_hex: String?
    var value: String?
    var confirmations: Int?
    var time: Int?
}
struct utxoData: Codable {
    var txs: [txsData]?
    var network: String?
    var address: String?
}
struct dataModel: Codable {
    var data: utxoData?
    var status: String?
}
class BTCManager: NSObject {
//    private enum BTCManagerError: Error {
//        case getUnspentUTXOFailed
//        case invalidAddress
//        case signatureError
//        case error(String)
//        case decryptMnemonicFailedError
//    }
//    /// 获取助词数组
//    ///
//    /// - Returns: 助词数组
//    func getMnemonic() -> [String] {
//        do {
//            let mnemonic = try Mnemonic.generate(language: Mnemonic.Language.english)
//            return mnemonic
//
//        } catch {
//            print(error.localizedDescription)
//            return []
//        }
//    }
//    /// 获取钱包对象
//    ///
//    /// - Parameter mnemonic: 助词数组
//    /// - Returns: 钱包对象
//    func getWallet(mnemonic: [String]) -> Wallet {
//        let seed = Mnemonic.seed(mnemonic: mnemonic)
//        let privateKey = HDPrivateKey.init(seed: seed, network: .testnetBTC).privateKey()
//        let wallet = Wallet.init(privateKey: privateKey)
//        return wallet
//    }
//    /// 根据钱包对象对应私钥
//    ///
//    /// - Parameter wallet: 钱包对象
//    /// - Returns: 钱包对应私钥
//    func getWalletPrivateKey(wallet: Wallet) -> String {
//        return wallet.privateKey.toWIF()
//    }
//    /// 根据钱包对象对应公钥
//    ///
//    /// - Parameter wallet: 钱包对象
//    /// - Returns: 钱包对应公钥
//    func getWalletPublicKey(wallet: Wallet) -> String {
//        return wallet.publicKey.raw.hex
//    }
//    /// 根据钱包对象对应地址
//    ///
//    /// - Parameter wallet: 钱包对象
//    /// - Returns: 钱包对应地址
//    func getWalletAddress(wallet: Wallet) -> String {
//        return wallet.publicKey.toLegacy().base58
//    }
//    /// 根据钱包对象地址二维码
//    ///
//    /// - Parameter publicKey: 公钥
//    /// - Returns: 钱包对应地址二维码
//    func getWalletAddressQRCode(address: String) -> UIImage? {
//        return QRCodeGenerator.generate(from: address)
//    }
//    #warning("待完成")
//    //    func getAccountTransactionList(wallet: Wallet) throws -> [Any] {
//    //
//    ////        do {
//    ////            let transectionList = wallet.transactions()
//    ////            if transectionList.count > 0 {
//    ////                return transectionList
//    ////            } else {
//    ////                wallet.reloadTransactions()
//    ////                return wallet.transactions()
//    ////            }
//    ////        } catch {
//    ////            throw error
//    ////        }
//    //    }
//    /// 检查地址有效性
//    ///
//    /// - Parameter address: 地址
//    /// - Returns: 有效性
//    func checkAddressInvalid(address: String?) -> Bool {
//        guard let str = address else {
//            return false
//        }
//        do {
//            _ = try LegacyAddress.init(str)
//            return true
//        } catch {
//            return false
//        }
//    }
//    /// 查询助词有效性
//    ///
//    /// - Parameter mnemonicArray: z助词数组
//    /// - Returns: 有效性
//    func checkMnenoicInvalid(mnemonicArray: [String]) -> Bool {
//        guard mnemonicArray.count != 0 else {
//            return false
//        }
//        let wordList: [String.SubSequence] =  MnenonicWordList.english
//        for i in 0...mnemonicArray.count - 1 {
//            let status = wordList.contains(Substring.init(mnemonicArray[i]))
//            if status == false {
//                return false
//            }
//        }
//        return true
//    }
//    func getTransectionSig(privateKey: PrivateKey, toAddress: String, amount: Double, fee: Double) {
//        let queue = DispatchQueue.init(label: "SendQueue")
//        let semaphore = DispatchSemaphore.init(value: 1)
////        var txString = String.init()
//        queue.async {
//            semaphore.wait()
//            mainProvide.request(.getBTCUnspentCoin("")) { result in
//                switch  result {
//                case let .success(response):
//                    do {
//                        let json = try response.map(dataModel.self)
//                        if let status = json.status, let data = json.data?.txs, status == "success", data.count > 0 {
//                            let tx = self.getTransectionSignature(data: data, privateKey: privateKey, toAddress: toAddress, amount: amount, fee: fee)
////                            txString = tx
//                            print("txhex == \(tx)")
//                            semaphore.signal()
//                        } else {
//                            print("解析失败")
//                            semaphore.signal()
//                        }
//                    } catch {
//                        print("解析异常\(error.localizedDescription)")
//                        semaphore.signal()
//                    }
//                case let .failure(error):
//                    guard error.errorCode != -999 else {
//                        print("网络请求已取消")
//                        return
//                    }
//                    semaphore.signal()
//                }
//            }
//        }
//    }
//    func getUnspentUTXO(address: String, successCallback:@escaping ([txsData]) -> ()) throws {
//        mainProvide.request(.getBTCUnspentCoin("mvgsVUUG62L5KMsFx9TCQuMkC2tRb38fFX")) { result in
//            switch  result {
//            case let .success(response):
//                do {
//                    let json = try response.map(dataModel.self)
//                    if let status = json.status, let data = json.data?.txs, status == "success", data.count > 0 {
//                        successCallback(data)
//                    } else {
//                        throw BTCManagerError.getUnspentUTXOFailed
//                    }
//                } catch {
//                    print("解析异常\(error.localizedDescription)")
//                }
//            case let .failure(error):
//                guard error.errorCode != -999 else {
//                    print("网络请求已取消")
//                    return
//                }
//            }
//        }
//    }
//    func senBitcoin(wallet:Wallet, toAddress:String, amount: Double, fee: Double) throws -> Bool {
//        do {
//            _ = try LegacyAddress.init(toAddress)
//            try getUnspentUTXO(address: "", successCallback: { (result) in
//                print(result)
////                let tx = try getTransectionSignature(prvateKey: wallet.privateKey.toWIF(), toAddress: toAddress, amount: amount, fee: fee)
//            })
//        } catch {
//            print(error.localizedDescription)
//            throw error
//        }
//        //        do {
//        //            let address = try LegacyAddress.init(toAddress)
//        //            try wallet.send(to: address, amount: amount) { (status) in
//        //                print(status)
//        //            }
//        //        } catch {
//        //            print(error.localizedDescription)
//        //            return false
//        //        }
////        let tx = sendBTC(prvateKey: "L3HBeeoi4EpQV1M8J4PYiTHXSfr77vev12NASWcvbGWXZMewdfo6", toAddress: "mp2DTfkHbSDtbgMvtuHRUXDdwe8uLKTkjT", amount: 0.00001, fee: 0.00001906)
////        sendFixedDepositContract(privateKey: "L3HBeeoi4EpQV1M8J4PYiTHXSfr77vev12NASWcvbGWXZMewdfo6", amount: 0.0001, day: 1)
////        redeemFixedDepositContract(privateKey: "L3HBeeoi4EpQV1M8J4PYiTHXSfr77vev12NASWcvbGWXZMewdfo6", contractAddress: "2N278npsufkmJiZRL5T9MxN5yi72P5vGJVh")
//
////        sendDemandDepositContract(privateKey: "L3HBeeoi4EpQV1M8J4PYiTHXSfr77vev12NASWcvbGWXZMewdfo6", amount: 0.0001, day: 1)
////        redeemDemandDepositContract(privateKey: "L3HBeeoi4EpQV1M8J4PYiTHXSfr77vev12NASWcvbGWXZMewdfo6", contractAddress: "2N5eER6WwQYz7PZmkGJKwiKUR6ru8QPmdn1")
//        return true
//    }
//
//    func sendFixedDepositContract(privateKey: PrivateKey, amount: Double, day: UInt) {
////        let personalPrivateKey = try! PrivateKey.init(wif: privateKey)
////        //转账人公钥
////        let personalPublicKey = privateKey.publicKey()
////        let address = personalPublicKey.toLegacy().base58
////        print(address)
////
////        let queue = DispatchQueue.init(label: "SendQueue")
////
////        let semaphore = DispatchSemaphore.init(value: 1)
////        var txString = String.init()
////        queue.async {
////            semaphore.wait()
////            mainProvide.request(.getBTCUnspentCoin("mvgsVUUG62L5KMsFx9TCQuMkC2tRb38fFX")) { result in
////                switch  result {
////                case let .success(response):
////                    do {
////                        let json = try response.map(dataModel.self)
////                        if let status = json.status, let data = json.data?.txs, status == "success", data.count > 0 {
////                            let (tx, _, _) = self.setFixedContract(data: data, privateKey: privateKey, amount: amount, day: day)
////                            txString = tx
////                            print("txhex == \(tx)")
////                            semaphore.signal()
////                        } else {
////                            print("解析失败")
////                            semaphore.signal()
////                        }
////                    } catch {
////                        print("解析异常\(error.localizedDescription)")
////                        semaphore.signal()
////                    }
////                case let .failure(error):
////                    guard error.localizedDescription != "已取消" else {
////                        //                    printLog(message: "网络请求已取消")
////                        return
////                    }
////                    semaphore.signal()
////                }
////            }
////        }
////        queue.async {
////            semaphore.wait()
////            guard txString.count > 0 else {
////                print("签名失败")
////                return
////            }
////            semaphore.signal()
////        }
////        queue.async {
////            semaphore.wait()
////            mainProvide.request(.sendTransaction("txString")) { result in
////                switch  result {
////                case let .success(response):
////                    if let json = try? response.mapJSON() as? [String: Any] {
////                        print(json)
////                        //                    semaphore.signal()
////                    } else {
////                        print(response.description)
////                        //                    semaphore.signal()
////                    }
////                case let .failure(error):
////                    guard error.localizedDescription != "已取消" else {
////                        //                    printLog(message: "网络请求已取消")
////                        return
////                    }
////                    //                semaphore.signal()
////                }
////            }
////        }
//    }
//    func redeemFixedDepositContract(privateKey: PrivateKey, contractAddress: String) {
//        let queue = DispatchQueue.init(label: "SendQueue")
//
//        let semaphore = DispatchSemaphore.init(value: 1)
//        var txString = String.init()
//        queue.async {
//            semaphore.wait()
//            mainProvide.request(.getBTCUnspentCoin(contractAddress)) { result in
//                switch  result {
//                case let .success(response):
//                    do {
//                        let json = try response.map(dataModel.self)
//                        if let status = json.status, let data = json.data?.txs, status == "success", data.count > 0 {
//                            let (tx, _) = self.withdrawFixedContract(data: data, privateKey: privateKey)
//                            txString = tx
//                            print("txhex == \(tx)")
//                            semaphore.signal()
//                        } else {
//                            print("解析失败")
//                            semaphore.signal()
//                        }
//                    } catch {
//                        print("解析异常\(error.localizedDescription)")
//                        semaphore.signal()
//                    }
//                case let .failure(error):
//                    guard error.errorCode != -999 else {
//                        print("网络请求已取消")
//                        return
//                    }
//                    semaphore.signal()
//                }
//            }
//        }
//        queue.async {
//            semaphore.wait()
//            guard txString.count > 0 else {
//                print("签名失败")
//                semaphore.signal()
//                return
//            }
//        }
//        queue.async {
//            semaphore.wait()
//            mainProvide.request(.sendTransaction("txString")) { result in
//                switch  result {
//                case let .success(response):
//                    if let json = try? response.mapJSON() as? [String: Any] {
//                        print(json)
//                        //                    semaphore.signal()
//                    } else {
//                        print(response.description)
//                        //                    semaphore.signal()
//                    }
//                case let .failure(error):
//                    guard error.errorCode != -999 else {
//                        print("网络请求已取消")
//                        return
//                    }
//                    //                semaphore.signal()
//                }
//            }
//        }
//    }
//    func sendDemandDepositContract(privateKey: PrivateKey, amount: Double, day: UInt) {
////        let personalPrivateKey = try! PrivateKey.init(wif: privateKey)
//        //转账人公钥
////        let personalPublicKey = privateKey.publicKey()
////        let address = personalPublicKey.toLegacy().base58
////        print(address)
////
////        let queue = DispatchQueue.init(label: "SendQueue")
////
////        let semaphore = DispatchSemaphore.init(value: 1)
////        var txString = String.init()
////        queue.async {
////            semaphore.wait()
////            mainProvide.request(.getBTCUnspentCoin("mvgsVUUG62L5KMsFx9TCQuMkC2tRb38fFX")) { result in
////                switch  result {
////                case let .success(response):
////                    do {
////                        let json = try response.map(dataModel.self)
////                        if let status = json.status, let data = json.data?.txs, status == "success", data.count > 0 {
//////                            let tx = self.setFixedContract(data: data, prvateKey: privateKey, amount: amount, day: day)
////                            let (tx, _, _,_) = self.setDemandContract(data: data, privateKey: privateKey, amount: amount, day: day)
////                            txString = tx
////                            print("txhex == \(tx)")
////                            semaphore.signal()
////                        } else {
////                            print("解析失败")
////                            semaphore.signal()
////                        }
////                    } catch {
////                        print("解析异常\(error.localizedDescription)")
////                        semaphore.signal()
////                    }
////                case let .failure(error):
////                    guard error.localizedDescription != "已取消" else {
////                        //                    printLog(message: "网络请求已取消")
////                        return
////                    }
////                    semaphore.signal()
////                }
////            }
////        }
////        queue.async {
////            semaphore.wait()
////            guard txString.count > 0 else {
////                print("签名失败")
////                return
////            }
////            semaphore.signal()
////        }
////        queue.async {
////            semaphore.wait()
////            mainProvide.request(.sendTransaction("txString")) { result in
////                switch  result {
////                case let .success(response):
////                    if let json = try? response.mapJSON() as? [String: Any] {
////                        print(json)
////                                            semaphore.signal()
////                    } else {
////                        print(response.description)
////                                            semaphore.signal()
////                    }
////                case let .failure(error):
////                    guard error.localizedDescription != "已取消" else {
////                        //                    printLog(message: "网络请求已取消")
////                        return
////                    }
////                                    semaphore.signal()
////                }
////            }
////        }
//    }
//    func redeemDemandDepositContract(privateKey: PrivateKey, contractAddress: String) {
////        let queue = DispatchQueue.init(label: "SendQueue")
////
////        let semaphore = DispatchSemaphore.init(value: 1)
////        var txString = String.init()
////        queue.async {
////            semaphore.wait()
////            mainProvide.request(.getBTCUnspentCoin(contractAddress)) { result in
////                switch  result {
////                case let .success(response):
////                    do {
////                        let json = try response.map(dataModel.self)
////                        if let status = json.status, let data = json.data?.txs, status == "success", data.count > 0 {
////                            let tx = self.withdrawDemandContract(data: data, privateKey: privateKey, oracleSignature: "", expire: false, locktime: 1)
////                            txString = tx
////                            print("txhex == \(tx)")
////                            semaphore.signal()
////                        } else {
////                            print("解析失败")
////                            semaphore.signal()
////                        }
////                    } catch {
////                        print("解析异常\(error.localizedDescription)")
////                        semaphore.signal()
////                    }
////                case let .failure(error):
////                    guard error.localizedDescription != "已取消" else {
////                        //                    printLog(message: "网络请求已取消")
////                        return
////                    }
////                    semaphore.signal()
////                }
////            }
////        }
////        queue.async {
////            semaphore.wait()
////            guard txString.count > 0 else {
////                print("签名失败")
////                semaphore.signal()
////                return
////            }
////        }
////        queue.async {
////            semaphore.wait()
////            mainProvide.request(.sendTransaction("txString")) { result in
////                switch  result {
////                case let .success(response):
////                    if let json = try? response.mapJSON() as? [String: Any] {
////                        print(json)
////                                            semaphore.signal()
////                    } else {
////                        print(response.description)
////                                            semaphore.signal()
////                    }
////                case let .failure(error):
////                    guard error.localizedDescription != "已取消" else {
////                        //                    printLog(message: "网络请求已取消")
////                        return
////                    }
////                                    semaphore.signal()
////                }
////            }
////        }
//    }
//    func reloadAccontBalance(wallet: Wallet){
//        //        wallet.reloadBalance()
//
//    }
}
