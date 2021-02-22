//
//  LibraWalletCoreTests.swift
//  LibraWalletTests
//
//  Created by palliums on 2019/10/15.
//  Copyright © 2019 palliums. All rights reserved.
//

import XCTest
@testable import ViolasPay
class LibraWalletCoreTests: XCTestCase {

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
    func testKeychainManager() {
        let mnemonic = ["legal","winner","thank","year","wave","sausage","worth","useful","legal","winner","thank","year","wave","sausage","worth","useful","legal","will"]
        do {
            let seed = try DiemMnemonic.seed(mnemonic: mnemonic)
            
            let testWallet = try DiemHDWallet.init(seed: seed, depth: 0)
            let walletAddress = testWallet.publicKey.toAddress()
//            try KeychainManager.KeyManager.savePayPasswordToKeychain(walletAddress: walletAddress, password: "123456")
//            let paymentPassword = try KeychainManager.KeyManager.getPayPasswordFromKeychain(walletAddress: walletAddress)
//            XCTAssertEqual(paymentPassword, "123456")
            
//            let result = KeychainManager.KeyManager.checkPayPasswordInvalid(walletAddress: walletAddress, password: "1234567")
//            XCTAssertEqual(result, false)
//            let result2 = KeychainManager.KeyManager.checkPayPasswordInvalid(walletAddress: walletAddress, password: "123456")
//            XCTAssertEqual(result2, true)
            
//            try KeychainManager.KeyManager.saveMnemonicStringToKeychain(walletAddress: walletAddress, mnemonic: mnemonic.joined(separator: " "))
//            
//            let menmonicString = try KeychainManager.KeyManager.getMnemonicStringFromKeychain(walletAddress: walletAddress)
//            let mnemonicArray = menmonicString.split(separator: " ").compactMap { (item) -> String in
//                return "\(item)"
//            }
//            XCTAssertEqual(mnemonic, mnemonicArray)
//
////            try KeychainManager.KeyManager.deletePayPasswordFromKeychain(walletAddress: walletAddress)
//
//            try KeychainManager.KeyManager.deleteMnemonicStringFromKeychain(walletAddress: walletAddress)

        } catch {
            print(error.localizedDescription)
        }
    }

