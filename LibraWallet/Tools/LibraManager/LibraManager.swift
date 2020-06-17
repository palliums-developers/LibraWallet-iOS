//
//  LibraManager.swift
//  LibraWallet
//
//  Created by palliums on 2019/11/11.
//  Copyright © 2019 palliums. All rights reserved.
//

import Foundation
import BigInt
struct LibraManager {
    /// 获取助词数组
    ///
    /// - Returns: 助词数组
    public static func getLibraMnemonic() throws -> [String] {
        do {
            let mnemonic = try LibraMnemonic.generate(strength: .default, language: .english)
            return mnemonic
        } catch {
            print(error.localizedDescription)
            throw error
        }
    }
    /// 获取Libra钱包对象
    ///
    /// - Parameter mnemonic: 助词数组
    /// - Returns: 钱包对象
    public static func getWallet(mnemonic: [String]) throws -> LibraHDWallet {
        do {
            let seed = try LibraMnemonic.seed(mnemonic: mnemonic)
            let wallet = try LibraHDWallet.init(seed: seed, depth: 0)
            return wallet
        } catch {
            throw error
        }
    }
    /// 校验地址是否有效
    /// - Parameter address: 地址
    public static func isValidLibraAddress(address: String) -> Bool {
        guard (address.count == 32 || address.count == 64)  else {
            // 位数异常
            return false
        }
        let email = "^[A-Za-z0-9]+$"
        let regextestmobile = NSPredicate(format: "SELF MATCHES %@",email)
        if (regextestmobile.evaluate(with: address) == true) {
            return true
        } else {
            return false
        }
    }
    /// 分割地址
    /// - Parameter address: 原始地址
    /// - Throws: 分割错误
    /// - Returns: （授权KEY， 地址）
    public static func splitAddress(address: String) throws -> (String, String) {
        guard isValidLibraAddress(address: address) else {
            throw LibraWalletError.error("Invalid Address")
        }
        if address.count == 64 {
            let authenticatorKey = address.prefix(address.count / 2)
            let shortAddress = address.suffix(address.count / 2)
            return ("\(authenticatorKey)", "\(shortAddress)")
        } else {
            return ("", address)
        }
    }
}
extension LibraManager {
    /// 获取Libra交易Hex
    /// - Parameters:
    ///   - sendAddress: 发送地址
    ///   - receiveAddress: 接收地址
    ///   - amount: 数量
    ///   - fee: 手续费
    ///   - mnemonic: 助记词
    ///   - sequenceNumber: 序列码
    public static func getNormalTransactionHex(sendAddress: String, receiveAddress: String, amount: Double, fee: Double, mnemonic: [String], sequenceNumber: Int, module: String) throws -> String {
        do {
            let wallet = try LibraManager.getWallet(mnemonic: mnemonic)
            let (_, address) = try LibraManager.splitAddress(address: receiveAddress)
            // 拼接交易
//            let argument0 = LibraTransactionArgument.init(code: .U8Vector,
//                                                          value: "")
            let argument0 = LibraTransactionArgument.init(code: .Address,
                                                          value: address)
            let argument1 = LibraTransactionArgument.init(code: .U64,
                                                          value: "\(Int(amount * 1000000))")
            // metadata
            let argument2 = LibraTransactionArgument.init(code: .U8Vector,
                                                          value: "")
            // metadata_signature
            let argument3 = LibraTransactionArgument.init(code: .U8Vector,
                                                          value: "")
            let script = LibraTransactionScript.init(code: Data.init(hex: LibraScriptCodeWithData),
                                                     typeTags: [LibraTypeTag.init(structData: LibraStructTag.init(type: .Normal(module)))],
                                                     argruments: [argument0, argument1, argument2, argument3])
            let rawTransaction = LibraRawTransaction.init(senderAddres: sendAddress,
                                                          sequenceNumber: sequenceNumber,
                                                          maxGasAmount: 1000000,
                                                          gasUnitPrice: 0,
                                                          expirationTime: Int(UInt64(Date().timeIntervalSince1970) + 3600),
                                                          payLoad: script.serialize(),
                                                          module: module)

            // 签名交易
            let signature = try wallet.privateKey.signTransaction(transaction: rawTransaction, wallet: wallet)
            return signature.toHexString()
        } catch {
            throw error
        }
    }
//    public static func getMultiTransactionHex(sendAddress: String, receiveAddress: String, amount: Double, fee: Double, sequenceNumber: Int, wallet: LibraMultiHDWallet, module: String) throws -> String {
//        do {
//            let (authenticatorKey, address) = try LibraManager.splitAddress(address: receiveAddress)
//            // 拼接交易
//            let argument1 = LibraTransactionArgument.init(code: .Address,
//                                                          value: address)
//            let argument2 = LibraTransactionArgument.init(code: .U64,
//                                                          value: "\(Int(amount * 1000000))")
//            let argument3 = LibraTransactionArgument.init(code: .U8Vector,
//                                                          value: authenticatorKey)
//            let script = LibraTransactionScript.init(code: Data.init(hex: libraScriptCode),
//                                                     typeTags: [LibraTypeTag.init(structData: LibraStructTag.init(type: .libraDefault))],
//                                                     argruments: [argument1, argument3, argument2])
//            let rawTransaction = LibraRawTransaction.init(senderAddres: sendAddress,
//                                                          sequenceNumber: sequenceNumber,
//                                                          maxGasAmount: 1000000,
//                                                          gasUnitPrice: 0,
//                                                          expirationTime: Int(UInt64(Date().timeIntervalSince1970) + 3600),
//                                                          payLoad: script.serialize(),
//                                                          module: module)
//            // 签名交易
//            let multiSignature = wallet.privateKey.signMultiTransaction(transaction: rawTransaction, publicKey: wallet.publicKey)
//            return multiSignature.toHexString()
//        } catch {
//            throw error
//        }
//    }
}
extension LibraManager {
    /// 获取注册稳定币交易Hex
    /// - Parameters:
    ///   - mnemonic: 助记词
    ///   - contact: 合约地址
    ///   - sequenceNumber: 序列码
    public static func getLibraPublishTokenTransactionHex(mnemonic: [String], sequenceNumber: Int) throws -> String {
        do {
            let wallet = try LibraManager.getWallet(mnemonic: mnemonic)
            // 拼接交易
            let script = LibraTransactionScript.init(code: Data.init(hex: LibraPublishScriptCode),
                                                     typeTags: [LibraTypeTag.init(structData: LibraStructTag.init(type: .Normal("LBR")))],
                                                     argruments: [])
            let rawTransaction = LibraRawTransaction.init(senderAddres: wallet.publicKey.toLegacy(),
                                                          sequenceNumber: sequenceNumber,
                                                          maxGasAmount: 400000,
                                                          gasUnitPrice: 0,
                                                          expirationTime: Int(UInt64(Date().timeIntervalSince1970) + 3600),
                                                          payLoad: script.serialize(),
                                                          module: "LBR")
            // 签名交易
            let signature = try wallet.privateKey.signTransaction(transaction: rawTransaction, wallet: wallet)
            return signature.toHexString()
        } catch {
            throw error
        }
    }
}
extension LibraManager {
    /// 获取Libra映射VLibra交易Hex
    /// - Parameters:
    ///   - sendAddress: 发送地址
    ///   - amount: 数量
    ///   - fee: 手续费
    ///   - mnemonic: 助记词
    ///   - contact: 合约
    ///   - sequenceNumber: 序列码
    ///   - libraReceiveAddress: 接收地址
    /// - Throws: 报错
    /// - Returns: 返回结果
    public static func getLibraToVLibraTransactionHex(sendAddress: String, amount: Double, fee: Double, mnemonic: [String], sequenceNumber: Int, vlibraReceiveAddress: String, module: String) throws -> String {
        do {
            let wallet = try LibraManager.getWallet(mnemonic: mnemonic)
            // 拼接交易
            let argument0 = LibraTransactionArgument.init(code: .Address,
                                                          value: "0a82179351b8ecb6c5e68ab7b08622de")
            let argument1 = LibraTransactionArgument.init(code: .U8Vector,
                                                          value: "")
            let argument2 = LibraTransactionArgument.init(code: .U64,
                                                          value: "\(Int(amount * 1000000))")
            let data = "{\"flag\":\"libra\",\"type\":\"l2v\",\"to_address\":\"\(vlibraReceiveAddress)\",\"state\":\"start\"}".data(using: .utf8)!
            let argument3 = LibraTransactionArgument.init(code: .U8Vector,
                                                          value: data.toHexString())

            let script = LibraTransactionScript.init(code: Data.init(hex: LibraScriptCodeWithData),
                                                      typeTags: [LibraTypeTag.init(structData: LibraStructTag.init(type: .libraDefault))],
                                                      argruments: [argument0, argument1, argument2, argument3])

            let rawTransaction = LibraRawTransaction.init(senderAddres: sendAddress,
                                                sequenceNumber: sequenceNumber,
                                                maxGasAmount: 560000,
                                                gasUnitPrice: 0,
                                                expirationTime: Int(UInt64(Date().timeIntervalSince1970) + 3600),
                                                payLoad: script.serialize(),
                                                module: module)
            // 签名交易
            let signature = try wallet.privateKey.signTransaction(transaction: rawTransaction, wallet: wallet)
            return signature.toHexString()
        } catch {
            throw error
        }
    }
}

