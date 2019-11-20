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
        // 初始化本地配置
        self.setBaseControlllerConfig()
        // 设置标题
        self.title = localLanguage(keyString: "wallet_manager_navigation_title")
        // 加载子View
        self.view.addSubview(self.viewModel.detailView)
        // 加载数据
        self.viewModel.loadLocalData(model: self.walletModel!)
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.viewModel.detailView.snp.makeConstraints { (make) in
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
//    typealias nextActionClosure = (ControllerAction, LibraWalletManager) -> Void
//    var actionClosure: nextActionClosure?
    lazy var viewModel: WalletDetailViewModel = {
        let viewModel = WalletDetailViewModel.init()
        viewModel.tableViewManager.delegate = self
        viewModel.canDelete = self.canDelete
        viewModel.detailView.delegate = self
        return viewModel
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
                    self.viewModel.loadLocalData(model: wallet)
                    self.viewModel.detailView.tableView.reloadData()
                    //更新钱包列表页面
//                    if let action = self.actionClosure {
//                        action(.update, wallet)
//                    }
                }
            }
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            let alertContr = UIAlertController(title: "", message: "请输入密码", preferredStyle: .alert)
            alertContr.addTextField {
                (textField: UITextField!) -> Void in
                textField.placeholder = "密码"
                textField.tintColor = DefaultGreenColor
                textField.isSecureTextEntry = true
            }
            alertContr.addAction(UIAlertAction(title: "确定", style: .default){
                clickHandler in
                let loginName = alertContr.textFields!.first! as UITextField
                NSLog("LoginName:\(loginName.text!)")
                let state = try? LibraWalletManager.shared.isValidPaymentPassword(walletRootAddress: (self.walletModel?.walletRootAddress)!, password: loginName.text!)
                guard state == true else {
                    self.view.makeToast("密码不正确", position: .center)
                    return
                }
                let vc = WalletMnemonicViewController()
                vc.rootAddress = self.walletModel?.walletRootAddress
                self.navigationController?.pushViewController(vc, animated: true)
                })
            alertContr.addAction(UIAlertAction(title: "取消", style: .cancel){
                clickHandler in
                NSLog("点击了取消")
                })
            self.present(alertContr, animated: true, completion: nil)
        }
    }
}
extension WalletDetailViewController: WalletDetailViewDelegate {
    func deleteButtonClick() {
        let alert = UIAlertController.init(title: "", message: "确定要删除钱包吗", preferredStyle: UIAlertController.Style.alert)
        let confirmAction = UIAlertAction.init(title: "确定", style: UIAlertAction.Style.destructive) { (UIAlertAction) in
            #warning("缺少删除keychain")
            let state = DataBaseManager.DBManager.deleteWalletFromTable(model: self.walletModel!)
            
            guard state == true else {
                return
            }
            self.view.makeToast(localLanguage(keyString: "wallet_manager_change_wallet_name_success_title"), duration: ToastManager.shared.duration, position: .center, title: nil, image: nil, style: ToastManager.shared.style, completion: { [weak self](bool) in
//                if let action = self?.actionClosure {
//                    action(.update, tempAccount!)
//                }
                self?.navigationController?.popViewController(animated: true)
            })
        }
        let cancelAction = UIAlertAction.init(title: "取消", style: UIAlertAction.Style.cancel) { (UIAlertAction) in

        }
        alert.addAction(cancelAction)
        alert.addAction(confirmAction)
        self.present(alert, animated: true, completion: nil)
    }
}
