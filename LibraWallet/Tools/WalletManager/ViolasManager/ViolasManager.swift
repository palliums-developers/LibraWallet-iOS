//
//  ViolasManager.swift
//  LibraWallet
//
//  Created by palliums on 2019/11/7.
//  Copyright © 2019 palliums. All rights reserved.
//

import Foundation
import BigInt

struct ViolasManager {
    /// 获取助词数组
    /// - Throws: 异常
    /// - Returns: 助记词
    public static func getLibraMnemonic() throws -> [String] {
        do {
            let mnemonic = try LibraMnemonic.generate(strength: .default, language: .english)
            return mnemonic
        } catch {
            print(error.localizedDescription)
            throw error
        }
    }
    /// 获取Violas钱包对象
    /// - Parameter mnemonic: 助记词
    /// - Throws: 异常
    /// - Returns: 钱包对象
    public static func getWallet(mnemonic: [String]) throws -> ViolasHDWallet {
        do {
            let seed = try LibraMnemonic.seed(mnemonic: mnemonic)
            let wallet = try ViolasHDWallet.init(seed: seed, depth: 0)
            return wallet
        } catch {
            throw error
        }
    }
    /// 校验地址是否有效
    /// - Parameter address: 地址
    /// - Returns: 结果
    public static func isValidViolasAddress(address: String) -> Bool {
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
        guard isValidViolasAddress(address: address) else {
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
extension ViolasManager {
    public static func getCodeData(move: String, address: String) -> Data {
        // 生成待替换数据
        let replaceData = Data.init(Array<UInt8>(hex: address))
        // 原始数据
        var code = Data.init(Array<UInt8>(hex: move))
        // 计算位置
        let location = ViolasManager().getViolasTokenContractLocation(code: move, contract: "7257c2417e4d1038e1817c8f283ace2e")
        // 设置替换区间
        let range = code.index(after: location)..<( code.endIndex - (code.endIndex - (location + 1) - 16))
        // 替换指定区间数据
        code.replaceSubrange(range, with: replaceData)
        return code
    }
    /// 计算位置
    /// - Parameter contract: 合约地址
    func getViolasTokenContractLocation(code: String, contract: String) -> Int {
        //位置-1所得正好
        let code = Data.init(Array<UInt8>(hex: code))
        let range: Range = code.toHexString().range(of: contract)!
        let location: Int = code.toHexString().distance(from: code.toHexString().startIndex, to: range.lowerBound)
        return (location / 2) - 1
    }
    /// 获取合约
    /// - Parameter name: 合约名字
    /// - Returns: 合约Hex
    private static func getLocalMoveCode(name: String) -> String {
        // 1.获取Bundle路径
        let marketContractBundlePath = Bundle.main.path(forResource:"MarketContracts", ofType:"bundle") ?? ""
        guard marketContractBundlePath.isEmpty == false else {
            return ""
        }
        // 2.获取Bundle
        guard let marketContractBundle = Bundle.init(path: marketContractBundlePath) else {
            return ""
        }
        // 3.获取Bundle下合约
        guard let path = marketContractBundle.path(forResource:name, ofType:"mv", inDirectory:""), path.isEmpty == false else {
            return ""
        }
        // 4.读取此合约
        do {
            let data = try Data.init(contentsOf: URL.init(fileURLWithPath: path))
            return data.toHexString()
        } catch {
            print(error.localizedDescription)
            return ""
        }
    }
}
//MARK: - 稳定币
extension ViolasManager {
    /// 获取Violas交易Hex
    /// - Parameters:
    ///   - sendAddress: 发送地址
    ///   - receiveAddress: 接收地址
    ///   - amount: 数量
    ///   - fee: 手续费
    ///   - mnemonic: 助记词
    ///   - sequenceNumber: 序列码
    ///   - module: 使用Module
    /// - Throws: 异常
    /// - Returns: 签名
    public static func getDefaultTransactionHex(sendAddress: String, receiveAddress: String, amount: UInt64, fee: UInt64, mnemonic: [String], sequenceNumber: UInt64, module: String) throws -> String {
        do {
            let wallet = try ViolasManager.getWallet(mnemonic: mnemonic)
            let (_, address) = try ViolasManager.splitAddress(address: receiveAddress)
            
            let argument0 = ViolasTransactionArgument.init(code: .Address,
                                                           value: address)
            let argument1 = ViolasTransactionArgument.init(code: .U64,
                                                           value: "\(amount)")
            // metadata
            let argument2 = ViolasTransactionArgument.init(code: .U8Vector,
                                                           value: "")
            // metadata_signature
            let argument3 = ViolasTransactionArgument.init(code: .U8Vector,
                                                           value: "")
            let script = ViolasTransactionScript.init(code: Data.init(hex: ViolasStableCoinScriptWithDataCode),
                                                      typeTags: [ViolasTypeTag.init(structData: ViolasStructTag.init(type: .Normal(module)))],
                                                      argruments: [argument0, argument1, argument2, argument3])
            let rawTransaction = ViolasRawTransaction.init(senderAddres: sendAddress,
                                                           sequenceNumber: sequenceNumber,
                                                           maxGasAmount: 1000000,
                                                           gasUnitPrice: fee,
                                                           expirationTime: NSDecimalNumber.init(value: Date().timeIntervalSince1970 + 600).uint64Value,
                                                           payLoad: script.serialize(),
                                                           module: module)
            // 签名交易
            let signature = try wallet.privateKey.signTransaction(transaction: rawTransaction, wallet: wallet)
            return signature.toHexString()
        } catch {
            throw error
        }
    }
    /// 注册稳定币交易Hex
    /// - Parameters:
    ///   - mnemonic: 助记词
    ///   - fee: 手续费
    ///   - sequenceNumber: 序列码
    ///   - inputModule: 注册Module
    /// - Throws: 异常
    /// - Returns: 签名
    public static func getPublishTokenTransactionHex(mnemonic: [String], fee: UInt64, sequenceNumber: UInt64, inputModule: String) throws -> String {
        do {
            let wallet = try ViolasManager.getWallet(mnemonic: mnemonic)
            // 拼接交易
            let script = ViolasTransactionScript.init(code: Data.init(hex: ViolasPublishScriptCode),
                                                      typeTags: [ViolasTypeTag.init(structData: ViolasStructTag.init(type: .Normal(inputModule)))],
                                                      argruments: [])
            let rawTransaction = ViolasRawTransaction.init(senderAddres: wallet.publicKey.toLegacy(),
                                                           sequenceNumber: sequenceNumber,
                                                           maxGasAmount: 1000000,
                                                           gasUnitPrice: fee,
                                                           expirationTime: NSDecimalNumber.init(value: Date().timeIntervalSince1970 + 600).uint64Value,
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
//MARK: - 交易所
extension ViolasManager {
    /// 交易所兑换交易Hex
    /// - Parameters:
    ///   - sendAddress: 发送地址
    ///   - mnemonic: 助记词
    ///   - feeModule: 手续费Module
    ///   - fee: 手续费
    ///   - sequenceNumber: 序列码
    ///   - inputAmount: 输入数量
    ///   - outputAmountMin: 最少兑回数量
    ///   - path: 兑换路径
    ///   - inputModule: 输入Module
    ///   - outputModule: 输出Module
    /// - Throws: 异常
    /// - Returns: 签名
    public static func getMarketSwapTransactionHex(sendAddress: String, mnemonic: [String], feeModule: String, fee: UInt64, sequenceNumber: UInt64, inputAmount: UInt64, outputAmountMin: UInt64, path: [UInt8], inputModule: String, outputModule: String) throws -> String {
        do {
            let wallet = try ViolasManager.getWallet(mnemonic: mnemonic)
            // 拼接交易
            let argument0 = ViolasTransactionArgument.init(code: .Address,
                                                           value: sendAddress)
            let argument1 = ViolasTransactionArgument.init(code: .U64,
                                                           value: "\(inputAmount)")
            let argument2 = ViolasTransactionArgument.init(code: .U64,
                                                           value: "\(outputAmountMin)")
            //            let mBytes:[UInt8]  =  [0,1];
            let data:Data = Data(bytes: path, count: path.count);
            let argument3 = ViolasTransactionArgument.init(code: .U8Vector,
                                                           value: data.toHexString())
            let argument4 = ViolasTransactionArgument.init(code: .U8Vector,
                                                           value: "")
            let script = ViolasTransactionScript.init(code: ViolasManager.getCodeData(move: ViolasManager.getLocalMoveCode(name: "swap"), address: "00000000000000000000000000000001"),
                                                      typeTags: [ViolasTypeTag.init(structData: ViolasStructTag.init(type: .Normal(inputModule))),
                                                                 ViolasTypeTag.init(structData: ViolasStructTag.init(type: .Normal(outputModule)))],
                                                      argruments: [argument0, argument1, argument2, argument3, argument4])
            let rawTransaction = ViolasRawTransaction.init(senderAddres: sendAddress,
                                                           sequenceNumber: sequenceNumber,
                                                           maxGasAmount: 1000000,
                                                           gasUnitPrice: fee,
                                                           expirationTime: NSDecimalNumber.init(value: Date().timeIntervalSince1970 + 600).uint64Value,
                                                           payLoad: script.serialize(),
                                                           module: feeModule)
            // 签名交易
            let signature = try wallet.privateKey.signTransaction(transaction: rawTransaction, wallet: wallet)
            return signature.toHexString()
        } catch {
            throw error
        }
    }
    /// 交易所添加流动性交易Hex
    /// - Parameters:
    ///   - sendAddress: 发送地址
    ///   - mnemonic: 助记词
    ///   - feeModule: 手续费Module
    ///   - fee: 手续费
    ///   - sequenceNumber: 序列码
    ///   - desiredAmountA: 期望兑换A数量
    ///   - desiredAmountB: 期望兑换B数量
    ///   - minAmountA: 最少兑换A数量
    ///   - minAmountB: 最少兑换B数量
    ///   - inputModuleA: 输入ModuleA
    ///   - inputModuleB: 输入ModuleB
    /// - Throws: 异常
    /// - Returns: 签名
    public static func getMarketAddLiquidityTransactionHex(sendAddress: String, mnemonic: [String], feeModule: String, fee: UInt64, sequenceNumber: UInt64, desiredAmountA: UInt64, desiredAmountB: UInt64, minAmountA: UInt64, minAmountB: UInt64, inputModuleA: String, inputModuleB: String) throws -> String {
        do {
            let wallet = try ViolasManager.getWallet(mnemonic: mnemonic)
            // 拼接交易
            let argument0 = ViolasTransactionArgument.init(code: .U64,
                                                           value: "\(desiredAmountA)")
            let argument1 = ViolasTransactionArgument.init(code: .U64,
                                                           value: "\(desiredAmountB)")
            let argument2 = ViolasTransactionArgument.init(code: .U64,
                                                           value: "\(minAmountA)")
            let argument3 = ViolasTransactionArgument.init(code: .U64,
                                                           value: "\(minAmountB)")
            //Data.init(hex: ViolasManager.getLocalMoveCode(name: "add_liquidity"))
            let script = ViolasTransactionScript.init(code: ViolasManager.getCodeData(move: ViolasManager.getLocalMoveCode(name: "add_liquidity"), address: "00000000000000000000000000000001"),
                                                      typeTags: [ViolasTypeTag.init(structData: ViolasStructTag.init(type: .Normal(inputModuleA))),
                                                                 ViolasTypeTag.init(structData: ViolasStructTag.init(type: .Normal(inputModuleB)))],
                                                      argruments: [argument0, argument1, argument2, argument3])
            let rawTransaction = ViolasRawTransaction.init(senderAddres: sendAddress,
                                                           sequenceNumber: sequenceNumber,
                                                           maxGasAmount: 1000000,
                                                           gasUnitPrice: fee,
                                                           expirationTime: NSDecimalNumber.init(value: Date().timeIntervalSince1970 + 600).uint64Value,
                                                           payLoad: script.serialize(),
                                                           module: feeModule)
            // 签名交易
            let signature = try wallet.privateKey.signTransaction(transaction: rawTransaction, wallet: wallet)
            return signature.toHexString()
        } catch {
            throw error
        }
    }
    /// 交易所取消流动性交易Hex
    /// - Parameters:
    ///   - sendAddress: 发送地址
    ///   - mnemonic: 助记词
    ///   - feeModule: 手续费Module
    ///   - fee: 手续费
    ///   - sequenceNumber: 序列码
    ///   - liquidity: 流动性
    ///   - minAmountA: 最少输出数量A
    ///   - minAmountB: 最少输出数量B
    ///   - inputModuleA: 输出ModuleA
    ///   - inputModuleB: 输出ModuleB
    /// - Throws: 异常
    /// - Returns: 签名
    public static func getMarketRemoveLiquidityTransactionHex(sendAddress: String, mnemonic: [String], feeModule: String, fee: UInt64, sequenceNumber: UInt64, liquidity: UInt64, minAmountA: UInt64, minAmountB: UInt64, inputModuleA: String, inputModuleB: String) throws -> String {
        do {
            let wallet = try ViolasManager.getWallet(mnemonic: mnemonic)
            // 拼接交易
            let argument0 = ViolasTransactionArgument.init(code: .U64,
                                                           value: "\(liquidity)")
            let argument1 = ViolasTransactionArgument.init(code: .U64,
                                                           value: "\(minAmountA)")
            let argument2 = ViolasTransactionArgument.init(code: .U64,
                                                           value: "\(minAmountB)")
            let script = ViolasTransactionScript.init(code: ViolasManager.getCodeData(move: ViolasManager.getLocalMoveCode(name: "remove_liquidity"), address: "00000000000000000000000000000001"),
                                                      typeTags: [ViolasTypeTag.init(structData: ViolasStructTag.init(type: .Normal(inputModuleA))),
                                                                 ViolasTypeTag.init(structData: ViolasStructTag.init(type: .Normal(inputModuleB)))],
                                                      argruments: [argument0, argument1, argument2])
            let rawTransaction = ViolasRawTransaction.init(senderAddres: sendAddress,
                                                           sequenceNumber: sequenceNumber,
                                                           maxGasAmount: 1000000,
                                                           gasUnitPrice: fee,
                                                           expirationTime: NSDecimalNumber.init(value: Date().timeIntervalSince1970 + 600).uint64Value,
                                                           payLoad: script.serialize(),
                                                           module: feeModule)
            // 签名交易
            let signature = try wallet.privateKey.signTransaction(transaction: rawTransaction, wallet: wallet)
            return signature.toHexString()
        } catch {
            throw error
        }
    }
}
//MARK: - Violas映射Libra、BTC
extension ViolasManager {
    /// Violas映射交易Hex
    /// - Parameters:
    ///   - sendAddress: 发送地址
    ///   - mnemonic: 助记词
    ///   - feeModule: 手续费Module
    ///   - fee: 手续费
    ///   - sequenceNumber: 序列吗
    ///   - inputModule: 输入Module
    ///   - inputAmount: 输入数量
    ///   - outputAmount: 输出Module
    ///   - centerAddress: 兑换中心地址
    ///   - receiveAddress: 接收地址
    ///   - mappingType: 映射类型
    /// - Throws: 异常
    /// - Returns: 签名
    public static func getViolasMappingTransactionHex(sendAddress: String, mnemonic: [String], feeModule: String, fee: UInt64, sequenceNumber: UInt64, inputModule: String, inputAmount: UInt64, outputAmount: UInt64, centerAddress: String, receiveAddress: String, mappingType: String) throws -> String {
        do {
            let wallet = try ViolasManager.getWallet(mnemonic: mnemonic)
            // 拼接交易
            let argument0 = ViolasTransactionArgument.init(code: .Address,
                                                           value: centerAddress)
            let argument1 = ViolasTransactionArgument.init(code: .U64,
                                                           value: "\(inputAmount)")
            // metadata
            let data = "{\"flag\":\"violas\",\"type\":\"\(mappingType)\",\"times\": 1000, \"to_address\":\"\(receiveAddress)\",\"out_amount\":\"\(outputAmount)\",\"state\":\"start\"}".data(using: .utf8)!
            let argument2 = ViolasTransactionArgument.init(code: .U8Vector,
                                                           value: data.toHexString())
            // metadata_signature
            let argument3 = ViolasTransactionArgument.init(code: .U8Vector,
                                                           value: "")
            let script = ViolasTransactionScript.init(code: Data.init(hex: ViolasStableCoinScriptWithDataCode),
                                                      typeTags: [ViolasTypeTag.init(structData: ViolasStructTag.init(type: .Normal(inputModule)))],
                                                      argruments: [argument0, argument1, argument2, argument3])
            let rawTransaction = ViolasRawTransaction.init(senderAddres: sendAddress,
                                                           sequenceNumber: sequenceNumber,
                                                           maxGasAmount: 1000000,
                                                           gasUnitPrice: fee,
                                                           expirationTime: NSDecimalNumber.init(value: Date().timeIntervalSince1970 + 600).uint64Value,
                                                           payLoad: script.serialize(),
                                                           module: feeModule)
            // 签名交易
            let signature = try wallet.privateKey.signTransaction(transaction: rawTransaction, wallet: wallet)
            return signature.toHexString()
        } catch {
            throw error
        }
    }
}
//MARK: - WalletConnect
extension ViolasManager {
    public static func getWalletConnectTransactionHex(mnemonic: [String], sequenceNumber: UInt64, fee: UInt64, model: WCRawTransaction, module: String) throws -> String {
        do {
            let wallet = try ViolasManager.getWallet(mnemonic: mnemonic)
            var tempArguments = [ViolasTransactionArgument]()
            if let args = model.payload?.args, args.count > 0 {
                for item in args {
                    if item.type?.lowercased() == "address" {
                        let argument = ViolasTransactionArgument.init(code: .Address,
                                                                      value: item.value ?? "")
                        tempArguments.append(argument)
                    } else if item.type?.lowercased() == "u64" {
                        let argument = ViolasTransactionArgument.init(code: .U64,
                                                                      value: "\(Int(item.value ?? "0")!)")
                        tempArguments.append(argument)
                    } else if item.type?.lowercased() == "bool" {
                        let argument = ViolasTransactionArgument.init(code: .Bool,
                                                                      value: item.value ?? "")
                        tempArguments.append(argument)
                    } else if item.type?.lowercased() == "vector" {
                        let argument = ViolasTransactionArgument.init(code: .U8Vector,
                                                                      value: item.value ?? "")
                        tempArguments.append(argument)
                    }
                }
            }
            let script = ViolasTransactionScript.init(code: Data.init(hex: model.payload?.code ?? ""),
                                                      typeTagsString: model.payload?.tyArgs ?? [String](),
                                                      argruments: tempArguments)
            let rawTransaction = ViolasRawTransaction.init(senderAddres: model.from ?? "",
                                                           sequenceNumber: sequenceNumber,
                                                           maxGasAmount: model.maxGasAmount ?? 1000000,
                                                           gasUnitPrice: model.gasUnitPrice ?? fee,
                                                           expirationTime: model.expirationTime ?? UInt64(Date().timeIntervalSince1970 + 600),
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
extension ViolasManager {
    public static func getSignMessage(mnemonic: [String], message: Data) throws -> String {
        do {
            let wallet = try ViolasManager.getWallet(mnemonic: mnemonic)
            // 签名交易
            let signature = try wallet.privateKey.signMessage(message: message, wallet: wallet)
            return signature.toHexString()
        } catch {
            throw error
        }
    }
}
extension ViolasManager {
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
        let nameCount = ViolasUtils.uleb128FormatToInt(data: Data.init(nameCountData))
        return (nameCount, data.suffix(data.count - nameCountData.count))
    }
    private static func readData(data: Data, count: Int) -> (Data, Data) {
        let tempData = data.prefix(count)
        let lastData = data.suffix(data.count - count)
        return (tempData, lastData)
    }
    static func readTypeTags(data: Data, typeTagCount: Int) -> (Data, String) {
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
        var model = WCDataModel.init(from: "",
                                     receive: "",
                                     amount: 0,
                                     module: "")
        for _ in 0..<argumentCount {
            let (type, lastData0) = readData(data: resultLastData, count: 1)
            switch type.toHexString() {
            case "00":
                let (amountData, lastData1) = readData(data: lastData0, count: 8)
                let amount = amountData.reversed().map {
                    $0
                }
                print("amount = \(BigUInt.init(Data.init(amount)))")
                resultLastData = lastData1
                model.amount = Int64(BigUInt.init(Data.init(amount)))
            case "01":
                let (addressData, lastData2) = readData(data: lastData0, count: 16)
                print("receiveAddress = \(addressData.toHexString())")
                resultLastData = lastData2
                model.receive = addressData.toHexString()
            case "02":
                let (U8VectorCount, lastData2) = getCount(data: lastData0)
                print("U8Count = \(U8VectorCount)")
                let (U8VectorData, lastData3) = readData(data: lastData2, count: U8VectorCount)
                print("U8Vector = \(U8VectorData.toHexString())")
                resultLastData = lastData3
            case "03":
                print("03")
            case "04":
                print("04")
            case "05":
                print("05")
            default:
                print("others")
            }
        }
        return (model, resultLastData)
    }
}
