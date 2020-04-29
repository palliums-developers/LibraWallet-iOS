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
        self.view.backgroundColor = UIColor.init(hex: "F9F9FB")
        // 添加导航栏按钮
        self.addNavigationBar()
        // 加载子View
        self.view.addSubview(detailView)
        // 初始化KVO
        self.initKVO()
        // 添加语言变换通知
        NotificationCenter.default.addObserver(self, selector: #selector(setText), name: NSNotification.Name(LCLLanguageChangeNotification), object: nil)
        //检查是否第一次打开app
        checkIsFisrtOpenApp()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        let result = DataBaseManager.DBManager.isExistAddressInWallet(address: self.detailView.model?.walletRootAddress ?? "")
        if result == false {
            self.detailView.makeToastActivity(.center)
            self.dataModel.getLocalUserInfo()
        }
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
        return view
    }()
    /// 钱包切换按钮
    lazy var changeWalletButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("---" + localLanguage(keyString: "wallet_home_wallet_type_last_title"), for: UIControl.State.normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.regular)
        button.setTitleColor(UIColor.white, for: UIControl.State.normal)
        button.setImage(UIImage.init(named: "home_show_detail"), for: UIControl.State.normal)
        // 调整位置
        button.imagePosition(at: .right, space: 10, imageViewSize: CGSize.init(width: 13, height: 7))
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
        let backView = UIBarButtonItem(customView: changeWalletButton)
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
        let vc = WalletListController()
        vc.hidesBottomBarWhenPushed = true
        vc.actionClosure = { (action, wallet) in
            if action == .update {
                //更新管理页面
                if self.detailView.headerView.walletModel?.walletRootAddress != wallet.walletRootAddress {
//                    self.detailView.headerView.walletModel = wallet
                    self.detailView.model = wallet
                }
                // 需要更新
                self.detailView.makeToastActivity(.center)
                if wallet.walletType == .Libra {
                    self.changeWalletButton.setTitle("Libra " + localLanguage(keyString: "wallet_home_wallet_type_last_title"), for: UIControl.State.normal)
                    self.changeWalletButton.imagePosition(at: .right, space: 10, imageViewSize: CGSize.init(width: 13, height: 7))

//                    self.dataModel.tempGetLibraBalance(walletID: wallet.walletID!, address: wallet.walletAddress ?? "")
                    self.dataModel.getLibraBalance(walletID: wallet.walletID!, address: wallet.walletAddress ?? "")
                    self.tableViewManager.dataModel?.removeAll()
                    self.detailView.tableView.reloadData()
                    self.detailView.headerView.hideAddTokenButtonState = true
                } else if wallet.walletType == .Violas {
                    self.changeWalletButton.setTitle("Violas " + localLanguage(keyString: "wallet_home_wallet_type_last_title"), for: UIControl.State.normal)
                    self.changeWalletButton.imagePosition(at: .right, space: 10, imageViewSize: CGSize.init(width: 13, height: 7))

                    self.dataModel.getEnableViolasToken(walletID: wallet.walletID ?? 0, address: wallet.walletAddress ?? "")
                    self.detailView.headerView.hideAddTokenButtonState = false

                } else {
                    self.changeWalletButton.setTitle("BTC " + localLanguage(keyString: "wallet_home_wallet_type_last_title"), for: UIControl.State.normal)
                    self.changeWalletButton.imagePosition(at: .right, space: 10, imageViewSize: CGSize.init(width: 13, height: 7))

                    self.dataModel.getBTCBalance(walletID: wallet.walletID ?? 0, address: wallet.walletAddress ?? "")
                    self.tableViewManager.dataModel?.removeAll()
                    self.detailView.tableView.reloadData()
                    self.detailView.headerView.hideAddTokenButtonState = true
                }
            }
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    /// 扫面按钮点击
    @objc func scanToTransfer() {
        let vc = ScanViewController()
        vc.actionClosure = { address in
            do {
                let result = try self.dataModel.scanResultHandle(content: address, contracts: self.tableViewManager.dataModel)
                if result.type == .transfer {
                    switch result.addressType {
                    case .BTC:
                        self.showBTCTransferViewController(address: result.address ?? "")
                    case .Violas:
                        if let model = result.contract {
                            self.showViolasTokenViewController(address: result.address ?? "", tokenModel: model)
                        } else {
                            self.showViolasTransferViewController(address: result.address ?? "")
                        }
                    case .Libra:
                        self.showLibraTransferViewController(address: result.address ?? "")
                    default:
                        self.showScanContent(content: address)
                    }
                } else if result.type == .login {
                    let vc = ScanLoginViewController()
                    vc.wallet = LibraWalletManager.shared
                    vc.sessionID = result.address
                    self.present(vc, animated: true, completion: nil)
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
    func showBTCTransferViewController(address: String) {
        let vc = BTCTransferViewController()
        vc.actionClosure = {
        //            self.dataModel.getLocalUserInfo()
        }
        vc.wallet = self.detailView.headerView.walletModel
        vc.address = address
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func showLibraTransferViewController(address: String) {
        let vc = TransferViewController()
        vc.actionClosure = {
//            self.dataModel.getLocalUserInfo()
        }
        vc.wallet = self.detailView.headerView.walletModel
        vc.address = address
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func showViolasTransferViewController(address: String) {
        let vc = ViolasTransferViewController()
        vc.actionClosure = {
        //            self.dataModel.getLocalUserInfo()
        }
        vc.wallet = self.detailView.headerView.walletModel
        vc.sendViolasTokenState = false
        vc.address = address
//        vc.title = (self.detailView.headerView.walletModel?.walletType?.description ?? "") + localLanguage(keyString: "wallet_transfer_navigation_title")
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func showViolasTokenViewController(address: String, tokenModel: ViolasTokenModel) {
        let vc = ViolasTransferViewController()
        vc.actionClosure = {
        //            self.dataModel.getLocalUserInfo()
        }
        vc.wallet = self.detailView.headerView.walletModel
        vc.sendViolasTokenState = true
        vc.vtokenModel = tokenModel
        vc.address = address
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func showScanContent(content: String) {
        let vc = ScanResultInvalidViewController()
        vc.hidesBottomBarWhenPushed = true
        vc.content = content
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
//MARK: - APP初次进入处理
extension HomeViewController {
    func checkIsFisrtOpenApp() {
        guard getWelcomeState() == false else {
            return
        }
        let alert = WelcomeAlert.init()
        alert.show()
    }
}
//MARK: - 下拉刷新
extension HomeViewController {
    /// 下拉刷新
    @objc func refreshData() {
        if self.detailView.headerView.walletModel?.walletType == .Libra {
//            self.dataModel.tempGetLibraBalance(walletID: self.detailView.headerView.walletModel?.walletID ?? 0,
//                                               address: self.detailView.headerView.walletModel?.walletAddress ?? "")
            self.dataModel.getLibraBalance(walletID: self.detailView.headerView.walletModel?.walletID ?? 0,
                                           address: self.detailView.headerView.walletModel?.walletAddress ?? "")
        } else if self.detailView.headerView.walletModel?.walletType == .Violas {
            self.dataModel.getViolasBalance(walletID: self.detailView.headerView.walletModel?.walletID ?? 0,
                                            address: self.detailView.headerView.walletModel?.walletAddress ?? "",
                                            vtokens: self.tableViewManager.dataModel!)
        } else {
            self.dataModel.getBTCBalance(walletID: self.detailView.headerView.walletModel?.walletID ?? 0,
                                         address: self.detailView.headerView.walletModel?.walletAddress ?? "")
        }
    }
}
//MARK: - 语言切换方法
extension HomeViewController {
    /// 语言切换
    @objc func setText() {
        if self.detailView.headerView.walletModel?.walletType == .Libra {
            self.changeWalletButton.setTitle("Libra " + localLanguage(keyString: "wallet_home_wallet_type_last_title"), for: UIControl.State.normal)
        } else if self.detailView.headerView.walletModel?.walletType == .Violas {
            self.changeWalletButton.setTitle("Violas " + localLanguage(keyString: "wallet_home_wallet_type_last_title"), for: UIControl.State.normal)
        } else {
            self.changeWalletButton.setTitle("BTC " + localLanguage(keyString: "wallet_home_wallet_type_last_title"), for: UIControl.State.normal)
        }
        self.changeWalletButton.imagePosition(at: .right, space: 10, imageViewSize: CGSize.init(width: 13, height: 7))
    }
}

//MARK: - 子View代理方法列表
extension HomeViewController: HomeHeaderViewDelegate {
    func checkWalletDetail() {
        let vc = WalletDetailViewController()
        vc.walletModel = self.detailView.headerView.walletModel
        vc.canDelete = false
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func checkWalletTransactionList() {
        let vc = WalletTransactionsViewController()
        vc.wallet = self.detailView.headerView.walletModel
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func addCoinToWallet() {
        let vc = AddAssetViewController()
        vc.hidesBottomBarWhenPushed = true
        vc.wallet = self.detailView.headerView.walletModel
        vc.needUpdateClosure = { result in
//            self.refreshData()
            self.detailView.makeToastActivity(.center)
            self.dataModel.getLocalUserInfo()
            print("刷新首页数据")
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func walletSend() {
        // 更新本地数据
        switch self.detailView.headerView.walletModel?.walletType {
        case .Libra:
            let vc = TransferViewController()
            vc.actionClosure = {
    //            self.dataModel.getLocalUserInfo()
            }
            vc.wallet = self.detailView.headerView.walletModel
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
            break
        case .Violas:
           let vc = ViolasTransferViewController()
           vc.actionClosure = {
    //            self.dataModel.getLocalUserInfo()
           }
           vc.wallet = self.detailView.headerView.walletModel
           vc.sendViolasTokenState = false
//           vc.title = (self.detailView.headerView.walletModel?.walletType?.description ?? "") + localLanguage(keyString: "wallet_transfer_navigation_title")

           vc.hidesBottomBarWhenPushed = true
           self.navigationController?.pushViewController(vc, animated: true)
            break
        case .BTC:
           let vc = BTCTransferViewController()
           vc.actionClosure = {
    //            self.dataModel.getLocalUserInfo()
           }
           vc.wallet = self.detailView.headerView.walletModel
           vc.hidesBottomBarWhenPushed = true
           self.navigationController?.pushViewController(vc, animated: true)
            break
        default:
            break
        }
    }
    func walletReceive() {
        let vc = WalletReceiveViewController()
        vc.wallet = self.detailView.headerView.walletModel
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func mapping() {
        let vc = TokenMappingViewController()
        vc.hidesBottomBarWhenPushed = true
        vc.wallet = self.detailView.headerView.walletModel
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
//MARK: - TableviewManager代理方法列表
extension HomeViewController: HomeTableViewManagerDelegate {
    func tableViewDidSelectRowAtIndexPath(indexPath: IndexPath, model: ViolasTokenModel) {
        let vc = VTokenMainViewController()
        vc.hidesBottomBarWhenPushed = true
        vc.wallet = self.detailView.headerView.walletModel
        vc.vtokenModel = model
        vc.title = model.name ?? ""
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
            if type == "LoadCurrentUseWallet" {
                // 加载本地默认钱包
                if let tempData = dataDic.value(forKey: "data") as? LibraWalletManager {
                    self?.detailView.model = tempData
                    self?.detailView.tableView.reloadData()
                    if tempData.walletType == .Libra {
                        self?.changeWalletButton.setTitle("Libra " + localLanguage(keyString: "wallet_home_wallet_type_last_title"), for: UIControl.State.normal)
                        let defaultModel = ViolasTokenModel.init(name: "Libra",
                                                                 description: "",
                                                                 address: tempData.walletAddress ?? "",
                                                                 icon: "",
                                                                 enable: true,
                                                                 balance: tempData.walletBalance ?? 0,
                                                                 registerState: true)
                        self?.tableViewManager.defaultModel = defaultModel
                    } else if tempData.walletType == .Violas {
                        self?.changeWalletButton.setTitle("Violas " + localLanguage(keyString: "wallet_home_wallet_type_last_title"), for: UIControl.State.normal)
                        let defaultModel = ViolasTokenModel.init(name: "Violas",
                                                                 description: "",
                                                                 address: tempData.walletAddress ?? "",
                                                                 icon: "",
                                                                 enable: true,
                                                                 balance: tempData.walletBalance ?? 0,
                                                                 registerState: true)
                        self?.tableViewManager.defaultModel = defaultModel
                    } else {
                        self?.changeWalletButton.setTitle("BTC " + localLanguage(keyString: "wallet_home_wallet_type_last_title"), for: UIControl.State.normal)
                        let defaultModel = ViolasTokenModel.init(name: "BTC",
                                                                 description: "",
                                                                 address: tempData.walletAddress ?? "",
                                                                 icon: "",
                                                                 enable: true,
                                                                 balance: (tempData.walletBalance ?? 0) / 100,
                                                                 registerState: true)
                        self?.tableViewManager.defaultModel = defaultModel
                    }
                    self?.detailView.tableView.reloadData()
                    self?.changeWalletButton.imagePosition(at: .right, space: 10, imageViewSize: CGSize.init(width: 13, height: 7))
                }
            } else if type == "UpdateBTCBalance" {
                if let tempData = dataDic.value(forKey: "data") as? BlockCypherBTCBalanceMainModel {
                    self?.detailView.headerView.btcModel = tempData
                    let defaultModel = ViolasTokenModel.init(name: "BTC",
                                                             description: "",
                                                             address: tempData.address ?? "",
                                                             icon: "",
                                                             enable: true,
                                                             balance: (tempData.balance ?? 0) / 100,
                                                             registerState: true)
                    self?.tableViewManager.defaultModel = defaultModel
                    self?.detailView.tableView.reloadData()
                }
            } else if type == "UpdateLibraBalance" {
                if let tempData = dataDic.value(forKey: "data") as? BalanceLibraModel {
                    self?.detailView.headerView.libraModel = tempData
                    let defaultModel = ViolasTokenModel.init(name: "lib",
                                                             description: "",
                                                             address: LibraWalletManager.shared.walletAddress ?? "",
                                                             icon: "",
                                                             enable: true,
                                                             balance: (tempData.balance?.amount ?? 0),
                                                             registerState: true)
                    self?.tableViewManager.defaultModel = defaultModel
                    self?.detailView.tableView.reloadData()
                }
            } else if type == "UpdateViolasBalance" {
                if let tempData = dataDic.value(forKey: "data") as? BalanceViolasModel {
                    self?.detailView.headerView.violasModel = tempData
                    self?.tableViewManager.defaultModel?.balance = tempData.balance ?? 0
                    if let modules = tempData.modules, let dataModel = self?.tableViewManager.dataModel, modules.isEmpty == false, dataModel.isEmpty == false {
                        self?.tableViewManager.dataModel = self?.dataModel.dealBalanceWithContract(modules: modules, violasTokens: dataModel)
                    }
                    self?.detailView.tableView.reloadData()
                }
            } else if type == "LoadEnableViolasTokenList" {
                if let tempData = dataDic.value(forKey: "data") as? [ViolasTokenModel] {
                    let defaultModel = ViolasTokenModel.init(name: "vtoken",
                                                             description: "",
                                                             address: self?.detailView.headerView.walletModel?.walletAddress ?? "",
                                                             icon: "",
                                                             enable: true,
                                                             balance: self?.detailView.headerView.walletModel?.walletBalance ?? 0,
                                                             registerState: true)
                    self?.tableViewManager.dataModel = tempData
                    self?.tableViewManager.defaultModel = defaultModel
                    self?.detailView.tableView.reloadData()
                }
            }
            self?.detailView.hideToastActivity()
            self?.detailView.tableView.mj_header?.endRefreshing()
        })
        self.detailView.makeToastActivity(.center)
        self.dataModel.getLocalUserInfo()
    }
}
