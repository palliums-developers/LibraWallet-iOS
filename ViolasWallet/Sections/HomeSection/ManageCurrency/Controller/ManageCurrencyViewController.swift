//
//  ManageCurrencyViewController.swift
//  ViolasWallet
//
//  Created by palliums on 2019/11/1.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit

class ManageCurrencyViewController: BaseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // 设置标题
        self.title = localLanguage(keyString: "wallet_assert_add_navigation_title")
        // 加载子View
        self.view.addSubview(self.detailView)
        // 获取测试币入口
//        self.addNavigationRightBar()
        requestData()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 设置StatusBar 颜色
        self.navigationController?.navigationBar.barStyle = .default
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // 设置StatusBar 颜色
        self.navigationController?.navigationBar.barStyle = .black
        if let action = self.needUpdateClosure {
            action(true)
        }
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.detailView.snp.makeConstraints { (make) in
            make.top.left.right.bottom.equalTo(self.view.safeAreaLayoutGuide)
        }
    }
    deinit {
        print("ManageCurrencyViewController销毁了")
    }
    override func back() {
        if needDismissViewController == true {
            self.dismiss(animated: true, completion: nil)
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    /// 网络请求、数据模型
    lazy var dataModel: ManageCurrencyModel = {
        let model = ManageCurrencyModel.init()
        return model
    }()
    /// tableView管理类
    lazy var tableViewManager: ManageCurrencyTableViewManager = {
        let manager = ManageCurrencyTableViewManager.init()
        manager.delegate = self
        return manager
    }()
    /// 子View
    lazy var detailView : ManageCurrencyView = {
        let view = ManageCurrencyView.init()
        view.tableView.delegate = self.tableViewManager
        view.tableView.dataSource = self.tableViewManager
        return view
    }()
    typealias successClosure = (Bool) -> Void
    var tokens: [Token]?
    var needDismissViewController: Bool?
    var needUpdateClosure: successClosure?
    lazy var addAddressButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle(localLanguage(keyString: "wallet_add_assets_get_test_coin_title"), for: UIControl.State.normal)
        button.setTitleColor(UIColor.init(hex: "7038FD"), for: UIControl.State.normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 14), weight: UIFont.Weight.regular)
        button.addTarget(self, action: #selector(addAddressMethod), for: .touchUpInside)
        return button
    }()
}
extension ManageCurrencyViewController {
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
    }
}
// MARK: - 网络请求数据处理中心
extension ManageCurrencyViewController {
    func requestData() {
        self.detailView.makeToastActivity(.center)
        self.dataModel.getSupportToken(localTokens: self.tokens!) { [weak self] (result) in
            self?.detailView.hideToastActivity()
            switch result {
            case let .success(tokens):
                self?.tableViewManager.dataModels = tokens
                self?.detailView.tableView.reloadData()
            case let .failure(error):
                self?.handleError(error: error)
            }
        }
    }
}
// MARK: - 网络请求数据处理
extension ManageCurrencyViewController {
    func handleError(error: LibraWalletError) {
        switch error {
        case .WalletRequest(reason: .networkInvalid):
            // 网络无法访问
            print(error.localizedDescription)
        case .WalletRequest(reason: .walletVersionExpired):
            // 版本太久
            print(error.localizedDescription)
        case .WalletRequest(reason: .parseJsonError):
            // 解析失败
            print(error.localizedDescription)
        case .WalletRequest(reason: .dataCodeInvalid):
            // 数据状态异常
            print(error.localizedDescription)
        default:
            // 其他错误
            print(error.localizedDescription)
        }
        self.view?.makeToast(error.localizedDescription, position: .center)
    }
}
extension ManageCurrencyViewController: ManageCurrencyTableViewManagerDelegate {
    func switchButtonChange(model: AssetsModel, state: Bool, failed: @escaping (()->Void)) {
        guard model.walletActiveState == true else {
            let alert = libraWalletTool.walletUnactivatedAlert(walletType: model.type) {
                failed()
                print("确认钱包未激活")
            }
            self.present(alert, animated: true, completion: nil)
            return
        }
        if model.registerState == true {
            // 已注册
            print("\(model.module ?? "Token") 已注册")
            self.successActiveCurrency(model: model, state: state) {
                failed()
            }
        } else {
            // 未注册
            print("\(model.module ?? "Token") 未注册")
            let alert = libraWalletTool.currencyUnactivatedAlert {
                self.showPasswordAlert(model: model, failed: failed)
            } cancel: {
                failed()
            }
            self.present(alert, animated: true, completion: nil)
        }
    }
    func showPasswordAlert(model: AssetsModel, failed: @escaping (()->Void)) {
        WalletManager.unlockWallet { [weak self] (result) in
            switch result {
            case let .success(mnemonic):
                self?.detailView.toastView.show(tag: 99)
                self?.dataModel.publishToken(sendAddress: model.walletAddress, mnemonic: mnemonic, model: model, completion: { (result) in
                    self?.detailView.toastView.hide(tag: 99)
                    switch result {
                    case .success(_):
                        print("\(model.module ?? "Token") 开启成功插入")
                        self?.successActiveCurrency(model: model, state: true) {
                            failed()
                        }
                        self?.detailView.makeToast(localLanguage(keyString: "wallet_add_asset_alert_success_title"), position: .center)
                    case let .failure(error):
                        print("\(model.module ?? "Token") 开启失败: \(error)")
                        failed()
                    }
                })
            case let .failure(error):
                failed()
                guard error.localizedDescription != "Cancel" else {
                    self?.detailView.toastView.hide(tag: 99)
                    return
                }
                self?.detailView.makeToast(error.localizedDescription, position: .center)
            }
        }
    }
    func successActiveCurrency(model: AssetsModel, state: Bool, failed: @escaping (()->Void)) {
        let token = Token.init(tokenID: 999,
                               tokenName: model.show_name ?? "",
                               tokenBalance: 0,
                               tokenAddress: model.walletAddress,
                               tokenType: model.type,
                               tokenIndex: 0,
                               tokenAuthenticationKey: model.authKey,
                               tokenActiveState: model.walletActiveState,
                               tokenIcon: model.icon ?? "",
                               tokenContract: model.address ?? "00000000000000000000000000000001",
                               tokenModule: model.module ?? "",
                               tokenModuleName: model.module ?? "",
                               tokenEnable: state,
                               tokenPrice: "0.0")
        do {
            try WalletManager.addCurrencyToWallet(token: token)
            if var totalModels = self.tableViewManager.dataModels {
                for i in 0..<totalModels.count {
                    if totalModels[i].type == token.tokenType && totalModels[i].module == model.module {
                        totalModels[i].enable = state
                        self.tableViewManager.dataModels = totalModels
                        break
                    }
                }
            }
        } catch {
            print(error.localizedDescription)
            failed()
        }
    }
}
