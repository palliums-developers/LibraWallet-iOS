//
//  WalletDetailViewController.swift
//  LibraWallet
//
//  Created by palliums on 2019/10/28.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit
import Toast_Swift
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
                    self.detailView.tableView.reloadData()
                    //更新钱包列表页面
                    if let action = self.actionClosure {
                        action(.update, wallet)
                    }
                }
            }
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            let alert = passowordAlert(rootAddress: (self.walletModel?.walletRootAddress)!, mnemonic: { [weak self] (mnemonic) in
//                let vc = WalletMnemonicViewController()
//                vc.rootAddress = self?.walletModel?.walletRootAddress
//                self?.navigationController?.pushViewController(vc, animated: true)
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
