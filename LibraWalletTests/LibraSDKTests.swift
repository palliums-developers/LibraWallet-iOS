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
    func testLibra() {
        //LibraTransactionArgument
        // u64
        let amount = LibraTransactionArgument.init(code: .U64("9213671392124193148")).serialize().toHexString().uppercased()
        XCTAssertEqual(amount, "017CC9BDA45089DD7F")
        // Address
        let address = LibraTransactionArgument.init(code: .Address("bafc671e8a38c05706f83b5159bbd8a4")).serialize().toHexString()
        XCTAssertEqual(address  , "03bafc671e8a38c05706f83b5159bbd8a4")
        // U8Vector
        let u8vector = LibraTransactionArgument.init(code: .U8Vector(Data.init(Array<UInt8>(hex: "CAFED00D")))).serialize().toHexString().uppercased()
        XCTAssertEqual(u8vector, "0404CAFED00D")
        // Bool
        let bool1 = LibraTransactionArgument.init(code: .Bool(false)).serialize().toHexString().uppercased()
        XCTAssertEqual(bool1, "0500")
        // Bool
        let bool2 = LibraTransactionArgument.init(code: .Bool(true)).serialize().toHexString().uppercased()
        XCTAssertEqual(bool2, "0501")
        //LibraTransactionAccessPath
        let accessPath1 = LibraAccessPath.init(address: "a71d76faa2d2d5c3224ec3d41deb2939",
                                               path: "01217da6c6b3e19f1825cfb2676daecce3bf3de03cf26647c78df00b371b25cc97",
                                               writeOp: .Deletion)
        let accessPath2 = LibraAccessPath.init(address: "c4c63f80c74b11263e421ebf8486a4e3",
                                               path: "01217da6c6b3e19f18",
                                               writeOp: .Value(Data.init(Array<UInt8>(hex: "CAFED00D"))))
        let writeSet = LibraWriteSet.init(accessPaths: [accessPath1, accessPath2])
        let writeSetCheckData: Array<UInt8> = [0x02, 0xA7, 0x1D, 0x76, 0xFA, 0xA2, 0xD2, 0xD5, 0xC3, 0x22, 0x4E, 0xC3, 0xD4, 0x1D, 0xEB,
                                               0x29, 0x39, 0x21, 0x01, 0x21, 0x7D, 0xA6, 0xC6, 0xB3, 0xE1, 0x9F, 0x18, 0x25, 0xCF, 0xB2,
                                               0x67, 0x6D, 0xAE, 0xCC, 0xE3, 0xBF, 0x3D, 0xE0, 0x3C, 0xF2, 0x66, 0x47, 0xC7, 0x8D, 0xF0,
                                               0x0B, 0x37, 0x1B, 0x25, 0xCC, 0x97, 0x00, 0xC4, 0xC6, 0x3F, 0x80, 0xC7, 0x4B, 0x11, 0x26,
                                               0x3E, 0x42, 0x1E, 0xBF, 0x84, 0x86, 0xA4, 0xE3, 0x09, 0x01, 0x21, 0x7D, 0xA6, 0xC6, 0xB3,
                                               0xE1, 0x9F, 0x18, 0x01, 0x04, 0xCA, 0xFE, 0xD0, 0x0D]
        XCTAssertEqual(writeSet.serialize().toHexString().lowercased(), Data.init(writeSetCheckData).toHexString())
        // LibraTransactionPayload_WriteSet
        let writeSetPayload = LibraTransactionWriteSetPayload.init(code: .direct(writeSet, [LibraContractEvent]()))
        let transactionWriteSetPayload = LibraTransactionPayload.init(payload: .writeSet(writeSetPayload))
        let writeSetPayloadData: Array<UInt8> = [0, 0, 2, 167, 29, 118, 250, 162, 210, 213, 195, 34, 78, 195, 212, 29, 235, 41, 57, 33, 1,
                                                 33, 125, 166, 198, 179, 225, 159, 24, 37, 207, 178, 103, 109, 174, 204, 227, 191, 61, 224,
                                                 60, 242, 102, 71, 199, 141, 240, 11, 55, 27, 37, 204, 151, 0, 196, 198, 63, 128, 199, 75,
                                                 17, 38, 62, 66, 30, 191, 132, 134, 164, 227, 9, 1, 33, 125, 166, 198, 179, 225, 159, 24, 1,
                                                 4, 202, 254, 208, 13, 0]
        
        XCTAssertEqual(transactionWriteSetPayload.serialize().toHexString().lowercased(), Data.init(writeSetPayloadData).toHexString())
        // LibraTransactionPayload_Module
        let module = LibraTransactionPayload.init(payload: .module(LibraTransactionModulePayload.init(code: Data.init(Array<UInt8>(hex: "CAFED00D")))))
        XCTAssertEqual(module.serialize().toHexString().uppercased(), "02CAFED00D")
        let writeSetRaw = LibraRawTransaction.init(senderAddres: "c3398a599a6f3b9f30b635af29f2ba04",
                                                   sequenceNumber: 32,
                                                   maxGasAmount: 0,
                                                   gasUnitPrice: 0,
                                                   expirationTime: UINT64_MAX,
                                                   payload: transactionWriteSetPayload,
                                                   module: "LBR",
                                                   chainID: 4)
        let rawTransactioinWriteSetCheckData: Array<UInt8> = [195, 57, 138, 89, 154, 111, 59, 159, 48, 182, 53, 175, 41, 242, 186, 4, 32, 0, 0, 0, 0, 0,
                                               0, 0, 0, 0, 2, 167, 29, 118, 250, 162, 210, 213, 195, 34, 78, 195, 212, 29, 235, 41, 57,
                                               33, 1, 33, 125, 166, 198, 179, 225, 159, 24, 37, 207, 178, 103, 109, 174, 204, 227, 191,
                                               61, 224, 60, 242, 102, 71, 199, 141, 240, 11, 55, 27, 37, 204, 151, 0, 196, 198, 63, 128,
                                               199, 75, 17, 38, 62, 66, 30, 191, 132, 134, 164, 227, 9, 1, 33, 125, 166, 198, 179, 225,
                                               159, 24, 1, 4, 202, 254, 208, 13, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 76,
                                               66, 82, 255, 255, 255, 255, 255, 255, 255, 255, 4]
        XCTAssertEqual(writeSetRaw.serialize().toHexString().lowercased(), Data.init(rawTransactioinWriteSetCheckData).toHexString())
        // LibraTransactionPayload_Script
        let transactionScript = LibraTransactionScriptPayload.init(code: ("move".data(using: .utf8)!),
                                                                   typeTags: [LibraTypeTag](),//
                                                                   argruments: [LibraTransactionArgument.init(code: .U64("14627357397735030511"))])
        let transactionScriptPayload = LibraTransactionPayload.init(payload: .script(transactionScript))
        let scriptRaw = LibraRawTransaction.init(senderAddres: "3a24a61e05d129cace9e0efc8bc9e338",
                                                 sequenceNumber: 32,
                                                 maxGasAmount: 10000,
                                                 gasUnitPrice: 20000,
                                                 expirationTime: 86400,
                                                 payload: transactionScriptPayload,
                                                 module: "LBR",
                                                 chainID: 4)
        let rawTransactioinScriptCheckData: Array<UInt8> = [58, 36, 166, 30, 5, 209, 41, 202, 206, 158, 14, 252, 139, 201, 227, 56, 32, 0, 0, 0, 0, 0,
        0, 0, 1, 4, 109, 111, 118, 101, 0, 1, 1, 239, 190, 173, 222, 13, 208, 254, 202, 16, 39, 0,
        0, 0, 0, 0, 0, 32, 78, 0, 0, 0, 0, 0, 0, 3, 76, 66, 82, 128, 81, 1, 0, 0, 0, 0, 0, 4]
        XCTAssertEqual(scriptRaw.serialize().toHexString().lowercased(), Data.init(rawTransactioinScriptCheckData).toHexString())

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
    func testKeychainReinstallGetPasswordAndMnemonic() {
        let mnemonic = ["legal","winner","thank","year","wave","sausage","worth","useful","legal","winner","thank","year","wave","sausage","worth","useful","legal","will"]
        do {
            let seed = try LibraMnemonic.seed(mnemonic: mnemonic)
            
            let testWallet = try LibraHDWallet.init(seed: seed, depth: 0)
            let walletAddress = testWallet.publicKey.toAddress()            
            
            //            let menmonicString = try KeychainManager.KeyManager.getMnemonicStringFromKeychain(walletAddress: walletAddress)
            //            let mnemonicArray = menmonicString.split(separator: " ").compactMap { (item) -> String in
            //                return "\(item)"
            //            }
            //            XCTAssertEqual(mnemonic, mnemonicArray)
            
        } catch {
            print(error.localizedDescription)
        }
        
    }
    func testULEB128() {
        //        XCTAssertEqual(LibraUtils.uleb128Format(length: 128).toHexString(), "8001")
        XCTAssertEqual(LibraUtils.uleb128Format(length: 16384).toHexString(), "808001")
        //        XCTAssertEqual(LibraUtils.uleb128Format(length: 2097152).toHexString(), "80808001")
        //        XCTAssertEqual(LibraUtils.uleb128Format(length: 268435456).toHexString(), "8080808001")
        //        XCTAssertEqual(LibraUtils.uleb128Format(length: 9487).toHexString(), "8f4a")
        print(ViolasUtils.uleb128FormatToInt(data: LibraUtils.uleb128Format(length: 16384)))
        
        XCTAssertEqual(ViolasUtils.uleb128FormatToInt(data: LibraUtils.uleb128Format(length: 128)), 128)
        XCTAssertEqual(ViolasUtils.uleb128FormatToInt(data: LibraUtils.uleb128Format(length: 16384)), 16384)
        XCTAssertEqual(ViolasUtils.uleb128FormatToInt(data: LibraUtils.uleb128Format(length: 2097152)), 2097152)
        XCTAssertEqual(ViolasUtils.uleb128FormatToInt(data: LibraUtils.uleb128Format(length: 268435456)), 268435456)
        XCTAssertEqual(ViolasUtils.uleb128FormatToInt(data: LibraUtils.uleb128Format(length: 9487)), 9487)
    }
    func testBitmap() {
        var tempBitmap = "00000000000000000000000000000000"
        let range = tempBitmap.index(tempBitmap.startIndex, offsetBy: 0)...tempBitmap.index(tempBitmap.startIndex, offsetBy: 0)
        tempBitmap.replaceSubrange(range, with: "1")
        let range2 = tempBitmap.index(tempBitmap.startIndex, offsetBy: 2)...tempBitmap.index(tempBitmap.startIndex, offsetBy: 2)
        tempBitmap.replaceSubrange(range2, with: "1")
        print(tempBitmap)
        let convert = LibraUtils.binary2dec(num: tempBitmap)
        //  101000 00000000 00000000 00000000
        //1000000 00000000 00000000 00000000
        print(BigUInt(convert).serialize().toHexString())
        
        //        var tempData = Data.init(Array<UInt8>(hex: "00"))
        //        var tempData = 0000 | 1
        //        print(tempData)
    }
    func testMultiAddress() {
        let wallet = LibraMultiHDWallet.init(privateKeys: [LibraMultiPrivateKeyModel.init(raw: Data.init(Array<UInt8>(hex: "f3cdd2183629867d6cfa24fb11c58ad515d5a4af014e96c00bb6ba13d3e5f80e")),
                                                                                          sequence: 1),
                                                           LibraMultiPrivateKeyModel.init(raw: Data.init(Array<UInt8>(hex: "c973d737cb40bcaf63a45a9736d7d7735e78148a06be185327304d6825e666ea")),
                                                                                          sequence: 2)],
                                             threshold: 1)
        XCTAssertEqual(wallet.publicKey.toLegacy(), "cd35f1a78093554f5dc9c61301f204e4")
    }
    func testLibraKit() {
        let mnemonic = ["display", "paddle", "crush", "crowd", "often", "friend", "topple", "agent", "entry", "use", "host", "begin"]
        do {
            let seed = try ViolasMnemonic.seed(mnemonic: mnemonic)
            let wallet = try ViolasHDWallet.init(seed: seed, depth: 0)
            let walletAddress = wallet.publicKey.toLegacy()
            let active = wallet.publicKey.toActive()
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
        } catch {
            print(error.localizedDescription)
        }
        
    }
    func testLibraKitMulti() {
        let mnemonic1 = ["display", "paddle", "crush", "crowd", "often", "friend", "topple", "agent", "entry", "use", "begin", "host"]
        let mnemonic2 = ["grant", "security", "cluster", "pill", "visit", "wave", "skull", "chase", "vibrant", "embrace", "bronze", "tip"]
        let mnemonic3 = ["net", "dice", "divide", "amount", "stamp", "flock", "brave", "nuclear", "fox", "aim", "father", "apology"]
        do {
            let seed1 = try LibraMnemonic.seed(mnemonic: mnemonic1)
            let seed2 = try LibraMnemonic.seed(mnemonic: mnemonic2)
            let seed3 = try LibraMnemonic.seed(mnemonic: mnemonic3)
            let seedModel1 = LibraSeedAndDepth.init(seed: seed1, depth: 0, sequence: 0)
            let seedModel2 = LibraSeedAndDepth.init(seed: seed2, depth: 0, sequence: 1)
            let seedModel3 = LibraSeedAndDepth.init(seed: seed3, depth: 0, sequence: 2)
            let multiPublicKey = LibraMultiPublicKey.init(data: [LibraMultiPublicKeyModel.init(raw: Data.init(Array<UInt8>(hex: "2bd7d9fe82120842daa860606060661b222824c65af7bfb2843eeb7792a3b967")), sequence: 0),
                                                                 LibraMultiPublicKeyModel.init(raw: Data.init(Array<UInt8>(hex: "50b715879a727bbc561786b0dc9e6afcd5d8a443da6eb632952e692b83e8e7cb")), sequence: 1),
                                                                 LibraMultiPublicKeyModel.init(raw: Data.init(Array<UInt8>(hex: "e7e1b22eeb0a9ce0c49e3bf6cf23ebbb4d93d24c2064c46f6ceb9daa6ca2e217")), sequence: 2)],
                                                          threshold: 2)
            let wallet = try LibraMultiHDWallet.init(models: [seedModel1, seedModel3], threshold: 2, multiPublicKey: multiPublicKey)
            //            let wallet = try LibraMultiHDWallet.init(models: [seedModel1, seedModel2, seedModel3], threshold: 2)
            print("Legacy = \(wallet.publicKey.toLegacy())")
            //bafc671e8a38c05706f83b5159bbd8a4
            print("Authentionkey = \(wallet.publicKey.toActive())")
            //bf2128295b7a57e6e42390d56293760cbafc671e8a38c05706f83b5159bbd8a4
            print("PublicKey = \(wallet.publicKey.toMultiPublicKey().toHexString())")
            //2bd7d9fe82120842daa860606060661b222824c65af7bfb2843eeb7792a3b96750b715879a727bbc561786b0dc9e6afcd5d8a443da6eb632952e692b83e8e7cbe7e1b22eeb0a9ce0c49e3bf6cf23ebbb4d93d24c2064c46f6ceb9daa6ca2e21702
            
            //            let sign = try LibraManager.getMultiTransactionHex(sendAddress: multiPublicKey.toLegacy(),
            //                                                               receiveAddress: "331321aefcce2ee794430d07d7a953a0",
            //                                                               amount: 0.5,
            //                                                               fee: 0,
            //                                                               sequenceNumber: 8,
            //                                                               wallet: wallet)
            //            print(sign)
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
        let model = LibraManager.derializeTransaction(tx: "793fdd2c245229230fd52aca841875b3080000000000000002f401a11ceb0b010007014600000002000000034800000011000000045900000004000000055d0000001c00000007790000004900000008c20000001000000009d200000022000000000000010001010100020203000003040101010006020602050a0200010501010405030a020a0205050a02030a020a020109000c4c696272614163636f756e74166372656174655f746573746e65745f6163636f756e74066578697374731d7061795f66726f6d5f73656e6465725f776974685f6d6574616461746100000000000000000000000000000000010105010e000a001101200305000508000a000b0138000a000a020b030b04380102010700000000000000000000000000000000034c42520154000503fa279f2615270daed6061313a48360f704000100e1f505000000000400040040420f00000000000000000000000000034c4252eb27cf5e0000000000200825e33e0e828cb8869cf5ca22bb5360cc5edeba621a1cde8f13ed179ce8135f402f957968ff0d3d2c780ee003dbd23ea38d8dee62a64f2de376eb969a0049fad35e24410031346ef0f22fce5dd50f98511a542ccb95e473ba864d1123ab35630c")
        print(model)
    }
    func testMarketTransaction() {
        //        let signature = try librama
        let mnemonic1 = ["display", "paddle", "crush", "crowd", "often", "friend", "topple", "agent", "entry", "use", "host", "begin"]
        let signature = try! ViolasManager.getMarketAddLiquidityTransactionHex(sendAddress: "fa279f2615270daed6061313a48360f7",
                                                                               fee: 0,
                                                                               mnemonic: mnemonic1,
                                                                               amounta_desired: 5000,
                                                                               amountb_desired: 5000,
                                                                               amounta_min: 1,
                                                                               amountb_min: 1,
                                                                               sequenceNumber: 67,
                                                                               moduleA: "VLSUSD",
                                                                               moduleB: "VLSGBP",
                                                                               feeModule: "LBR")
        //        let signature = try! ViolasManager.getMarketRemoveLiquidityTransactionHex(sendAddress: "fa279f2615270daed6061313a48360f7",
        //                                                                                  fee: 0,
        //                                                                                  mnemonic: mnemonic1,
        //                                                                                  liquidity: 2,
        //                                                                                  amounta_min: 1,
        //                                                                                  amountb_min: 1,
        //                                                                                  sequenceNumber: 9,
        //                                                                                  moduleA: "VLSUSD",
        //                                                                                  moduleB: "VLSEUR",
        //                                                                                  feeModule: "LBR")
        //        let signature = try! ViolasManager.getMarketSwapTransactionHex(sendAddress: "fa279f2615270daed6061313a48360f7",
        //                                                                           amountIn: 2,
        //                                                                           amountOutMin: 1,
        //                                                                           path: [0,1],
        //                                                                           fee: 0,
        //                                                                           mnemonic: mnemonic1,
        //                                                                           sequenceNumber: 30,
        //                                                                           moduleA: "VLSUSD",
        //                                                                           moduleB: "VLSEUR",
        //                                                                           feeModule: "LBR")
        print(signature)
    }
    func testMarketMappingTransaction() {
        let mnemonic = ["display", "paddle", "crush", "crowd", "often", "friend", "topple", "agent", "entry", "use", "host", "begin"]
        let signature = try! ViolasManager.getViolasToLibraMappingTransactionHex(sendAddress: "fa279f2615270daed6061313a48360f7",
                                                                                 module: "VLSUSD",
                                                                                 amountIn: 15,
                                                                                 amountOut: 14,
                                                                                 fee: 0,
                                                                                 mnemonic: mnemonic,
                                                                                 sequenceNumber: 94,
                                                                                 exchangeCenterAddress: "dc49a7c8979f83cde4bc229fb35fd27f",
                                                                                 libraReceiveAddress: "fa279f2615270daed6061313a48360f7",
                                                                                 feeModule: "LBR",
                                                                                 type: "v2lusd")
        //        let signature = try! LibraManager.getLibraToViolasMappingTransactionHex(sendAddress: "fa279f2615270daed6061313a48360f7",
        //                                                                         module: "LBR",
        //                                                                         amountIn: 10,
        //                                                                         amountOut: 10,
        //                                                                         fee: 0,
        //                                                                         mnemonic: mnemonic,
        //                                                                         sequenceNumber: 6,
        //                                                                         exchangeCenterAddress: "c5e53097c9f82f81513d02eeb515ecce",
        //                                                                         violasReceiveAddress: "fa279f2615270daed6061313a48360f7",
        //                                                                         feeModule: "LBR",
        //                                                                         type: "l2vusd")
        
        print(signature)
        
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
}
