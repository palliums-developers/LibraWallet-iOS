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
        // 添加通知
        addNotifications()
        // 检查是否第一次打开app
        checkIsFisrtOpenApp()
        // 添加服务协议
        checkConfirmLegal()
        // 请求数据
        requestData()
        // 请求是否是新钱包
        requestWaletNewState()

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.barStyle = .black
        self.detailView.activeButton.alpha = WalletManager.shared.isNewWallet == true ? 1:0
        // 展示未备份警告
        isBackupMnemonic()
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
        view.delegate = self
        view.headerView.delegate = self
        view.tableView.mj_header = MJRefreshNormalHeader.init(refreshingTarget: self, refreshingAction:  #selector(refreshData))
        view.importOrCreateView.delegate = self
        return view
    }()
    /// 全部资产价值按钮
    lazy var totalAssetsButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle(localLanguage(keyString: "wallet_home_wallet_total_asset_title"), for: UIControl.State.normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: UIFont.Weight.regular)
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
    /// 消息按钮
    lazy var messageButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage.init(named: "home_notification"), for: UIControl.State.normal)
        button.addTarget(self, action: #selector(checkNotificationCenter), for: .touchUpInside)
        return button
    }()
    lazy var messagesUnreadCountLabel: UILabel = {
        let label = UILabel.init(frame: CGRect.init(x: 10, y: -1, width: 17, height: 8))
        label.textAlignment = NSTextAlignment.center
        label.textColor = UIColor.white
        label.backgroundColor = UIColor.red
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 7), weight: UIFont.Weight.medium)
        label.text = ""
        label.layer.cornerRadius = 3
        label.layer.masksToBounds = true
        label.alpha = 0
        return label
    }()
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(LCLLanguageChangeNotification), object: nil)
        print("HomeViewController销毁了")
    }
    func addNotifications() {
        // 添加语言变换通知
        NotificationCenter.default.addObserver(self, selector: #selector(setText), name: NSNotification.Name(LCLLanguageChangeNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(deleteWallet), name: NSNotification.Name("PalliumsWalletDelete"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(registerFCMToken(notification:)), name: NSNotification.Name("FCMToken"), object: nil)
    }
    var refreshing: Bool = false
    var unreadMessageDataModel: unreadMessagesCountDataModel? {
        didSet {
            guard let model = unreadMessageDataModel else {
                return
            }
            let totalCount = (model.message ?? 0) + (model.notice ?? 0)
            if totalCount > 0 {
                self.messagesUnreadCountLabel.alpha = 1
                if totalCount > 99 {
                    self.messagesUnreadCountLabel.text = "99+"
                } else {
                    self.messagesUnreadCountLabel.text = "\(totalCount)+"
                }
            } else {
                self.messagesUnreadCountLabel.alpha = 0
            }
        }
    }
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
        
        let notiView = UIBarButtonItem(customView: messageButton)
        let spaceItem = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        spaceItem.width = 15
        messageButton.addSubview(messagesUnreadCountLabel)
        self.navigationItem.rightBarButtonItems = [rightBarButtonItem, scanView, spaceItem, notiView]
//        self.navigationItem.rightBarButtonItems = [rightBarButtonItem, scanView]

    }
    /// 切换钱包
    @objc func changeWallet() {
        if let amount = self.detailView.headerView.assetLabel.text, amount.hasPrefix("***") == true {
            self.detailView.headerView.showAssets()
            self.totalAssetsButton.setImage(UIImage.init(named: "eyes_open_white"), for: UIControl.State.normal)
            self.tableViewManager.hideValue = false
        } else {
            self.detailView.headerView.assetLabel.text = "*****"
            self.totalAssetsButton.setImage(UIImage.init(named: "eyes_close_white"), for: UIControl.State.normal)
            self.tableViewManager.hideValue = true
        }
        self.detailView.tableView.reloadData()
    }
    
    /// 扫面按钮点击
    @objc func scanToTransfer() {
        let vc = ScanViewController()
        vc.actionClosure = { address in
            do {
                let result = try ScanHandleManager.scanResultHandle(content: address, contracts: self.tableViewManager.dataModel)
                if result.type == .transfer {
                    switch result.addressType {
                    case .BTC:
                        if let model = result.token {
                            self.showBTCTransferViewController(address: result.address ?? "", tokenModel: model, amount: result.amount)
                        } else {
                            self.showScanContent(content: address)
                        }
                    case .Violas:
                        if let model = result.token {
                            self.showViolasTokenViewController(address: result.address ?? "", subAddress: result.subAddress ?? "", tokenModel: model, amount: result.amount)
                        } else {
                            self.showScanContent(content: address)
                        }
                    case .Libra:
                        if let model = result.token {
                            self.showLibraTransferViewController(address: result.address ?? "", subAddress: result.subAddress ?? "", tokenModel: model, amount: result.amount)
                        } else {
                            self.showScanContent(content: address)
                        }
                    default:
                        self.showScanContent(content: address)
                    }
                } else if result.type == .walletConnect {
                    self.showWalletConnect(wcURL: result.originContent)
                } else {
                    self.showScanContent(content: address)
                }
                
            } catch {
                self.detailView.makeToast(error.localizedDescription, position: .center)
            }
        }
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func showBTCTransferViewController(address: String, tokenModel: Token, amount: UInt64?) {
        let vc = BTCTransferViewController()
        vc.actionClosure = {
            //            self.dataModel.getLocalUserInfo()
        }
        vc.wallet = tokenModel
        vc.address = address
        vc.amount = amount
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func showLibraTransferViewController(address: String, subAddress: String, tokenModel: Token, amount: UInt64?) {
        let vc = LibraTransferViewController()
        vc.actionClosure = {
            //            self.dataModel.getLocalUserInfo()
        }
        vc.wallet = tokenModel
        vc.address = address
        vc.subAddress = subAddress
        vc.amount = amount
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func showViolasTokenViewController(address: String, subAddress: String, tokenModel: Token, amount: UInt64?) {
        let vc = ViolasTransferViewController()
        vc.actionClosure = {
            //            self.dataModel.getLocalUserInfo()
        }
        vc.wallet = tokenModel
        vc.address = address
//        vc.subAddress = subAddress
        vc.amount = amount
        //        vc.sendViolasTokenState = false
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
    @objc func checkNotificationCenter() {
        let vc = NotificationCenterViewController()
        //        vc.wallet = self.wallet
        vc.hidesBottomBarWhenPushed = true
        vc.unreadMessageDataModel = self.unreadMessageDataModel
        vc.successReadClosure = { [weak self] model in
            self?.unreadMessageDataModel = model
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
extension HomeViewController: HomeViewDelegate {
    func getFreeCoin() {
        let vc = EnrollPhoneViewController()
        let navi = BaseNavigationViewController.init(rootViewController: vc)
        vc.hidesBottomBarWhenPushed = true
        vc.successClosure = {
            print("success")
            self.detailView.showActiveButtonState = false
        }
        self.navigationController?.present(navi, animated: true, completion: nil)
    }
    func backupMenmonic() {
        WalletManager.unlockWallet { [weak self] (result) in
            switch result {
            case let .success(mnemonic):
                let vc = BackupWarningViewController()
                vc.FirstInApp = false
                vc.tempWallet = mnemonic
                vc.hidesBottomBarWhenPushed = true
                self?.navigationController?.pushViewController(vc, animated: true)
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
//MARK: - APP初次进入处理
extension HomeViewController {
    func checkIsFisrtOpenApp() {
        guard getWelcomeState() == false else {
            return
        }
        let alert = WelcomeAlert.init()
        alert.show(tag: 99)
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
    func isBackupMnemonic() {
        guard getIdentityWalletState() == true else {
            return
        }
        guard WalletManager.shared.walletBackupState == false else {
            self.detailView.hideBackupWarningAlert()
            return
        }
        self.detailView.showBackupWarningAlert()
    }
    
}
//MARK: - 下拉刷新
extension HomeViewController {
    /// 下拉刷新
    @objc func refreshData() {
        guard self.refreshing == false else {
            print("Refreshing")
            return
        }
        self.refreshing = true
//        self.dataModel.getLocalTokens()
        self.requestData()
    }
    func requestWaletNewState() {
        self.dataModel.isNewWallet(address: WalletManager.shared.violasAddress ?? "") { [weak self] (result) in
            switch result {
            case let .success(state):
                if state == true {
                    self?.detailView.showActiveButtonState = true
                }
            case let .failure(error):
                print(error.localizedDescription)
            }
        }
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
        self.detailView.hideActiveButtonAnimation()
    }
}
//MARK: - 注册消息通知
extension HomeViewController {
    @objc func registerFCMToken(notification: NSNotification) {
        guard let address = WalletManager.shared.violasAddress else {
            return
        }
        guard let token = notification.userInfo?["token"] as? String else {
            return
        }
        self.dataModel.registerFCMToken(address: address, token: token) { [weak self] (result) in
            switch result {
            case let .success(token):
                print("Register Token: \(token)")
                // 设置请求Token
                setRequestToken(token: token)
                // 获取未读消息数
                self?.getUnreadMessagesCount(token: token)
            case let .failure(error):
                print(error.localizedDescription)
            }
        }
    }
    func getUnreadMessagesCount(token: String) {
        self.dataModel.getUnreadMessagesCount(address: WalletManager.shared.violasAddress ?? "", token: token) { [weak self] (result) in
            switch result {
            case let .success(model):
                self?.unreadMessageDataModel = model
            case let .failure(error):
                print(error.localizedDescription)
            }
        }
    }
}

//MARK: - 子View代理方法列表
extension HomeViewController: HomeHeaderViewDelegate {
    func walletConnectState() {
        let vc = ScanLogoutViewController()
        self.present(vc, animated: true, completion: nil)
    }
    func addAssets() {
        let vc = AddAssetViewController()
        vc.hidesBottomBarWhenPushed = true
        vc.tokens = self.tableViewManager.dataModel
        vc.needUpdateClosure = { result in
            //            self.refreshData()
            self.detailView.makeToastActivity(.center)
            self.requestData()
            print("刷新首页数据")
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func transfer() {
        let vc = TransferViewController()
//        vc.actionClosure = {
//        //            self.dataModel.getLocalUserInfo()
//        }
//        vc.wallet = self.wallet
//        vc.title = (self.wallet?.tokenName ?? "") + localLanguage(keyString: "wallet_transfer_navigation_title")
        vc.tokens = self.tableViewManager.dataModel
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func receive() {
        let vc = ReceiveViewController()
        //        vc.wallet = self.wallet
        vc.tokens = self.tableViewManager.dataModel
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func mapping() {
        let vc = TokenMappingViewController()
        //        vc.wallet = self.wallet
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func yieldFarmingRules() {
        let vc = YieldFarmingViewController()
//        let navi = BaseNavigationViewController.init(rootViewController: vc)
        vc.hidesBottomBarWhenPushed = true
//        self.present(navi, animated: true, completion: nil)
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
extension HomeViewController: HomeWithoutWalletViewDelegate {
    func createWallet() {
        let vc = AddWalletViewController()
        vc.successCreateClosure = {
            self.detailView.importOrCreateView.removeFromSuperview()
            self.requestData()
            self.requestWaletNewState()
        }
        let navi = BaseNavigationViewController.init(rootViewController: vc)
        self.present(navi, animated: true, completion: nil)
    }
    func importWallet() {
        let vc = ImportWalletViewController()
        vc.successImportClosure = {
            self.detailView.importOrCreateView.removeFromSuperview()
            self.requestData()
            self.requestWaletNewState()
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
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.detailView.hideActiveButtonAnimation()
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.detailView.showActiveButtonAnimation()
    }
}
//MARK: - 网络请求数据处理中心
extension HomeViewController {
    private func requestData() {
        self.dataModel.getTokens { [weak self] result in
            self?.detailView.hideToastActivity()
            switch result {
            case let .success(data):
                if data.tokens.isEmpty == false && data.indexPath.isEmpty == true {
                    // 首次进入
                    self?.tableViewManager.dataModel = data.tokens
                    self?.detailView.tableView.reloadData()
                } else if data.tokens.isEmpty == false && data.indexPath.isEmpty == false {
                    // 需要刷新
                    self?.tableViewManager.dataModel = data.tokens
                    self?.detailView.tableView.beginUpdates()
                    self?.detailView.tableView.reloadRows(at: data.indexPath, with: .fade)
                    self?.detailView.tableView.endUpdates()
                } else if data.tokens.isEmpty == true && data.indexPath.isEmpty == true {
                    // 汇总价格
                    if self?.detailView.headerView.assetsModel != data.totalPrice {
                        self?.detailView.headerView.assetsModel = data.totalPrice
                    }
                    if self?.detailView.tableView.mj_header?.isRefreshing == true {
                        self?.detailView.tableView.mj_header?.endRefreshing()
                    }
                    self?.refreshing = false
                }
            case let .failure(error):
                print(error.localizedDescription)
                self?.handleError(requestType: "", error: error)
            }
        }
    }
    private func handleError(requestType: String, error: LibraWalletError) {
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
