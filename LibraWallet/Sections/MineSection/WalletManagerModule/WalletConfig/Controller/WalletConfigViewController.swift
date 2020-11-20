//
//  WalletConfigViewController.swift
//  LibraWallet
//
//  Created by palliums on 2019/10/28.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit
import Toast_Swift
import BiometricAuthentication
class WalletConfigViewController: BaseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // 设置标题
        self.title = localLanguage(keyString: "wallet_manager_navigation_title")
        // 加载子View
        self.view.addSubview(detailView)
        // 加载数据
        self.loadLocalData()
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        detailView.snp.makeConstraints { (make) in
            if #available(iOS 11.0, *) {
                make.top.equalTo(self.view.safeAreaLayoutGuide)
            } else {
                make.top.equalTo(self.view)
            }
            make.left.right.bottom.equalTo(self.view)
        }
    }
    deinit {
        print("WalletDetailViewController销毁了")
    }
    func loadLocalData() {
        self.tableViewManager.dataModel = dataModel.loadLocalConfig()
        self.detailView.tableView.reloadData()
    }
    typealias nextActionClosure = (ControllerAction) -> Void
    var actionClosure: nextActionClosure?
    /// 网络请求、数据模型
    lazy var dataModel: WalletConfigModel = {
        let model = WalletConfigModel.init()
        return model
    }()
    /// tableView管理类
    lazy var tableViewManager: WalletConfigTableViewManager = {
        let manager = WalletConfigTableViewManager.init()
        manager.delegate = self
        return manager
    }()
    /// 子View
    lazy var detailView : WalletConfigView = {
        let view = WalletConfigView.init(canDelete: self.canDelete!)
        view.tableView.delegate = self.tableViewManager
        view.tableView.dataSource = self.tableViewManager
        view.delegate = self
        return view
    }()
    /// 是否允许删除钱包
    var canDelete: Bool?
}
extension WalletConfigViewController: WalletConfigTableViewManagerDelegate {
    func tableViewDidSelectRowAtIndexPath(indexPath: IndexPath) {
        if indexPath.row == 0 {
            WalletManager.unlockWallet { [weak self] (result) in
                switch result {
                case let .success(mnemonic):
                    if WalletManager.shared.walletBackupState == true {
                        let vc = BackupMnemonicController()
                        vc.JustShow = true
                        vc.tempWallet = mnemonic
                        self?.navigationController?.pushViewController(vc, animated: true)
                    } else {
                        let vc = BackupWarningViewController()
                        vc.FirstInApp = false
                        vc.tempWallet = mnemonic
                        self?.navigationController?.pushViewController(vc, animated: true)
                    }
                case let .failure(error):
                    guard error.localizedDescription != "Cancel" else {
                        self?.detailView.hideToastActivity()
                        return
                    }
                    self?.detailView.makeToast(error.localizedDescription, position: .center)
                }
            }
        }
    }
    func switchButtonValueChange(button: UISwitch) {
        WalletManager.changeBiometricState(state: button.isOn) { [weak self] (result) in
            switch result {
            case .success(_):
                print("生物识别状态：\(button.isOn)成功")
            case let .failure(error):
                button.setOn(!button.isOn, animated: true)
                guard error.localizedDescription != "Cancel" else {
                    return
                }
                self?.detailView.makeToast(error.localizedDescription, position: .center)
            }
        }
    }
}
extension WalletConfigViewController: WalletConfigViewDelegate {
    func deleteButtonClick() {
        let alert = libraWalletTool.deleteWalletAlert {
            WalletManager.unlockWallet { [weak self] (result) in
                switch result {
                case .success(_):
                    self?.view.makeToast(localLanguage(keyString: "wallet_delete_wallet_success_title"), duration: 1, position: .center, title: nil, image: nil, style: ToastManager.shared.style, completion: { [weak self](bool) in
                    //                if let action = self?.actionClosure {
                    //                    action(.delete)
                    //                }
                        WalletManager.deleteWallet(password: "", createOrImport: false, step: 999)
                                    self?.navigationController?.popViewController(animated: true)
                                })
                case let .failure(error):
                    guard error.localizedDescription != "Cancel" else {
                        self?.detailView.hideToastActivity()
                        return
                    }
                    self?.detailView.makeToast(error.localizedDescription, position: .center)
                }
            }
        }
        self.present(alert, animated: true, completion: nil)
    }
}
