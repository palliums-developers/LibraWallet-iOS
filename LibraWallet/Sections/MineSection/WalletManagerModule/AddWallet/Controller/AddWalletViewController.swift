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
    }
    func createViolasWallet(name: String, password: String) {
        self.detailView.toastView.show()
        let quene = DispatchQueue.init(label: "createWalletQuene")
        quene.async {
            do {
                let mnemonic = try ViolasManager.getLibraMnemonic()
                let wallet = try ViolasManager.getWallet(mnemonic: mnemonic)

                let walletModel = LibraWalletManager.init(walletID: 999,
                                                          walletBalance: 0,
                                                          walletAddress: wallet.publicKey.toAddress(),
                                                          walletRootAddress: "Violas_" + wallet.publicKey.toAddress(),
                                                          walletCreateTime: Int(NSDate().timeIntervalSince1970),
                                                          walletName: name,
                                                          walletCurrentUse: false,
                                                          walletBiometricLock: false,
                                                          walletIdentity: 1,
                                                          walletType: .Violas,
                                                          walletBackupState: true)
                
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
    }
    func createLibraWallet(name: String, password: String) {
        self.detailView.toastView.show()
        let quene = DispatchQueue.init(label: "createWalletQuene")
        quene.async {
            do {
                let mnemonic = try LibraManager.getLibraMnemonic()
                let wallet = try LibraManager.getWallet(mnemonic: mnemonic)
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
    }
}
