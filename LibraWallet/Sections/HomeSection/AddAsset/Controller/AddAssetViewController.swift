//
//  AddAssetViewController.swift
//  LibraWallet
//
//  Created by palliums on 2019/11/1.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit

class AddAssetViewController: BaseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        // 加载子View
        self.view.addSubview(self.viewModel.detailView)
        // 加载数据
        self.viewModel.initKVO(walletID: (model?.walletID)!)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.barStyle = .default
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.barStyle = .black
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
        print("AddAssetViewController销毁了")
    }
    lazy var viewModel: AddAssetViewModel = {
        let viewModel = AddAssetViewModel.init()
        viewModel.tableViewManager.headerData = self.model
        viewModel.delegate = self
        return viewModel
    }()
    var model: LibraWalletManager?
}
extension AddAssetViewController: AddAssetViewModelDelegate {
    func switchButtonChange(model: ViolasTokenModel, state: Bool, indexPath: IndexPath) {
        let alertView = UIAlertController.init(title: localLanguage(keyString: "wallet_add_asset_alert_title"),
                                               message: localLanguage(keyString: "wallet_add_asset_alert_content"),
                                               preferredStyle: .alert)
        let cancelAction = UIAlertAction.init(title:localLanguage(keyString: "wallet_add_asset_alert_cancel_button_title"), style: .default) { okAction in
            let cell = self.viewModel.detailView.tableView.cellForRow(at: indexPath) as! AddAssetViewTableViewCell
            cell.switchButton.setOn(!state, animated: true)
        }
        let confirmAction = UIAlertAction.init(title:localLanguage(keyString: "wallet_add_asset_alert_confirm_button_title"), style: .default) { okAction in
            self.showPasswordAlert(model: model)
        }
        alertView.addAction(cancelAction)
        alertView.addAction(confirmAction)
        self.present(alertView, animated: true, completion: nil)
    }
    func showPasswordAlert(model: ViolasTokenModel) {
        let alertContr = UIAlertController(title: localLanguage(keyString: "wallet_type_in_password_title"), message: localLanguage(keyString: "wallet_type_in_password_content"), preferredStyle: .alert)
        alertContr.addTextField {
            (textField: UITextField!) -> Void in
            textField.placeholder = localLanguage(keyString: "wallet_type_in_password_textfield_placeholder")
            textField.tintColor = DefaultGreenColor
            textField.isSecureTextEntry = true
        }
        alertContr.addAction(UIAlertAction(title: localLanguage(keyString: "wallet_type_in_password_confirm_button_title"), style: .default) { [weak self] clickHandler in
            let passwordTextField = alertContr.textFields!.first! as UITextField
            guard let password = passwordTextField.text else {
                self?.view.makeToast(LibraWalletError.WalletCheckPassword(reason: .passwordInvalidError).localizedDescription,
                                    position: .center)
                return
            }
            guard password.isEmpty == false else {
                self?.view.makeToast(LibraWalletError.WalletCheckPassword(reason: .passwordEmptyError).localizedDescription,
                                    position: .center)
                return
            }
            NSLog("Password:\(password)")
            do {
                let state = try LibraWalletManager.shared.isValidPaymentPassword(walletRootAddress: (self?.model?.walletRootAddress)!, password: password)
                guard state == true else {
                    self?.view.makeToast(LibraWalletError.WalletCheckPassword(reason: .passwordEmptyError).localizedDescription,
                                         position: .center)
                    return
                }
                self?.viewModel.detailView.toastView?.show()
                let menmonic = try LibraWalletManager.shared.getMnemonicFromKeychain(walletRootAddress: (self?.model?.walletRootAddress)!)
                self?.viewModel.dataModel.publishViolasToken(sendAddress: (self?.model?.walletAddress)!, mnemonic: menmonic, contact: model.address ?? "")
            } catch {
                self?.viewModel.detailView.toastView?.hide()
            }
        })
        alertContr.addAction(UIAlertAction(title: localLanguage(keyString: "wallet_type_in_password_cancel_button_title"), style: .cancel){
            clickHandler in
            NSLog("点击了取消")
            })
        self.present(alertContr, animated: true, completion: nil)
    }
}