    func testCrypte() {
        do {
            //legal winner thank year wave sausage worth useful legal winner thank year wave sausage worth useful legal will
            let crypteString = try PasswordCrypto.encryptPassword(content: "legal winner thank year wave sausage worth useful legal winner thank year wave sausage worth useful legal will", password: "123456")
            XCTAssertEqual(crypteString, "G4+qYkXjuRzPo9GQPpti0SO4zAhjJ8TV9Vj5VHx5718zJAYkjCx5i6Cho7mad0rxr6CwgzVzqoBmtu+xTN+57qmDuTg4ONUjqnWdFW+WCbhWPvqY7/O9b4fARTCpoHgP8HudFCP48SwUBmtAESBQDQ==")
            
            let decryptString = try PasswordCrypto.decryptPassword(cryptoString: crypteString, password: "123456")
            XCTAssertEqual(decryptString, "legal winner thank year wave sausage worth useful legal winner thank year wave sausage worth useful legal will")
            
//            let state = PasswordCrypto.isValidPassword(password: "legal winner thank year wave sausage worth useful legal winner thank year wave sausage worth useful legal will", encryptString: "E2TLcN8bRc0BSYCbupXfOtbChiVRS7mT1GJzb+ytdBM7XU165JKoJvKy0vpDzJi6XQza7/cGCom4fNT5n7hkZfagDzU5MDk87jwsXIDiisf3io3N99ltkLAKW6MOa6WQcqChxmLwyXQLBCW1Sot2Bg=")
//            XCTAssertEqual(state, false)
            
//            let state2 = PasswordCrypto.isValidPassword(password: "legal winner thank year wave sausage worth useful legal winner thank year wave sausage worth useful legal will", encryptString: "E2TLcN8bRc0BSYCbupXfOtbChiVRS7mT1GJzb+ytdBM7XU165JKoJvKy0vpDzJi6XQza7/cGCom4fNT5n7hkZfagDzU5MDk87jwsXIDiisf3io3N99ltkLAKW6MOa6WQcqChxmLwyXQLBCW1Sot2Bg==")
//            XCTAssertEqual(state2, true)

        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    func testSaveGetFunction() {
//        let mnemonic = ["legal","winner","thank","year","wave","sausage","worth","useful","legal","winner","thank","year","wave","sausage","worth","useful","legal","will"]
//        do {
//            let seed = try LibraMnemonic.seed(mnemonic: mnemonic)
//
//            let libraWallet = try LibraHDWallet.init(seed: seed)
//            LibraWalletManager.shared.initWallet(walletID: 0, walletBalance: 0, walletAddress: "", walletRootAddress: "", walletCreateTime: 0, walletName: "", walletCurrentUse: true, walletBiometricLock: false, walletIdentity: 0, walletType: .Libra, walletBackupState: false, walletAuthenticationKey: "", walletActiveState: false)
//
//            try LibraWalletManager.shared.saveMnemonicToKeychain(mnemonic: mnemonic, password: "123456", walletRootAddress: libraWallet.publicKey.toAddress())
//
//            let result = try LibraWalletManager.shared.getMnemonicFromKeychain(password: "123456", walletRootAddress: libraWallet.publicKey.toAddress())
//            XCTAssertEqual(result, mnemonic)
//
//        } catch {
//            XCTFail(error.localizedDescription)
//        }
        
    }
    func testAddressManager() {
//        DataBaseManager.DBManager.createTransferAddressListTable()
//        let model = AddressModel.init(addressID: 0, address: "test", addressName: "test", addressType: "Libra")
//        _ = DataBaseManager.DBManager.insertTransferAddress(model: model)
        
        let data = try? DataBaseManager.DBManager.getTransferAddress(type: "Libra")
        print(data)
//        let updateResult = try? DataBaseManager.DBManager.updateTransferAddressName(model: data.firstObject as! AddressModel, name: "haha")
//        print(updateResult)
        let data2 = try? DataBaseManager.DBManager.getTransferAddress(type: "Libra")
        print(data2)        
    }
    func testMnemonicCount() {
        let mnemonic = try? DiemMnemonic.generate(strength: .veryHigh, language: .english)
        print(mnemonic!.count)
        let mnemonic2 = try? DiemMnemonic.generate(strength: .high, language: .english)
        print(mnemonic2!.count)
        let mnemonic3 = try? DiemMnemonic.generate(strength: .medium, language: .english)
        print(mnemonic3!.count)
        let mnemonic4 = try? DiemMnemonic.generate(strength: .low, language: .english)
        print(mnemonic4!.count)
        let mnemonic5 = try? DiemMnemonic.generate(strength: .default, language: .english)
        print(mnemonic5!.count)
    }
    func testMarketTransaction() {
        //        let signature = try librama
        let mnemonic1 = ["display", "paddle", "crush", "crowd", "often", "friend", "topple", "agent", "entry", "use", "host", "begin"]
//        let signature = try! ViolasManager.getMarketAddLiquidityTransactionHex(sendAddress: "fa279f2615270daed6061313a48360f7",
//                                                                               fee: 0,
//                                                                               mnemonic: mnemonic1,
//                                                                               amounta_desired: 5000,
//                                                                               amountb_desired: 5000,
//                                                                               amounta_min: 1,
//                                                                               amountb_min: 1,
//                                                                               sequenceNumber: 67,
//                                                                               inputModuleA: "VLSUSD",
//                                                                               inputModuleB: "VLSGBP",
//                                                                               feeModule: "LBR")
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
//        print(signature)
    }
    func testMarketMappingTransaction() {
        let mnemonic = ["display", "paddle", "crush", "crowd", "often", "friend", "topple", "agent", "entry", "use", "host", "begin"]
//        let signature = try! ViolasManager.getViolasToLibraMappingTransactionHex(sendAddress: "fa279f2615270daed6061313a48360f7",
//                                                                                 module: "VLSUSD",
//                                                                                 amountIn: 15,
//                                                                                 amountOut: 14,
//                                                                                 fee: 0,
//                                                                                 mnemonic: mnemonic,
//                                                                                 sequenceNumber: 94,
//                                                                                 exchangeCenterAddress: "dc49a7c8979f83cde4bc229fb35fd27f",
//                                                                                 libraReceiveAddress: "fa279f2615270daed6061313a48360f7",
//                                                                                 feeModule: "LBR",
//                                                                                 type: "v2lusd")
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
        
//        print(signature)
        
    }
    func testBank() {
//        let mnemonic1 = ["display", "paddle", "crush", "crowd", "often", "friend", "topple", "agent", "entry", "use", "host", "begin"]
        
        let mnemonic = ["wrist", "post", "hover", "mixed", "like", "update", "salute", "access", "venture", "grant", "another", "team"]
        
//        let signature = try! ViolasManager.getBankFeaturesTransactionHex(sendAddress: "f41799563e5381b693d0885b56ebf19b",
//                                                                         mnemonic: mnemonic,
//                                                                         feeModule: "LBR",
//                                                                         fee: 0,
//                                                                         sequenceNumber: 9,
//                                                                         module: "USD")
        // 存钱
//        let signature = try! ViolasManager.getBankDepositTransactionHex(sendAddress: "f41799563e5381b693d0885b56ebf19b",
//                                                                        mnemonic: mnemonic,
//                                                                        feeModule: "LBR",
//                                                                        fee: 2,
//                                                                        sequenceNumber: 10,
//                                                                        module: "USD",
//                                                                        amount: 20000000)
        // 借钱
//        let signature = try! ViolasManager.getBankLoanTransactionHex(sendAddress: "f41799563e5381b693d0885b56ebf19b",
//                                                                        mnemonic: mnemonic,
//                                                                        feeModule: "LBR",
//                                                                        fee: 2,
//                                                                        sequenceNumber: 11,
//                                                                        module: "USD",
//                                                                        amount: 5000000)
        // 还钱
//        let signature = try! ViolasManager.getBankRepaymentTransactionHex(sendAddress: "f41799563e5381b693d0885b56ebf19b",
//                                                                          mnemonic: mnemonic,
//                                                                          feeModule: "LBR",
//                                                                          fee: 2,
//                                                                          sequenceNumber: 13,
//                                                                          module: "USD",
//                                                                          amount: 1000000)
        // 赎回
//        let signature = try! ViolasManager.getBankRedeemTransactionHex(sendAddress: "f41799563e5381b693d0885b56ebf19b",
//                                                                       mnemonic: mnemonic,
//                                                                       feeModule: "LBR",
//                                                                       fee: 2,
//                                                                       sequenceNumber: 14,
//                                                                       module: "USD",
//                                                                       amount: 20000000)
//
//        print(signature)
    }
}
