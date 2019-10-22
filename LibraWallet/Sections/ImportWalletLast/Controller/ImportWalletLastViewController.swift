//
//  ImportWalletLastViewController.swift
//  PalliumsWallet
//
//  Created by palliums on 2019/5/30.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit
import Toast_Swift
class ImportWalletLastViewController: BaseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = localLanguage(keyString: "wallet_wallet_manager_import_new_wallet_navigationbar_title")
        self.view.addSubview(detailView)
//        self.detailView.mnemonicTextView.text = "next feature record section tuition unlock legal room clarify small job question"
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
    var mnemonicArray: [String]?
//    typealias nextActionClosure = (ViewControllerAction, HomeData) -> Void
//    var actionClosure: nextActionClosure?
    //懒加载子View
    private lazy var detailView : ImportWalletLastView = {
        let view = ImportWalletLastView.init()
        view.delegate = self
        return view
    }()
    deinit {
        print("ImportWalletLastViewController销毁了")
    }
}
extension ImportWalletLastViewController: ImportWalletLastViewDelegate {
    func nextStepClickClickMethod(button: UIButton) {
        guard let walletName = self.detailView.walletNameTextField.text else {
            self.view.makeToast(localLanguage(keyString: "wallet_creat_name_invalid_error"), position: .center)
            return
        }
        guard walletName.count > 0 else {
            print("请输入钱包名字")
            self.view.makeToast(localLanguage(keyString: "wallet_creat_name_error"), position: .center)
            return
        }
        guard let password = self.detailView.walletPasswordTextField.text else {
            print("密码无效")
            self.view.makeToast(localLanguage(keyString: "wallet_creat_password_invalid_error"), position: .center)
            return
        }
        guard password.count > 0 else {
            print("请输入密码")
            self.view.makeToast(localLanguage(keyString: "wallet_creat_password_error"), position: .center)
            return
        }
        guard let passwordAgain = self.detailView.walletPasswordAgainTextField.text else {
            print("确认密码无效")
            self.view.makeToast(localLanguage(keyString: "wallet_creat_password_again_invalid_error"), position: .center)
            return
        }
        guard passwordAgain.count > 0 else {
            print("请输入确认密码")
            self.view.makeToast(localLanguage(keyString: "wallet_creat_password_again_error"), position: .center)
            return
        }
        guard passwordAgain == password else {
            print("两次密码不一致，请检查")
            self.view.makeToast(localLanguage(keyString: "wallet_creat_password_check_error"), position: .center)
            return
        }
//        let wallet = BTCManager().getWallet(mnemonic: self.mnemonicArray!)
//        let savePasswordStatus = KeyChainManager.KeyManager.savePasswordToKeychain(walletAddress: BTCManager().getWalletAddress(wallet: wallet), password: password)
//        let encryptMnemonicString = BTCManager().getEncryptMnemonic(mnemonic: self.mnemonicArray!, password: password)
//        //判断当前钱包是否有钱包
//        let defaultStatus = DataBaseManager.BDManager.getWalletCount() == 0 ? "1":"0"
//        let data = HomeData.init(walletID: 99,
//                                 walletName: walletName,
//                                 walletPrivatekey: encryptMnemonicString,
//                                 walletAmount: 0.0,
//                                 walletAddress: BTCManager().getWalletAddress(wallet: wallet),
//                                 walletCreateTime: NSDate().timeIntervalSince1970,
//                                 walletPasswordRemarks: self.detailView.walletPasswordRemarksTextField.text,
//                                 walletDefaultStatus: defaultStatus)
//        let status = DataBaseManager.BDManager.insertAccountToWallet(homeData: data)
//        if savePasswordStatus == true && status == true {
//            self.detailView.tapToHideKeyboard()
//            let view = CustomeAlertView.init {
//                if let action = self.actionClosure {
//                    action(.add, data)
//                }
//                let contraller = (self.navigationController?.viewControllers)!.filter({
//                    $0.isKind(of: WalletListViewController.self)
//                })
//                guard contraller.count != 0 else {
//                    self.navigationController?.popViewController(animated: true)
//                    return
//                }
//                self.navigationController?.popToViewController(contraller.last!, animated: true)
//            }
//            view.data = ["title":"wallet_import_success_alert_title","icon":"","describe":"wallet_import_success_alert_detail_title","buttonTitle":"wallet_import_success_alert_button_title"]
//            view.show()
//        } else {
//            print("创建失败")
//            self.view.makeToast(localLanguage(keyString: "wallet_creat_failed"), position: .center)
//            _ = KeyChainManager.KeyManager.deletePasswordFromKeychain(walletAddress: BTCManager().getWalletAddress(wallet: wallet))
//
//        }
    }
}
