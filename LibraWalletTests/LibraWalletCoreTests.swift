//
//  LibraWalletCoreTests.swift
//  LibraWalletTests
//
//  Created by palliums on 2019/10/15.
//  Copyright © 2019 palliums. All rights reserved.
//

import XCTest
@testable import Violas
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
            let seed = try LibraMnemonic.seed(mnemonic: mnemonic)
            
            let testWallet = try LibraWallet.init(seed: seed, depth: 0)
            let walletAddress = testWallet.publicKey.toAddress()
            try KeychainManager.KeyManager.savePayPasswordToKeychain(walletAddress: walletAddress, password: "123456")
            let paymentPassword = try KeychainManager.KeyManager.getPayPasswordFromKeychain(walletAddress: walletAddress)
            XCTAssertEqual(paymentPassword, "123456")
            
            let result = KeychainManager.KeyManager.checkPayPasswordInvalid(walletAddress: walletAddress, password: "1234567")
            XCTAssertEqual(result, false)
            let result2 = KeychainManager.KeyManager.checkPayPasswordInvalid(walletAddress: walletAddress, password: "123456")
            XCTAssertEqual(result2, true)
            
            try KeychainManager.KeyManager.saveMnemonicStringToKeychain(walletAddress: walletAddress, mnemonic: mnemonic.joined(separator: " "))
            
            let menmonicString = try KeychainManager.KeyManager.getMnemonicStringFromKeychain(walletAddress: walletAddress)
            let mnemonicArray = menmonicString.split(separator: " ").compactMap { (item) -> String in
                return "\(item)"
            }
            XCTAssertEqual(mnemonic, mnemonicArray)

            try KeychainManager.KeyManager.deletePayPasswordFromKeychain(walletAddress: walletAddress)

            try KeychainManager.KeyManager.deleteMnemonicStringFromKeychain(walletAddress: walletAddress)

        } catch {
            print(error.localizedDescription)
        }
    }

    func testCrypte() {
        do {
            //legal winner thank year wave sausage worth useful legal winner thank year wave sausage worth useful legal will
            let crypteString = try PasswordCrypto().encryptPassword(password: "legal winner thank year wave sausage worth useful legal winner thank year wave sausage worth useful legal will")
            XCTAssertEqual(crypteString, "E2TLcN8bRc0BSYCbupXfOtbChiVRS7mT1GJzb+ytdBM7XU165JKoJvKy0vpDzJi6XQza7/cGCom4fNT5n7hkZfagDzU5MDk87jwsXIDiisf3io3N99ltkLAKW6MOa6WQcqChxmLwyXQLBCW1Sot2Bg==")
            
            let decryptString = try PasswordCrypto().decryptPassword(cryptoString: crypteString)
            XCTAssertEqual(decryptString, "legal winner thank year wave sausage worth useful legal winner thank year wave sausage worth useful legal will")
            
            let state = PasswordCrypto().isValidPassword(password: "legal winner thank year wave sausage worth useful legal winner thank year wave sausage worth useful legal will", encryptString: "E2TLcN8bRc0BSYCbupXfOtbChiVRS7mT1GJzb+ytdBM7XU165JKoJvKy0vpDzJi6XQza7/cGCom4fNT5n7hkZfagDzU5MDk87jwsXIDiisf3io3N99ltkLAKW6MOa6WQcqChxmLwyXQLBCW1Sot2Bg=")
            XCTAssertEqual(state, false)
            
            let state2 = PasswordCrypto().isValidPassword(password: "legal winner thank year wave sausage worth useful legal winner thank year wave sausage worth useful legal will", encryptString: "E2TLcN8bRc0BSYCbupXfOtbChiVRS7mT1GJzb+ytdBM7XU165JKoJvKy0vpDzJi6XQza7/cGCom4fNT5n7hkZfagDzU5MDk87jwsXIDiisf3io3N99ltkLAKW6MOa6WQcqChxmLwyXQLBCW1Sot2Bg==")
            XCTAssertEqual(state2, true)

        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    func testSaveGetFunction() {
        let mnemonic = ["legal","winner","thank","year","wave","sausage","worth","useful","legal","winner","thank","year","wave","sausage","worth","useful","legal","will"]
        do {
            let seed = try LibraMnemonic.seed(mnemonic: mnemonic)

            let libraWallet = try LibraWallet.init(seed: seed)
            LibraWalletManager.shared.initWallet(walletID: 0, walletBalance: 0, walletAddress: "", walletRootAddress: "", walletCreateTime: 0, walletName: "", walletCurrentUse: true, walletBiometricLock: false, walletIdentity: 0, walletType: .Libra)
            
            try LibraWalletManager.shared.saveMnemonicToKeychain(mnemonic: mnemonic, walletRootAddress: libraWallet.publicKey.toAddress())

            let result = try LibraWalletManager.shared.getMnemonicFromKeychain(walletRootAddress: libraWallet.publicKey.toAddress())
            XCTAssertEqual(result, mnemonic)

        } catch {
            XCTFail(error.localizedDescription)
        }
        
    }
    func testAddressManager() {
//        DataBaseManager.DBManager.createTransferAddressListTable()
//        let model = AddressModel.init(addressID: 0, address: "test", addressName: "test", addressType: "Libra")
//        _ = DataBaseManager.DBManager.insertTransferAddress(model: model)
        
        let data = DataBaseManager.DBManager.getTransferAddress(type: "Libra")
        print(data)
        let updateResult = DataBaseManager.DBManager.updateTransferAddressName(model: data.firstObject as! AddressModel, name: "haha")
        print(updateResult)
        let data2 = DataBaseManager.DBManager.getTransferAddress(type: "Libra")
        print(data2)        
    }
    func testMnemonicCount() {
        let mnemonic = try? LibraMnemonic.generate(strength: .veryHigh, language: .english)
        print(mnemonic!.count)
        let mnemonic2 = try? LibraMnemonic.generate(strength: .high, language: .english)
        print(mnemonic2!.count)
        let mnemonic3 = try? LibraMnemonic.generate(strength: .medium, language: .english)
        print(mnemonic3!.count)
        let mnemonic4 = try? LibraMnemonic.generate(strength: .low, language: .english)
        print(mnemonic4!.count)
        let mnemonic5 = try? LibraMnemonic.generate(strength: .default, language: .english)
        print(mnemonic5!.count)
    }
}
