//
//  ImportWalletModel.swift
//  LibraWallet
//
//  Created by palliums on 2019/10/28.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit
import Moya
class ImportWalletModel: NSObject {
    private var requests: [Cancellable] = []
    @objc var dataDic: NSMutableDictionary = [:]
    
    func importViolasWallet(name: String, password: String, mnemonicArray: [String]) {
//        self.detailView.toastView.show()
//        let quene = DispatchQueue.init(label: "createWalletQuene")
//        quene.async {
//            do {
//                let wallet = try ViolasManager.getWallet(mnemonic: mnemonicArray)
//
//                let walletModel = LibraWalletManager.init(walletID: 999,
//                                                          walletBalance: 0,
//                                                          walletAddress: wallet.publicKey.toAddress(),
//                                                          walletRootAddress: "Violas_" + wallet.publicKey.toAddress(),
//                                                          walletCreateTime: Int(NSDate().timeIntervalSince1970),
//                                                          walletName: name,
//                                                          walletCurrentUse: false,
//                                                          walletBiometricLock: false,
//                                                          walletIdentity: 1,
//                                                          walletType: .Violas)
//                guard DataBaseManager.DBManager.isExistAddressInWallet(address: walletModel.walletRootAddress ?? "") == false else {
//                    DispatchQueue.main.async(execute: {
//                        self.detailView.toastView.hide()
//                        self.view.makeToast(LibraWalletError.WalletCreate(reason: .walletExist).localizedDescription, position: .center)
//                    })
//                    return
//                }
//                let result = DataBaseManager.DBManager.insertWallet(model: walletModel)
//                if result == true {
//                    try LibraWalletManager().saveMnemonicToKeychain(mnemonic: mnemonicArray, walletRootAddress: walletModel.walletRootAddress ?? "")
//                    try LibraWalletManager().savePaymentPasswordToKeychain(password: password, walletRootAddress: walletModel.walletRootAddress ?? "")
//                    DispatchQueue.main.async(execute: {
//                        self.detailView.toastView.hide()
//                        self.view.makeToast(localLanguage(keyString: "wallet_import_wallet_success_title"), duration: 1, position: .center, title: nil, image: nil, style: ToastManager.shared.style, completion: { [weak self](bool) in
//                            self?.jumpToWalletManagerController()
//                        })
//                    })
//                } else {
//                    // 插入数据库失败
//                    DispatchQueue.main.async(execute: {
//                        self.detailView.toastView.hide()
//                        self.view.makeToast(LibraWalletError.WalletCreate(reason: .walletImportFailed).localizedDescription, position: .center)
//                    })
//                }
//            } catch {
//                DispatchQueue.main.async(execute: {
//                    self.detailView.toastView.hide()
//                    print(error.localizedDescription)
//                    self.view.makeToast(LibraWalletError.WalletCreate(reason: .walletImportFailed).localizedDescription, position: .center)
//                })
//            }
//        }
    }
    
    func getWalletEnableToken(address: String) {
        let request = mainProvide.request(.GetViolasAccountEnableToken(address)) {[weak self](result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(ViolasAccountEnableTokenResponseModel.self)
                    guard json.code == 2000 else {
                        let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.dataCodeInvalid), type: "GetWalletEnableCoin")
                        self?.setValue(data, forKey: "dataDic")
                        return
                    }
                    guard json.data?.isEmpty == false else {
                        let data = setKVOData(error: LibraWalletError.error(localLanguage(keyString: "尚未注册任何稳定币")), type: "GetWalletEnableCoin")
                        self?.setValue(data, forKey: "dataDic")
                        return
                    }
//                    let data = setKVOData(type: "GetSupportCoin", data: json.data)
//                    self?.setValue(data, forKey: "dataDic")
                } catch {
                    print("GetWalletEnableCoin_解析异常\(error.localizedDescription)")
                    let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.parseJsonError), type: "GetWalletEnableCoin")
                    self?.setValue(data, forKey: "dataDic")
                }
            case let .failure(error):
                guard error.errorCode != -999 else {
                    print("GetWalletEnableCoin_网络请求已取消")
                    return
                }
                let data = setKVOData(error: LibraWalletError.WalletRequest(reason: .networkInvalid), type: "GetWalletEnableCoin")
                self?.setValue(data, forKey: "dataDic")
            }
        }
        self.requests.append(request)
    }
    deinit {
        requests.forEach { cancellable in
            cancellable.cancel()
        }
        requests.removeAll()
        print("MarketModel销毁了")
    }
}
