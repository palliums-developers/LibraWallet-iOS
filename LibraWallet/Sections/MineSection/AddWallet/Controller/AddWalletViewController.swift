//
//  AddWalletViewController.swift
//  LibraWallet
//
//  Created by palliums on 2019/10/25.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit
import Toast_Swift
class AddWalletViewController: BaseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // 初始化本地配置
        self.setBaseControlllerConfig()
        // 加载子View
        self.view.addSubview(detailView)
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        detailView.snp.makeConstraints { (make) in
            if #available(iOS 11.0, *) {
                make.top.bottom.equalTo(self.view.safeAreaLayoutGuide)
            } else {
                make.top.bottom.equalTo(self.view)
            }
            make.left.right.equalTo(self.view)
        }
    }
    //子View
    private lazy var detailView : AddWalletView = {
        let view = AddWalletView.init()
        view.type = self.type
        view.delegate = self
        return view
    }()
    deinit {
        print("AddWalletViewController销毁了")
    }
    var type: String?
    var myContext = 0

}
extension AddWalletViewController: AddWalletViewDelegate {
    func confirmAddWallet(name: String, password: String) {
        print(name, password)
//        self.view.makeToastActivity(.center)
        if type == "BTC" {
            self.createBTCWallet(name: name, password: password)
        } else if type == "Lib" {
            self.createLibraWallet(name: name, password: password)
        } else {
            self.createViolasWallet(name: name, password: password)
        }
    }
    func createBTCWallet(name: String, password: String) {
        self.detailView.toastView.show()
        let quene = DispatchQueue.init(label: "createWalletQuene")
        quene.async {
            let mnemonic = BTCManager().getMnemonic()
            let wallet = BTCManager().getWallet(mnemonic: mnemonic)
    //            let wallet = try LibraWallet.init(seed: seed, depth: 0)
            let walletModel = LibraWalletManager.init(walletID: 999,
                                                      walletBalance: 0,
                                                      walletAddress: wallet.address.description,
                                                      walletRootAddress: "BTC_" + wallet.address.description,
                                                      walletCreateTime: Int(NSDate().timeIntervalSince1970),
                                                      walletName: name,
                                                      walletCurrentUse: false,
                                                      walletBiometricLock: false,
                                                      walletIdentity: 1,
                                                      walletType: .BTC)
            
            let createModel = CreateWalletModel.init(password: password,
                                                     mnemonic: mnemonic,
                                                     wallet: walletModel)
            DispatchQueue.main.async(execute: {
                self.detailView.toastView.hide()
                let vc = BackupWarningViewController()
                vc.FirstInApp = false
                vc.tempWallet = createModel
                self.navigationController?.pushViewController(vc, animated: true)
            })
        }
//        let mnemonic = BTCManager().getMnemonic()
//        let wallet = BTCManager().getWallet(mnemonic: mnemonic)
////            let wallet = try LibraWallet.init(seed: seed, depth: 0)
//        let walletModel = LibraWalletManager.init(walletID: 999,
//                                                  walletBalance: 0,
//                                                  walletAddress: wallet.address.description,
//                                                  walletRootAddress: "BTC_" + wallet.address.description,
//                                                  walletCreateTime: Int(NSDate().timeIntervalSince1970),
//                                                  walletName: name,
//                                                  walletCurrentUse: false,
//                                                  walletBiometricLock: false,
//                                                  walletIdentity: 1,
//                                                  walletType: .BTC)
//        guard DataBaseManager.DBManager.isExistAddressInWallet(address: wallet.address.description) == false else {
//            self.view.hideToastActivity()
//            self.view.makeToast("已存在", position: .center)
//            return
//        }
//        let result = DataBaseManager.DBManager.insertWallet(model: walletModel)
//        self.view.hideToastActivity()
//        if result == true {
//            do {
//                try LibraWalletManager().saveMnemonicToKeychain(mnemonic: mnemonic, walletRootAddress: walletModel.walletRootAddress ?? "")
//                try LibraWalletManager().savePaymentPasswordToKeychain(password: password, walletRootAddress: walletModel.walletRootAddress ?? "")
//
//                self.view.makeToast(localLanguage(keyString: "创建成功"), duration: 1, position: .center, title: nil, image: nil, style: ToastManager.shared.style, completion: { [weak self](bool) in
//                //                    if let vc = UIApplication.shared.keyWindow?.rootViewController {
//                //                        guard vc.children.isEmpty == false else {
//                //                            return
//                //                        }
//                //                        if let tempHome = vc.children.first, tempHome.isKind(of: HomeViewController.classForCoder()) {
//                //                            (tempHome as! HomeViewController).needRefresh = true
//                //                        }
//                //                    }
//                //                    self?.navigationController?.popToRootViewController(animated: true)
//
//                            })
//            } catch {
//                print(error.localizedDescription)
//                //删除从数据库创建好钱包
//                _ = DataBaseManager.DBManager.deleteWalletFromTable(model: walletModel)
//            }
            
            
//        }
    }
    func createViolasWallet(name: String, password: String) {
        self.detailView.toastView.show()
        let quene = DispatchQueue.init(label: "createWalletQuene")
        quene.async {
            do {
                let mnemonic = try LibraMnemonic.generate(strength: .default, language: .english)
                let seed = try LibraMnemonic.seed(mnemonic: mnemonic)
                let wallet = try LibraWallet.init(seed: seed, depth: 0)
                let walletModel = LibraWalletManager.init(walletID: 999,
                                                          walletBalance: 0,
                                                          walletAddress: wallet.publicKey.toAddress(),
                                                          walletRootAddress: "Violas_" + wallet.publicKey.toAddress(),
                                                          walletCreateTime: Int(NSDate().timeIntervalSince1970),
                                                          walletName: name,
                                                          walletCurrentUse: false,
                                                          walletBiometricLock: false,
                                                          walletIdentity: 1,
                                                          walletType: .Violas)
                
                let createModel = CreateWalletModel.init(password: password,
                                                         mnemonic: mnemonic,
                                                         wallet: walletModel)
                DispatchQueue.main.async(execute: {
                    self.detailView.toastView.hide()
                    let vc = BackupWarningViewController()
                    vc.FirstInApp = false
                    vc.tempWallet = createModel
                    self.navigationController?.pushViewController(vc, animated: true)
                })
            } catch {
                print(error.localizedDescription)
            }
        }
//        do {
//            #warning("主线程阻塞,待处理")
//            let mnemonic = try LibraMnemonic.generate(strength: .default, language: .english)
//            let seed = try LibraMnemonic.seed(mnemonic: mnemonic)
//            let wallet = try LibraWallet.init(seed: seed, depth: 0)
//            let walletModel = LibraWalletManager.init(walletID: 999,
//                                                      walletBalance: 0,
//                                                      walletAddress: wallet.publicKey.toAddress(),
//                                                      walletRootAddress: "Violas_" + wallet.publicKey.toAddress(),
//                                                      walletCreateTime: Int(NSDate().timeIntervalSince1970),
//                                                      walletName: name,
//                                                      walletCurrentUse: false,
//                                                      walletBiometricLock: false,
//                                                      walletIdentity: 1,
//                                                      walletType: .Violas)
//            guard DataBaseManager.DBManager.isExistAddressInWallet(address: wallet.publicKey.toAddress()) == false else {
//                self.view.hideToastActivity()
//                self.view.makeToast("已存在", position: .center)
//                return
//            }
//            let result = DataBaseManager.DBManager.insertWallet(model: walletModel)
//            self.view.hideToastActivity()
//            if result == true {
//                do {
//                    try LibraWalletManager().saveMnemonicToKeychain(mnemonic: mnemonic, walletRootAddress: walletModel.walletRootAddress ?? "")
//                    try LibraWalletManager().savePaymentPasswordToKeychain(password: password, walletRootAddress: walletModel.walletRootAddress ?? "")
//                    self.view.makeToast(localLanguage(keyString: "创建成功"), duration: 1, position: .center, title: nil, image: nil, style: ToastManager.shared.style, completion: { [weak self](bool) in
//                    //                    if let vc = UIApplication.shared.keyWindow?.rootViewController {
//                    //                        guard vc.children.isEmpty == false else {
//                    //                            return
//                    //                        }
//                    //                        if let tempHome = vc.children.first, tempHome.isKind(of: HomeViewController.classForCoder()) {
//                    //                            (tempHome as! HomeViewController).needRefresh = true
//                    //                        }
//                    //                    }
//                    //                    self?.navigationController?.popToRootViewController(animated: true)
//
//                                })
//                } catch {
//                    print(error.localizedDescription)
//                    //删除从数据库创建好钱包
//                    _ = DataBaseManager.DBManager.deleteWalletFromTable(model: walletModel)
//                }
//            }
//        } catch {
//            
//        }
    }
    func createLibraWallet(name: String, password: String) {
        self.detailView.toastView.show()
        let quene = DispatchQueue.init(label: "createWalletQuene")
        quene.async {
            do {
                let mnemonic = try LibraMnemonic.generate(strength: .default, language: .english)
                let seed = try LibraMnemonic.seed(mnemonic: mnemonic)
                let wallet = try LibraWallet.init(seed: seed, depth: 0)
                let walletModel = LibraWalletManager.init(walletID: 999,
                                                          walletBalance: 0,
                                                          walletAddress: wallet.publicKey.toAddress(),
                                                          walletRootAddress: "Libra_" + wallet.publicKey.toAddress(),
                                                          walletCreateTime: Int(NSDate().timeIntervalSince1970),
                                                          walletName: name,
                                                          walletCurrentUse: false,
                                                          walletBiometricLock: false,
                                                          walletIdentity: 1,
                                                          walletType: .Libra)
                
                let createModel = CreateWalletModel.init(password: password,
                                                         mnemonic: mnemonic,
                                                         wallet: walletModel)
                DispatchQueue.main.async(execute: {
                    self.detailView.toastView.hide()
                    let vc = BackupWarningViewController()
                    vc.FirstInApp = false
                    vc.tempWallet = createModel
                    self.navigationController?.pushViewController(vc, animated: true)
                })
            } catch {
                print(error.localizedDescription)
            }
        }
//        do {
//            #warning("主线程阻塞,待处理")
//            let mnemonic = try LibraMnemonic.generate(strength: .default, language: .english)
//            let seed = try LibraMnemonic.seed(mnemonic: mnemonic)
//            let wallet = try LibraWallet.init(seed: seed, depth: 0)
//            let walletModel = LibraWalletManager.init(walletID: 999,
//                                                      walletBalance: 0,
//                                                      walletAddress: wallet.publicKey.toAddress(),
//                                                      walletRootAddress: "Libra_" + wallet.publicKey.toAddress(),
//                                                      walletCreateTime: Int(NSDate().timeIntervalSince1970),
//                                                      walletName: name,
//                                                      walletCurrentUse: false,
//                                                      walletBiometricLock: false,
//                                                      walletIdentity: 1,
//                                                      walletType: .Libra)
//            guard DataBaseManager.DBManager.isExistAddressInWallet(address: wallet.publicKey.toAddress()) == false else {
//                self.view.hideToastActivity()
//                self.view.makeToast("已存在", position: .center)
//                return
//            }
//            let result = DataBaseManager.DBManager.insertWallet(model: walletModel)
//            self.view.hideToastActivity()
//            if result == true {
//                do {
//                    try LibraWalletManager().saveMnemonicToKeychain(mnemonic: mnemonic, walletRootAddress: walletModel.walletRootAddress ?? "")
//                    try LibraWalletManager().savePaymentPasswordToKeychain(password: password, walletRootAddress: walletModel.walletRootAddress ?? "")
//                    self.view.makeToast(localLanguage(keyString: "创建成功"), duration: 1, position: .center, title: nil, image: nil, style: ToastManager.shared.style, completion: { [weak self](bool) in
////                    if let vc = UIApplication.shared.keyWindow?.rootViewController {
////                        guard vc.children.isEmpty == false else {
////                            return
////                        }
////                        if let tempHome = vc.children.first, tempHome.isKind(of: HomeViewController.classForCoder()) {
////                            (tempHome as! HomeViewController).needRefresh = true
////                        }
////                    }
////                    self?.navigationController?.popToRootViewController(animated: true)
//
//                                })
//                } catch {
//                    print(error.localizedDescription)
//                    //删除从数据库创建好钱包
//                    _ = DataBaseManager.DBManager.deleteWalletFromTable(model: walletModel)
//                }
//            }
//        } catch {
//
//        }
    }
}
