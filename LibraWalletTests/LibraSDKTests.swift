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
@testable import Violas
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
        // String
//        let string = TransactionArgument.init(code: .String, value: "Hello, World!").serialize().toHexString().uppercased()
//        XCTAssertEqual(string, "020000000D00000048656C6C6F2C20576F726C6421")
//
//        // u64
//        let amount = TransactionArgument.init(code: .U64, value: "9213671392124193148").serialize().toHexString().uppercased()
//        XCTAssertEqual(amount, "000000007CC9BDA45089DD7F")
//        // String
//        let address = TransactionArgument.init(code: .Address, value: "2c25991785343b23ae073a50e5fd809a2cd867526b3c1db2b0bf5d1924c693ed").serialize().toHexString().uppercased()
//        XCTAssertEqual(address  , "01000000200000002C25991785343B23AE073A50E5FD809A2CD867526B3C1DB2B0BF5D1924C693ED")
//
        // Byte
        let byte = TransactionArgument.init(code: .U8Vector, value: "cafed00d").serialize().toHexString().uppercased()
        XCTAssertEqual(byte  , "0300000004000000CAFED00D")

        let accessPath1 = TransactionAccessPath.init(address: "a71d76faa2d2d5c3224ec3d41deb293973564a791e55c6782ba76c2bf0495f9a", path: "01217da6c6b3e19f1825cfb2676daecce3bf3de03cf26647c78df00b371b25cc97", writeType: TransactionWriteType.Delete)
        let accessPath2 = TransactionAccessPath.init(address: "c4c63f80c74b11263e421ebf8486a4e398d0dbc09fa7d4f62ccdb309f3aea81f", path: "01217da6c6b3e19f18", writeType: TransactionWriteType.Write)
        let write = TransactionWriteSet.init(accessPaths: [accessPath1, accessPath2]).serialize().toHexString().uppercased()
        XCTAssertEqual(write, "010000000200000020000000A71D76FAA2D2D5C3224EC3D41DEB293973564A791E55C6782BA76C2BF0495F9A2100000001217DA6C6B3E19F1825CFB2676DAECCE3BF3DE03CF26647C78DF00B371B25CC970000000020000000C4C63F80C74B11263E421EBF8486A4E398D0DBC09FA7D4F62CCDB309F3AEA81F0900000001217DA6C6B3E19F180100000004000000CAFED00D")
//
//
//
//        let string1 = TransactionArgument.init(code: .String, value: "CAFE D00D")
//        let string2 = TransactionArgument.init(code: .String, value: "cafe d00d")
//        let program = TransactionProgram.init(code: "move".data(using: String.Encoding.utf8)!, argruments: [string1, string2], modules: [Data.init(hex: "CA"), Data.init(hex: "FED0"), Data.init(hex: "0D")]).serialize().toHexString().uppercased()
//        XCTAssertEqual(program, "00000000040000006D6F766502000000020000000900000043414645204430304402000000090000006361666520643030640300000001000000CA02000000FED0010000000D")

