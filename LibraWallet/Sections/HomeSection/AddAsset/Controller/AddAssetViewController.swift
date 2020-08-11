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
        self.initKVO()
        #warning("测试")
        self.addNavigationRightBar()
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
    var tokens: [Token]?
    var needDismissViewController: Bool?
    var myContext = 0
    var needUpdateClosure: successClosure?
    lazy var addAddressButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle(localLanguage(keyString: "wallet_add_assets_get_test_coin_title"), for: UIControl.State.normal)
        button.setTitleColor(UIColor.init(hex: "7038FD"), for: UIControl.State.normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 14), weight: UIFont.Weight.regular)
        button.addTarget(self, action: #selector(addAddressMethod), for: .touchUpInside)
        return button
    }()
    /// 数据监听KVO
    var observer: NSKeyValueObservation?
}
extension AddAssetViewController: AddAssetTableViewManagerDelegate {
    func switchButtonChange(model: AssetsModel, state: Bool, indexPath: IndexPath) {
        if model.registerState == true {
            // 已注册
            //判断数据库是否已存在
            print("已注册")
            let wallet = tokens?.filter({
                $0.tokenType == model.type
            })
            if DataBaseManager.DBManager.isExistViolasToken(tokenAddress: wallet?.first?.tokenAddress ?? "", tokenModule: model.module ?? "", tokenType: model.type!) {
                //已存在改状态
                print("已存在改状态,\(wallet?.first?.tokenAddress ?? "")")
                let changeState = DataBaseManager.DBManager.updateViolasTokenState(tokenAddress: wallet?.first?.tokenAddress ?? "", tokenModule: model.module ?? "", tokenType: model.type!, state: state)
                if changeState == false {
                    let cell = self.detailView.tableView.cellForRow(at: indexPath) as! AddAssetViewTableViewCell
                    cell.switchButton.setOn(!state, animated: true)
                }
            } else {
                //不存在插入
                print("不存在插入")
                let token = Token.init(tokenID: 999,
                                       tokenName: model.show_name ?? "",
                                       tokenBalance: 0,
                                       tokenAddress: wallet?.first?.tokenAddress ?? "",
                                       tokenType: model.type!,
                                       tokenIndex: 0,
                                       tokenAuthenticationKey: wallet?.first?.tokenAuthenticationKey ?? "",
                                       tokenActiveState: true,
                                       tokenIcon: model.icon ?? "",
                                       tokenContract: model.address ?? "00000000000000000000000000000001",
                                       tokenModule: model.module ?? "",
                                       tokenModuleName: "T",
                                       tokenEnable: true,
                                       tokenPrice: "0.0")
                let changeState = DataBaseManager.DBManager.insertToken(token: token)
                if changeState == false {
                    let cell = self.detailView.tableView.cellForRow(at: indexPath) as! AddAssetViewTableViewCell
                    cell.switchButton.setOn(!state, animated: true)
                }
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
                let wallet = self.tokens?.filter({
                    $0.tokenType == model.type
                })
                self.showPasswordAlert(model: model, indexPath: indexPath, wallet: wallet!.first!)
                
            }
            alertView.addAction(cancelAction)
            alertView.addAction(confirmAction)
            self.present(alertView, animated: true, completion: nil)
        }
    }
    func showPasswordAlert(model: AssetsModel, indexPath: IndexPath, wallet: Token) {
        WalletManager.unlockWallet(controller: self, successful: { [weak self] (mnemonic) in
            self?.detailView.toastView?.show(tag: 99)
            self?.dataModel.publishViolasToken(sendAddress: wallet.tokenAddress, mnemonic: mnemonic, type: wallet.tokenType, module: model.module ?? "")
            self?.actionClosure = { result in
                if result == true {
                    print("开启成功插入")
                    let token = Token.init(tokenID: 999,
                                           tokenName: model.show_name ?? "",
                                           tokenBalance: 0,
                                           tokenAddress: wallet.tokenAddress,
                                           tokenType: model.type!,
                                           tokenIndex: 0,
                                           tokenAuthenticationKey: wallet.tokenAuthenticationKey,
                                           tokenActiveState: true,
                                           tokenIcon: model.icon ?? "",
                                           tokenContract: model.address ?? "00000000000000000000000000000001",
                                           tokenModule: model.module ?? "",
                                           tokenModuleName: model.module ?? "",
                                           tokenEnable: true,
                                           tokenPrice: "0.0")
                    _ = DataBaseManager.DBManager.insertToken(token: token)
                    if let action = self?.needUpdateClosure {
                        action(true)
                    }
                } else {
                    let cell = self?.detailView.tableView.cellForRow(at: indexPath) as! AddAssetViewTableViewCell
                    cell.switchButton.setOn(result, animated: true)
                    print("开启失败")
                }
            }
        }) { [weak self] (error) in
            let cell = self?.detailView.tableView.cellForRow(at: indexPath) as! AddAssetViewTableViewCell
            cell.switchButton.setOn(false, animated: true)
            guard error != "Cancel" else {
                self?.detailView.toastView?.hide(tag: 99)
                return
            }
            self?.detailView.makeToast(error,
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
        let violasTokens = tokens?.filter({
            $0.tokenType == .Violas
        })
        if violasTokens?.isEmpty == false {
            let vc = TransactionDetailWebViewController()
            let navi = BaseNavigationViewController.init(rootViewController: vc)
            vc.requestURL = "https://testnet.violas.io/faucet/\(violasTokens?.first?.tokenAddress ?? "")"
            vc.needDismissViewController = true
            self.present(navi, animated: true, completion: nil)
        }

//        self.detailView.toastView?.show(tag: 99)
//        self.dataModel.publishViolasToken(sendAddress: "fa279f2615270daed6061313a48360f7",
//                                          mnemonic: ["display", "paddle", "crush", "crowd", "often", "friend", "topple", "agent", "entry", "use", "host", "begin"],
//                                          type: .Violas,
//                                          module: "Coin1")
//        self.dataModel.publishViolasToken(sendAddress: "128fdad1853cd1096354e5371c8e0d1d",
//                                          mnemonic: ["wrist", "post", "hover", "mixed", "like", "update", "salute", "access", "venture", "grant", "another", "team"],
//                                          type: .Libra,
//                                          module: "Coin1")
        //           team
    }
}
//MARK: - 网络请求数据处理中心
extension AddAssetViewController {
    func initKVO() {
        self.observer = dataModel.observe(\.dataDic, options: [.new], changeHandler: { [weak self](model, change) in
            guard let dataDic = change.newValue, dataDic.count != 0 else {
                self?.detailView.hideToastActivity()
                self?.detailView.toastView?.hide(tag: 99)
                return
            }
            let type = dataDic.value(forKey: "type") as! String
            if let error = dataDic.value(forKey: "error") as? LibraWalletError {
                if error.localizedDescription == LibraWalletError.WalletRequest(reason: .networkInvalid).localizedDescription {
                    // 网络无法访问
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
                } else if error.localizedDescription == LibraWalletError.WalletRequest(reason: .dataCodeInvalid).localizedDescription {
                    print(error.localizedDescription)
                    // 数据返回状态异常
                }
                self?.detailView.hideToastActivity()
                self?.detailView.toastView?.hide(tag: 99)
                self?.detailView.makeToast(error.localizedDescription,
                                           position: .center)
                if let action = self?.actionClosure {
                    action(false)
                }
                return
            }
            if type == "GetTokenList" {
                if let tempData = dataDic.value(forKey: "data") as? [AssetsModel] {
                    self?.tableViewManager.dataModel = tempData
                    self?.detailView.tableView.reloadData()
                    self?.detailView.hideToastActivity()
                }
            } else if type == "SendLibraTransaction" || type == "SendViolasTransaction" {
                self?.detailView.toastView?.hide(tag: 99)
                if let action = self?.actionClosure {
                    action(true)
                }
                self?.detailView.makeToast(localLanguage(keyString: "wallet_add_asset_alert_success_title"),
                                           position: .center)
            }
            self?.detailView.hideToastActivity()
            self?.detailView.toastView?.hide(tag: 99)
        })
        self.detailView.makeToastActivity(.center)
        let wallet = tokens?.filter({
            $0.tokenType == .Violas
        })
        self.dataModel.getSupportToken(localTokens: self.tokens!)
    }
}
