//
//  LibraWalletManager.swift
//  LibraWallet
//
//  Created by palliums on 2019/9/5.
//  Copyright © 2019 palliums. All rights reserved.
//

import Foundation

struct LibraWalletManager {
    static var wallet = LibraWalletManager()
    
    private let semaphore = DispatchSemaphore.init(value: 1)
    
    private(set) var walletID: Int64?
    
    private(set) var walletBalance: Int64?
    
    private(set) var walletAddress: String?
    
    private(set) var walletCreateTime: Int?
    
    private(set) var walletName: String?
    
    private(set) var walletMnemonic: String?
    
    private(set) var walletCurrentUse: Bool?
    
    private(set) var walletBiometricLock: Bool?
    
    private(set) var wallet: LibraWallet?
    
}
extension LibraWalletManager {
    mutating func initWallet(walletID: Int64, walletBalance: Int64, walletAddress: String, walletCreateTime: Int, walletName: String, walletMnemonic: String, walletCurrentUse: Bool, walletBiometricLock: Bool, wallet: LibraWallet) {
        self.semaphore.wait()
        
        self.walletID = walletID
        self.walletBalance = walletBalance
        self.walletAddress = walletAddress
        self.walletCreateTime = walletCreateTime
        self.walletName = walletName
        self.walletMnemonic = walletMnemonic
        self.walletCurrentUse = walletCurrentUse
        self.walletBiometricLock = walletBiometricLock
        self.wallet = wallet
        
        self.semaphore.signal()
    }
    mutating func changeWalletBalance(banlance: Int64) {
        self.semaphore.wait()
        self.walletBalance = banlance
        self.semaphore.signal()
    }
    mutating func changeWalletName(name: String) {
        self.semaphore.wait()
        self.walletName = name
        self.semaphore.signal()
    }
    mutating func changeWalletAddress(address: String) {
        self.semaphore.wait()
        self.walletAddress = address
        self.semaphore.signal()
    }
    mutating func changeWalletBiometricLock(state: Bool) {
        self.semaphore.wait()
        self.walletBiometricLock = state
        self.semaphore.signal()
    }
}
