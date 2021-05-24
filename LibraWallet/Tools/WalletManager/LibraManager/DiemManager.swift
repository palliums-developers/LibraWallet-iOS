//
//  DiemManager.swift
//  LibraWallet
//
//  Created by palliums on 2019/11/11.
//  Copyright © 2019 palliums. All rights reserved.
//

import Foundation
import BigInt
import CryptoSwift

struct DiemManager {
    /// 获取助词数组
    /// - Throws: 异常
    /// - Returns: 助记词
    public static func getDiemMnemonic() throws -> [String] {
        do {
            let mnemonic = try DiemMnemonic.generate(strength: .default, language: .english)
            return mnemonic
        } catch {
            print(error.localizedDescription)
            throw error
        }
    }
    /// 获取Diem钱包对象
    /// - Parameter mnemonic: 助记词
    /// - Throws: 异常
    /// - Returns: 钱包对象
    public static func getWallet(mnemonic: [String]) throws -> DiemHDWallet {
        do {
            let seed = try DiemMnemonic.seed(mnemonic: mnemonic)
            let wallet = try DiemHDWallet.init(seed: seed, depth: 0, network: DIEM_PUBLISH_NET)
            return wallet
        } catch {
            throw error
        }
    }
    /// 校验地址是否有效
    /// - Parameter address: 地址
    /// - Returns: 结果
    public static func isValidDiemAddress(address: String) -> Bool {
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
    /// 检查有效地址
    /// - Parameter address: Bech 32地址
    /// - Throws: 异常
    /// - Returns: 主地址、子地址
    public static func isValidTransferAddress(address: String) throws -> (String, String) {
        do {
            let (prifix, result) = try DiemBech32.decode(address, separator: "1")
            guard prifix.isEmpty == false else {
                throw LibraWalletError.WalletScan(reason: .handleInvalid)
            }
            guard prifix.lowercased() == DIEM_PUBLISH_NET.addressPrefix else {
                throw LibraWalletError.WalletScan(reason: .handleInvalid)
            }
            let address = result.prefix(16).toHexString()
            let subAddress = result.suffix(8).toHexString()
            guard isValidDiemAddress(address: address) == true else {
                throw LibraWalletError.WalletScan(reason: .libraAddressInvalid)
            }
            return (address, subAddress)
        } catch {
            throw error
        }
    }
    /// 获取二维码地址
    /// - Parameters:
    ///   - rootAccount: 是否是默认根账户地址（默认不是）
    ///   - version: 版本（默认为1）
    /// - Returns: 返回地址
    static func getQRAddress(address: String, rootAccount: Bool = false, version: UInt8 = 1) -> String {
        var randomData = Data()
        if rootAccount == false {
            for _ in 0..<8 {
                let randomValue = UInt8.random(in: 0...255)
                let tempData = Data([randomValue])
                randomData.append(tempData)
            }
        } else {
            let tempData = Data.init(count: 8)
            randomData.append(tempData)
        }
        let payload = Data(Array<UInt8>(hex: address)) + randomData
        let address: String = DiemBech32.encode(payload: Data.init(payload),
                                                prefix: DIEM_PUBLISH_NET.addressPrefix,
                                                version: version,
                                                separator: "1")
        return address
    }
    static func handleMaxGasAmount(balances: [ViolasBalanceDataModel]) -> UInt64 {
        let model = balances.filter {
            $0.currency == "VLS"
        }
        guard model.isEmpty == false else {
            return 1_000_000
        }
        if let balance = model.first?.amount, balance > 0 {
            if balance < 1_000_000 {
                return NSDecimalNumber.init(value: balance).uint64Value
            } else {
                return 1_000_000
            }
        } else {
            return 1_000_000
        }
    }
}
// MARK: - Diem单签
extension DiemManager {
    /// Diem交易Hex
    /// - Parameters:
    ///   - sendAddress: 发送地址
    ///   - receiveAddress: 接收地址
    ///   - amount: 数量
    ///   - fee: 手续费
    ///   - mnemonic: 助记词
    ///   - sequenceNumber: 序列码
    ///   - module: 消耗Module
    /// - Throws: 异常
    /// - Returns: 签名
    public static func getNormalTransactionHex(sendAddress: String, receiveAddress: String, amount: UInt64, fee: UInt64, mnemonic: [String], sequenceNumber: UInt64, module: String, toSubAddress: String, fromSubAddress: String, referencedEvent: String) throws -> String {
        do {
            let wallet = try DiemManager.getWallet(mnemonic: mnemonic)
            // 拼接交易
            let argument0 = DiemTransactionArgument.init(code: .Address(receiveAddress))
            let argument1 = DiemTransactionArgument.init(code: .U64(amount))
            var argument2 = DiemTransactionArgument(code: .U8Vector(Data()))
            // metadata
            if toSubAddress.isEmpty == true && fromSubAddress.isEmpty == true {
                // NC To NC
            } else {
                // NC to C && C To C
                let metadataV0 = DiemGeneralMetadataV0.init(to_subaddress: toSubAddress,
                                                            from_subaddress: fromSubAddress,
                                                            referenced_event: referencedEvent)
                let metadata = DiemMetadata.init(code: DiemMetadataTypes.GeneralMetadata(DiemGeneralMetadata.init(code: .GeneralMetadataVersion0(metadataV0))))
                argument2 = DiemTransactionArgument.init(code: .U8Vector(metadata.serialize()))
            }
            // metadata_signature
            let argument3 = DiemTransactionArgument.init(code: .U8Vector(Data()))
            let script = DiemTransactionScriptPayload.init(code: Data.init(hex: DiemUtils.getMoveCode(name: "peer_to_peer_with_metadata")),
                                                           typeTags: [DiemTypeTag.init(typeTag: .Struct(DiemStructTag.init(type: .Normal(module))))],
                                                           argruments: [argument0, argument1, argument2, argument3])
            let transactionPayload = DiemTransactionPayload.init(payload: .script(script))
            let rawTransaction = DiemRawTransaction.init(senderAddres: sendAddress,
                                                         sequenceNumber: UInt64(sequenceNumber),
                                                         maxGasAmount: 1000000,
                                                         gasUnitPrice: fee,
                                                         expirationTime: UInt64(Date().timeIntervalSince1970 + 600),
                                                         payload: transactionPayload,
                                                         module: module,
                                                         chainID: wallet.network.chainId)
            
            // 签名交易
            let signature = wallet.buildTransaction(transaction: rawTransaction)
            return signature.toHexString()
        } catch {
            throw error
        }
    }

}
// MARK: - Diem多签
extension DiemManager {
    /// Diem多签
    /// - Parameters:
    ///   - sendAddress: 发送地址
    ///   - receiveAddress: 接收地址
    ///   - amount: 接收地址
    ///   - fee: 手续费
    ///   - sequenceNumber: 序列码
    ///   - wallet: 多签钱包
    ///   - module: 转账币种
    ///   - feeModule: 手续费币种
    /// - Throws: 报错
    /// - Returns: 交易签名
    public static func getMultiTransactionHex(sendAddress: String, receiveAddress: String, amount: UInt64, fee: UInt64, sequenceNumber: UInt64, wallet: DiemMultiHDWallet, module: String, feeModule: String) -> String {
        // 拼接交易
        let argument0 = DiemTransactionArgument.init(code: .Address(receiveAddress))
        let argument1 = DiemTransactionArgument.init(code: .U64(amount))
        let argument2 = DiemTransactionArgument.init(code: .U8Vector(Data()))
        let argument3 = DiemTransactionArgument.init(code: .U8Vector(Data()))
        let script = DiemTransactionScriptPayload.init(code: Data.init(hex: DiemUtils.getMoveCode(name: "peer_to_peer_with_metadata")),
                                                       typeTags: [DiemTypeTag.init(typeTag: .Struct(DiemStructTag.init(type: .Normal(module))))],
                                                       argruments: [argument0, argument1, argument2, argument3])
        let transactionPayload = DiemTransactionPayload.init(payload: .script(script))
        let rawTransaction = DiemRawTransaction.init(senderAddres: sendAddress,
                                                     sequenceNumber: sequenceNumber,
                                                     maxGasAmount: 1000000,
                                                     gasUnitPrice: fee,
                                                     expirationTime: UInt64(Date().timeIntervalSince1970 + 600),
                                                     payload: transactionPayload,
                                                     module: feeModule,
                                                     chainID: wallet.network.chainId)
        // 签名交易
        let multiSignature = wallet.buildTransaction(transaction: rawTransaction)
        return multiSignature.toHexString()
    }
}
// MARK: - Diem换私钥
extension DiemManager {
    public static func getRotateAuthenticationKeyTransactionHex(mnemonic: [String], sequenceNumber: UInt64, fee: UInt64, module: String, authKey: String, feeModule: String) throws -> String {
        do {
            let wallet = try DiemManager.getWallet(mnemonic: mnemonic)
            // 拼接交易
            let argument0 = DiemTransactionArgument.init(code: .U8Vector(Data.init(Array<UInt8>(hex: authKey))))
            let script = DiemTransactionScriptPayload.init(code: Data.init(hex: DiemUtils.getMoveCode(name: "rotate_authentication_key")),
                                                           typeTags: [DiemTypeTag](),
                                                           argruments: [argument0])
            let transactionPayload = DiemTransactionPayload.init(payload: .script(script))
            let rawTransaction = DiemRawTransaction.init(senderAddres: wallet.publicKey.toLegacy(),
                                                         sequenceNumber: sequenceNumber,
                                                         maxGasAmount: 1000000,
                                                         gasUnitPrice: fee,
                                                         expirationTime: UInt64(Date().timeIntervalSince1970 + 600),
                                                         payload: transactionPayload,
                                                         module: feeModule,
                                                         chainID: wallet.network.chainId)
            let signature = wallet.buildTransaction(transaction: rawTransaction)
            return signature.toHexString()
        } catch {
            throw error
        }
    }
}
// MARK: - Diem注册币
extension DiemManager {
    /// 注册稳定币交易Hex
    /// - Parameters:
    ///   - mnemonic: 助记词
    ///   - sequenceNumber: 序列码
    ///   - fee: 手续费
    ///   - module: 消耗Module
    /// - Throws: 异常
    /// - Returns: 签名
    public static func getPublishTokenTransactionHex(mnemonic: [String], sequenceNumber: UInt64, fee: UInt64, module: String, feeModule: String) throws -> String {
        do {
            let wallet = try DiemManager.getWallet(mnemonic: mnemonic)
            // 拼接交易
            let script = DiemTransactionScriptPayload.init(code: Data.init(hex: DiemUtils.getMoveCode(name: "add_currency_to_account")),
                                                           typeTags: [DiemTypeTag.init(typeTag: .Struct(DiemStructTag.init(type: .Normal(module))))],
                                                           argruments: [])
            let transactionPayload = DiemTransactionPayload.init(payload: .script(script))
            let rawTransaction = DiemRawTransaction.init(senderAddres: wallet.publicKey.toLegacy(),
                                                         sequenceNumber: sequenceNumber,
                                                         maxGasAmount: 400000,
                                                         gasUnitPrice: fee,
                                                         expirationTime:  (UInt64(Date().timeIntervalSince1970) + 600),
                                                         payload: transactionPayload,
                                                         module: feeModule,
                                                         chainID: wallet.network.chainId)
            // 签名交易
            let signature = wallet.buildTransaction(transaction: rawTransaction)
            return signature.toHexString()
        } catch {
            throw error
        }
    }
}
// MARK: - Diem映射Violas、BTC
extension DiemManager {
    /// Diem映射Violas、BTC
    /// - Parameters:
    ///   - sendAddress: 发送地址
    ///   - mnemonic: 助记词
    ///   - feeModule: 手续费Module
    ///   - fee: 手续费
    ///   - sequenceNumber: 序列码
    ///   - module: 消耗Module
    ///   - inputAmount: 输入数量
    ///   - outputAmount: 兑换数量
    ///   - centerAddress: 兑换中心地址
    ///   - violasReceiveAddress: 接收地址
    ///   - mappingType: 兑换类型
    /// - Throws: 异常
    /// - Returns: 签名
    public static func getLibraMappingTransactionHex(sendAddress: String, mnemonic: [String], feeModule: String, fee: UInt64, sequenceNumber: UInt64, inputModule: String, inputAmount: UInt64, outputAmount: UInt64, centerAddress: String, receiveAddress: String, mappingType: String) throws -> String {
        do {
            let wallet = try DiemManager.getWallet(mnemonic: mnemonic)
            // 拼接交易
            let argument0 = DiemTransactionArgument.init(code: .Address(centerAddress))
            let argument1 = DiemTransactionArgument.init(code: .U64(inputAmount))
            // metadata
            let data = "{\"flag\":\"libra\",\"type\":\"\(mappingType)\",\"times\": 1000, \"to_address\":\"\(receiveAddress)\",\"out_amount\":\"\(outputAmount)\",\"state\":\"start\"}".data(using: .utf8)!
            let argument2 = DiemTransactionArgument.init(code: .U8Vector(data))
            // metadata_signature
            let argument3 = DiemTransactionArgument.init(code: .U8Vector(Data()))
            let script = DiemTransactionScriptPayload.init(code: Data.init(hex: DiemUtils.getMoveCode(name: "peer_to_peer_with_metadata")),
                                                            typeTags: [DiemTypeTag.init(typeTag: .Struct(DiemStructTag.init(type: .Normal(inputModule))))],
                                                            argruments: [argument0, argument1, argument2, argument3])
            let transactionPayload = DiemTransactionPayload.init(payload: .script(script))
            
            let rawTransaction = DiemRawTransaction.init(senderAddres: sendAddress,
                                                          sequenceNumber: sequenceNumber,
                                                          maxGasAmount: 1000000,
                                                          gasUnitPrice: fee,
                                                          expirationTime: (UInt64(Date().timeIntervalSince1970) + 600),
                                                          payload: transactionPayload,
                                                          module: feeModule,
                                                          chainID: 2)
            // 签名交易
            let signature = wallet.buildTransaction(transaction: rawTransaction)
            return signature.toHexString()
        } catch {
            throw error
        }
    }
}
//MARK: - WalletConnect
extension DiemManager {
    public static func getWalletConnectTransactionHex(mnemonic: [String], sequenceNumber: UInt64, model: WCLibraRawTransaction, module: String) throws -> String {
        do {
            let wallet = try DiemManager.getWallet(mnemonic: mnemonic)
            var tempArguments = [DiemTransactionArgument]()
            if let args = model.payload?.args, args.count > 0 {
                for item in args {
                    if item.type?.lowercased() == "address" {
                        let argument = DiemTransactionArgument.init(code: .Address(item.value ?? ""))
                        tempArguments.append(argument)
                    } else if item.type?.lowercased() == "bool" {
                        let argument = DiemTransactionArgument.init(code: .Bool(NSDecimalNumber.init(string: item.value).boolValue))
                        tempArguments.append(argument)
                    } else if item.type?.lowercased() == "vector" {
                        let argument = DiemTransactionArgument.init(code: .U8Vector(Data.init(hex: item.value ?? "")))
                        tempArguments.append(argument)
                    } else if item.type?.lowercased() == "u64" {
                        let argument = DiemTransactionArgument.init(code: .U64(NSDecimalNumber.init(string: item.value).uint64Value))
                        tempArguments.append(argument)
                    }
                }
            }
            let tempTypeTags = model.payload?.tyArgs.map({ item in
                item.map {
                    DiemTypeTag.init(typeTag: .Struct(DiemStructTag.init(address: $0.address ?? "", module: $0.module ?? "", name: $0.name ?? "", typeParams: [String]())))
                }
            }) ?? [DiemTypeTag]()
            let script = DiemTransactionScriptPayload.init(code: Data.init(hex: model.payload?.code ?? ""),
                                                            typeTags: tempTypeTags,
                                                            argruments: tempArguments)
            let transactionPayload = DiemTransactionPayload.init(payload: .script(script))
            let rawTransaction = DiemRawTransaction.init(senderAddres: model.from ?? "",
                                                           sequenceNumber: sequenceNumber,
                                                           maxGasAmount: model.maxGasAmount ?? 1000000,
                                                           gasUnitPrice: model.gasUnitPrice ?? 0,
                                                           expirationTime: (UInt64(Date().timeIntervalSince1970) + 600),
                                                           payload: transactionPayload,
                                                           module: module,
                                                           chainID: model.chainId ?? 2)
            // 签名交易
            let signature = wallet.buildTransaction(transaction: rawTransaction)
            return signature.toHexString()
        } catch {
            throw error
        }
    }
}
extension DiemManager {
    public static func derializeTransaction(tx: String) -> WCDataModel {
        let txData = Data.init(Array<UInt8>(hex: tx))
        var WCTransferModel = WCDataModel.init(from: "",
                                               receive: "",
                                               amount: 0,
                                               module: "")
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
        let (lastData6, module) = readTypeTags(data: lastData5, typeTagCount: typeTagCount)
        let (argumentCount, lastData7) = getCount(data: lastData6)
        print("argumentCount = \(argumentCount)")
        let (model, lastData8) = readArgument(data: lastData7, argumentCount: argumentCount)
        print(lastData8.toHexString())
        print("success")
        return WCDataModel.init(from: sendAddress.toHexString(),
                                receive: model.receive,
                                amount: model.amount,
                                module: module)
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
        let nameCount = DiemUtils.uleb128FormatToInt(data: Data.init(nameCountData))
        return (nameCount, data.suffix(data.count - nameCountData.count))
    }
    private static func readData(data: Data, count: Int) -> (Data, Data) {
        let tempData = data.prefix(count)
        let lastData = data.suffix(data.count - count)
        return (tempData, lastData)
    }
    private static func readTypeTags(data: Data, typeTagCount: Int) -> (Data, String) {
        var resultLastData = data
        var tempModule = ""
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
                tempModule = module
            default:
                print("invalid")
            }
        }
        return (resultLastData, tempModule)
    }
    private static func readArgument(data: Data, argumentCount: Int) -> (WCDataModel, Data) {
        var resultLastData = data
        var model = WCDataModel.init(from: "", receive: "", amount: 0, module: "")
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
