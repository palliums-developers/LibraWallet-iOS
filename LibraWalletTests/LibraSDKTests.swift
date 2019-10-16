//
//  LibraSDKTests.swift
//  LibraWalletTests
//
//  Created by palliums on 2019/9/5.
//  Copyright © 2019 palliums. All rights reserved.
//

import XCTest
import SwiftEd25519
import CryptoSwift
import BigInt
import SwiftGRPC
@testable import LibraWallet
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
        let byte = TransactionArgument.init(code: .Bytes, value: "cafed00d").serialize().toHexString().uppercased()
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
    
    func testDeserialize() {
        let testData = Data.init(hex: "010000002100000001217da6c6b3e19f1825cfb2676daecce3bf3de03cf26647c78df00b371b25cc978e00000020000000b8c39fc6910816ad21bc2be4f7e804539e7529b7b7d188c80f093e1e61f192cf00a8e6cf0000000000000700000000000000200000003b07b78954be13a5bc5cb2e0eaf48312a85d864091d5cb5faee296d5248d89df0400000000000000200000003f486909a2abd12a387797d9d1f78496c95b7d3878767a56dafe8f2260e5144d0400000000000000")
        let account = LibraAccount.init(accountData: testData)
        XCTAssertEqual(account.address, "b8c39fc6910816ad21bc2be4f7e804539e7529b7b7d188c80f093e1e61f192cf")
        XCTAssertEqual(account.sequenceNumber, 4)

    }
    
    func testLibraKit() {
        //有钱助词
        let mnemonic = ["net", "dice", "divide", "amount", "stamp", "flock", "brave", "nuclear", "fox", "aim", "father", "apology"]
        let seed = try! LibraMnemonic.seed(mnemonic: mnemonic)
        let wallet = try! LibraWallet.init(seed: seed)

//
//        let string3 = TransactionArgument.init(code: .Address, value:  "4fddcee027aa66e4e144d44dd218a345fb5af505284cb03368b7739e92dd6b3c")
//        let string4 = TransactionArgument.init(code: .U64, value: "\(9 * 1000000)")
//        let program2 = TransactionProgram.init(code: getProgramCode(), argruments: [string3, string4], modules: []).serialize()
//        print(string4.serialize().toHexString())
//        let raw = RawTransaction.init(senderAddres: wallet.publicKey.toAddress(),
//                                      sequenceNumber: 0,
//                                      maxGasAmount: 140000,
//                                      gasUnitPrice: 0,
//                                      expirationTime: 0,
//                                      programOrWrite: program2)
//
//
//        let signResult = try! wallet.privateKey.signTransaction(transaction: raw, wallet: wallet).serializedData()
//        print(signResult.toHexString())
//        d3686886094923eace9e502f8198a185de5435ac974bffa6f155bdece325acbc
        
        
//        f3895db4abc90322afcc4e7dea8eed40a506507b6f100caed41fac95aa58f64517ff6731a1a1b35e278db4cc5ccd13f792003306fbd803fafcfecadeed7a070a
        
        let testSign = try! KeyPair.init(publicKey: Data.init(hex: "f7972ae8140338b76702cc35431e7a79386f8b2ded1a5d71a0cdb2ba83dcfe7b").bytes, privateKey: Data.init(hex: "f591d756e9e522d24e22d83f0f777c90ba8d3fe9052155bb29873cb7d38ad8c8").bytes)
        let testResult = testSign.sign(Data.init(hex: "d3686886094923eace9e502f8198a185de5435ac974bffa6f155bdece325acbc").bytes)
        XCTAssertEqual(testResult.toHexString(), "f3895db4abc90322afcc4e7dea8eed40a506507b6f100caed41fac95aa58f64517ff6731a1a1b35e278db4cc5ccd13f792003306fbd803fafcfecadeed7a070a")

        
    }
    func testPrint() {
//        let mnemonic = try! LibraMnemonic.generate(language: LibraMnemonic.Language.english)
//        print(mnemonic)
        
        //02081eb1573be35048677d6540a7690f03e9269aa36f2ddfb9da9228fbb7f761
        
        
        let mnemonic = ["legal","winner","thank","year","wave","sausage","worth","useful","legal","winner","thank","year","wave","sausage","worth","useful","legal","will"]
        let seed = try! LibraMnemonic.seed(mnemonic: mnemonic)
        let masterKey = try! HMAC.init(key: "LIBRA WALLET: master key salt$", variant: .sha3_256).authenticate(seed)
        XCTAssertEqual(masterKey.toHexString(), "16274c9618ed59177ca948529c1884ba65c57984d562ec2b4e5aa1ee3e3903be")


        
//        let salt: Array<UInt8> = Array("LIBRA WALLET: derived key$".utf8)
        let tempInfo = Data() + Array("LIBRA WALLET: derived key$".utf8) + Data.init(hex: "0000000000000000")
        do {
            //Data.init(hex: "16274c9618ed59177ca948529c1884ba65c57984d562ec2b4e5aa1ee3e3903be").bytes
            
            
            let temp = try HKDF.init(password: seed,
                                       salt:Array("LIBRA WALLET: master key salt$".utf8),
                                       info: tempInfo.bytes,
                                       keyLength: 32,
                                       variant: .sha3_256).calculate()
            
            
            
            
            
            XCTAssertEqual(temp.toHexString(), "358a375f36d74c30b7f3299b62d712b307725938f8cc931100fbd10a434fc8b9")
            
        } catch {
            print(error.localizedDescription)
        }
    }
    func testNewWalletKit() {
        let mnemonic = ["legal","winner","thank","year","wave","sausage","worth","useful","legal","winner","thank","year","wave","sausage","worth","useful","legal","will"]
        do {
            let seed = try LibraMnemonic.seed(mnemonic: mnemonic)
            
            let testWallet = try LibraWallet.init(seed: seed, depth: 0)
            let testMasterKey = try testWallet.getMasterKey()
            XCTAssertEqual(testMasterKey.toHexString(), "16274c9618ed59177ca948529c1884ba65c57984d562ec2b4e5aa1ee3e3903be")
            
            
            XCTAssertEqual(testWallet.privateKey.raw.toHexString(), "358a375f36d74c30b7f3299b62d712b307725938f8cc931100fbd10a434fc8b9")
            let testWallet2 = try LibraWallet.init(seed: seed, depth: 1)
            
            XCTAssertEqual(testWallet2.privateKey.raw.toHexString(), "a325fe7d27b1b49f191cc03525951fec41b6ffa2d4b3007bb1d9dd353b7e56a6")


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
            
            let testWallet = try LibraWallet.init(seed: seed, depth: 0)
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
    
}