//        let string3 = TransactionArgument.init(code: .Address, value: "4fddcee027aa66e4e144d44dd218a345fb5af505284cb03368b7739e92dd6b3c")
//        let string4 = TransactionArgument.init(code: .U64, value: "\(9 * 1000000)")
//        let program2 = TransactionProgram.init(code: getProgramCode(), argruments: [string3, string4], modules: []).serialize()
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
    func testNewWalletKit() {
//        let mnemonic = ["legal","winner","thank","year","wave","sausage","worth","useful","legal","winner","thank","year","wave","sausage","worth","useful","legal","will"]
        //        key shoulder focus dish donate inmate move weekend hold regret peanut link
        
//        let mnemonic = ["key","shoulder","focus","dish","donate","inmate","move","weekend","hold","regret","peanut","link"]
//        LibraHDPublicKey= f47df986f4e7421a125e87e7b49137461254a67333a0d9b8dea9472724f0c67d
//        authKey = 1e7d12e8a75683776012faf9987028061409fc67d04cddf259240703809b6d12
//        let mnemonic = ["display", "paddle", "crush", "crowd", "often", "friend", "topple", "agent", "entry", "use", "host", "begin"]
        let mnemonic = ["grant", "security", "cluster", "pill", "visit", "wave", "skull", "chase", "vibrant", "embrace", "bronze", "tip"]

        do {
            let seed = try LibraMnemonic.seed(mnemonic: mnemonic)
            
            let testWallet = try LibraHDWallet.init(seed: seed, depth: 0)
//            let testMasterKey = try testWallet.getMasterKey()
            //24e236320adcdf04306257212433bbcaa0d8ccc6037cae4440455146c9cf8bf6
            print(testWallet.publicKey.raw.toHexString())
//            print(Data.init(hex: "f47df986f4e7421a125e87e7b49137461254a67333a0d9b8dea9472724f0c67d0").sha3(SHA3.Variant.sha256).toHexString())
            let tempAddress = Data.init(hex: "\(testWallet.publicKey.raw.toHexString())0").sha3(SHA3.Variant.sha256).toHexString()
//            let tempAddress = publicKey.bytes.sha3(SHA3.Variant.sha256).toHexString()
            let index = tempAddress.index(tempAddress.startIndex, offsetBy: 32)
            let address = tempAddress.suffix(from: index)
            let subStr: String = String(address)
            print(subStr)
            //1e7d12e8a75683776012faf9987028061409fc67d04cddf259240703809b6d12
//            XCTAssertEqual(testWallet.privateKey.raw.toHexString(), "358a375f36d74c30b7f3299b62d712b307725938f8cc931100fbd10a434fc8b9")
//            let testWallet2 = try LibraWallet.init(seed: seed, depth: 1)
//
//            XCTAssertEqual(testWallet2.privateKey.raw.toHexString(), "a325fe7d27b1b49f191cc03525951fec41b6ffa2d4b3007bb1d9dd353b7e56a6")
            print("success")
            print("success")
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
        func testKeychainReinstallGetPasswordAndMnemonic() {
        let mnemonic = ["legal","winner","thank","year","wave","sausage","worth","useful","legal","winner","thank","year","wave","sausage","worth","useful","legal","will"]
        do {
            let seed = try LibraMnemonic.seed(mnemonic: mnemonic)
            
            let testWallet = try LibraHDWallet.init(seed: seed, depth: 0)
            let walletAddress = testWallet.publicKey.toAddress()
//            try KeychainManager.KeyManager.savePayPasswordToKeychain(walletAddress: walletAddress, password: "123456")
            let paymentPassword = try KeychainManager.KeyManager.getPayPasswordFromKeychain(walletAddress: walletAddress)
            XCTAssertEqual(paymentPassword, "123456")
            
            let result = KeychainManager.KeyManager.checkPayPasswordInvalid(walletAddress: walletAddress, password: "1234567")
            XCTAssertEqual(result, false)
            let result2 = KeychainManager.KeyManager.checkPayPasswordInvalid(walletAddress: walletAddress, password: "123456")
            XCTAssertEqual(result2, true)
            
//            try KeychainManager.KeyManager.saveMnemonicStringToKeychain(walletAddress: walletAddress, mnemonic: mnemonic.joined(separator: " "))
            
            let menmonicString = try KeychainManager.KeyManager.getMnemonicStringFromKeychain(walletAddress: walletAddress)
            let mnemonicArray = menmonicString.split(separator: " ").compactMap { (item) -> String in
                return "\(item)"
            }
            XCTAssertEqual(mnemonic, mnemonicArray)

        } catch {
            print(error.localizedDescription)
        }

    }
    func testCommonData() {
        //测试welcome
//        let state = getWelcomeState()
//        XCTAssertEqual(state, true)
//        setWelcomeState(show: false)
//        let state2 = getWelcomeState()
//        XCTAssertEqual(state2, true)
//        setWelcomeState(show: true)
        // 测试数据库
        let state = DataBaseManager.DBManager.isExistTable(name: "Wallet")
        XCTAssertEqual(state, true)
        let state2 = DataBaseManager.DBManager.isExistTable(name: "Walet")
        XCTAssertEqual(state2, false)
    }
    func testMultiEdd25519() {
        struct MultiEdd25519PublicKey {
            var publicKeys: [String]
            var threshold: Int
        }
        do {
//            let mnemonic1 = ["display", "paddle", "crush", "crowd", "often", "friend", "topple", "agent", "entry", "use", "begin", "host"]
            let mnemonic1 = ["grant", "security", "cluster", "pill", "visit", "wave", "skull", "chase", "vibrant", "embrace", "bronze", "tip"]
            let seed1 = try LibraMnemonic.seed(mnemonic: mnemonic1)
            let wallet1 = try LibraHDWallet.init(seed: seed1, depth: 0)
            print(wallet1.publicKey.toActive())
//            f2fef5f785ceac4cbd25eac2f248d2bb331321aefcce2ee794430d07d7a953a0
            //24e236320adcdf04306257212433bbcaa0d8ccc6037cae4440455146c9cf8bf6
//            d943f6333b7995da537a66133fc72d5f9b2842c5678ad43e2111840b13572f4d
        } catch {
            print(error.localizedDescription)
        }
    }
    func testULEB128() {
        XCTAssertEqual(uleb128Format(length: 128).toHexString(), "8001")
        XCTAssertEqual(uleb128Format(length: 16384).toHexString(), "808001")
        XCTAssertEqual(uleb128Format(length: 2097152).toHexString(), "80808001")
        XCTAssertEqual(uleb128Format(length: 268435456).toHexString(), "8080808001")
        XCTAssertEqual(uleb128Format(length: 9487).toHexString(), "8f4a")
    }
    func testBitmap() {
//        let testData = TransactionArgument.init(code: .U64, value: "9213671392124193148")
//        print(testData.serialize().toHexString())
//        print("move".data(using: String.Encoding.utf8)?.toHexString())
//        print(BigUInt(86400).serialize().bytes)
//        var bitmap = Data.init(Array<UInt8>(hex: "00000000"))
//        for i in 0..<32 {
//            print(i)
//            bitmap = LibraMultiPrivateKey.init(privateKeys: [Data()], threshold: 1).setBitmap(bitmap: bitmap, index: i)
//            print(String.init(BigUInt(bitmap), radix: 2))
//        }
        
        var tempBitmap = "00000000000000000000000000000000"
        let range = tempBitmap.index(tempBitmap.startIndex, offsetBy: 0)...tempBitmap.index(tempBitmap.startIndex, offsetBy: 0)
        tempBitmap.replaceSubrange(range, with: "1")
        let range2 = tempBitmap.index(tempBitmap.startIndex, offsetBy: 2)...tempBitmap.index(tempBitmap.startIndex, offsetBy: 2)
        tempBitmap.replaceSubrange(range2, with: "1")
        print(tempBitmap)
        let convert = binary2dec(num: tempBitmap)
        //  101000 00000000 00000000 00000000
        //1000000 00000000 00000000 00000000
        print(BigUInt(convert).serialize().toHexString())
        
//        var tempData = Data.init(Array<UInt8>(hex: "00"))
//        var tempData = 0000 | 1
//        print(tempData)
    }
    func testMultiAddress() {
        let wallet = LibraMultiHDWallet.init(privateKeys: [MultiPrivateKeyModel.init(raw: Data.init(Array<UInt8>(hex: "f3cdd2183629867d6cfa24fb11c58ad515d5a4af014e96c00bb6ba13d3e5f80e")),
                                                                                     sequence: 1),
                                                           MultiPrivateKeyModel.init(raw: Data.init(Array<UInt8>(hex: "c973d737cb40bcaf63a45a9736d7d7735e78148a06be185327304d6825e666ea")),
                                                           sequence: 2)],
                                             threshold: 1)
        XCTAssertEqual(wallet.publicKey.toLegacy(), "cd35f1a78093554f5dc9c61301f204e4")
    }
    func testLibraKit() {
        let mnemonic1 = ["display", "paddle", "crush", "crowd", "often", "friend", "topple", "agent", "entry", "use", "begin", "host"]
        let mnemonic2 = ["grant", "security", "cluster", "pill", "visit", "wave", "skull", "chase", "vibrant", "embrace", "bronze", "tip"]
        let mnemonic3 = ["net", "dice", "divide", "amount", "stamp", "flock", "brave", "nuclear", "fox", "aim", "father", "apology"]
        do {
            let seed1 = try LibraMnemonic.seed(mnemonic: mnemonic1)
            let seed2 = try LibraMnemonic.seed(mnemonic: mnemonic2)
            let seed3 = try LibraMnemonic.seed(mnemonic: mnemonic3)
            let seedModel1 = SeedAndDepth.init(seed: seed1, depth: 0, sequence: 0)
            let seedModel2 = SeedAndDepth.init(seed: seed2, depth: 0, sequence: 1)
            let seedModel3 = SeedAndDepth.init(seed: seed3, depth: 0, sequence: 2)
            let multiPublicKey = LibraMultiPublicKey.init(data: [MultiPublicKeyModel.init(raw: Data.init(Array<UInt8>(hex: "2bd7d9fe82120842daa860606060661b222824c65af7bfb2843eeb7792a3b967")), sequence: 0),
                                                                 MultiPublicKeyModel.init(raw: Data.init(Array<UInt8>(hex: "50b715879a727bbc561786b0dc9e6afcd5d8a443da6eb632952e692b83e8e7cb")), sequence: 1),
                                                                 MultiPublicKeyModel.init(raw: Data.init(Array<UInt8>(hex: "e7e1b22eeb0a9ce0c49e3bf6cf23ebbb4d93d24c2064c46f6ceb9daa6ca2e217")), sequence: 2)],
                                                          threshold: 2)
            let wallet = try LibraMultiHDWallet.init(models: [seedModel1, seedModel3], threshold: 2, multiPublicKey: multiPublicKey)
//            let wallet = try LibraMultiHDWallet.init(models: [seedModel1, seedModel2, seedModel3], threshold: 2)
            print("Legacy = \(wallet.publicKey.toLegacy())")
            //bafc671e8a38c05706f83b5159bbd8a4
            print("Authentionkey = \(wallet.publicKey.toActive())")
            //bf2128295b7a57e6e42390d56293760cbafc671e8a38c05706f83b5159bbd8a4
            print("PublicKey = \(wallet.publicKey.toMultiPublicKey().toHexString())")
            //2bd7d9fe82120842daa860606060661b222824c65af7bfb2843eeb7792a3b96750b715879a727bbc561786b0dc9e6afcd5d8a443da6eb632952e692b83e8e7cbe7e1b22eeb0a9ce0c49e3bf6cf23ebbb4d93d24c2064c46f6ceb9daa6ca2e21702
            
            let sign = try LibraManager.getMultiTransactionHex(sendAddress: multiPublicKey.toLegacy(),
                                                               receiveAddress: "331321aefcce2ee794430d07d7a953a0",
                                                               amount: 0.5,
                                                               fee: 0,
                                                               sequenceNumber: 8,
                                                               wallet: wallet)
            print(sign)
        } catch {
            print(error.localizedDescription)
        }
    }
    func decTobin(number:Int) -> String {
            var num = number
            var str = ""
            while num > 0 {
                str = "\(num % 2)" + str
                num /= 2
            }
            return str
        }
}
