//
//  CheckBackupViewController.swift
//  LibraWallet
//
//  Created by palliums on 2019/11/5.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit
import Toast_Swift
class CheckBackupViewController: BaseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // 初始化本地配置
//        self.setBaseControlllerConfig()
        // 加载子View
        self.view.addSubview(self.viewModel.detailView)
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        viewModel.detailView.snp.makeConstraints { (make) in
            if #available(iOS 11.0, *) {
                make.top.bottom.equalTo(self.view.safeAreaLayoutGuide)
            } else {
                make.top.bottom.equalTo(self.view)
            }
            make.left.right.equalTo(self.view)
        }
    }
    deinit {
        print("CheckBackupViewController销毁了")
    }
    typealias nextActionClosure = (ControllerAction, LibraWalletManager) -> Void
    var actionClosure: nextActionClosure?
    lazy var viewModel: CheckBackupViewModel = {
        let viewModel = CheckBackupViewModel.init()
        viewModel.detailView.delegate = self
        return viewModel
    }()
    var FirstInApp: Bool?
    var tempWallet: CreateWalletModel? {
        didSet {
            self.viewModel.dataArray = tempWallet?.mnemonic
        }
    }
}
extension CheckBackupViewController: CheckBackupViewDelegate {
    func confirmBackup() {
        do {
            try self.viewModel.checkIsAllValid()
            if FirstInApp == true {
                self.view.makeToast(localLanguage(keyString: "wallet_check_mnemonic_success_title"), duration: 0.5, position: .center, title: nil, image: nil, style: ToastManager.shared.style, completion: { (bool) in
                    let tabbar = BaseTabBarViewController.init()
                    UIApplication.shared.keyWindow?.rootViewController = tabbar
                    UIApplication.shared.keyWindow?.makeKeyAndVisible()
                })
            } else {
                let result = DataBaseManager.DBManager.insertWallet(model: tempWallet!.wallet!)
                self.view.hideToastActivity()
                if result == true {
                    do {
                        try LibraWalletManager().saveMnemonicToKeychain(mnemonic: tempWallet!.mnemonic!, walletRootAddress: tempWallet?.wallet?.walletRootAddress ?? "")
                        try LibraWalletManager().savePaymentPasswordToKeychain(password: tempWallet!.password!, walletRootAddress: tempWallet?.wallet?.walletRootAddress ?? "")
                        self.view.makeToast(localLanguage(keyString: localLanguage(keyString: "wallet_create_wallet_success_title")), duration: 1, position: .center, title: nil, image: nil, style: ToastManager.shared.style, completion: { [weak self](bool) in
                            self?.jumpToWalletManagerController()
                        })
                    } catch {
                        print(error.localizedDescription)
                        //删除从数据库创建好钱包
                        _ = DataBaseManager.DBManager.deleteWalletFromTable(model: tempWallet!.wallet!)
                    }
                }
            }
        } catch {
            self.view.makeToast(error.localizedDescription,
                                position: .center)
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
