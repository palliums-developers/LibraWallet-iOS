//
//  MarketViewController.swift
//  LibraWallet
//
//  Created by palliums on 2019/11/6.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit
//import SocketIO
import StatefulViewController
import Localize_Swift
class MarketViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        self.addNavigationBar()
        // 加载子View
        self.view.addSubview(detailView)
        self.addFirstSubView()
        // 添加语言变换通知
        NotificationCenter.default.addObserver(self, selector: #selector(setText), name: NSNotification.Name(LCLLanguageChangeNotification), object: nil)
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        exchangeButton.snp.makeConstraints { (make) in
            make.top.left.bottom.equalTo(titleButtonView)
            make.width.equalTo(assetsPoolButton)
        }
        assetsPoolButton.snp.makeConstraints { (make) in
            make.top.right.bottom.equalTo(titleButtonView)
            make.left.equalTo(exchangeButton.snp.right)
        }
        detailView.snp.makeConstraints { (make) in
            if #available(iOS 11.0, *) {
                make.top.bottom.equalTo(self.view.safeAreaLayoutGuide)
            } else {
                make.top.bottom.equalTo(self.view)
            }
            make.left.right.equalTo(self.view)
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.barStyle = .default
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.navigationController?.navigationBar.barStyle = .default
    }
    deinit {
        print("MarketViewController销毁了")
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(LCLLanguageChangeNotification), object: nil)
    }
    func addNavigationBar() {
        titleButtonView.addSubview(exchangeButton)
        titleButtonView.addSubview(assetsPoolButton)
        self.navigationItem.titleView = self.titleButtonView
        
        let mineView = UIBarButtonItem(customView: marketMineButton)
        // 重要方法，用来调整自定义返回view距离左边的距离
        let rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        rightBarButtonItem.width = 15
        // 返回按钮设置成功
        self.navigationItem.rightBarButtonItems = [rightBarButtonItem, mineView]
    }
    func addFirstSubView() {
        self.detailView.scrollView.addSubview(exchangeCon.view)
        exchangeCon.view.snp.makeConstraints { (make) in
            make.left.equalTo(self.detailView.scrollView)
            make.top.bottom.equalTo(self.detailView)
            make.width.equalTo(mainWidth)
        }
        self.detailView.scrollView.addSubview(assetsPoolCon.view)
        assetsPoolCon.view.snp.makeConstraints { (make) in
            make.left.equalTo(self.detailView.scrollView).offset(mainWidth)
            make.top.bottom.equalTo(self.detailView)
            make.width.equalTo(mainWidth)
        }
    }
    /// 网络请求、数据模型
    lazy var dataModel: MarketModel = {
        let model = MarketModel.init()
        return model
    }()
    /// tableView管理类
