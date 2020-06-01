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
        self.title = localLanguage(keyString: "wallet_assert_add_navigation_title")

        self.view.backgroundColor = UIColor.white
        // 加载子View
        self.view.addSubview(self.detailView)
        // 加载数据
        self.initKVO(walletID: (wallet?.walletID)!, walletAddress: wallet?.walletAddress ?? "")
        #warning("测试")
//        self.addNavigationRightBar()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.barStyle = .default
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.barStyle = .black
        if let action = self.needUpdateClosure {
            action(true)
        }
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.detailView.snp.makeConstraints { (make) in
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
    override func back() {
        if needDismissViewController == true {
            self.dismiss(animated: true, completion: nil)
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    //网络请求、数据模型
    lazy var dataModel: AddAssetModel = {
        let model = AddAssetModel.init()
        return model
    }()
    //tableView管理类
    lazy var tableViewManager: AddAssetTableViewManager = {
        let manager = AddAssetTableViewManager.init()
        manager.delegate = self
        return manager
    }()
    //子View
    lazy var detailView : AddAssetView = {
        let view = AddAssetView.init()
        view.tableView.delegate = self.tableViewManager
        view.tableView.dataSource = self.tableViewManager
        return view
    }()
    typealias successClosure = (Bool) -> Void
    var actionClosure: successClosure?
    var wallet: LibraWalletManager?
    var needDismissViewController: Bool?
    var myContext = 0
    var needUpdateClosure: successClosure?
    lazy var addAddressButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage.init(named: "add"), for: UIControl.State.normal)
        button.addTarget(self, action: #selector(addAddressMethod), for: .touchUpInside)
        return button
    }()
}
extension AddAssetViewController: AddAssetTableViewManagerDelegate {
    func switchButtonChange(model: ViolasTokenModel, state: Bool, indexPath: IndexPath) {
        if model.registerState == true {
            // 已注册
            //判断数据库是否已存在
            print("已注册")
            if DataBaseManager.DBManager.isExistViolasToken(walletID: wallet?.walletID ?? 0, contract: model.address ?? "", tokenNumber: model.id ?? 9999) {
                //已存在改状态
                print("已存在改状态,\(model.address ?? "")")
                let cell = self.detailView.tableView.cellForRow(at: indexPath) as! AddAssetViewTableViewCell
                cell.switchButton.setOn(state, animated: true)
                _ = DataBaseManager.DBManager.updateViolasTokenState(walletID: wallet?.walletID ?? 0, tokenAddress: model.address ?? "", tokenNumber: model.id ?? 9999, state: state)
            } else {
                //不存在插入
                print("不存在插入")
                _ = DataBaseManager.DBManager.insertViolasToken(walletID: wallet?.walletID ?? 0, model: model)
            }
        } else {
            // 未注册
            print("未注册")
            let alertView = UIAlertController.init(title: localLanguage(keyString: "wallet_add_asset_alert_title"),
                                                   message: localLanguage(keyString: "wallet_add_asset_alert_content"),
                                                   preferredStyle: .alert)
            let cancelAction = UIAlertAction.init(title:localLanguage(keyString: "wallet_add_asset_alert_cancel_button_title"), style: .default) { okAction in
                let cell = self.detailView.tableView.cellForRow(at: indexPath) as! AddAssetViewTableViewCell
                cell.switchButton.setOn(!state, animated: true)
            }
            let confirmAction = UIAlertAction.init(title:localLanguage(keyString: "wallet_add_asset_alert_confirm_button_title"), style: .default) { okAction in
                self.showPasswordAlert(model: model, indexPath: indexPath)
            }
            alertView.addAction(cancelAction)
            alertView.addAction(confirmAction)
            self.present(alertView, animated: true, completion: nil)
        }
    }
    func showPasswordAlert(model: ViolasTokenModel, indexPath: IndexPath) {
        let alert = passowordAlert(rootAddress: (self.wallet?.walletRootAddress)!, mnemonic: { [weak self] (mnemonic) in
            self?.detailView.toastView?.show()
            self?.dataModel.publishViolasToken(sendAddress: (self?.wallet?.walletAddress)!, mnemonic: mnemonic, contact: model.address ?? "")
            self?.actionClosure = { result in
                if result == true {
                    print("开启成功插入")
                    if DataBaseManager.DBManager.isExistViolasToken(walletID: self?.wallet?.walletID ?? 0, contract: model.address ?? "", tokenNumber: model.id ?? 9999) {
                        //已存在改状态
                        print("已存在改状态,\(model.address ?? "")")
                        let cell = self?.detailView.tableView.cellForRow(at: indexPath) as! AddAssetViewTableViewCell
                        cell.switchButton.setOn(result, animated: true)
                        _ = DataBaseManager.DBManager.updateViolasTokenState(walletID: self?.wallet?.walletID ?? 0, tokenAddress: model.address ?? "", tokenNumber: model.id ?? 9999, state: result)
                    } else {
                        //不存在插入
                        print("不存在插入")
                        _ = DataBaseManager.DBManager.insertViolasToken(walletID: self?.wallet?.walletID ?? 0, model: model)
                    }
                    if let action = self?.needUpdateClosure {
                        action(true)
                    }
                } else {
                    let cell = self?.detailView.tableView.cellForRow(at: indexPath) as! AddAssetViewTableViewCell
                    cell.switchButton.setOn(result, animated: true)
                    print("开启失败")
                }
            }
        }) { [weak self] (errorContent) in
            let cell = self?.detailView.tableView.cellForRow(at: indexPath) as! AddAssetViewTableViewCell
            cell.switchButton.setOn(false, animated: true)
            self?.view.makeToast(errorContent, position: .center)
        }
        self.present(alert, animated: true, completion: nil)
    }
}
extension AddAssetViewController {
    func initKVO(walletID: Int64, walletAddress: String) {
        dataModel.addObserver(self, forKeyPath: "dataDic", options: NSKeyValueObservingOptions.new, context: &myContext)
        self.detailView.makeToastActivity(.center)
        self.dataModel.getSupportToken(walletID: walletID, walletAddress: walletAddress)
    }
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?)  {
        
        guard context == &myContext else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }
        guard (change?[NSKeyValueChangeKey.newKey]) != nil else {
            return
        }
        guard let jsonData = (object! as AnyObject).value(forKey: "dataDic") as? NSDictionary else {
            return
        }
        if let error = jsonData.value(forKey: "error") as? LibraWalletError {
            if error.localizedDescription == LibraWalletError.WalletRequest(reason: .networkInvalid).localizedDescription {
                // 网络无法访问
                print(error.localizedDescription)
            } else if error.localizedDescription == LibraWalletError.WalletRequest(reason: .walletTokenExpired).localizedDescription {
                print(error.localizedDescription)
            } else if error.localizedDescription == LibraWalletError.WalletRequest(reason: .walletVersionExpired).localizedDescription {
                // 版本太久
                print(error.localizedDescription)
            } else if error.localizedDescription == LibraWalletError.WalletRequest(reason: .parseJsonError).localizedDescription {
                // 解析失败
                print(error.localizedDescription)
            } else if error.localizedDescription == LibraWalletError.WalletRequest(reason: .dataEmpty).localizedDescription {
                print(error.localizedDescription)
                // 数据为空
            }
            self.detailView.toastView?.hide()
            self.detailView.hideToastActivity()
            if let action = self.actionClosure {
                action(false)
            }
//            self.detailView.makeToast("开启失败", position: .center)
            return
        }
        let type = jsonData.value(forKey: "type") as! String
        
        if type == "GetTokenList" {
            if let tempData = jsonData.value(forKey: "data") as? [ViolasTokenModel] {
                self.tableViewManager.dataModel = tempData
                self.detailView.tableView.reloadData()
                self.detailView.hideToastActivity()
            }
        } else if type == "SendViolasTransaction" {
            self.detailView.toastView?.hide()
            if let action = self.actionClosure {
                action(true)
            }
            self.detailView.makeToast(localLanguage(keyString: "wallet_add_asset_alert_success_title"),
                                position: .center)
        }
    }
}
extension AddAssetViewController {
    func addNavigationRightBar() {
        // 自定义导航栏的UIBarButtonItem类型的按钮
        let backView = UIBarButtonItem(customView: addAddressButton)
        // 重要方法，用来调整自定义返回view距离左边的距离
        let barButtonItem = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        barButtonItem.width = 5
        // 返回按钮设置成功
        self.navigationItem.rightBarButtonItems = [barButtonItem, backView]
    }
    @objc func addAddressMethod() {
        let alert = passowordAlert(rootAddress: (self.wallet?.walletRootAddress)!, mnemonic: { [weak self] (mnemonic) in
            self?.detailView.toastView?.show()
            self?.dataModel.publishViolasToken(sendAddress: (self?.wallet?.walletAddress)!,
                                               mnemonic: mnemonic,
                                               contact: ViolasMainContract)
            self?.actionClosure = { result in
                
            }
        }) { [weak self] (errorContent) in
            self?.view.makeToast(errorContent, position: .center)
        }
        self.present(alert, animated: true, completion: nil)
    }

}
