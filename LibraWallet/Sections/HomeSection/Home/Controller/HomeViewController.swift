//
//  HomeViewController.swift
//  LibraWallet
//
//  Created by palliums on 2019/9/11.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit
import Localize_Swift
import MJRefresh
class HomeViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // 设置背景色
        self.view.backgroundColor = UIColor.white
        // 添加导航栏按钮
        self.addNavigationBar()
        // 加载子View
        self.view.addSubview(detailView)
        // 初始化KVO
        self.initKVO()
        // 添加语言变换通知
        NotificationCenter.default.addObserver(self, selector: #selector(setText), name: NSNotification.Name(LCLLanguageChangeNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(deleteWallet), name: NSNotification.Name("PalliumsWalletDelete"), object: nil)

        // 检查是否第一次打开app
        checkIsFisrtOpenApp()
        checkConfirmLegal()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.barStyle = .black
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.barStyle = .default
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        detailView.snp.makeConstraints { (make) in
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(self.view.safeAreaLayoutGuide)
            } else {
                make.bottom.equalTo(self.view)
            }
            make.top.left.right.equalTo(self.view)
        }
    }
    /// 网络请求、数据模型
    lazy var dataModel: HomeModel = {
        let model = HomeModel.init()
        return model
    }()
    /// tableView管理类
    lazy var tableViewManager: HomeTableViewManager = {
        let manager = HomeTableViewManager.init()
        manager.delegate = self
        return manager
    }()
    /// 子View
    lazy var detailView : HomeView = {
        let view = HomeView.init()
        view.tableView.delegate = self.tableViewManager
        view.tableView.dataSource = self.tableViewManager
        view.headerView.delegate = self
        view.tableView.mj_header = MJRefreshNormalHeader.init(refreshingTarget: self, refreshingAction:  #selector(refreshData))
        view.importOrCreateView.delegate = self
        return view
    }()
    /// 全部资产价值按钮
    lazy var totalAssetsButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle(localLanguage(keyString: "wallet_home_wallet_total_asset_title"), for: UIControl.State.normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.regular)
        button.setTitleColor(UIColor.white, for: UIControl.State.normal)
        button.setImage(UIImage.init(named: "eyes_open_white"), for: UIControl.State.normal)
        // 调整位置
        button.imagePosition(at: .right, space: 4, imageViewSize: CGSize.init(width: 14, height: 8))
        button.addTarget(self, action: #selector(changeWallet), for: .touchUpInside)
        return button
    }()
    /// 二维码扫描按钮
    lazy var scanButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage.init(named: "home_scan"), for: UIControl.State.normal)
        button.addTarget(self, action: #selector(scanToTransfer), for: .touchUpInside)
        return button
    }()
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(LCLLanguageChangeNotification), object: nil)
        print("HomeViewController销毁了")
    }
    /// 数据监听KVO
    var observer: NSKeyValueObservation?
}
//MARK: - 导航栏添加按钮
extension HomeViewController {
    func addNavigationBar() {
        // 自定义导航栏的UIBarButtonItem类型的按钮
        let backView = UIBarButtonItem(customView: totalAssetsButton)
        // 重要方法，用来调整自定义返回view距离左边的距离
        let barButtonItem = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        barButtonItem.width = 15
        // 返回按钮设置成功
        self.navigationItem.leftBarButtonItems = [barButtonItem, backView]
        
        let scanView = UIBarButtonItem(customView: scanButton)
        // 重要方法，用来调整自定义返回view距离左边的距离
        let rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        rightBarButtonItem.width = 15
        // 返回按钮设置成功
        self.navigationItem.rightBarButtonItems = [rightBarButtonItem, scanView]
    }
    /// 切换钱包
    @objc func changeWallet() {
        if let amount = self.detailView.headerView.assetLabel.text, amount.hasPrefix("***") == true {
            self.detailView.headerView.showAssets()
            self.totalAssetsButton.setImage(UIImage.init(named: "eyes_open_white"), for: UIControl.State.normal)
        } else {
            self.detailView.headerView.assetLabel.text = "*****"
            self.totalAssetsButton.setImage(UIImage.init(named: "eyes_close_white"), for: UIControl.State.normal)
        }
    }
    
