//
//  WalletDetailViewController.swift
//  LibraWallet
//
//  Created by palliums on 2019/10/28.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit
import Toast_Swift
import BiometricAuthentication
class WalletDetailViewController: BaseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // 设置标题
        self.title = localLanguage(keyString: "wallet_manager_navigation_title")
        // 加载子View
        self.view.addSubview(detailView)
        // 加载数据
        self.loadLocalData(model: self.walletModel!)
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
    deinit {
        print("WalletDetailViewController销毁了")
    }
    func loadLocalData(model: LibraWalletManager) {
        self.tableViewManager.dataModel = dataModel.loadLocalConfig(model: model)
        self.detailView.tableView.reloadData()
    }
    typealias nextActionClosure = (ControllerAction, LibraWalletManager?) -> Void
    var actionClosure: nextActionClosure?
    //网络请求、数据模型
    lazy var dataModel: WalletDetailModel = {
        let model = WalletDetailModel.init()
        return model
    }()
    //tableView管理类
    lazy var tableViewManager: WalletDetailTableViewManager = {
        let manager = WalletDetailTableViewManager.init()
        manager.delegate = self
        manager.walletModel = self.walletModel
        return manager
    }()
    //子View
    lazy var detailView : WalletDetailView = {
        let view = WalletDetailView.init(canDelete: self.canDelete!)
        view.tableView.delegate = self.tableViewManager
        view.tableView.dataSource = self.tableViewManager
        view.delegate = self
        return view
    }()
    var walletModel: LibraWalletManager?
    var canDelete: Bool?
}
extension WalletDetailViewController: WalletDetailTableViewManagerDelegate {
    func tableViewDidSelectRowAtIndexPath(indexPath: IndexPath) {
        if indexPath.section == 0 {
            let vc = WalletChangeNameViewController()
            vc.account = walletModel
            vc.actionClosure = { (action, wallet) in
                if action == .update {
                    //更新管理页面
                    self.loadLocalData(model: wallet)
                    self.walletModel = wallet
                    self.detailView.tableView.reloadData()
                    //更新钱包列表页面
                    if let action = self.actionClosure {
                        action(.update, wallet)
                    }
                }
            }
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            if LibraWalletManager.shared.walletBiometricLock == true {
                KeychainManager().getPasswordWithBiometric(walletAddress: LibraWalletManager.shared.walletRootAddress ?? "") { [weak self](result, error) in
                    if result.isEmpty == false {
                        do {
                            let mnemonic = try LibraWalletManager.shared.getMnemonicFromKeychain(password: result, walletRootAddress: LibraWalletManager.shared.walletRootAddress ?? "")
                            if self?.walletModel?.walletBackupState == true {
                                let vc = BackupMnemonicController()
                                vc.JustShow = true
                                vc.tempWallet = CreateWalletModel.init(password: "", mnemonic: mnemonic, wallet: self?.walletModel)
                                self?.navigationController?.pushViewController(vc, animated: true)
                            } else {
                                let vc = BackupWarningViewController()
                                vc.FirstInApp = false
                                vc.tempWallet = CreateWalletModel.init(password: "", mnemonic: mnemonic, wallet: self?.walletModel)
                                self?.navigationController?.pushViewController(vc, animated: true)
                            }
                        } catch {
                            self?.detailView.makeToast(error.localizedDescription, position: .center)
                        }
                    } else {
                        self?.detailView.makeToast(error, position: .center)
                    }
                }
            } else {
                let alert = passowordAlert(rootAddress: (self.walletModel?.walletRootAddress)!, mnemonic: { [weak self] (mnemonic) in
                    if self?.walletModel?.walletBackupState == true {
                        let vc = BackupMnemonicController()
                        vc.JustShow = true
                        vc.tempWallet = CreateWalletModel.init(password: "", mnemonic: mnemonic, wallet: self?.walletModel)
                        self?.navigationController?.pushViewController(vc, animated: true)
                    } else {
                        let vc = BackupWarningViewController()
                        vc.FirstInApp = false
                        vc.tempWallet = CreateWalletModel.init(password: "", mnemonic: mnemonic, wallet: self?.walletModel)
                        self?.navigationController?.pushViewController(vc, animated: true)
                    }
                }) { [weak self] (errorContent) in
                    self?.view.makeToast(errorContent, position: .center)
                }
                self.present(alert, animated: true, completion: nil)
            }

        }
    }
    func switchButtonValueChange(button: UISwitch) {
        if button.isOn == true {
            let alert = passowordCheckAlert(rootAddress: LibraWalletManager.shared.walletRootAddress ?? "", passwordContent: { (password) in
                KeychainManager().addBiometric(walletAddress: LibraWalletManager.shared.walletRootAddress ?? "", password: password, success: { (result, error) in
                    if result == "Success" {
                        let result = DataBaseManager.DBManager.updateWalletBiometricLockState(walletID: LibraWalletManager.shared.walletID!, state: button.isOn)
                        guard result == true else {
                            button.setOn(!button.isOn, animated: true)
                            return
                        }
                        LibraWalletManager.shared.changeWalletBiometricLock(state: button.isOn)
                    } else {
                        self.detailView.makeToast(error, position: .center)
                        button.setOn(!button.isOn, animated: true)
                    }
                })
            }, errorContent: { (error) in
                if error != "Cancel" {
                    self.detailView.makeToast(error, position: .center)
                }
                button.setOn(!button.isOn, animated: true)
            })
            self.present(alert, animated: true, completion: nil)
        } else {
            var str = localLanguage(keyString: "wallet_biometric_alert_face_id_describe")
            if BioMetricAuthenticator.shared.touchIDAvailable() {
                str = localLanguage(keyString: "wallet_biometric_alert_fingerprint_describe")
            }
            BioMetricAuthenticator.authenticateWithBioMetrics(reason: str) { (result) in
                switch result {
                case .success( _):
                    KeychainManager().removeBiometric(walletAddress: LibraWalletManager.shared.walletRootAddress ?? "", password: "", success: { (result, error) in
                        if result == "Success" {
                            let result = DataBaseManager.DBManager.updateWalletBiometricLockState(walletID: LibraWalletManager.shared.walletID!, state: button.isOn)
                            guard result == true else {
                                button.setOn(!button.isOn, animated: true)
                                return
                            }
                            LibraWalletManager.shared.changeWalletBiometricLock(state: button.isOn)
                        } else {
                            self.detailView.makeToast(error, position: .center)
                            button.setOn(!button.isOn, animated: true)
                        }
                    })
                    print("success")
                case .failure(let error):
                    button.setOn(!button.isOn, animated: true)
                    switch error {
                    // device does not support biometric (face id or touch id) authentication
                    case .biometryNotAvailable:
                        print("biometryNotAvailable")
                    // No biometry enrolled in this device, ask user to register fingerprint or face
                    case .biometryNotEnrolled:
                        print("biometryNotEnrolled")
                    case .fallback:
                        //                    self.txtUsername.becomeFirstResponder() // enter username password manually
                        print("fallback")
                    // Biometry is locked out now, because there were too many failed attempts.
                    // Need to enter device passcode to unlock.
                    case .biometryLockedout:
                        print("biometryLockedout")
                        if BioMetricAuthenticator.shared.touchIDAvailable() {
                            self.detailView.makeToast(localLanguage(keyString: "wallet_biometric_touch_id_attempts_too_much_error"),
                                                      position: .center)
                        } else {
                            self.detailView.makeToast(localLanguage(keyString: "wallet_biometric_face_id_attempts_too_much_error"),
                                                      position: .center)
                        }
                    // do nothing on canceled by system or user
                    case .canceledBySystem, .canceledByUser:
                        print("cancel")
                        break
                        
                    // show error for any other reason
                    default:
                        print(error.localizedDescription)
                    }
                }
            }
            
        }
    }
}
extension WalletDetailViewController: WalletDetailViewDelegate {
    func deleteButtonClick() {
        let alert = UIAlertController.init(title: localLanguage(keyString: "wallet_alert_delete_wallet_title"), message: localLanguage(keyString: "wallet_alert_delete_wallet_content"), preferredStyle: UIAlertController.Style.alert)
        let confirmAction = UIAlertAction.init(title: localLanguage(keyString: "wallet_alert_delete_wallet_confirm_button_title"), style: UIAlertAction.Style.destructive) { (UIAlertAction) in
            #warning("缺少删除keychain")
            let state = DataBaseManager.DBManager.deleteWalletFromTable(model: self.walletModel!)
            
            guard state == true else {
                return
            }
            _ = DataBaseManager.DBManager.updateDefaultViolasWallet()
                        
            self.view.makeToast(localLanguage(keyString: "wallet_delete_wallet_success_title"), duration: 1, position: .center, title: nil, image: nil, style: ToastManager.shared.style, completion: { [weak self](bool) in
                if let action = self?.actionClosure {
                    action(.delete, self?.walletModel)
                }
                self?.navigationController?.popViewController(animated: true)
            })
        }
        let cancelAction = UIAlertAction.init(title: localLanguage(keyString: "wallet_alert_delete_wallet_cancel_button_title"), style: UIAlertAction.Style.cancel) { (UIAlertAction) in

        }
        alert.addAction(cancelAction)
        alert.addAction(confirmAction)
        self.present(alert, animated: true, completion: nil)
    }
}
