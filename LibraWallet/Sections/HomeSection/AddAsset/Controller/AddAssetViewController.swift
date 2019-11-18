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
        // 初始化本地配置
        self.setBaseControlllerConfig()
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
        let alertView = UIAlertController.init(title: localLanguage(keyString: "提醒"),
                                               message: localLanguage(keyString: "开启需要消耗Gas费,是否立即开启"),
                                               preferredStyle: .alert)
        let cancelAction = UIAlertAction.init(title:localLanguage(keyString: "取消"), style: .default) { okAction in
            let cell = self.viewModel.detailView.tableView.cellForRow(at: indexPath) as! AddAssetViewTableViewCell
            cell.switchButton.setOn(!state, animated: true)
        }
        let confirmAction = UIAlertAction.init(title:localLanguage(keyString: "确定"), style: .default) { okAction in
            self.showPasswordAlert(model: model)
        }
        alertView.addAction(cancelAction)
        alertView.addAction(confirmAction)
        self.present(alertView, animated: true, completion: nil)
    }
    func showPasswordAlert(model: ViolasTokenModel) {
        let alertContr = UIAlertController(title: "", message: "请输入密码", preferredStyle: .alert)
        alertContr.addTextField {
            (textField: UITextField!) -> Void in
            textField.placeholder = "密码"
            textField.tintColor = DefaultGreenColor
            textField.isSecureTextEntry = true
        }
        alertContr.addAction(UIAlertAction(title: "确定", style: .default) {
            clickHandler in
            let password = alertContr.textFields!.first! as UITextField
            NSLog("password:\(password.text!)")
            do {
                let state = try LibraWalletManager.shared.isValidPaymentPassword(walletRootAddress: (self.model?.walletRootAddress)!, password: password.text!)
                guard state == true else {
                    self.view.makeToast("密码不正确", position: .center)
                    return
                }
                self.viewModel.detailView.toastView?.show()
                let menmonic = try LibraWalletManager.shared.getMnemonicFromKeychain(walletRootAddress: (self.model?.walletRootAddress)!)
                self.viewModel.dataModel.publishViolasToken(sendAddress: (self.model?.walletAddress)!, mnemonic: menmonic, contact: model.address ?? "")
            } catch {
                self.viewModel.detailView.toastView?.hide()
            }
        })
        alertContr.addAction(UIAlertAction(title: "取消", style: .cancel){
            clickHandler in
            NSLog("点击了取消")
            })
        self.present(alertContr, animated: true, completion: nil)
    }
}
