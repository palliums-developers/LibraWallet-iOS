//
//  LibraSDKTests.swift
//  LibraWalletTests
//
//  Created by palliums on 2019/9/5.
//  Copyright © 2019 palliums. All rights reserved.
//

import XCTest
import CryptoSwift
import BigInt
import BitcoinKit

@testable import ViolasPay
class LibraSDKTests: XCTestCase {
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    func testLibraSDK() {
        let mnemonic = ["legal","winner","thank","year","wave","sausage","worth","useful","legal","winner","thank","year","wave","sausage","worth","useful","legal","will"]
//        let mnemonic = ["trouble", "menu", "nephew", "group", "alert", "recipe", "hotel", "fatigue", "wet", "shadow", "say", "fold", "huge", "olive", "solution", "enjoy", "garden", "appear", "vague", "joy", "great", "keep", "cactus", "melt"]
        do {
            let seed = try DiemMnemonic.seed(mnemonic: mnemonic)
//            XCTAssertEqual(seed.toHexString(), "66ae6b767defe3ea0c646f10bf31ad3b36f822064d3923adada7676703a350c0")
            let testWallet = try DiemHDWallet.init(seed: seed, depth: 0, network: DiemNetworkState.testnet)
            XCTAssertEqual(testWallet.privateKey.raw.toHexString(), "732bc883893c716f320c01864709ca9f16f8f30342a1de42144bfcc2ddb7af10")
            let testWallet2 = try DiemHDWallet.init(seed: seed, depth: 1, network: DiemNetworkState.testnet)
            XCTAssertEqual(testWallet2.privateKey.raw.toHexString(), "f6b472bd0941e315d3c34c3ac679d610d2b9e1abe85128752d04bb0f042f3391")
        } catch {
            print(error.localizedDescription)
        }
    }
    func testDiemSDK2() {
        let mnemonic = ["trouble", "menu", "nephew", "group", "alert", "recipe", "hotel", "fatigue", "wet", "shadow", "say", "fold", "huge", "olive", "solution", "enjoy", "garden", "appear", "vague", "joy", "great", "keep", "cactus", "melt"]
        do {
            let seed = try DiemMnemonic.seed(mnemonic: mnemonic)
            let testWallet = try DiemHDWallet.init(seed: seed, depth: 0, network: .testnet)
            let walletAddress = testWallet.publicKey.toLegacy()         
            XCTAssertEqual(walletAddress, "6c1dd50f35f120061babc2814cf9378b")
        } catch {
            print(error.localizedDescription)
        }
    }
    func testViolasSDK() {
        let mnemonic = ["trouble", "menu", "nephew", "group", "alert", "recipe", "hotel", "fatigue", "wet", "shadow", "say", "fold", "huge", "olive", "solution", "enjoy", "garden", "appear", "vague", "joy", "great", "keep", "cactus", "melt"]
        do {
            let seed = try ViolasMnemonic.seed(mnemonic: mnemonic)
            let testWallet = try ViolasHDWallet.init(seed: seed, depth: 0, network: .testnet)
            let walletAddress = testWallet.publicKey.toLegacy()
            XCTAssertEqual(walletAddress, "6c1dd50f35f120061babc2814cf9378b")
        } catch {
            print(error.localizedDescription)
        }
    }
    func testLibraKit() {
        //LibraTransactionArgument
        // u64
        let amount = DiemTransactionArgument.init(code: .U64(9213671392124193148)).serialize().toHexString().uppercased()
        XCTAssertEqual(amount, "017CC9BDA45089DD7F")
        // Address
        let address = DiemTransactionArgument.init(code: .Address("bafc671e8a38c05706f83b5159bbd8a4")).serialize().toHexString()
        XCTAssertEqual(address  , "03bafc671e8a38c05706f83b5159bbd8a4")
        // U8Vector
        let u8vector = DiemTransactionArgument.init(code: .U8Vector(Data.init(Array<UInt8>(hex: "CAFED00D")))).serialize().toHexString().uppercased()
        XCTAssertEqual(u8vector, "0404CAFED00D")
        // Bool
        let bool1 = DiemTransactionArgument.init(code: .Bool(false)).serialize().toHexString().uppercased()
        XCTAssertEqual(bool1, "0500")
        // Bool
        let bool2 = DiemTransactionArgument.init(code: .Bool(true)).serialize().toHexString().uppercased()
        XCTAssertEqual(bool2, "0501")
        //LibraTransactionAccessPath
        let accessPath1 = DiemAccessPath.init(address: "a71d76faa2d2d5c3224ec3d41deb2939",
                                               path: "01217da6c6b3e19f1825cfb2676daecce3bf3de03cf26647c78df00b371b25cc97",
                                               writeOp: .Deletion)
        let accessPath2 = DiemAccessPath.init(address: "c4c63f80c74b11263e421ebf8486a4e3",
                                               path: "01217da6c6b3e19f18",
                                               writeOp: .Value(Data.init(Array<UInt8>(hex: "CAFED00D"))))
        let writeSet = DiemWriteSet.init(accessPaths: [accessPath1, accessPath2])
        let writeSetCheckData: Array<UInt8> = [0x02, 0xA7, 0x1D, 0x76, 0xFA, 0xA2, 0xD2, 0xD5, 0xC3, 0x22, 0x4E, 0xC3, 0xD4, 0x1D, 0xEB,
                                               0x29, 0x39, 0x21, 0x01, 0x21, 0x7D, 0xA6, 0xC6, 0xB3, 0xE1, 0x9F, 0x18, 0x25, 0xCF, 0xB2,
                                               0x67, 0x6D, 0xAE, 0xCC, 0xE3, 0xBF, 0x3D, 0xE0, 0x3C, 0xF2, 0x66, 0x47, 0xC7, 0x8D, 0xF0,
                                               0x0B, 0x37, 0x1B, 0x25, 0xCC, 0x97, 0x00, 0xC4, 0xC6, 0x3F, 0x80, 0xC7, 0x4B, 0x11, 0x26,
                                               0x3E, 0x42, 0x1E, 0xBF, 0x84, 0x86, 0xA4, 0xE3, 0x09, 0x01, 0x21, 0x7D, 0xA6, 0xC6, 0xB3,
                                               0xE1, 0x9F, 0x18, 0x01, 0x04, 0xCA, 0xFE, 0xD0, 0x0D]
        XCTAssertEqual(writeSet.serialize().toHexString().lowercased(), Data.init(writeSetCheckData).toHexString())
        // LibraTransactionPayload_WriteSet
        let writeSetPayload = DiemTransactionWriteSetPayload.init(code: .direct(writeSet, [DiemContractEvent]()))
        let transactionWriteSetPayload = DiemTransactionPayload.init(payload: .writeSet(writeSetPayload))
        let writeSetPayloadData: Array<UInt8> = [0, 0, 2, 167, 29, 118, 250, 162, 210, 213, 195, 34, 78, 195, 212, 29, 235, 41, 57, 33, 1,
                                                 33, 125, 166, 198, 179, 225, 159, 24, 37, 207, 178, 103, 109, 174, 204, 227, 191, 61, 224,
                                                 60, 242, 102, 71, 199, 141, 240, 11, 55, 27, 37, 204, 151, 0, 196, 198, 63, 128, 199, 75,
                                                 17, 38, 62, 66, 30, 191, 132, 134, 164, 227, 9, 1, 33, 125, 166, 198, 179, 225, 159, 24, 1,
                                                 4, 202, 254, 208, 13, 0]
        
        XCTAssertEqual(transactionWriteSetPayload.serialize().toHexString().lowercased(), Data.init(writeSetPayloadData).toHexString())
        // LibraTransactionPayload_Module
        let module = DiemTransactionPayload.init(payload: .module(DiemTransactionModulePayload.init(code: Data.init(Array<UInt8>(hex: "CAFED00D")))))
        XCTAssertEqual(module.serialize().toHexString().uppercased(), "02CAFED00D")
        let writeSetRaw = DiemRawTransaction.init(senderAddres: "c3398a599a6f3b9f30b635af29f2ba04",
                                                   sequenceNumber: 32,
                                                   maxGasAmount: 0,
                                                   gasUnitPrice: 0,
                                                   expirationTime: UINT64_MAX,
                                                   payload: transactionWriteSetPayload,
                                                   module: "XUS",
                                                   chainID: 4)
        let rawTransactioinWriteSetCheckData: Array<UInt8> = [195, 57, 138, 89, 154, 111, 59, 159, 48, 182, 53, 175, 41, 242, 186, 4, 32, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 167, 29, 118, 250, 162, 210, 213, 195, 34, 78, 195, 212, 29, 235, 41, 57, 33, 1, 33, 125, 166, 198, 179, 225, 159, 24, 37, 207, 178, 103, 109, 174, 204, 227, 191, 61, 224, 60, 242, 102, 71, 199, 141, 240, 11, 55, 27, 37, 204, 151, 0, 196, 198, 63, 128, 199, 75, 17, 38, 62, 66, 30, 191, 132, 134, 164, 227, 9, 1, 33, 125, 166, 198, 179, 225, 159, 24, 1, 4, 202, 254, 208, 13, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 88, 85, 83, 255, 255, 255, 255, 255, 255, 255, 255, 4]
        XCTAssertEqual(writeSetRaw.serialize().toHexString().lowercased(), Data.init(rawTransactioinWriteSetCheckData).toHexString())
        // LibraTransactionPayload_Script
        let transactionScript = DiemTransactionScriptPayload.init(code: ("move".data(using: .utf8)!),
                                                                   typeTags: [DiemTypeTag](),//
                                                                   argruments: [DiemTransactionArgument.init(code: .U64(14627357397735030511))])
        let transactionScriptPayload = DiemTransactionPayload.init(payload: .script(transactionScript))
        let scriptRaw = DiemRawTransaction.init(senderAddres: "3a24a61e05d129cace9e0efc8bc9e338",
                                                 sequenceNumber: 32,
                                                 maxGasAmount: 10000,
                                                 gasUnitPrice: 20000,
                                                 expirationTime: 86400,
                                                 payload: transactionScriptPayload,
                                                 module: "XUS",
                                                 chainID: 4)
        let rawTransactioinScriptCheckData: Array<UInt8> = [58, 36, 166, 30, 5, 209, 41, 202, 206, 158, 14, 252, 139, 201, 227, 56, 32, 0, 0, 0, 0, 0, 0, 0, 1, 4, 109, 111, 118, 101, 0, 1, 1, 239, 190, 173, 222, 13, 208, 254, 202, 16, 39, 0, 0, 0, 0, 0, 0, 32, 78, 0, 0, 0, 0, 0, 0, 3, 88, 85, 83, 128, 81, 1, 0, 0, 0, 0, 0, 4]
        XCTAssertEqual(scriptRaw.serialize().toHexString().lowercased(), Data.init(rawTransactioinScriptCheckData).toHexString())
    }
    func testLibraWallet() {
//        let mnemonic = ["trouble", "menu", "nephew", "group", "alert", "recipe", "hotel", "fatigue", "wet", "shadow", "say", "fold", "huge", "olive", "solution", "enjoy", "garden", "appear", "vague", "joy", "great", "keep", "cactus", "melt"]
                let mnemonic = ["display", "paddle", "crush", "crowd", "often", "friend", "topple", "agent", "entry", "use", "host", "begin"]
        do {
            let seed = try DiemMnemonic.seed(mnemonic: mnemonic)
            let wallet = try DiemHDWallet.init(seed: seed, depth: 0, network: .testnet)
            let walletAddress = wallet.publicKey.toLegacy()
//            2e797751e6ae643d129a854f8c739b72783a439b523f2545d3a71622c9e74b38
//            783a439b523f2545d3a71622c9e74b38
            XCTAssertEqual(walletAddress, "2e9829f376318154bff603ebc8e0b743")
        } catch {
            print(error.localizedDescription)
        }
    }
    func testED25519() {
        let mnemonic = ["net", "dice", "divide", "amount", "stamp", "flock", "brave", "nuclear", "fox", "aim", "father", "apology"]
        do {
            let salt: Array<UInt8> = Array("LIBRA WALLET: mnemonic salt prefix$LIBRA".utf8)
            let mnemonicTemp = mnemonic.joined(separator: " ")
            let dk = try PKCS5.PBKDF2(password: Array(mnemonicTemp.utf8), salt: salt, iterations: 2048, keyLength: 32, variant: .sha3_256).calculate()
            let keyPairManager = Ed25519.calcPublicKey(secretKey: dk)

            print(keyPairManager.sha3(SHA3.Variant.sha256).toHexString())

        } catch {
            print(error)
        }
    }
    func testULEB128() {
        //        XCTAssertEqual(LibraUtils.uleb128Format(length: 128).toHexString(), "8001")
        XCTAssertEqual(DiemUtils.uleb128Format(length: 16384).toHexString(), "808001")
        //        XCTAssertEqual(LibraUtils.uleb128Format(length: 2097152).toHexString(), "80808001")
        //        XCTAssertEqual(LibraUtils.uleb128Format(length: 268435456).toHexString(), "8080808001")
        //        XCTAssertEqual(LibraUtils.uleb128Format(length: 9487).toHexString(), "8f4a")
        print(ViolasUtils.uleb128FormatToInt(data: DiemUtils.uleb128Format(length: 16384)))
        
        XCTAssertEqual(ViolasUtils.uleb128FormatToInt(data: DiemUtils.uleb128Format(length: 128)), 128)
        XCTAssertEqual(ViolasUtils.uleb128FormatToInt(data: DiemUtils.uleb128Format(length: 16384)), 16384)
        XCTAssertEqual(ViolasUtils.uleb128FormatToInt(data: DiemUtils.uleb128Format(length: 2097152)), 2097152)
        XCTAssertEqual(ViolasUtils.uleb128FormatToInt(data: DiemUtils.uleb128Format(length: 268435456)), 268435456)
        XCTAssertEqual(ViolasUtils.uleb128FormatToInt(data: DiemUtils.uleb128Format(length: 9487)), 9487)
    }
    func testBitmap() {
        var tempBitmap = "00000000000000000000000000000000"
        let range = tempBitmap.index(tempBitmap.startIndex, offsetBy: 0)...tempBitmap.index(tempBitmap.startIndex, offsetBy: 0)
        tempBitmap.replaceSubrange(range, with: "1")
        let range2 = tempBitmap.index(tempBitmap.startIndex, offsetBy: 2)...tempBitmap.index(tempBitmap.startIndex, offsetBy: 2)
        tempBitmap.replaceSubrange(range2, with: "1")
        print(tempBitmap)
        let convert = DiemUtils.binary2dec(num: tempBitmap)
        //  101000 00000000 00000000 00000000
        //1000000 00000000 00000000 00000000
        print(BigUInt(convert).serialize().toHexString())
        
        //        var tempData = Data.init(Array<UInt8>(hex: "00"))
        //        var tempData = 0000 | 1
        //        print(tempData)
    }
    func testMultiAddress() {
        let wallet = DiemMultiHDWallet.init(privateKeys: [DiemMultiPrivateKeyModel.init(privateKey: DiemHDPrivateKey.init(privateKey: Array<UInt8>(hex: "f3cdd2183629867d6cfa24fb11c58ad515d5a4af014e96c00bb6ba13d3e5f80e")),
                                                                                        sequence: 1),
                                                          DiemMultiPrivateKeyModel.init(privateKey: DiemHDPrivateKey.init(privateKey: Array<UInt8>(hex: "c973d737cb40bcaf63a45a9736d7d7735e78148a06be185327304d6825e666ea")),
                                                                                        sequence: 2)],
                                            threshold: 1,
                                            network: .testnet)
        XCTAssertEqual(wallet.publicKey.toLegacy(), "cd35f1a78093554f5dc9c61301f204e4")
    }
    func testLibraKitSSO() {
        //        let mnemonic = ["display", "paddle", "crush", "crowd", "often", "friend", "topple", "agent", "entry", "use", "host", "begin"]
        //b90148b7d177538c2f91c9a13d695506 f41799563e5381b693d0885b56ebf19b
        let mnemonic = ["wrist", "post", "hover", "mixed", "like", "update", "salute", "access", "venture", "grant", "another", "team"]
        //2e797751e6ae643d129a854f8c739b72 783a439b523f2545d3a71622c9e74b38
        do {
            let seed = try ViolasMnemonic.seed(mnemonic: mnemonic)
            let wallet = try ViolasHDWallet.init(seed: seed, depth: 0, network: .testnet)
            let walletAddress = wallet.publicKey.toLegacy()
            let active = wallet.publicKey.toAuthKeyPrefix()
            print(walletAddress, active)
            //注册Module
            // 拼接交易
            //            let request = ViolasTransaction.init(sendAddress: wallet.publicKey.toLegacy(),
            //                                                 sequenceNumber: 6,
            //                                                 code: ViolasManager.getCodeData(move: createTokenCode, address: "331321aefcce2ee794430d07d7a953a0"),
            //                                                 test: true)
            //            let signature = try wallet.privateKey.signTransaction(transaction: request.request, wallet: wallet)
            //            print("signature.toHexString() = \(signature.toHexString())")
            // Publish
            //            let request = ViolasTransaction.init(sendAddress: walletAddress,
            //                                                 sequenceNumber: 9,
            //                                                 code: ViolasManager.getCodeData(move: ViolasPublishScriptCode, address: "331321aefcce2ee794430d07d7a953a0"))
            //            let signature = try wallet.privateKey.signTransaction(transaction: request.request, wallet: wallet)
            //            print("signature.toHexString() = \(signature.toHexString())")
            
            //CreateToken
            //            let argument1 = ViolasTransactionArgument.init(code: .Address, value: "331321aefcce2ee794430d07d7a953a0")
            //            let argument3 = ViolasTransactionArgument.init(code: .U8Vector, value: "331321aefcce2ee794430d07d7a953a0")
            //
            //            let script = ViolasTransactionScript.init(code: ViolasManager.getCodeData(move: testCode, address: "331321aefcce2ee794430d07d7a953a0"),
            //                                                      typeTags: [ViolasTypeTag](),
            //                                                      argruments: [argument1, argument3])
            //
            //            let raw = ViolasRawTransaction.init(senderAddres: walletAddress,
            //                                                sequenceNumber: 16,
            //                                                maxGasAmount: 400000,
            //                                                gasUnitPrice: 0,
            //                                                expirationTime: Int(UInt64(Date().timeIntervalSince1970) + 3600),
            //                                                programOrWrite: script.serialize())
            //            let signature = try wallet.privateKey.signTransaction(transaction: raw, wallet: wallet)
            //            print(signature.toHexString())
            // Mint
            //            let argument0 = ViolasTransactionArgument.init(code: .U64, value: "0")
            //
            //            let argument1 = ViolasTransactionArgument.init(code: .Address, value: "331321aefcce2ee794430d07d7a953a0")
            //            let argument2 = ViolasTransactionArgument.init(code: .U64, value: "\(Int(1 * 1000000))")
            //
            //            let argument3 = ViolasTransactionArgument.init(code: .U8Vector, value: "331321aefcce2ee794430d07d7a953a0")
            //
            //            let program = ViolasTransactionScript.init(code: ViolasManager.getCodeData(move: testMintCode, address: "331321aefcce2ee794430d07d7a953a0"),
            //                                                       typeTags: [ViolasTypeTag](),
            //                                                       argruments: [argument0, argument1, argument2, argument3])
            //
            //            let raw = ViolasRawTransaction.init(senderAddres: "331321aefcce2ee794430d07d7a953a0",
            //                                                sequenceNumber: 13,
            //                                                maxGasAmount: 400000,
            //                                                gasUnitPrice: 0,
            //                                                expirationTime: Int(UInt64(Date().timeIntervalSince1970) + 3600),
            //                                                programOrWrite: program.serialize())
            //            let signature = try wallet.privateKey.signTransaction(transaction: raw, wallet: wallet)
            //            print(signature.toHexString())
            //Transfer
            //             拼接交易
            //            let request = ViolasTransaction.init(sendAddress: "fa279f2615270daed6061313a48360f7",
            //                                                 receiveAddress: "7f4644ae2b51b65bd3c9d414aa853407",
            //                                                 amount: 1,
            //                                                 sequenceNumber: 16,
            //                                                 code: ViolasManager.getCodeData(move: ViolasStableCoinScriptCode, address: "e1be1ab8360a35a0259f1c93e3eac736"),
            //                                                 tokenIndex: "0")
            // 签名交易
            //            let signature = try wallet.privateKey.signTransaction(transaction: request.request, wallet: wallet)
            //            print(signature.toHexString())
            let argument0 = ViolasTransactionArgument.init(code: .Address("783a439b523f2545d3a71622c9e74b38"))
            
            let argument1 = ViolasTransactionArgument.init(code: .U8Vector(Data.init(hex: "2e797751e6ae643d129a854f8c739b72")))
            let argument2 = ViolasTransactionArgument.init(code: .Bool(true))
            
            let argument3 = ViolasTransactionArgument.init(code: .U64(1000000))

            let script = ViolasTransactionScriptPayload.init(code: Data.init(hex: ViolasUtils.getMoveCode(name: "create_child_vasp_account")),
                                                             typeTags: [ViolasTypeTag.init(typeTag: ViolasTypeTags.Struct(ViolasStructTag.init(type: ViolasStructTagType.Normal("Coin1"))))],
                                                             argruments: [argument0, argument1, argument2, argument3])
            let transactionPayload = ViolasTransactionPayload.init(payload: .script(script))
            let rawTransaction = ViolasRawTransaction.init(senderAddres: wallet.publicKey.toLegacy(),
                                                           sequenceNumber: 6,
                                                           maxGasAmount: 1000000,
                                                           gasUnitPrice: 10,
                                                           expirationTime: NSDecimalNumber.init(value: Date().timeIntervalSince1970 + 600).uint64Value,
                                                           payload: transactionPayload,
                                                           module: "Coin1",
                                                           chainID: 4)
            let signature = wallet.buildTransaction(transaction: rawTransaction)
            print(signature.toHexString())
        } catch {
            print(error.localizedDescription)
        }
        
    }
    func testLibraKitSingle() {
//        let mnemonic = ["display", "paddle", "crush", "crowd", "often", "friend", "topple", "agent", "entry", "use", "begin", "host"]
        let mnemonic = ["grant", "security", "cluster", "pill", "visit", "wave", "skull", "chase", "vibrant", "embrace", "bronze", "tip"]
//        let mnemonic = ["net", "dice", "divide", "amount", "stamp", "flock", "brave", "nuclear", "fox", "aim", "father", "apology"]
//        let mnemonic = ["trouble", "menu", "nephew", "group", "alert", "recipe", "hotel", "fatigue", "wet", "shadow", "say", "fold", "huge", "olive", "solution", "enjoy", "garden", "appear", "vague", "joy", "great", "keep", "cactus", "melt"]

        do {
            let seed = try DiemMnemonic.seed(mnemonic: mnemonic)
            let wallet = try DiemHDWallet.init(seed: seed, network: .testnet)
            let tempAddress = (wallet.publicKey.raw + Data.init(hex: "00")).bytes.sha3(SHA3.Variant.sha256).toHexString()
            print(tempAddress)
            let signature = try DiemManager.getNormalTransactionHex(sendAddress: "643eb4651234bde53a7d865f61ed96f8",
                                                                    receiveAddress: "6c1dd50f35f120061babc2814cf9378b",
                                                                    amount: 1000000,
                                                                    fee: 1,
                                                                    mnemonic: mnemonic,
                                                                    sequenceNumber: 5,
                                                                    module: "XUS",
                                                                    toSubAddress: "",
                                                                    fromSubAddress: "",
                                                                    referencedEvent: "")
            print(signature)
            print("Success")
        } catch {
            print(error.localizedDescription)
        }
    }
    func testLibraSingleTTT() {
//        var sha3Data = Data.init(Array<UInt8>(hex: (DiemSignSalt.sha3(SHA3.Variant.sha256))))
        let tempPrifix: Array<UInt8> = [15,19,82,119,2,122,140,210,18,111,242,229,12,251,75,124,244,220,177,20,89,178,210,253,180,76,30,216,204,80,56,44,12]
        var sha3Data = Data.init(bytes: tempPrifix, count: tempPrifix.count)
        sha3Data.append("Hello, World".data(using: .utf8)!)

        let privateKey: Array<UInt8> = [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1]
        let data = Ed25519.sign(message: sha3Data.bytes, secretKey: privateKey)
        print(data)
        print("Success")
    }
    func testLibraKitMulti() {
        let mnemonic1 = ["display", "paddle", "crush", "crowd", "often", "friend", "topple", "agent", "entry", "use", "begin", "host"]
//        let mnemonic2 = ["grant", "security", "cluster", "pill", "visit", "wave", "skull", "chase", "vibrant", "embrace", "bronze", "tip"]
        let mnemonic3 = ["net", "dice", "divide", "amount", "stamp", "flock", "brave", "nuclear", "fox", "aim", "father", "apology"]
        do {
            let seed1 = try DiemMnemonic.seed(mnemonic: mnemonic1)
//            let seed2 = try DiemMnemonic.seed(mnemonic: mnemonic2)
            let seed3 = try DiemMnemonic.seed(mnemonic: mnemonic3)
            let seedModel1 = DiemSeedAndDepth.init(seed: seed1, depth: 0, sequence: 0)
//            let seedModel2 = DiemSeedAndDepth.init(seed: seed2, depth: 0, sequence: 1)
            let seedModel3 = DiemSeedAndDepth.init(seed: seed3, depth: 0, sequence: 2)
            let multiPublicKey = DiemMultiPublicKey.init(data: [DiemMultiPublicKeyModel.init(raw: Data.init(Array<UInt8>(hex: "e12136fd95251348cd993b91e8fbf36bcebe9422842f3c505ca2893f5612ae53")), sequence: 0),
                                                                DiemMultiPublicKeyModel.init(raw: Data.init(Array<UInt8>(hex: "ee2586aaaeaaa39ae4eb601999e5c2aade701ac4262f79ac98d9413cce67b0db")), sequence: 1),
                                                                DiemMultiPublicKeyModel.init(raw: Data.init(Array<UInt8>(hex: "d0b27e06a1bf428c380bd10b7469d8b4f251e763724b2543c730abcaea18c8b0")), sequence: 2)],
                                                          threshold: 2,
                                                          network: .testnet)
            let wallet = try DiemMultiHDWallet.init(models: [seedModel1, seedModel3], threshold: 2, multiPublicKey: multiPublicKey, network: .testnet)
            //            let wallet = try LibraMultiHDWallet.init(models: [seedModel1, seedModel2, seedModel3], threshold: 2)
            print("Legacy = \(wallet.publicKey.toLegacy())")
            //0d6a04436002d61228a3b58d3f0ecc71
            print("Authentionkey = \(wallet.publicKey.toAuthKey())")
            //df8c99ad74f921563f3f7242b4a3e4570d6a04436002d61228a3b58d3f0ecc71
            print("PublicKey = \(wallet.publicKey.toMultiPublicKey().toHexString())")
            //e12136fd95251348cd993b91e8fbf36bcebe9422842f3c505ca2893f5612ae53ee2586aaaeaaa39ae4eb601999e5c2aade701ac4262f79ac98d9413cce67b0dbd0b27e06a1bf428c380bd10b7469d8b4f251e763724b2543c730abcaea18c8b002
            let sign = DiemManager.getMultiTransactionHex(sendAddress: multiPublicKey.toLegacy(),
                                                              receiveAddress: "6c1dd50f35f120061babc2814cf9378b",
                                                              amount: 1000000,
                                                              fee: 1,
                                                              sequenceNumber: 9,
                                                              wallet: wallet,
                                                              module: "XUS",
                                                              feeModule: "XUS")
            print(sign)
            print("Success")
        } catch {
            print(error.localizedDescription)
        }
    }
    func testLibraKitPublishModule() {
        print(BigUInt(86400).serialize().bytes)
        //        print("LBR".data(using: .utf8)?.bytes.toHexString())
        //        print("T".data(using: .utf8)?.bytes.toHexString())
        //        let data = Data.init(Array<UInt8>(hex: "76696f6c617301003000fa279f2615270daed6061313a48360f7000000005ea2b35be1be1ab8360a35a0259f1c93e3eac736"))
        //        let string = String.init(data: data, encoding: String.Encoding.utf8)
        //        print(string)
        //        print(LibraUtils.getLengthData(length: Int(20000), appendBytesCount: 8).bytes)
    }
    func testReadMV() {
        let htmlBundlePath = Bundle.main.path(forResource:"MarketContracts", ofType:"bundle") ?? ""
        
        let htmlBundle = Bundle.init(path: htmlBundlePath)
        let path = htmlBundle!.path(forResource:"swap", ofType:"mv", inDirectory:"")
        //        print(path)
        //        let path = Bundle.main.path(forResource: "peer_to_peer_with_metadata", ofType: "mv")
        let data = try! Data.init(contentsOf: URL.init(fileURLWithPath: path!))
        print(data.toHexString())
    }
    func testDe() {
        let model = DiemManager.derializeTransaction(tx: "6c1dd50f35f120061babc2814cf9378b370000000000000001e001a11ceb0b010000000701000202020403061004160205181d0735600895011000000001010000020001000003020301010004010300010501060c0108000506080005030a020a020005060c05030a020a020109000b4469656d4163636f756e741257697468647261774361706162696c6974791b657874726163745f77697468647261775f6361706162696c697479087061795f66726f6d1b726573746f72655f77697468647261775f6361706162696c69747900000000000000000000000000000001010104010c0b0011000c050e050a010a020b030b0438000b0511020201070000000000000000000000000000000103564c5303564c530004033bfb3f8051721b8140631d862a637b2d0140420f00000000000400040040420f0000000000010000000000000003564c533a667560000000000200203068f13177975de372700d554dac59e1cde9efb742bdfa6859ccc6e0e0b3ff3a409ac11f7972a2adb686cfedb0b3c0136182e10ad00ff52210b9d436214fc4d1e3aae032d2b6d4e142e5411e31578feeaeafd0703334502a20b60d21f04948460d")
        print(model)
    }

