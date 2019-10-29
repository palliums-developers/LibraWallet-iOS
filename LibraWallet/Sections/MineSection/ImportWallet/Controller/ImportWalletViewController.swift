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
    private lazy var detailView : ImportWalletView = {
        let view = ImportWalletView.init()
        view.type = self.type
        view.delegate = self
        return view
    }()
    deinit {
        print("ImportWalletViewController销毁了")
    }
    var type: String?
}
extension ImportWalletViewController: ImportWalletViewDelegate {
    func confirmAddWallet(name: String, password: String, mnemonicArray: [String]) {
        self.view.makeToastActivity(.center)
        do {
            #warning("主线程阻塞,待处理")
            let seed = try LibraMnemonic.seed(mnemonic: mnemonicArray)
            let wallet = try LibraWallet.init(seed: seed, depth: 0)
            var walletType = 0
            if type == "BTC" {
                walletType = 2
                self.view.hideToastActivity()
                self.view.makeToast("不能创建BTC", position: .center)
                return
            } else if type == "Lib" {
                walletType = 0
            } else {
                walletType = 1
            }
            let walletModel = LibraWalletManager.init(walletID: 999,
                                                      walletBalance: 0,
                                                      walletAddress: wallet.publicKey.toAddress(),
                                                      walletRootAddress: wallet.publicKey.toAddress(),
                                                      walletCreateTime: Int(NSDate().timeIntervalSince1970),
                                                      walletName: name,
                                                      walletCurrentUse: false,
                                                      walletBiometricLock: false,
                                                      walletIdentity: 1,
                                                      walletType: walletType)
            guard DataBaseManager.DBManager.isExistAddressInWallet(address: wallet.publicKey.toAddress()) == false else {
                self.view.hideToastActivity()
                self.view.makeToast("已存在", position: .center)
                return
            }
            let result = DataBaseManager.DBManager.insertWallet(model: walletModel)
            self.view.hideToastActivity()
            if result == true {
                self.view.makeToast(localLanguage(keyString: "创建成功"), duration: 1, position: .center, title: nil, image: nil, style: ToastManager.shared.style, completion: { [weak self](bool) in
//                    if let vc = UIApplication.shared.keyWindow?.rootViewController {
//                        guard vc.children.isEmpty == false else {
//                            return
//                        }
//                        if let tempHome = vc.children.first, tempHome.isKind(of: HomeViewController.classForCoder()) {
//                            (tempHome as! HomeViewController).needRefresh = true
//                        }
//                    }
//                    self?.navigationController?.popToRootViewController(animated: true)

                })
            }
        } catch {
            
        }
    }
}
