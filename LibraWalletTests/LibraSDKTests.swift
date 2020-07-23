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
        let amount = LibraTransactionArgument.init(code: .U64, value: "9213671392124193148").serialize().toHexString().uppercased()
        XCTAssertEqual(amount, "017CC9BDA45089DD7F")
        // Address
        let address = LibraTransactionArgument.init(code: .Address, value: "bafc671e8a38c05706f83b5159bbd8a4").serialize().toHexString()
        XCTAssertEqual(address  , "03bafc671e8a38c05706f83b5159bbd8a4")
        // U8Vector
        let u8vector = LibraTransactionArgument.init(code: .U8Vector, value: "CAFED00D").serialize().toHexString().uppercased()
        XCTAssertEqual(u8vector, "0404CAFED00D")
        // Bool
        let bool1 = LibraTransactionArgument.init(code: .Bool, value: "00").serialize().toHexString().uppercased()
        XCTAssertEqual(bool1, "0500")
        // Bool
        let bool2 = LibraTransactionArgument.init(code: .Bool, value: "01").serialize().toHexString().uppercased()
        XCTAssertEqual(bool2, "0501")
        //LibraTransactionAccessPath
        let accessPath1 = LibraTransactionAccessPath.init(address: "a71d76faa2d2d5c3224ec3d41deb2939",
                                                          path: "01217da6c6b3e19f1825cfb2676daecce3bf3de03cf26647c78df00b371b25cc97",
                                                          writeType: LibraTransactionWriteType.Deletion)
        let accessPath2 = LibraTransactionAccessPath.init(address: "c4c63f80c74b11263e421ebf8486a4e3",
                                                          path: "01217da6c6b3e19f18",
                                                          writeType: LibraTransactionWriteType.Value,
                                                          value: Data.init(Array<UInt8>(hex: "CAFED00D")))
        let write = LibraTransactionWriteSet.init(accessPaths: [accessPath1, accessPath2]).serialize().toHexString().lowercased()
        XCTAssertEqual(write, "0002a71d76faa2d2d5c3224ec3d41deb29392101217da6c6b3e19f1825cfb2676daecce3bf3de03cf26647c78df00b371b25cc9700c4c63f80c74b11263e421ebf8486a4e30901217da6c6b3e19f180104cafed00d")
        let module = LibraTransactionModule.init(code: Data.init(Array<UInt8>(hex: "CAFED00D"))).serialize().toHexString().uppercased()
        XCTAssertEqual(module, "02CAFED00D")
//        let a: Array<UInt8> = [0, 2, 167, 29, 118, 250, 162, 210, 213, 195, 34, 78, 195, 212, 29, 235, 41, 57, 33, 1, 33,
//            125, 166, 198, 179, 225, 159, 24, 37, 207, 178, 103, 109, 174, 204, 227, 191, 61, 224, 60,
//            242, 102, 71, 199, 141, 240, 11, 55, 27, 37, 204, 151, 0, 196, 198, 63, 128, 199, 75, 17,
//            38, 62, 66, 30, 191, 132, 134, 164, 227, 9, 1, 33, 125, 166, 198, 179, 225, 159, 24, 1, 4,
//            202, 254, 208, 13, 0]
//        print(Data.init(a).toHexString())
//        print("succ")
//
//        let raw = RawTransaction.init(senderAddres: "65e39e2e6b90ac215ec79e2b84690421d7286e6684b0e8e08a0b25dec640d849",
//                                      sequenceNumber: 0,
//                                      maxGasAmount: 140000,
//                                      gasUnitPrice: 0,
//                                      expirationTime: 0,
//                                      programOrWrite: program2)
//        XCTAssertEqual(raw.serialize().toHexString(), "2000000065e39e2e6b90ac215ec79e2b84690421d7286e6684b0e8e08a0b25dec640d849000000000000000000000000b80000004c49425241564d0a010007014a00000004000000034e000000060000000d54000000060000000e5a0000000600000005600000002900000004890000002000000008a90000000f00000000000001000200010300020002040200030204020300063c53454c463e0c4c696272614163636f756e74046d61696e0f7061795f66726f6d5f73656e6465720000000000000000000000000000000000000000000000000000000000000000000100020004000c000c01130101020200000001000000200000004fddcee027aa66e4e144d44dd218a345fb5af505284cb03368b7739e92dd6b3c00000000405489000000000000000000e02202000000000000000000000000000000000000000000")
//
//        //有钱助词
//        let mnemonic = ["net", "dice", "divide", "amount", "stamp", "flock", "brave", "nuclear", "fox", "aim", "father", "apology"]
//        let seed = try! LibraMnemonic.seed(mnemonic: mnemonic)
//        let wallet = try! LibraWallet.init(seed: seed)
//        _ = try! wallet.privateKey.signTransaction(transaction: raw, wallet: wallet)

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
        print(BigUInt(20000).serialize().bytes)
        print("LBR".data(using: .utf8)?.bytes.toHexString())
        print("T".data(using: .utf8)?.bytes.toHexString())
//        let data = Data.init(Array<UInt8>(hex: "76696f6c617301003000fa279f2615270daed6061313a48360f7000000005ea2b35be1be1ab8360a35a0259f1c93e3eac736"))
//        let string = String.init(data: data, encoding: String.Encoding.utf8)
//        print(string)
        print(LibraUtils.getLengthData(length: Int(20000), appendBytesCount: 8).bytes)
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
}