    func testBTCScript() {
        let script = BTCManager().getBTCScript(address: "c91806cabcd5b2b5fa25ae1c50bed3c6",
                                               type: "0x4000",
                                               tokenContract: "524689a4f870c46d6a5d901b5ac1fdb2",
                                               amount: 10000)
        print(script.toHexString())
        XCTAssertEqual("76696f6c617300034000c91806cabcd5b2b5fa25ae1c50bed3c600000004b40537b6524689a4f870c46d6a5d901b5ac1fdb200000000000027100000", script.toHexString())
        //        76696f6c617300034000c91806cabcd5b2b5fa25ae1c50bed3c600000004b40537b6524689a4f870c46d6a5d901b5ac1fdb200000000000027100000
        //        76696f6c617300034000c91806cabcd5b2b5fa25ae1c50bed3c6000000005f1946f7524689a4f870c46d6a5d901b5ac1fdb200000000000027100000
    }
    func testA() {
        let a: Array<UInt8> = [165, 87, 66, 216, 60, 179, 202, 135, 205,248,242,49,242,45,215,85,52,162,88,139,23,75,32,230,220,65,41,46,146,206,121,229]
        print(Data.init(a).toHexString())
    }
    func testViolasAddCurrency() {
//        let mnemonic = ["display", "paddle", "crush", "crowd", "often", "friend", "topple", "agent", "entry", "use", "host", "begin"]
        //2e797751e6ae643d129a854f8c739b72 783a439b523f2545d3a71622c9e74b38
        let mnemonic = ["wrist", "post", "hover", "mixed", "like", "update", "salute", "access", "venture", "grant", "another", "team"]
        //b90148b7d177538c2f91c9a13d695506 f41799563e5381b693d0885b56ebf19b

        do {
            let seed = try ViolasMnemonic.seed(mnemonic: mnemonic)
            let wallet = try ViolasHDWallet.init(seed: seed, depth: 0, network: .testnet)
            let walletAddress = wallet.publicKey.toLegacy()
            let active = wallet.publicKey.toAuthKeyPrefix()
            print(walletAddress, active)
            let script = ViolasTransactionScriptPayload.init(code: Data.init(hex: ViolasUtils.getMoveCode(name: "add_currency_to_account")),
                                                             typeTags: [ViolasTypeTag.init(typeTag: ViolasTypeTags.Struct(ViolasStructTag.init(type: ViolasStructTagType.Normal("Coin1"))))],
                                                             argruments: [])
            let transactionPayload = ViolasTransactionPayload.init(payload: .script(script))
            
            let rawTransaction = ViolasRawTransaction.init(senderAddres: wallet.publicKey.toLegacy(),
                                                           sequenceNumber: 0,
                                                           maxGasAmount: 1000000,
                                                           gasUnitPrice: 0,
                                                           expirationTime: NSDecimalNumber.init(value: Date().timeIntervalSince1970 + 600).uint64Value,
                                                           payload: transactionPayload,
                                                           module: "Coin1",
                                                           chainID: 2)
            let signature = wallet.buildTransaction(transaction: rawTransaction)
            print(signature.toHexString())
        } catch {
            print(error.localizedDescription)
        }
    }
    func testViolasCreateChildAccount() {
//        let mnemonic = ["display", "paddle", "crush", "crowd", "often", "friend", "topple", "agent", "entry", "use", "host", "begin"]
//        d1b95da976b562694ff66e015ef31296 71d403e7a38e608b03540dd7adf92e10
//        let mnemonic = ["wrist", "post", "hover", "mixed", "like", "update", "salute", "access", "venture", "grant", "another", "team"]
        //0b53278836e90d7f5aaa4346d47b7246 3bfb3f8051721b8140631d862a637b2d
//        let mnemonic = ["net", "dice", "divide", "amount", "stamp", "flock", "brave", "nuclear", "fox", "aim", "father", "apology"]
        //1d0f84eb9752f7d5bf224fe504a35f6e 2da8e2146b015a5986138312baafbc61
        let mnemonic = ["trouble", "menu", "nephew", "group", "alert", "recipe", "hotel", "fatigue", "wet", "shadow", "say", "fold", "huge", "olive", "solution", "enjoy", "garden", "appear", "vague", "joy", "great", "keep", "cactus", "melt"]

        do {
            let seed = try ViolasMnemonic.seed(mnemonic: mnemonic)
            let wallet = try ViolasHDWallet.init(seed: seed, depth: 0, network: .testnet)
            let walletAddress = wallet.publicKey.toLegacy()
            let active = wallet.publicKey.toAuthKeyPrefix()
            print(walletAddress, active)
            let argument0 = ViolasTransactionArgument.init(code: .Address("3bfb3f8051721b8140631d862a637b2d"))
            
            let argument1 = ViolasTransactionArgument.init(code: .U8Vector(Data.init(hex: "0b53278836e90d7f5aaa4346d47b7246")))
            let argument2 = ViolasTransactionArgument.init(code: .Bool(true))
            
            let argument3 = ViolasTransactionArgument.init(code: .U64(1000000))
            
            let script = ViolasTransactionScriptPayload.init(code: Data.init(hex: ViolasUtils.getMoveCode(name: "create_child_vasp_account")),
                                                             typeTags: [ViolasTypeTag.init(typeTag: ViolasTypeTags.Struct(ViolasStructTag.init(type: ViolasStructTagType.Normal("XUS"))))],
                                                             argruments: [argument0, argument1, argument2, argument3])
            let transactionPayload = ViolasTransactionPayload.init(payload: .script(script))
            let rawTransaction = ViolasRawTransaction.init(senderAddres: wallet.publicKey.toLegacy(),
                                                           sequenceNumber: 8,
                                                           maxGasAmount: 1000000,
                                                           gasUnitPrice: 10,
                                                           expirationTime: NSDecimalNumber.init(value: Date().timeIntervalSince1970 + 600).uint64Value,
                                                           payload: transactionPayload,
                                                           module: "XUS",
                                                           chainID: 2)
            let signature = wallet.buildTransaction(transaction: rawTransaction)
            print(signature.toHexString())
        } catch {
            print(error.localizedDescription)
        }
    }
    func testViolasChildLargeTransfer() {
        let mnemonic = ["display", "paddle", "crush", "crowd", "often", "friend", "topple", "agent", "entry", "use", "host", "begin"]
//        d1b95da976b562694ff66e015ef31296 71d403e7a38e608b03540dd7adf92e10
//        let mnemonic = ["wrist", "post", "hover", "mixed", "like", "update", "salute", "access", "venture", "grant", "another", "team"]
        //0b53278836e90d7f5aaa4346d47b7246 3bfb3f8051721b8140631d862a637b2d
//        let mnemonic = ["trouble", "menu", "nephew", "group", "alert", "recipe", "hotel", "fatigue", "wet", "shadow", "say", "fold", "huge", "olive", "solution", "enjoy", "garden", "appear", "vague", "joy", "great", "keep", "cactus", "melt"]

        do {
            let seed = try ViolasMnemonic.seed(mnemonic: mnemonic)
            let wallet = try ViolasHDWallet.init(seed: seed, depth: 0, network: .testnet)
            let walletAddress = wallet.publicKey.toLegacy()
            let active = wallet.publicKey.toAuthKeyPrefix()
            print(walletAddress, active)
            let argument0 = ViolasTransactionArgument.init(code: .Address("3bfb3f8051721b8140631d862a637b2d"))
            
            let argument1 = ViolasTransactionArgument.init(code: .U64(6000_000_000))
            // metadata
            let argument2 = ViolasTransactionArgument.init(code: .U8Vector(Data()))
            // metadata_signature
            let argument3 = ViolasTransactionArgument.init(code: .U8Vector(Data()))
            
            let script = ViolasTransactionScriptPayload.init(code: Data.init(hex: ViolasUtils.getMoveCode(name: "peer_to_peer_with_metadata")),
                                                             typeTags: [ViolasTypeTag.init(typeTag: ViolasTypeTags.Struct(ViolasStructTag.init(type: ViolasStructTagType.Normal("XUS"))))],
                                                             argruments: [argument0, argument1, argument2, argument3])
            let transactionPayload = ViolasTransactionPayload.init(payload: .script(script))
            let rawTransaction = ViolasRawTransaction.init(senderAddres: wallet.publicKey.toLegacy(),
                                                           sequenceNumber: 1,
                                                           maxGasAmount: 1000000,
                                                           gasUnitPrice: 10,
                                                           expirationTime: NSDecimalNumber.init(value: Date().timeIntervalSince1970 + 600).uint64Value,
                                                           payload: transactionPayload,
                                                           module: "XUS",
                                                           chainID: 2)
            let signature = wallet.buildTransaction(transaction: rawTransaction)
            print(signature.toHexString())
        } catch {
            print(error.localizedDescription)
        }
    }
    func testViolasLargeTransfer() {
        let mnemonic = ["display", "paddle", "crush", "crowd", "often", "friend", "topple", "agent", "entry", "use", "host", "begin"]
        //2e797751e6ae643d129a854f8c739b72 783a439b523f2545d3a71622c9e74b38
//        let mnemonic = ["wrist", "post", "hover", "mixed", "like", "update", "salute", "access", "venture", "grant", "another", "team"]
        //b90148b7d177538c2f91c9a13d695506 f41799563e5381b693d0885b56ebf19b
//        let mnemonic = ["trouble", "menu", "nephew", "group", "alert", "recipe", "hotel", "fatigue", "wet", "shadow", "say", "fold", "huge", "olive", "solution", "enjoy", "garden", "appear", "vague", "joy", "great", "keep", "cactus", "melt"]

        do {
            let seed = try DiemMnemonic.seed(mnemonic: mnemonic)
            let wallet = try DiemHDWallet.init(seed: seed, depth: 0, network: .testnet)
            let walletAddress = wallet.publicKey.toLegacy()
            let active = wallet.publicKey.toAuthKey()
            print(walletAddress, active)
            // 拼接交易
            let argument0 = DiemTransactionArgument.init(code: .Address("2da8e2146b015a5986138312baafbc61"))
            let argument1 = DiemTransactionArgument.init(code: .U64(9000_000_000))
//            // metadata
//            let argument2 = LibraTransactionArgument.init(code: .U8Vector("10".data(using: .utf8)!))
//            // metadata_signature
//            let argument3 = LibraTransactionArgument.init(code: .U8Vector(Data.init(hex: "40776041804bfb69ea8f03cdd8b065e51d47aab44e0169826d80ee232fd0fb96f1b9a7431f2e7d4e40270a235548f494568305614012d56302621cdf419bd305")))
            // metadata
            let argument2 = DiemTransactionArgument.init(code: .U8Vector(Data()))
            // metadata_signature
            let argument3 = DiemTransactionArgument.init(code: .U8Vector(Data()))
            let script = DiemTransactionScriptPayload.init(code: Data.init(hex: DiemUtils.getMoveCode(name: "peer_to_peer_with_metadata")),
                                                            typeTags: [DiemTypeTag.init(typeTag: .Struct(DiemStructTag.init(type: .Normal("Coin1"))))],
                                                            argruments: [argument0, argument1, argument2, argument3])
            let transactionPayload = DiemTransactionPayload.init(payload: .script(script))
            let rawTransaction = DiemRawTransaction.init(senderAddres: walletAddress,
                                                          sequenceNumber: 2,
                                                          maxGasAmount: 1000000,
                                                          gasUnitPrice: 10,
                                                          expirationTime: UInt64(Date().timeIntervalSince1970 + 600),
                                                          payload: transactionPayload,
                                                          module: "Coin1",
                                                          chainID: 2)
            let signature = wallet.buildTransaction(transaction: rawTransaction)
            print(signature.toHexString())
        } catch {
            print(error.localizedDescription)
        }
    }
    func testViolasLargeTransferSign() {
//        let mnemonic = ["display", "paddle", "crush", "crowd", "often", "friend", "topple", "agent", "entry", "use", "host", "begin"]
        //2e797751e6ae643d129a854f8c739b72 783a439b523f2545d3a71622c9e74b38
        let mnemonic = ["wrist", "post", "hover", "mixed", "like", "update", "salute", "access", "venture", "grant", "another", "team"]
        //b90148b7d177538c2f91c9a13d695506 f41799563e5381b693d0885b56ebf19b
        do {
            let seed = try ViolasMnemonic.seed(mnemonic: mnemonic)
            let wallet = try ViolasHDWallet.init(seed: seed, depth: 0, network: .testnet)
            var result = Data()
            result += "10".data(using: .utf8)!
            
            result += Data.init(Array<UInt8>(hex: "2e9829f376318154bff603ebc8e0b743"))
            
            result += ViolasUtils.getLengthData(length: NSDecimalNumber.init(string: "10000000000").uint64Value, appendBytesCount: 8)
            
            result += Array("@@$$DIEM_ATTEST$$@@".utf8)

            print(result.toHexString())
            // 4.3签名数据
            let sign = Ed25519.sign(message: result.bytes, secretKey: wallet.privateKey.raw.bytes)
            let testResult = Ed25519.verify(signature: sign, message: result.bytes, publicKey: wallet.publicKey.raw.bytes)
            print(testResult)
            print(sign.toHexString())
        } catch {
            print(error.localizedDescription)
        }
        //3130 2e9829f376318154bff603ebc8e0b743 00e40b5402000000 404024244c494252415f41545445535424244040
        //0a783a439b523f2545d3a71622c9e74b3800e40b540200000014404024244c494252415f4154544553542424404000206865d4cb3f7f71986f60ff3ecc7653c7408844f7ef30c9f9711c89a46df6cf60404a873e9cc638e55e69d09094476b965dda1fc6cb5c382aa183855dff4a3e95d8d571da1d53067456b99c658761f8ca2b4230ef994610836c7cabff32e0438204
    }
    func testViolasLargeTransferSetDualA() {
//        let mnemonic = ["display", "paddle", "crush", "crowd", "often", "friend", "topple", "agent", "entry", "use", "host", "begin"]
        //2e797751e6ae643d129a854f8c739b72 783a439b523f2545d3a71622c9e74b38
        let mnemonic = ["wrist", "post", "hover", "mixed", "like", "update", "salute", "access", "venture", "grant", "another", "team"]
        //b90148b7d177538c2f91c9a13d695506 f41799563e5381b693d0885b56ebf19b
//        let mnemonic = ["trouble", "menu", "nephew", "group", "alert", "recipe", "hotel", "fatigue", "wet", "shadow", "say", "fold", "huge", "olive", "solution", "enjoy", "garden", "appear", "vague", "joy", "great", "keep", "cactus", "melt"]

        do {
            let seed = try ViolasMnemonic.seed(mnemonic: mnemonic)
            let wallet = try ViolasHDWallet.init(seed: seed, depth: 0, network: .testnet)
            let walletAddress = wallet.publicKey.toLegacy()
            let active = wallet.publicKey.toAuthKeyPrefix()
            print(walletAddress, active)
            let argument0 = ViolasTransactionArgument.init(code: .U8Vector("www.google.com".data(using: .utf8)!))
            let argument1 = ViolasTransactionArgument.init(code: .U8Vector(wallet.publicKey.raw))
            let script = ViolasTransactionScriptPayload.init(code: Data.init(hex: ViolasUtils.getMoveCode(name: "rotate_dual_attestation_info")),
                                                             typeTags: [ViolasTypeTag](),
                                                             argruments: [argument0, argument1])
            let transactionPayload = ViolasTransactionPayload.init(payload: .script(script))
            
            let rawTransaction = ViolasRawTransaction.init(senderAddres: wallet.publicKey.toLegacy(),
                                                           sequenceNumber: 1,
                                                           maxGasAmount: 1000000,
                                                           gasUnitPrice: 0,
                                                           expirationTime: NSDecimalNumber.init(value: Date().timeIntervalSince1970 + 600).uint64Value,
                                                           payload: transactionPayload,
                                                           module: "Coin1",
                                                           chainID: 2)
            let signature = wallet.buildTransaction(transaction: rawTransaction)
            print(signature.toHexString())
        } catch {
            print(error.localizedDescription)
        }
    }
    func testLibraBech32() {
        let payload = Data.init(Array<UInt8>(hex: "f72589b71ff4f8d139674a3f7369c69b")) + Data.init(Array<UInt8>(hex: "cf64428bdeb62af2"))
        let cashaddr: String = DiemBech32.encode(payload: payload,
                                                  prefix: "lbr",
                                                  version: 1,
                                                  separator: "1")
        print(cashaddr)
        XCTAssertEqual(cashaddr, "lbr1p7ujcndcl7nudzwt8fglhx6wxn08kgs5tm6mz4usw5p72t")
        do {
            let (prifix, hahah) = try DiemBech32.decode("lbr1p7ujcndcl7nudzwt8fglhx6wxn08kgs5tm6mz4usw5p72t",
                                                         version: 1,
                                                         separator: "1")
            XCTAssertEqual(prifix, "lbr")
            XCTAssertEqual(hahah.dropLast(8).toHexString(), "f72589b71ff4f8d139674a3f7369c69b")
        } catch {
            print(error)
            XCTFail()
        }
    }
    func testLibraKitBech32Address() {
        let mnemonic = ["wrist", "post", "hover", "mixed", "like", "update", "salute", "access", "venture", "grant", "another", "team"]
        do {
            let seed = try ViolasMnemonic.seed(mnemonic: mnemonic)
            let wallet = try ViolasHDWallet.init(seed: seed, depth: 0, network: .testnet)
            print(wallet.publicKey.toQRAddress())
            print(wallet.publicKey.toQRAddress(rootAccount: true))
            let (prifix, hahah) = try ViolasBech32.decode(wallet.publicKey.toQRAddress(),
                                                          version: 1,
                                                          separator: "1")
            XCTAssertEqual(prifix, "lbr")
            XCTAssertEqual(hahah.dropLast(8).toHexString(), "f41799563e5381b693d0885b56ebf19b")
        } catch {
            XCTFail()
        }
    }
    func testDecode() {
        do {
            let (prifix, hahah) = try ViolasBech32.decode("tlb1pdswa2re47ysqvxatc2q5e7fh30l7edxa7r0lvnqxz04rj",
                                                          version: 1,
                                                          separator: "1")
            XCTAssertEqual(prifix, "tlb")
            print(hahah.toHexString())
            XCTAssertEqual(hahah.dropLast(8).toHexString(), "6c1dd50f35f120061babc2814cf9378b")
        } catch {
            XCTFail()
        }
    }
    func testMetaDataToSubAddress() {
        let fromSubAddress = ""
        let toSubAddress = "8f8b82153010a1bd"
        let referencedEvent = ""
        let metadataV0 = DiemGeneralMetadataV0.init(to_subaddress: toSubAddress,
                                                     from_subaddress: fromSubAddress,
                                                     referenced_event: referencedEvent)
        let metadata = DiemMetadata.init(code: DiemMetadataTypes.GeneralMetadata(DiemGeneralMetadata.init(code: .GeneralMetadataVersion0(metadataV0))))
        let tempMetadata = metadata.serialize().toHexString()
        print(tempMetadata)
        
        XCTAssertEqual(tempMetadata, "010001088f8b82153010a1bd0000")
    }
    func testMetaDataFromSubAddress() {
        let fromSubAddress = "8f8b82153010a1bd"
        let toSubAddress = ""
        let referencedEvent = ""
        let metadataV0 = DiemGeneralMetadataV0.init(to_subaddress: toSubAddress,
                                                     from_subaddress: fromSubAddress,
                                                     referenced_event: referencedEvent)
        let metadata = DiemMetadata.init(code: DiemMetadataTypes.GeneralMetadata(DiemGeneralMetadata.init(code: .GeneralMetadataVersion0(metadataV0))))
        let tempMetadata = metadata.serialize().toHexString()
        print(tempMetadata)
        
        XCTAssertEqual(tempMetadata, "01000001088f8b82153010a1bd00")
    }
    func testMetaDataFromToSubAddress() {
        let fromSubAddress = "8f8b82153010a1bd"
        let toSubAddress = "111111153010a111"
        let referencedEvent = ""
        let metadataV0 = DiemGeneralMetadataV0.init(to_subaddress: toSubAddress,
                                                     from_subaddress: fromSubAddress,
                                                     referenced_event: referencedEvent)
        let metadata = DiemMetadata.init(code: DiemMetadataTypes.GeneralMetadata(DiemGeneralMetadata.init(code: .GeneralMetadataVersion0(metadataV0))))
        let tempMetadata = metadata.serialize().toHexString()
        print(tempMetadata)
        //010001088f8b82153010a1bd0108111111153010a11100
        //01000108111111153010a11101088f8b82153010a1bd00
        XCTAssertEqual(tempMetadata, "01000108111111153010a11101088f8b82153010a1bd00")
    }
    func testMetaDataReferencedEvent() {
        // 测试退款
        let fromSubAddress = "8f8b82153010a1bd"
        let toSubAddress = "111111153010a111"
        let referencedEvent = "324"
        let metadataV0 = DiemGeneralMetadataV0.init(to_subaddress: fromSubAddress,
                                                    from_subaddress: toSubAddress,
                                                    referenced_event: referencedEvent)
        let metadata = DiemMetadata.init(code: DiemMetadataTypes.GeneralMetadata(DiemGeneralMetadata.init(code: .GeneralMetadataVersion0(metadataV0))))
        let tempMetadata = metadata.serialize().toHexString()
        print(tempMetadata)
        
        //010001088f8b82153010a1bd0108111111153010a111014401000000000000
        //010001088f8b82153010a1bd0108111111153010a111014401000000000000
        XCTAssertEqual(tempMetadata, "010001088f8b82153010a1bd0108111111153010a111014401000000000000")
    }
    func testMetaTravelRuleMetadata() {
        let address = "f72589b71ff4f8d139674a3f7369c69b"
        let referenceID = "off chain reference id"
        let amount: UInt64 = 1000
        let TravelRuleMetadataV0 = DiemTravelRuleMetadataV0.init(off_chain_reference_id: referenceID)
        let metadata = DiemMetadata.init(code: DiemMetadataTypes.TravelRuleMetadata(DiemTravelRuleMetadata.init(code: .TravelRuleMetadataVersion0(TravelRuleMetadataV0))))
        let tempMetadata = metadata.serialize()
        print(tempMetadata.toHexString())
        XCTAssertEqual(tempMetadata.toHexString(), "020001166f666620636861696e207265666572656e6365206964")
        let amountData = DiemUtils.getLengthData(length: NSDecimalNumber.init(value: amount).uint64Value, appendBytesCount: 8)
        let sigMessage = tempMetadata + Data.init(Array<UInt8>(hex: address)) + amountData + "@@$$DIEM_ATTEST$$@@".data(using: .utf8)!
        print(sigMessage.toHexString())
        XCTAssertEqual(sigMessage.toHexString(), "020001166f666620636861696e207265666572656e6365206964f72589b71ff4f8d139674a3f7369c69be803000000000000404024244449454d5f41545445535424244040")
    }
    func testUnstructuredBytesMetadata() {        
        let unstruct = DiemUnstructuredBytesMetadata.init(code: "abcd".data(using: .utf8)!)
        let metadata = DiemMetadata.init(code: DiemMetadataTypes.UnstructuredBytesMetadata(unstruct))
        
        print(metadata.serialize().toHexString())
        XCTAssertEqual(metadata.serialize().toHexString(), "03010461626364")
    }
    func testRefundMetadata() {
        let refund = DiemRefundMetadata.init(code: .RefundMetadataV0(DiemRefundMetadataV0.init(transaction_version: 12343,
                                                                                               reason: .UserInitiatedFullRefund)))
        let metadata = DiemMetadata.init(code: DiemMetadataTypes.RefundMetadata(refund))
        
        print(metadata.serialize().toHexString())
        XCTAssertEqual(metadata.serialize().toHexString(), "0400373000000000000003")
    }
    func testCoinTradeMetadata() {
        let coinTrade = DiemCoinTradeMetadata.init(code: DiemCoinTradeMetadataTypes.CoinTradeMetadataV0(DiemCoinTradeMetadataV0.init(trade_ids: ["abc", "efg"])))
        let metadata = DiemMetadata.init(code: DiemMetadataTypes.CoinTradeMetadata(coinTrade))
        
        print(metadata.serialize().toHexString())
        XCTAssertEqual(metadata.serialize().toHexString(), "0500020361626303656667")
    }
    func testLibraNCToCTransaction() {
        let mnemonic = ["wrist", "post", "hover", "mixed", "like", "update", "salute", "access", "venture", "grant", "another", "team"]
        do {
            let seed = try DiemMnemonic.seed(mnemonic: mnemonic)
            let wallet = try DiemHDWallet.init(seed: seed, depth: 0, network: .testnet)
            let walletAddress = wallet.publicKey.toLegacy()
            // 拼接交易
            let argument0 = DiemTransactionArgument.init(code: .Address("46147770d00885b622e2ccfd56e0583f"))
            let argument1 = DiemTransactionArgument.init(code: .U64(11000000))
            
            let fromSubAddress = ""
            let toSubAddress = "b990f3550ab6da64"
            let referencedEvent = ""
            let metadataV0 = DiemGeneralMetadataV0.init(to_subaddress: toSubAddress,
                                                         from_subaddress: fromSubAddress,
                                                         referenced_event: referencedEvent)
            let metadata = DiemMetadata.init(code: DiemMetadataTypes.GeneralMetadata(DiemGeneralMetadata.init(code: .GeneralMetadataVersion0(metadataV0))))
            // metadata
            let argument2 = DiemTransactionArgument.init(code: .U8Vector(metadata.serialize()))
            // metadata_signature
            let argument3 = DiemTransactionArgument.init(code: .U8Vector(Data()))
            let script = DiemTransactionScriptPayload.init(code: Data.init(hex: DiemUtils.getMoveCode(name: "peer_to_peer_with_metadata")),
                                                            typeTags: [DiemTypeTag.init(typeTag: .Struct(DiemStructTag.init(type: .Normal("Coin1"))))],
                                                            argruments: [argument0, argument1, argument2, argument3])
            let transactionPayload = DiemTransactionPayload.init(payload: .script(script))
            let rawTransaction = DiemRawTransaction.init(senderAddres: walletAddress,
                                                          sequenceNumber: 7,
                                                          maxGasAmount: 1000000,
                                                          gasUnitPrice: 10,
                                                          expirationTime: UInt64(Date().timeIntervalSince1970 + 600),
                                                          payload: transactionPayload,
                                                          module: "Coin1",
                                                          chainID: 2)
            let signature = wallet.buildTransaction(transaction: rawTransaction)
            print(signature.toHexString())
        } catch {
            
        }
    }
    func testDiemRotateAuthenticationKeyTransaction() {
//        let mnemonic1 = ["display", "paddle", "crush", "crowd", "often", "friend", "topple", "agent", "entry", "use", "begin", "host"]
        let mnemonic2 = ["grant", "security", "cluster", "pill", "visit", "wave", "skull", "chase", "vibrant", "embrace", "bronze", "tip"]
        let mnemonic3 = ["net", "dice", "divide", "amount", "stamp", "flock", "brave", "nuclear", "fox", "aim", "father", "apology"]
        do {
            let seed = try DiemMnemonic.seed(mnemonic: mnemonic2)
            let wallet = try DiemHDWallet.init(seed: seed, depth: 0, network: .testnet)
            let seed3 = try DiemMnemonic.seed(mnemonic: mnemonic3)
            let wallet3 = try DiemHDWallet.init(seed: seed3, depth: 0, network: .testnet)
            let walletAddress = wallet.publicKey.toLegacy()
            // 拼接交易
            
            let argument0 = DiemTransactionArgument.init(code: .U8Vector(Data.init(Array<UInt8>(hex: wallet.publicKey.toAuthKey()))))
            let script = DiemTransactionScriptPayload.init(code: Data.init(hex: DiemUtils.getMoveCode(name: "rotate_authentication_key")),
                                                           typeTags: [DiemTypeTag](),
                                                           argruments: [argument0])
            let transactionPayload = DiemTransactionPayload.init(payload: .script(script))
            let rawTransaction = DiemRawTransaction.init(senderAddres: walletAddress,
                                                         sequenceNumber: 2,
                                                         maxGasAmount: 1000000,
                                                         gasUnitPrice: 10,
                                                         expirationTime: UInt64(Date().timeIntervalSince1970 + 600),
                                                         payload: transactionPayload,
                                                         module: "XUS",
                                                         chainID: 2)
            let signature = wallet3.buildTransaction(transaction: rawTransaction)
            print(signature.toHexString())
        } catch {
            
        }
    }
    func testAuthKey() {
        let privateKey = Data.init(Array<UInt8>(hex: "b4ed5891b9853b4a87ab19cdca87090d9d98b57c44588f193046da4e13b4302b"))
        let key = ViolasHDPrivateKey.init(privateKey: privateKey.bytes)
        print(key.extendedPublicKey(network: .premainnet).toAuthKey())
        //ac992b6f0c025f712683e0533bfda6c8
        //b307e9866f89bbc005aa3d9a780254ca
    }
    func testU128() {
        let vug = BigInt.init("11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111", radix: 2)//BigNumber.init(Data.init(Array<UInt8>(hex: "ffffffffffffffffffffffffffffffffffffffff")))
        print(vug?.serialize() ?? "")
        //18446744073709551615
        //18446744073709551615
        //340282366920938463463374607431768211455
        //340282366920938463463374607431768211455
    }
}