    /// 扫面按钮点击
    @objc func scanToTransfer() {
        let vc = ScanViewController()
        vc.actionClosure = { address in
            do {
                let result = try libraWalletTool.scanResultHandle(content: address, contracts: [ViolasTokenModel]())
                if result.type == .transfer {
                    switch result.addressType {
                    case .BTC:
                        self.showBTCTransferViewController(address: result.address ?? "", amount: result.amount)
                    case .Violas:
                        if let model = result.contract {
                            self.showViolasTokenViewController(address: result.address ?? "", tokenModel: model, amount: result.amount)
                        } else {
                            self.showViolasTransferViewController(address: result.address ?? "", amount: result.amount)
                        }
                    case .Libra:
                        self.showLibraTransferViewController(address: result.address ?? "", amount: result.amount)
                    default:
                        self.showScanContent(content: address)
                    }
                } else if result.type == .walletConnect {
                    self.showWalletConnect(wcURL: result.originContent)
                } else {
                    self.showScanContent(content: address)
                }
                
            } catch {
                self.view.makeToast(error.localizedDescription, position: .center)
            }
        }
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func showBTCTransferViewController(address: String, amount: Int64?) {
        let vc = BTCTransferViewController()
        vc.actionClosure = {
            //            self.dataModel.getLocalUserInfo()
        }
        vc.wallet = self.detailView.headerView.walletModel
        vc.address = address
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func showLibraTransferViewController(address: String, amount: Int64?) {
        let vc = TransferViewController()
        vc.actionClosure = {
            //            self.dataModel.getLocalUserInfo()
        }
        vc.wallet = self.detailView.headerView.walletModel
        vc.address = address
        vc.amount = amount
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func showViolasTransferViewController(address: String, amount: Int64?) {
        let vc = ViolasTransferViewController()
        vc.actionClosure = {
            //            self.dataModel.getLocalUserInfo()
        }
        vc.wallet = self.detailView.headerView.walletModel
        vc.sendViolasTokenState = false
        vc.address = address
        vc.amount = amount
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func showViolasTokenViewController(address: String, tokenModel: ViolasTokenModel, amount: Int64?) {
        let vc = ViolasTransferViewController()
        vc.actionClosure = {
            //            self.dataModel.getLocalUserInfo()
        }
        vc.wallet = self.detailView.headerView.walletModel
        vc.sendViolasTokenState = true
        vc.vtokenModel = tokenModel
        vc.address = address
        vc.amount = amount
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func showScanContent(content: String) {
        let vc = ScanResultInvalidViewController()
        vc.hidesBottomBarWhenPushed = true
        vc.content = content
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func showWalletConnect(wcURL: String) {
        if WalletConnectManager.shared.state == true {
            print("已登录")
        } else {
            // 未登录
            self.detailView.toastView?.show(tag: 99)
            WalletConnectManager.shared.allowConnect = {
                self.detailView.toastView?.hide(tag: 99)
                let vc = ScanLoginViewController()
                //                vc.wallet = LibraWalletManager.shared
                vc.sessionID = wcURL
                self.present(vc, animated: true, completion: nil)
            }
            WalletConnectManager.shared.connectToServer(url: wcURL)
            WalletConnectManager.shared.connectInvalid = {
                self.detailView.toastView?.hide(tag: 99)
                self.detailView.makeToast(localLanguage(keyString: "wallet_connect_connect_time_invalid_title"), position: .center)
            }
        }
        
    }
}
//MARK: - APP初次进入处理
extension HomeViewController {
    func checkIsFisrtOpenApp() {
        guard getWelcomeState() == false else {
            return
        }
        let alert = WelcomeAlert.init()
        alert.show(tag: 199)
    }
    func checkConfirmLegal() {
        guard getConfirmPrivateAndUseLegalState() == false else {
            return
        }
        let alert = PrivateAlertView.init(openPrivateLegal: {
            let vc = ServiceLegalViewController()
            vc.needDismissViewController = true
            let navi = UINavigationController.init(rootViewController: vc)
            self.present(navi, animated: true, completion: nil)
        }) {
            let vc = PrivateLegalViewController()
            vc.needDismissViewController = true
            let navi = UINavigationController.init(rootViewController: vc)
            self.present(navi, animated: true, completion: nil)
        }
        
        alert.show(tag: 199)
        //        let alert = WelcomeAlert.init()
        //        alert.show()
    }
    
}
//MARK: - 下拉刷新
extension HomeViewController {
    /// 下拉刷新
    @objc func refreshData() {
        self.dataModel.getLocalTokens()
    }
}
//MARK: - 语言切换方法
extension HomeViewController {
    /// 语言切换
    @objc func setText() {
        self.totalAssetsButton.setTitle(localLanguage(keyString: "wallet_home_wallet_total_asset_title"), for: UIControl.State.normal)
        self.totalAssetsButton.imagePosition(at: .right, space: 4, imageViewSize: CGSize.init(width: 14, height: 8))
    }
    @objc func deleteWallet() {
        self.detailView.headerView.assetsModel = "0"
        self.tableViewManager.dataModel?.removeAll()
        self.detailView.tableView.reloadData()
    }
}

//MARK: - 子View代理方法列表
extension HomeViewController: HomeHeaderViewDelegate {
    func walletConnectState() {
        print("123")
    }
    func addAssets() {
        let vc = AddAssetViewController()
        vc.hidesBottomBarWhenPushed = true
        vc.tokens = self.tableViewManager.dataModel
        vc.needUpdateClosure = { result in
            //            self.refreshData()
            self.detailView.makeToastActivity(.center)
            self.dataModel.getLocalTokens()
            print("刷新首页数据")
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
extension HomeViewController: HomeWithoutWalletViewDelegate {
    func createWallet() {
        let vc = AddWalletViewController()
        vc.successCreateClosure = {
            self.detailView.importOrCreateView.removeFromSuperview()
            self.dataModel.getLocalTokens()
        }
        let navi = BaseNavigationViewController.init(rootViewController: vc)
        self.present(navi, animated: true, completion: nil)
    }
    func importWallet() {
        let vc = ImportWalletViewController()
        vc.successImportClosure = {
            self.detailView.importOrCreateView.removeFromSuperview()
            self.dataModel.getLocalTokens()
        }
        let navi = BaseNavigationViewController.init(rootViewController: vc)
        self.present(navi, animated: true, completion: nil)
    }
}
//MARK: - TableviewManager代理方法列表
extension HomeViewController: HomeTableViewManagerDelegate {
    func tableViewDidSelectRowAtIndexPath(indexPath: IndexPath, model: Token) {
        let vc = WalletMainViewController()
        vc.wallet = model
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
//MARK: - 网络请求数据处理中心
extension HomeViewController {
    func initKVO() {
        self.observer = dataModel.observe(\.dataDic, options: [.new], changeHandler: { [weak self](model, change) in
            guard let dataDic = change.newValue, dataDic.count != 0 else {
                self?.detailView.hideToastActivity()
                //                self?.endLoading()
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
                self?.detailView.tableView.mj_header?.endRefreshing()
                return
            }
            if type == "LoadCurrentEnableTokens" {
                // 加载本地默认钱包
                if let tempData = dataDic.value(forKey: "data") as? [Token] {
                    //                    self?.detailView.model = tempData
                    self?.tableViewManager.dataModel = tempData
                    self?.detailView.tableView.reloadData()
                    self?.detailView.headerView.assetsModel = "0.00"
                }
            } else if type == "UpdateBTCBalance" {
                if let tempData = dataDic.value(forKey: "data") as? TrezorBTCBalanceMainModel {
                    guard let dataModels = self?.tableViewManager.dataModel else {
                        return
                    }
                    var tempTokens = [Token]()
                    var tempIndexPath = [IndexPath]()
                    for i in 0..<dataModels.count {
                        guard dataModels[i].tokenType == .BTC else {
                            tempTokens.append(dataModels[i])
                            continue
                        }
                        for var model in dataModels {
                            guard model.tokenType == .BTC else {
                                tempTokens.append(model)
                                continue
                            }
                            if NSDecimalNumber.init(string: tempData.balance ?? "").int64Value != dataModels[i].tokenBalance {
                                model.changeTokenBalance(banlance: NSDecimalNumber.init(string: tempData.balance ?? "").int64Value)
                                tempIndexPath.append(IndexPath.init(item: i, section: 0))
                            }
                            tempTokens.append(model)
                        }
                    }
                    if tempIndexPath.isEmpty == false {
                        self?.tableViewManager.dataModel = tempTokens
                        self?.detailView.tableView.beginUpdates()
                        self?.detailView.tableView.reloadRows(at: tempIndexPath, with: .fade)
                        self?.detailView.tableView.endUpdates()
                    }
                }
            } else if type == "UpdateLibraBalance" {
                if let tempData = dataDic.value(forKey: "data") as? [LibraBalanceModel] {
                    guard let dataModels = self?.tableViewManager.dataModel else {
                        return
                    }
                    var tempTokens = [Token]()
                    var tempIndexPath = [IndexPath]()
                    for i in 0..<dataModels.count {
                        guard dataModels[i].tokenType == .Libra else {
                            tempTokens.append(dataModels[i])
                            continue
                        }
                        var changeState = false
                        for token in tempData {
                            if token.currency == dataModels[i].tokenModule {
                                var tempLocalToken = dataModels[i]
                                if token.amount != dataModels[i].tokenBalance {
                                    tempLocalToken.changeTokenBalance(banlance: token.amount ?? 0)
                                    tempIndexPath.append(IndexPath.init(item: i, section: 0))
                                }
                                tempTokens.append(tempLocalToken)
                                changeState = true
                                continue
                            }
                        }
                        if changeState == false {
                            tempTokens.append(dataModels[i])
                        }
                    }
                    if tempIndexPath.isEmpty == false {
                        self?.tableViewManager.dataModel = tempTokens
                        self?.detailView.tableView.beginUpdates()
                        self?.detailView.tableView.reloadRows(at: tempIndexPath, with: .fade)
                        self?.detailView.tableView.endUpdates()
                    }
                }
            } else if type == "UpdateViolasBalance" {
                if let tempData = dataDic.value(forKey: "data") as? [ViolasBalanceModel] {
                    guard let dataModels = self?.tableViewManager.dataModel else {
                        return
                    }
                    var tempTokens = [Token]()
                    var tempIndexPath = [IndexPath]()
                    for i in 0..<dataModels.count {
                        guard dataModels[i].tokenType == .Violas else {
                            tempTokens.append(dataModels[i])
                            continue
                        }
                        var changeState = false
                        for token in tempData {
                            if token.currency == dataModels[i].tokenModule {
                                var tempLocalToken = dataModels[i]
                                if token.amount != dataModels[i].tokenBalance {
                                    tempLocalToken.changeTokenBalance(banlance: token.amount ?? 0)
                                    tempIndexPath.append(IndexPath.init(item: i, section: 0))
                                }
                                tempTokens.append(tempLocalToken)
                                changeState = true
                                continue
                            }
                        }
                        if changeState == false {
                            tempTokens.append(dataModels[i])
                        }
                    }
                    if tempIndexPath.isEmpty == false {
                        self?.tableViewManager.dataModel = tempTokens
                        self?.detailView.tableView.beginUpdates()
                        self?.detailView.tableView.reloadRows(at: tempIndexPath, with: .fade)
                        self?.detailView.tableView.endUpdates()
                    }
                }
            } else if type == "GetBTCPrice" {
                if let tempData = dataDic.value(forKey: "data") as? [ModelPriceDataModel] {
                    guard let dataModels = self?.tableViewManager.dataModel else {
                        return
                    }
                    var tempTokens = [Token]()
                    var tempIndexPath = [IndexPath]()
                    for i in 0..<dataModels.count {
                        guard dataModels[i].tokenType == .Violas else {
                            tempTokens.append(dataModels[i])
                            continue
                        }
                        var changeState = false
                        for token in tempData {
                            if token.name == dataModels[i].tokenModule {
                                var tempLocalToken = dataModels[i]
                                let newPrice = NSDecimalNumber.init(value: token.rate ?? 0.0).stringValue
                                if newPrice != dataModels[i].tokenPrice {
                                    tempLocalToken.changeTokenPrice(price: newPrice)
                                    _ = DataBaseManager.DBManager.updateTokenPrice(tokenID: dataModels[i].tokenID, price: newPrice)
                                    tempIndexPath.append(IndexPath.init(item: i, section: 0))
                                }
                                tempTokens.append(tempLocalToken)
                                changeState = true
                                continue
                            }
                        }
                        if changeState == false {
                            tempTokens.append(dataModels[i])
                        }
                    }
                    if tempIndexPath.isEmpty == false {
                        self?.tableViewManager.dataModel = tempTokens
                        self?.detailView.tableView.beginUpdates()
                        self?.detailView.tableView.reloadRows(at: tempIndexPath, with: .fade)
                        self?.detailView.tableView.endUpdates()
                    }
                }
            } else if type == "GetViolasPrice" {
                if let tempData = dataDic.value(forKey: "data") as? [ModelPriceDataModel] {
                    guard let dataModels = self?.tableViewManager.dataModel else {
                        return
                    }
                    var tempTokens = [Token]()
                    var tempIndexPath = [IndexPath]()
                    for i in 0..<dataModels.count {
                        guard dataModels[i].tokenType == .Violas else {
                            tempTokens.append(dataModels[i])
                            continue
                        }
                        var changeState = false
                        for token in tempData {
                            if token.name == dataModels[i].tokenModule {
                                var tempLocalToken = dataModels[i]
                                let newPrice = NSDecimalNumber.init(value: token.rate ?? 0.0).stringValue
                                if newPrice != dataModels[i].tokenPrice {
                                    tempLocalToken.changeTokenPrice(price: newPrice)
                                    _ = DataBaseManager.DBManager.updateTokenPrice(tokenID: dataModels[i].tokenID, price: newPrice)
                                    tempIndexPath.append(IndexPath.init(item: i, section: 0))
                                }
                                tempTokens.append(tempLocalToken)
                                changeState = true
                                continue
                            }
                        }
                        if changeState == false {
                            tempTokens.append(dataModels[i])
                        }
                    }
                    if tempIndexPath.isEmpty == false {
                        self?.tableViewManager.dataModel = tempTokens
                        self?.detailView.tableView.beginUpdates()
                        self?.detailView.tableView.reloadRows(at: tempIndexPath, with: .fade)
                        self?.detailView.tableView.endUpdates()
                    }
                }
            } else if type == "GetLibraPrice" {
                if let tempData = dataDic.value(forKey: "data") as? [ModelPriceDataModel] {
                    guard let dataModels = self?.tableViewManager.dataModel else {
                        return
                    }
                    var tempTokens = [Token]()
                    var tempIndexPath = [IndexPath]()
                    for i in 0..<dataModels.count {
                        guard dataModels[i].tokenType == .Libra else {
                            tempTokens.append(dataModels[i])
                            continue
                        }
                        var changeState = false
                        for token in tempData {
                            if token.name == dataModels[i].tokenModule {
                                var tempLocalToken = dataModels[i]
                                let newPrice = NSDecimalNumber.init(value: token.rate ?? 0.0).stringValue
                                if newPrice != dataModels[i].tokenPrice {
                                    _ = DataBaseManager.DBManager.updateTokenPrice(tokenID: dataModels[i].tokenID, price: newPrice)
                                    tempLocalToken.changeTokenPrice(price: newPrice)
                                    tempIndexPath.append(IndexPath.init(item: i, section: 0))
                                }
                                tempTokens.append(tempLocalToken)
                                changeState = true
                                continue
                            }
                        }
                        if changeState == false {
                            tempTokens.append(dataModels[i])
                        }
                    }
                    if tempIndexPath.isEmpty == false {
                        self?.tableViewManager.dataModel = tempTokens
                        self?.detailView.tableView.beginUpdates()
                        self?.detailView.tableView.reloadRows(at: tempIndexPath, with: .fade)
                        self?.detailView.tableView.endUpdates()
                    }
                }
            } else if type == "GetTotalPrice" {
                var totalPrice = 0.0
                guard let dataModels = self?.tableViewManager.dataModel, dataModels.isEmpty == false else {
                    return
                }
                for model in dataModels {
                    var unit = 1000000
                    if model.tokenType == .BTC {
                        unit = 100000000
                    }
                    let rate = NSDecimalNumber.init(string: model.tokenPrice)
                    let amount = getDecimalNumber(amount: NSDecimalNumber.init(value: model.tokenBalance),
                                                   scale: 4,
                                                   unit: unit)
                    let value = rate.multiplying(by: amount)
                    totalPrice += value.doubleValue
                }
                let numberConfig = NSDecimalNumberHandler.init(roundingMode: .down,
                                                               scale: 4,
                                                               raiseOnExactness: false,
                                                               raiseOnOverflow: false,
                                                               raiseOnUnderflow: false,
                                                               raiseOnDivideByZero: false)
                let value = NSDecimalNumber.init(value: totalPrice).multiplying(by: 1, withBehavior: numberConfig)
                if self?.detailView.headerView.assetsModel != value.stringValue {
                    
                    self?.detailView.headerView.assetsModel = value.stringValue
                }
            }
            self?.detailView.hideToastActivity()
            self?.detailView.tableView.mj_header?.endRefreshing()
        })
        self.detailView.makeToastActivity(.center)
        self.dataModel.getLocalTokens()
    }
    func refreshTableView(type: WalletType, localTokens: [Token], dataModels: [ViolasBalanceModel]) {
        //        guard let dataModels = self?.tableViewManager.dataModel else {
        //            return
        //        }
        //        var tempTokens = [Token]()
        //        var tempIndexPath = [IndexPath]()
        //        for i in 0..<dataModels.count {
        //            guard dataModels[i].tokenType == type else {
        //                tempTokens.append(dataModels[i])
        //                continue
        //            }
        //            var changeState = false
        //            for token in tempData {
        //                if token.currency == dataModels[i].tokenModule {
        //                    var tempLocalToken = dataModels[i]
        //                    if token.amount != dataModels[i].tokenBalance {
        //                        tempLocalToken.changeTokenBalance(banlance: token.amount ?? 0)
        //                        tempIndexPath.append(IndexPath.init(item: i, section: 0))
        //                    }
        //                    tempTokens.append(tempLocalToken)
        //                    changeState = true
        //                    continue
        //                }
        //            }
        //            if changeState == false {
        //                tempTokens.append(dataModels[i])
        //            }
        //        }
        //        if tempIndexPath.isEmpty == false {
        //            self?.tableViewManager.dataModel = tempTokens
        //            self?.detailView.tableView.beginUpdates()
        //            self?.detailView.tableView.reloadRows(at: tempIndexPath, with: .fade)
        //            self?.detailView.tableView.endUpdates()
        //        }
        
    }
}
