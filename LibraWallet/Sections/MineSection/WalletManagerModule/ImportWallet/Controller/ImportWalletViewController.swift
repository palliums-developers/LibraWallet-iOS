//
//  ImportWalletViewController.swift
//  LibraWallet
//
//  Created by palliums on 2019/10/28.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit
import Toast_Swift
class ImportWalletViewController: BaseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
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
    private lazy var detailView : ImportWalletView = {
        let view = ImportWalletView.init()
        view.type = self.type
        view.delegate = self
        return view
    }()
    //网络请求、数据模型
    lazy var dataModel: ImportWalletModel = {
        let model = ImportWalletModel.init()
        return model
    }()
    deinit {
        print("ImportWalletViewController销毁了")
    }
    var type: String?
    var myContext = 0

}
extension ImportWalletViewController: ImportWalletViewDelegate {
    func confirmAddWallet(name: String, password: String, mnemonicArray: [String]) {
        if type == "BTC" {
            self.importBTCWallet(name: name, password: password, mnemonicArray: mnemonicArray)
        } else if type == "Libra" {
            self.importLibraWallet(name: name, password: password, mnemonicArray: mnemonicArray)
        } else {
            self.importViolasWallet(name: name, password: password, mnemonicArray: mnemonicArray)
        }
    }
    func importBTCWallet(name: String, password: String, mnemonicArray: [String]) {
        self.detailView.toastView.show()
        let quene = DispatchQueue.init(label: "createWalletQuene")
        quene.async {
            let wallet = BTCManager().getWallet(mnemonic: mnemonicArray)
            let walletModel = LibraWalletManager.init(walletID: 999,
                                                      walletBalance: 0,
                                                      walletAddress: wallet.address.description,
                                                      walletRootAddress: "BTC_" + wallet.address.description,
                                                      walletCreateTime: Int(NSDate().timeIntervalSince1970),
                                                      walletName: name,
                                                      walletCurrentUse: false,
                                                      walletBiometricLock: false,
                                                      walletIdentity: 1,
                                                      walletType: .BTC,
                                                      walletBackupState: true)
            guard DataBaseManager.DBManager.isExistAddressInWallet(address: walletModel.walletRootAddress ?? "") == false else {
                DispatchQueue.main.async(execute: {
                    self.detailView.toastView.hide()
                    self.view.makeToast(LibraWalletError.WalletCreate(reason: .walletExist).localizedDescription, position: .center)
                })
                return
            }
            let result = DataBaseManager.DBManager.insertWallet(model: walletModel)
            if result == true {
                do {
                    try LibraWalletManager().saveMnemonicToKeychain(mnemonic: mnemonicArray, walletRootAddress: walletModel.walletRootAddress ?? "")
                    try LibraWalletManager().savePaymentPasswordToKeychain(password: password, walletRootAddress: walletModel.walletRootAddress ?? "")
                    DispatchQueue.main.async(execute: {
                        self.detailView.toastView.hide()
                        self.view.makeToast(localLanguage(keyString: "wallet_import_wallet_success_title"), duration: 1, position: .center, title: nil, image: nil, style: ToastManager.shared.style, completion: { [weak self](bool) in
                            self?.jumpToWalletManagerController()
                        })
                    })
                } catch {
                    // 插入数据库失败
                    DispatchQueue.main.async(execute: {
                        //删除从数据库创建好钱包
                        _ = DataBaseManager.DBManager.deleteWalletFromTable(model: walletModel)
                        self.detailView.toastView.hide()
                        self.view.makeToast(LibraWalletError.WalletCreate(reason: .walletImportFailed).localizedDescription, position: .center)
                    })
                    print(error.localizedDescription)
                }
            } else {
                DispatchQueue.main.async(execute: {
                    self.detailView.toastView.hide()
                    self.view.makeToast(LibraWalletError.WalletCreate(reason: .walletImportFailed).localizedDescription, position: .center)
                })
            }
        }
    }
    func importViolasWallet(name: String, password: String, mnemonicArray: [String]) {
        self.detailView.toastView.show()
        let quene = DispatchQueue.init(label: "createWalletQuene")
        quene.async {
            do {
                let wallet = try ViolasManager.getWallet(mnemonic: mnemonicArray)

                let walletModel = LibraWalletManager.init(walletID: 999,
                                                          walletBalance: 0,
                                                          walletAddress: wallet.publicKey.toLegacy(),
                                                          walletRootAddress: "Violas_" + wallet.publicKey.toLegacy(),
                                                          walletCreateTime: Int(NSDate().timeIntervalSince1970),
                                                          walletName: name,
                                                          walletCurrentUse: false,
                                                          walletBiometricLock: false,
                                                          walletIdentity: 1,
                                                          walletType: .Violas,
                                                          walletBackupState: true)
                guard DataBaseManager.DBManager.isExistAddressInWallet(address: walletModel.walletRootAddress ?? "") == false else {
                    DispatchQueue.main.async(execute: {
                        self.detailView.toastView.hide()
                        self.view.makeToast(LibraWalletError.WalletCreate(reason: .walletExist).localizedDescription, position: .center)
                    })
                    return
                }
                let result = DataBaseManager.DBManager.insertWallet(model: walletModel)
                if result == true {
                    try LibraWalletManager().saveMnemonicToKeychain(mnemonic: mnemonicArray, walletRootAddress: walletModel.walletRootAddress ?? "")
                    try LibraWalletManager().savePaymentPasswordToKeychain(password: password, walletRootAddress: walletModel.walletRootAddress ?? "")
                    DispatchQueue.main.async(execute: {
                        self.detailView.toastView.hide()
                        self.view.makeToast(localLanguage(keyString: "wallet_import_wallet_success_title"), duration: 1, position: .center, title: nil, image: nil, style: ToastManager.shared.style, completion: { [weak self](bool) in
                            self?.jumpToWalletManagerController()
                        })
                    })
                } else {
                    // 插入数据库失败
                    DispatchQueue.main.async(execute: {
                        self.detailView.toastView.hide()
                        self.view.makeToast(LibraWalletError.WalletCreate(reason: .walletImportFailed).localizedDescription, position: .center)
                    })
                }
            } catch {
                DispatchQueue.main.async(execute: {
                    self.detailView.toastView.hide()
                    print(error.localizedDescription)
                    self.view.makeToast(LibraWalletError.WalletCreate(reason: .walletImportFailed).localizedDescription, position: .center)
                })
            }
        }
    }
    func importLibraWallet(name: String, password: String, mnemonicArray: [String]) {
        self.detailView.toastView.show()
        let quene = DispatchQueue.init(label: "createWalletQuene")
        quene.async {
            do {
                let wallet = try LibraManager.getWallet(mnemonic: mnemonicArray)

                let walletModel = LibraWalletManager.init(walletID: 999,
                                                          walletBalance: 0,
                                                          walletAddress: wallet.publicKey.toAddress(),
                                                          walletRootAddress: "Libra_" + wallet.publicKey.toAddress(),
                                                          walletCreateTime: Int(NSDate().timeIntervalSince1970),
                                                          walletName: name,
                                                          walletCurrentUse: false,
                                                          walletBiometricLock: false,
                                                          walletIdentity: 1,
                                                          walletType: .Libra,
                                                          walletBackupState: true)
                guard DataBaseManager.DBManager.isExistAddressInWallet(address: walletModel.walletRootAddress ?? "") == false else {
                    DispatchQueue.main.async(execute: {
                        self.detailView.toastView.hide()
                        self.view.makeToast(LibraWalletError.WalletCreate(reason: .walletExist).localizedDescription, position: .center)
                    })
                    return
                }
                let result = DataBaseManager.DBManager.insertWallet(model: walletModel)
                if result == true {
                    try LibraWalletManager().saveMnemonicToKeychain(mnemonic: mnemonicArray, walletRootAddress: walletModel.walletRootAddress ?? "")
                    try LibraWalletManager().savePaymentPasswordToKeychain(password: password, walletRootAddress: walletModel.walletRootAddress ?? "")
                    DispatchQueue.main.async(execute: {
                        self.detailView.toastView.hide()
                        self.view.makeToast(localLanguage(keyString: "wallet_import_wallet_success_title"), duration: 1, position: .center, title: nil, image: nil, style: ToastManager.shared.style, completion: { [weak self](bool) in
                            self?.jumpToWalletManagerController()
                        })
                    })
                } else {
                    // 插入数据库失败
                    DispatchQueue.main.async(execute: {
                        self.detailView.toastView.hide()
                        self.view.makeToast(LibraWalletError.WalletCreate(reason: .walletImportFailed).localizedDescription, position: .center)
                    })
                }
            } catch {
                DispatchQueue.main.async(execute: {
                    self.detailView.toastView.hide()
                    print(error.localizedDescription)
                    self.view.makeToast(LibraWalletError.WalletCreate(reason: .walletImportFailed).localizedDescription, position: .center)
                })
            }
        }
    }
    func jumpToWalletManagerController() {
        if let vc = UIApplication.shared.keyWindow?.rootViewController, vc.children.isEmpty == false {
            if let mineControllers = vc.children.last?.children, mineControllers.isEmpty == false {
                for con in mineControllers {
                    if con.isKind(of: WalletManagerViewController.classForCoder()) {
                        (con as! WalletManagerViewController).needRefresh = true
                        self.navigationController?.popToViewController(con, animated: true)
                        return
                    }
                }
                self.navigationController?.popToRootViewController(animated: true)
            } else {
                self.navigationController?.popToRootViewController(animated: true)
            }
        } else {
            // 根控制器为空,重置App
            let tabbar = BaseTabBarViewController.init()
            UIApplication.shared.keyWindow?.rootViewController = tabbar
            UIApplication.shared.keyWindow?.makeKeyAndVisible()
        }
    }
}