extension LibraManager {
    public static func derializeTransaction(tx: String) -> WCDataModel {
        let txData = Data.init(Array<UInt8>(hex: tx))
        var WCTransferModel = WCDataModel.init(from: "",
                                               receive: "",
                                               amount: 0)
        let (sendAddress, lastData0) = readData(data: txData, count: 16)
        print("sendAddress = \(sendAddress.toHexString())")
        WCTransferModel.from = sendAddress.toHexString()
        let (sequenceNumberData, lastData1) = readData(data: lastData0, count: 8)
        let tempSe = sequenceNumberData.bytes.reversed().map {
            $0
        }
        let sequenceNumber = BigUInt.init(Data.init(bytes: tempSe, count: 8))
        print("sequenceNumber = \(sequenceNumber)")
        let (payloadType, lastData2) = readData(data: lastData1, count: 1)
        print("payloadType = \(payloadType.toHexString())")
        let (codeLength, lastData3) = getCount(data: lastData2)
        print("codeLength = \(codeLength)")
        let (codeData, lastData4) = readData(data: lastData3, count: codeLength)
        print("codeData = \(codeData.toHexString())")
        let (typeTagCount , lastData5) = getCount(data: lastData4)
        print("typeTagCount = \(typeTagCount)")
        let lastData6 = readTypeTags(data: lastData5, typeTagCount: typeTagCount)
        let (argumentCount, lastData7) = getCount(data: lastData6)
        print("argumentCount = \(argumentCount)")
        let (model, lastData8) = readArgument(data: lastData7, argumentCount: argumentCount)
        print(lastData8.toHexString())
        print("success")
        return WCDataModel.init(from: sendAddress.toHexString(),
                                receive: model.receive,
                                amount: model.amount)
    }
    private static func getCount(data: Data) -> (Int, Data) {
        var nameCountData = [UInt8]()
        for OneByte in data {
            let erjinzhi = String.init(BigUInt.init(OneByte), radix: 2)
            if erjinzhi.count < 8 {
                nameCountData.append(OneByte)
                break
            } else {
                if erjinzhi.hasPrefix("1") {
                    nameCountData.append(OneByte)
                } else {
                    nameCountData.append(OneByte)
                    break
                }
            }
        }
        let nameCount = ViolasUtils.uleb128FormatToInt(data: Data.init(nameCountData))
        return (nameCount, data.suffix(data.count - nameCountData.count))
    }
    private static func readData(data: Data, count: Int) -> (Data, Data) {
        let tempData = data.prefix(count)
        let lastData = data.suffix(data.count - count)
        return (tempData, lastData)
    }
    private static func readTypeTags(data: Data, typeTagCount: Int) -> (Data) {
        var resultLastData = data
        for _ in 0..<typeTagCount {
            let (type, lastData0) = readData(data: resultLastData, count: 1)
            switch type.toHexString() {
            case "00":
                print("00")
            case "01":
                print("01")
            case "02":
                print("02")
            case "03":
                print("03")
            case "04":
                print("04")
            case "05":
                print("05")
            case "06":
                print("06")
            case "07":
                //Struct
                print("07")
                let (addressData, lastData1) = readData(data: lastData0, count: 16)
                print("address = \(addressData.toHexString())")
                let (moduleCount, lastData2) = getCount(data: lastData1)
                print("moduleCount = \(moduleCount)")
                let (moduleData, lastData3) = readData(data: lastData2, count: moduleCount)
                let module = String.init(data: moduleData, encoding: .utf8)!
                print("module = \(module)")
                let (nameCount, lastData4) = getCount(data: lastData3)
                print("nameCount = \(nameCount)")
                let (nameData, lastData5) = readData(data: lastData4, count: nameCount)
                let name = String.init(data: nameData, encoding: .utf8)!
                print("name = \(name)")
                let (typeParamsCount, lastData6) = getCount(data: lastData5)
                print("TypeParams = \(typeParamsCount)")
                
                resultLastData = lastData6
            default:
                print("invalid")
            }
        }
        return resultLastData
    }
    private static func readArgument(data: Data, argumentCount: Int) -> (WCDataModel, Data) {
        var resultLastData = data
        var model = WCDataModel.init(from: "", receive: "", amount: 0)
        for _ in 0..<argumentCount {
            let (type, lastData0) = readData(data: resultLastData, count: 1)
            switch type.toHexString() {
            case "00":
                print("00")
            case "01":
                let (amountData, lastData1) = readData(data: lastData0, count: 8)
                let amount = amountData.reversed().map {
                    $0
                }
                print("amount = \(BigUInt.init(Data.init(amount)))")
                resultLastData = lastData1
                model.amount = Int64(BigUInt.init(Data.init(amount)))
            case "02":
                print("02")
            case "03":
                let (addressData, lastData2) = readData(data: lastData0, count: 16)
                print("receiveAddress = \(addressData.toHexString())")
                resultLastData = lastData2
                model.receive = addressData.toHexString()
            case "04":
                let (U8VectorCount, lastData2) = getCount(data: lastData0)
                print("U8Count = \(U8VectorCount)")
                let (U8VectorData, lastData3) = readData(data: lastData2, count: U8VectorCount)
                print("U8Vector = \(U8VectorData.toHexString())")
                resultLastData = lastData3
            case "05":
                print("05")
            default:
                print("others")
            }
        }
        return (model, resultLastData)
    }
}
