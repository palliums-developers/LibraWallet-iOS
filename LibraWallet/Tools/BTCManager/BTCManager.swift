//
//  BTCManager.swift
//  PalliumsWallet
//
//  Created by palliums on 2019/5/7.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit
import BitcoinKit
import Moya
import BigInt
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
    private enum BTCManagerError: Error {
        case getUnspentUTXOFailed
        case invalidAddress
        case signatureError
        case error(String)
        case decryptMnemonicFailedError
    }
    /// 获取助词数组
    ///
    /// - Returns: 助词数组
    func getMnemonic() -> [String] {
        do {
            let mnemonic = try Mnemonic.generate(strength: .default, language: Mnemonic.Language.english)
            return mnemonic

        } catch {
            print(error.localizedDescription)
            return []
        }
    }
    /// 获取钱包对象
    ///
    /// - Parameter mnemonic: 助词数组
    /// - Returns: 钱包对象
    func getWallet(mnemonic: [String]) -> HDWallet {
        let seed = try! Mnemonic.seed(mnemonic: mnemonic)
//        let privateKey = HDPrivateKey.init(seed: seed, network: .testnetBTC).privateKey()
        let wallet = HDWallet.init(seed: seed, externalIndex: 0, internalIndex: 0, network: .testnetBTC)
        return wallet
    }
    /// 根据钱包对象对应地址
    ///
    /// - Parameter wallet: 钱包对象
    /// - Returns: 钱包对应地址
    func getWalletAddress(wallet: HDWallet) -> String {
        return wallet.address.qrcodeString
    }
    /// 根据钱包对象地址二维码
    ///
    /// - Parameter publicKey: 公钥
    /// - Returns: 钱包对应地址二维码
    func getWalletAddressQRCode(address: String) -> UIImage? {
        return QRCodeGenerator.generate(from: address)
    }
    /// 检查地址有效性
    ///
    /// - Parameter address: 地址
    /// - Returns: 有效性
    public static func isValidBTCAddress(address: String?) -> Bool {
        guard let str = address else {
            return false
        }
        let data = Base58Check.decode(str)
        guard data?.isEmpty == false else {
            return false
        }
        return true
    }
    func getBTCToVBTCScript(address: String, tokenContract: String) -> Data {
        var data = Data()
        data += "violas".data(using: .utf8)!
        data += UInt16(0x0000)
        data += UInt16(0x3000).bigEndian
        data += Data.init(Array<UInt8>(hex: (address)))
        data += UInt64(20200113201).bigEndian
        data += Data.init(Array<UInt8>(hex: (tokenContract)))
        print(data.hex)
        return data
    }
    func getData(script: Data) -> Data {
        var scriptData: Data = Data()
        scriptData += OpCode.OP_RETURN
        scriptData += OpCode.OP_PUSHDATA1
        scriptData += getLengthData(length: script.count, appendBytesCount: 1)
        scriptData += script
        return scriptData
    }
    private func getLengthData(length: Int, appendBytesCount: Int) -> Data {
        var newData = Data()
        let lengthData = BigUInt(length).serialize()
        // 补全长度
        for _ in 0..<(appendBytesCount - lengthData.count) {
            newData.append(Data.init(hex: "00"))
        }
        // 追加原始数据
        newData.append(lengthData)
        // 倒序输出
        let reversedAmount = newData.bytes.reversed()
        return Data() + reversedAmount
    }
    /// 查询助词有效性
    ///
    /// - Parameter mnemonicArray: z助词数组
    /// - Returns: 有效性
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

}