//    lazy var tableViewManager: MarketTableViewManager = {
//        let manager = MarketTableViewManager.init()
//        manager.delegate = self
//        return manager
//    }()
    /// 子View
    private lazy var detailView : MarketView = {
        let view = MarketView.init()
        return view
    }()
    private lazy var titleButtonView: UIView = {
        let view = UIView.init()
        view.layer.cornerRadius = 15
        view.layer.borderColor = UIColor.init(hex: "7038FD").cgColor
        view.layer.borderWidth = 0.5
        view.layer.masksToBounds = true
        view.widthAnchor.constraint(equalToConstant: 200).isActive = true
        view.heightAnchor.constraint(equalToConstant: 30).isActive = true
        view.contentMode = .scaleAspectFit
        return view
    }()
    lazy var exchangeButton: UIButton = {
        let button = UIButton(type: .custom)
        // 设置字体
        button.setTitle(localLanguage(keyString: "wallet_market_exchange_navigation_title"), for: UIControl.State.normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.regular)
        button.setTitleColor(UIColor.white, for: UIControl.State.normal)
        button.addTarget(self, action: #selector(changeSubViewButtonClick(button:)), for: UIControl.Event.touchUpInside)
        button.layer.backgroundColor = UIColor.init(hex: "7038FD").cgColor
        button.layer.cornerRadius = 15
        button.tag = 10
        return button
    }()
    lazy var assetsPoolButton: UIButton = {
        let button = UIButton(type: .custom)
        // 设置字体
        button.setTitle(localLanguage(keyString: "wallet_market_assets_pool_navigation_title"), for: UIControl.State.normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.regular)
        button.setTitleColor(UIColor.init(hex: "7038FD"), for: UIControl.State.normal)
        button.addTarget(self, action: #selector(changeSubViewButtonClick(button:)), for: UIControl.Event.touchUpInside)
        button.layer.backgroundColor = UIColor.white.cgColor
        button.layer.cornerRadius = 15
        button.tag = 20
        return button
    }()
    /// 交易所个人中心
    lazy var marketMineButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage.init(named: "market_mine"), for: UIControl.State.normal)
        button.addTarget(self, action: #selector(marketMineButtonClick), for: .touchUpInside)
        return button
    }()
    lazy var exchangeCon: ExchangeViewController = {
        let vc = ExchangeViewController()
        return vc
    }()
    lazy var assetsPoolCon: AssetsPoolViewController = {
        let vc = AssetsPoolViewController()
        return vc
    }()
    @objc func changeSubViewButtonClick(button: UIButton) {
        if button.tag == 10 {
            exchangeButton.setTitleColor(UIColor.white, for: UIControl.State.normal)
            exchangeButton.layer.backgroundColor = UIColor.init(hex: "7038FD").cgColor
            assetsPoolButton.setTitleColor(UIColor.init(hex: "7038FD"), for: UIControl.State.normal)
            assetsPoolButton.layer.backgroundColor = UIColor.white.cgColor
        } else {
            exchangeButton.setTitleColor(UIColor.init(hex: "7038FD"), for: UIControl.State.normal)
            exchangeButton.layer.backgroundColor = UIColor.white.cgColor
            assetsPoolButton.setTitleColor(UIColor.white, for: UIControl.State.normal)
            assetsPoolButton.layer.backgroundColor = UIColor.init(hex: "7038FD").cgColor
        }
    }
    @objc func marketMineButtonClick(button: UIButton) {
        let vc = MarketMineViewController()
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    /// 语言切换
    @objc func setText() {
        exchangeButton.setTitle(localLanguage(keyString: "wallet_market_exchange_navigation_title"), for: UIControl.State.normal)
        assetsPoolButton.setTitle(localLanguage(keyString: "wallet_market_assets_pool_navigation_title"), for: UIControl.State.normal)
    }
}
/*
 extension MarketViewController: MarketTableViewManagerDelegate {
    //    func changeLeftRightTokenModel(leftModel: MarketSupportCoinDataModel, rightModel: MarketSupportCoinDataModel) {
    //        // 获取当前钱包地址
    //        guard let walletAddress = self.wallet?.tokenAddress else {
    //            return
    //        }
    //        self.detailView.toastView?.show(tag: 99)
    //        // 移除旧的监听
    //        self.dataModel.removeDepthsLisening(payContract: rightModel.id ?? "", exchangeContract: leftModel.id ?? "")
    //        // 请求交易所对应交易对数据
    //        self.dataModel.getMarketData(address: walletAddress, payContract: leftModel.id ?? "", exchangeContract: rightModel.id ?? "")
    //        // http请求
    ////        self.dataModel.getCurrentOrder(address: walletAddress, baseAddress: leftModel.addr ?? "", exchangeAddress: rightModel.addr ?? "")
    //        // 添加对应交易对数据变化监听
    //        self.dataModel.addDepthsLisening(payContract: leftModel.id ?? "", exchangeContract: rightModel.id ?? "")
    //    }
    //
    //    func selectToken(button: UIButton, leftModelName: String, rightModelName: String, header: MarketExchangeHeaderView) {
    //        // 获取当前钱包地址
    //        guard let walletAddress = self.wallet?.tokenAddress else {
    //            return
    //        }
    //        self.detailView.toastView?.show(tag: 99)
    //        self.dataModel.getSupportToken(address: walletAddress)
    //
    //        self.actionClosure = { dataModel in
    //            var tempDataModel = dataModel
    //            // 筛选左右展示数据
    //            var showRegisterModel: Bool = false
    //            if button.tag == 20 {
    //                // 左边点击
    //                tempDataModel = dataModel.filter({ item in
    //                    item.enable == true
    //                })
    //                showRegisterModel = true
    //            } else {
    //                // 右边点击
    //                tempDataModel = dataModel.filter({ item in
    //                    item.name != leftModelName
    //                }).sorted(by: {
    //                    ($0.enable ?? false) != ($1.enable ?? false)
    //                }).reversed()
    //                showRegisterModel = false
    //            }
    //            // 尚未注册任何稳定币
    //            if button.tag == 20 && tempDataModel.isEmpty == true {
    //                let alertContr = UIAlertController(title: localLanguage(keyString: "wallet_market_alert_register_token_title"), message: localLanguage(keyString: "wallet_market_alert_register_token_content"), preferredStyle: .alert)
    //                alertContr.addAction(UIAlertAction(title: localLanguage(keyString: "wallet_type_in_password_confirm_button_title"), style: .default){ [weak self] clickHandler in
    //                    let vc = AddAssetViewController()
    ////                    vc.wallet = self?.wallet
    //                    vc.needDismissViewController = true
    //                    let navi = UINavigationController.init(rootViewController: vc)
    //                    self?.present(navi, animated: true, completion: nil)
    //                })
    //                alertContr.addAction(UIAlertAction(title: localLanguage(keyString: "wallet_type_in_password_cancel_button_title"), style: .cancel){ clickHandler in
    //                    NSLog("点击了取消")
    //                })
    //                self.present(alertContr, animated: true, completion: nil)
    //                return
    //            }
    //            let alert = TokenPickerViewAlert.init(successClosure: { (model) in
    //                if button.tag == 20 {
    //                    // 移除之前监听
    //                    if let payContract = header.leftTokenModel?.id, let exchangeContract = header.rightTokenModel?.id, payContract.isEmpty == false, exchangeContract.isEmpty == false {
    //                        print("移除之前监听")
    //                        self.dataModel.removeDepthsLisening(payContract: payContract, exchangeContract: exchangeContract)
    //                    } else {
    //                        // 之前无监听
    //                        print("之前无监听")
    //                    }
    //                    header.leftTokenModel = model
    //                    // 右边设置为空
    //                    if header.rightTokenModel?.name == header.leftTokenModel?.name {
    //                        self.detailView.changeHeaderViewDefault(hideLeftModel: false)
    //                    }
    //                } else {
    //                    guard header.rightTokenModel?.name != model.name else {
    //                        return
    //                    }
    //                    // 移除之前监听
    //                    if let payContract = header.leftTokenModel?.id, let exchangeContract = header.rightTokenModel?.id, payContract.isEmpty == false, exchangeContract.isEmpty == false {
    //                        print("移除之前监听")
    //                        self.dataModel.removeDepthsLisening(payContract: payContract, exchangeContract: exchangeContract)
    //                    } else {
    //                        // 之前无监听
    //                        print("之前无监听")
    //                    }
    //                    header.rightTokenModel = model
    //                }
    //                // 添加监听
    //                if let payContract = header.leftTokenModel?.id, let exchangeContract = header.rightTokenModel?.id, payContract.isEmpty == false, exchangeContract.isEmpty == false {
    //                    guard let walletAddress = self.wallet?.tokenAddress else {
    //                        return
    //                    }
    //                    print("添加监听")
    //                    self.detailView.toastView?.show(tag: 99)
    //                    self.dataModel.getMarketData(address: walletAddress, payContract: payContract, exchangeContract: exchangeContract)
    //                    // http
    ////                    self.dataModel.getCurrentOrder(address: walletAddress, baseAddress: leftModel.addr ?? "", exchangeAddress: rightModel.addr ?? "")
    //
    //                    self.dataModel.addDepthsLisening(payContract: payContract, exchangeContract: exchangeContract)
    //                }
    //            }, data: tempDataModel, onlyRegisterToken: showRegisterModel)
    //            alert.show(tag: 99)
    //            alert.showAnimation()
    //        }
    //    }
    func exchangeToken(payToken: MarketSupportCoinDataModel, receiveToken: MarketSupportCoinDataModel, amount: Double, exchangeAmount: Double) {
        //        self.detailView.toastView?.show(tag: 99)
        //        // 第一步，检查余额是否充足
        ////        self.dataModel.getViolasBalance(walletID: LibraWalletManager.shared.walletID ?? 0,
        ////                                        address: LibraWalletManager.shared.walletAddress ?? "",
        ////                                        vtoken: payToken.id ?? "")
        //        self.checkBalanceClosure = { balance in
        //            if balance >= Int64(amount * 1000000) {
        //                //第二步，余额充足，检查是否将要兑换的币已注册
        //                guard receiveToken.enable == true else {
        //                    let alertContr = UIAlertController(title: localLanguage(keyString: "wallet_type_in_password_title"), message: LibraWalletError.WalletMarket(reason: .exchangeTokenPublishedInvalid).localizedDescription, preferredStyle: .alert)
        //                    alertContr.addAction(UIAlertAction(title: localLanguage(keyString: "wallet_type_in_password_confirm_button_title"), style: .default){ [weak self] clickHandler in
        //                        self?.showPublishPasswordAlert(payContract: payToken.id ?? "",
        //                                                      receiveContract: receiveToken.id ?? "",
        //                                                      amount: amount,
        //                                                      exchangeAmount: exchangeAmount,
        //                                                      name: receiveToken.name ?? "")
        //
        //                    })
        //                    alertContr.addAction(UIAlertAction(title: localLanguage(keyString: "wallet_type_in_password_cancel_button_title"), style: .cancel){ clickHandler in
        //                        NSLog("点击了取消")
        //                    })
        //                    self.present(alertContr, animated: true, completion: nil)
        //                    return
        //                }
        //                self.showPasswordAlert(payContract: payToken.id ?? "",
        //                                       receiveContract: receiveToken.id ?? "",
        //                                       amount: amount,
        //                                       exchangeAmount: exchangeAmount)
        //            } else {
        //                self.detailView.makeToast(LibraWalletError.WalletMarket(reason: .payAmountNotEnough).localizedDescription, position: .center)
        //            }
        //        }
    }
    func showPublishPasswordAlert(payContract: String, receiveContract: String, amount: Double, exchangeAmount: Double, name: String) {
        //        if LibraWalletManager.shared.walletBiometricLock == true {
        //            KeychainManager().getPasswordWithBiometric(walletAddress: LibraWalletManager.shared.walletRootAddress ?? "") { [weak self](result, error) in
        //                if result.isEmpty == false {
        //                    do {
        //                        let mnemonic = try LibraWalletManager.shared.getMnemonicFromKeychain(password: result, walletRootAddress: LibraWalletManager.shared.walletRootAddress ?? "")
        //                        guard let walletAddress = self?.wallet?.walletAddress else {
        //                            return
        //                        }
        //                        self?.detailView.toastView?.show()
        //                        self?.dataModel.publishTokenForTransaction(sendAddress: walletAddress,
        //                                                                   mnemonic: mnemonic,
        //                                                                   contact: receiveContract)
        //                        self?.publishTokenClosure = {
        //                            // 更新列表数据
        //                            if let headerView = self?.detailView.tableView.headerView(forSection: 0) as? MarketExchangeHeaderView {
        //                                headerView.rightTokenModel?.enable = true
        //                            }
        //                            // 插入本地数据库
        //                            let violasToken = ViolasTokenModel.init(name: name,
        //                                                                    description: "",
        //                                                                    address: Data.init(Array<UInt8>(hex: receiveContract)).toHexString(),
        //                                                                    icon: "",
        //                                                                    enable: true,
        //                                                                    balance: Int64(exchangeAmount * 1000000),
        //                                                                    registerState: true)
        //                            _ = DataBaseManager.DBManager.insertViolasToken(walletID: self?.wallet?.walletID ?? 0, model: violasToken)
        //                            // 发送交易
        //                            self?.dataModel.exchangeViolasTokenTransaction(sendAddress: walletAddress,
        //                                                                           amount: amount,
        //                                                                           fee: 0,
        //                                                                           mnemonic: mnemonic,
        //                                                                           contact: ViolasMainContract,
        //                                                                           exchangeTokenContract: receiveContract,
        //                                                                           exchangeTokenAmount: exchangeAmount,
        //                                                                           tokenIndex: payContract)
        //                        }
        //                    } catch {
        //                        self?.detailView.makeToast(error.localizedDescription, position: .center)
        //                    }
        //                } else {
        //                    self?.detailView.makeToast(error, position: .center)
        //                }
        //            }
        //        } else {
        //            let alert = passowordAlert(rootAddress: (self.wallet?.walletRootAddress)!, mnemonic: { [weak self] mnemonic in
        //                guard let walletAddress = self?.wallet?.walletAddress else {
        //                    return
        //                }
        //                self?.detailView.toastView?.show()
        //                self?.dataModel.publishTokenForTransaction(sendAddress: walletAddress,
        //                                                           mnemonic: mnemonic,
        //                                                           contact: receiveContract)
        //                self?.publishTokenClosure = {
        //                    // 更新列表数据
        //                    if let headerView = self?.detailView.tableView.headerView(forSection: 0) as? MarketExchangeHeaderView {
        //                        headerView.rightTokenModel?.enable = true
        //                    }
        //                    // 插入本地数据库
        //                    let violasToken = ViolasTokenModel.init(name: name,
        //                                                            description: "",
        //                                                            address: Data.init(Array<UInt8>(hex: receiveContract)).toHexString(),
        //                                                            icon: "",
        //                                                            enable: true,
        //                                                            balance: Int64(exchangeAmount * 1000000),
        //                                                            registerState: true)
        //                    _ = DataBaseManager.DBManager.insertViolasToken(walletID: self?.wallet?.walletID ?? 0, model: violasToken)
        //                    // 发送交易
        //                    self?.dataModel.exchangeViolasTokenTransaction(sendAddress: walletAddress,
        //                                                                   amount: amount,
        //                                                                   fee: 0,
        //                                                                   mnemonic: mnemonic,
        //                                                                   contact: ViolasMainContract,
        //                                                                   exchangeTokenContract: receiveContract,
        //                                                                   exchangeTokenAmount: exchangeAmount,
        //                                                                   tokenIndex: payContract)
        //                }
        //            }) { [weak self] errorContent in
        //                self?.view.makeToast(errorContent, position: .center)
        //            }
        //            self.present(alert, animated: true, completion: nil)
        //
        //        }
    }
    func showPasswordAlert(payContract: String, receiveContract: String, amount: Double, exchangeAmount: Double) {
        //        if LibraWalletManager.shared.walletBiometricLock == true {
        //            KeychainManager().getPasswordWithBiometric(walletAddress: LibraWalletManager.shared.walletRootAddress ?? "") { [weak self](result, error) in
        //                if result.isEmpty == false {
        //                    do {
        //                        let mnemonic = try LibraWalletManager.shared.getMnemonicFromKeychain(password: result, walletRootAddress: LibraWalletManager.shared.walletRootAddress ?? "")
        //                        guard let walletAddress = self?.wallet?.walletAddress else {
        //                            return
        //                        }
        //                        self?.detailView.toastView?.show()
        //                        self?.dataModel.exchangeViolasTokenTransaction(sendAddress: walletAddress,
        //                                                                       amount: amount,
        //                                                                       fee: 0,
        //                                                                       mnemonic: mnemonic,
        //                                                                       contact: ViolasMainContract,
        //                                                                       exchangeTokenContract: receiveContract,
        //                                                                       exchangeTokenAmount: exchangeAmount,
        //                                                                       tokenIndex: payContract)
        //                    } catch {
        //                        self?.detailView.makeToast(error.localizedDescription, position: .center)
        //                    }
        //                } else {
        //                    self?.detailView.makeToast(error, position: .center)
        //                }
        //            }
        //        } else {
        //            let alert = passowordAlert(rootAddress: (self.wallet?.walletRootAddress)!, mnemonic: { [weak self] mnemonic in
        //                guard let walletAddress = self?.wallet?.walletAddress else {
        //                    return
        //                }
        //                self?.detailView.toastView?.show()
        //                self?.dataModel.exchangeViolasTokenTransaction(sendAddress: walletAddress,
        //                                                               amount: amount,
        //                                                               fee: 0,
        //                                                               mnemonic: mnemonic,
        //                                                               contact: ViolasMainContract,
        //                                                               exchangeTokenContract: receiveContract,
        //                                                               exchangeTokenAmount: exchangeAmount,
        //                                                               tokenIndex: payContract)
        //            }) { [weak self] errorContent in
        //                self?.view.makeToast(errorContent, position: .center)
        //            }
        //            self.present(alert, animated: true, completion: nil)
        //        }
    }
    func showOrderCenter() {
        //        let vc = OrderCenterViewController()
        //        vc.hidesBottomBarWhenPushed = true
        //        vc.wallet = self.wallet
        //        self.navigationController?.pushViewController(vc, animated: true)
    }
    func showHideOthersToMax(state: Bool) {
//        self.detailView.tableView.beginUpdates()
//        if state == true  {
//            // 展示
//            if (self.tableViewManager.sellOrders?.count ?? 0) > 5 {
//                // 大于5条
//                var tempIndexPaths = [IndexPath]()
//                let maxRow = (self.tableViewManager.sellOrders?.count ?? 0) >= 20 ? 20:(self.tableViewManager.sellOrders?.count ?? 0)
//                for i in 5..<maxRow {
//                    let indexPath = IndexPath.init(row: i, section: 2)
//                    tempIndexPaths.append(indexPath)
//                }
//                self.detailView.tableView.insertRows(at: tempIndexPaths, with: UITableView.RowAnimation.bottom)
//            } else {
//                // 小于5条不做操作
//            }
//        } else {
//            // 隐藏
//            if (self.tableViewManager.sellOrders?.count ?? 0) > 5 {
//                // 大于5条
//                var tempIndexPaths = [IndexPath]()
//                let maxRow = (self.tableViewManager.sellOrders?.count ?? 0) >= 20 ? 20:(self.tableViewManager.sellOrders?.count ?? 0)
//                for i in 5..<maxRow {
//                    let indexPath = IndexPath.init(row: i, section: 2)
//                    tempIndexPaths.append(indexPath)
//                }
//                self.detailView.tableView.deleteRows(at: tempIndexPaths, with: UITableView.RowAnimation.bottom)
//            } else {
//                // 小于5条不做操作
//            }
//        }
//        self.detailView.tableView.endUpdates()
    }
}
extension MarketViewController {
    func initKVO() {
        //        dataModel.addObserver(self, forKeyPath: "dataDic", options: NSKeyValueObservingOptions.new, context: &myContext)
    }
    //    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?)  {
    //
    //        guard context == &myContext else {
    //            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
    //            return
    //        }
    //        guard (change?[NSKeyValueChangeKey.newKey]) != nil else {
    //            return
    //        }
    //        guard let jsonData = (object! as AnyObject).value(forKey: "dataDic") as? NSDictionary else {
    //            return
    //        }
    //        if let error = jsonData.value(forKey: "error") as? LibraWalletError {
    //            self.detailView.toastView?.hide(tag: 99)
    //            if error.localizedDescription == LibraWalletError.WalletRequest(reason: .networkInvalid).localizedDescription {
    //                // 网络无法访问
    //                print(error.localizedDescription)
    //                self.detailView.makeToast(error.localizedDescription, position: .center)
    //            } else if error.localizedDescription == LibraWalletError.WalletRequest(reason: .walletTokenExpired).localizedDescription {
    //                // 钱包不存在
    //                print(error.localizedDescription)
    //                self.detailView.makeToast(error.localizedDescription, position: .center)
    //            } else if error.localizedDescription == LibraWalletError.WalletRequest(reason: .walletVersionExpired).localizedDescription {
    //                // 版本太久
    //                print(error.localizedDescription)
    //                self.detailView.makeToast(error.localizedDescription, position: .center)
    //            } else if error.localizedDescription == LibraWalletError.WalletRequest(reason: .parseJsonError).localizedDescription {
    //                // 解析失败
    //                print(error.localizedDescription)
    //                self.detailView.makeToast(error.localizedDescription, position: .center)
    //            } else if error.localizedDescription == LibraWalletError.WalletRequest(reason: .dataEmpty).localizedDescription {
    //                print(error.localizedDescription)
    //                // 数据为空
    //                self.detailView.makeToast(error.localizedDescription, position: .center)
    //            } else if error.localizedDescription == LibraWalletError.WalletRequest(reason: .dataCodeInvalid).localizedDescription {
    //                print(error.localizedDescription)
    //                // 数据返回状态异常
    //                self.detailView.makeToast(error.localizedDescription, position: .center)
    //            } else if error.localizedDescription == LibraWalletError.WalletMarket(reason: .publishedListEmpty).localizedDescription {
    //                print(error.localizedDescription)
    //                let alertContr = UIAlertController(title: localLanguage(keyString: "wallet_type_in_password_title"), message: localLanguage(keyString: "wallet_market_alert_register_token_content"), preferredStyle: .alert)
    //                alertContr.addAction(UIAlertAction(title: localLanguage(keyString: "wallet_type_in_password_confirm_button_title"), style: .default){ [weak self] clickHandler in
    //                    let vc = AddAssetViewController()
    ////                    vc.wallet = self?.wallet
    //                    vc.needDismissViewController = true
    //                    let navi = UINavigationController.init(rootViewController: vc)
    //                    self?.present(navi, animated: true, completion: nil)
    //                })
    //                alertContr.addAction(UIAlertAction(title: localLanguage(keyString: "wallet_type_in_password_cancel_button_title"), style: .cancel){ clickHandler in
    //                    NSLog("点击了取消")
    //                })
    //                self.present(alertContr, animated: true, completion: nil)
    //            } else if error.localizedDescription == LibraWalletError.WalletMarket(reason: .marketSupportTokenEmpty).localizedDescription {
    //                print(error.localizedDescription)
    //
    //            }
    ////            self.detailView.hideToastActivity()
    //
    //            return
    //        }
    //        let type = jsonData.value(forKey: "type") as! String
    //
    //        if type == "GetTokenList" {
    //            // 获取交易所支持稳定币列表
    //            self.detailView.toastView?.hide(tag: 99)
    //            if let tempData = jsonData.value(forKey: "data") as? [MarketSupportCoinDataModel] {
    //                if let action = self.actionClosure {
    //                    action(tempData)
    //                }
    //            }
    //        } else if type == "GetCurrentOrder" {
    //            self.detailView.toastView?.hide(tag: 99)
    ////            if let tempData = jsonData.value(forKey: "data") as? MarketResponseMainModel {
    ////                #warning("无奈之举，望谅解")
    ////                let headerView = self.detailView.tableView.headerView(forSection: 0) as? MarketExchangeHeaderView
    ////                self.tableViewManager.buyOrders = tempData.orders?.filter({
    ////                    $0.user?.contains(self.wallet?.tokenAddress ?? "") == true
    ////                }).sorted(by: {
    ////                    ($0.date ?? 0) > ($1.date ?? 0)
    ////                }).map({ (item) in
    ////                    MarketOrderDataModel.init(id: item.id, user: item.user, state: item.state, tokenGet: item.tokenGet, tokenGetSymbol: item.tokenGetSymbol, amountGet: item.amountGet, tokenGive: item.tokenGive, tokenGiveSymbol: item.tokenGiveSymbol, amountGive: item.amountGive, version: item.version, date: item.date, update_date: item.update_date, update_version: item.update_version, amountFilled: item.amountFilled, tokenGivePrice: item.tokenGivePrice, tokenGetPrice: item.tokenGetPrice)
    ////                })
    ////                #warning("无奈之举，望谅解")
    ////                self.tableViewManager.sellOrders = tempData.depths?.buys?.filter({
    ////                    $0.user?.contains(self.wallet?.tokenAddress ?? "") == false
    ////                }).sorted(by: {
    ////                    ($0.date ?? 0) < ($1.date ?? 0)
    ////                }).map({ (item) in
    ////                    MarketOrderDataModel.init(id: item.id, user: item.user, state: item.state, tokenGet: item.tokenGet, tokenGetSymbol: item.tokenGetSymbol, amountGet: item.amountGet, tokenGive: item.tokenGive, tokenGiveSymbol: item.tokenGiveSymbol, amountGive: item.amountGive, version: item.version, date: item.date, update_date: item.update_date, update_version: item.update_version, amountFilled: item.amountFilled, tokenGivePrice: item.tokenGivePrice, tokenGetPrice: item.tokenGetPrice)
    ////                })
    ////                headerView?.rate = tempData.price ?? 0
    ////                self.detailView.tableView.reloadData()
    ////            }
    //        } else if type == "OrderChange" {
    //            // 订单状态变更
    //            self.detailView.toastView?.hide(tag: 99)
    //            if let tempData = jsonData.value(forKey: "data") as? MarketOrderModel {
    //                if let data = tempData.buys, data.isEmpty == false {
    //                    refreshTableView(data: data)
    //                }
    //            }
    //        } else if type == "ExchangeDone" {
    //            // 兑换挂单成功
    //            self.detailView.toastView?.hide(tag: 99)
    //            self.detailView.makeToast(localLanguage(keyString: "wallet_market_alert_make_order_success_title"), position: .center)
    ////            let headerView = self.detailView.tableView.headerView(forSection: 0) as! MarketExchangeHeaderView
    ////            headerView.leftAmountTextField.text = ""
    ////            headerView.rightAmountTextField.text = ""
    //        } else if type == "UpdateViolasBalance" {
    //            // 获取余额
    ////            self.detailView.toastView?.hide()
    ////            if let tempData = jsonData.value(forKey: "data") as? BalanceViolasModel {
    ////                if let data = tempData.modules, data.isEmpty == false, let tempModule = data.first {
    ////                    if let action = self.checkBalanceClosure {
    ////                        action(Int64(tempModule.balance ?? 0))
    ////                    }
    ////                }
    ////            }
    //        } else if type == "PublishTokenForTransaction" {
    //            // 代币注册
    //            if let action = self.publishTokenClosure {
    //                action()
    //            }
    //        } else if type == "SocketReconnect" {
    //            // Socket 重连
    //            self.tableViewManager.buyOrders?.removeAll()
    //            self.tableViewManager.sellOrders?.removeAll()
    //            self.detailView.tableView.reloadData()
    //            self.requestData()
    //        }
    //    }
}
*/
