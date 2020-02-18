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
        if needRefresh == true {
//            dataModel.getLocalUserInfo()
        }
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
    func checkIsFisrtOpenApp() {
        guard getWelcomeState() == false else {
            return
        }
        let alert = WelcomeAlert.init()
        alert.show()
    }
    func addNavigationBar() {
        // 自定义导航栏的UIBarButtonItem类型的按钮
//        changeWalletButtonView.addSubview(changeWalletButton)
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
   //网络请求、数据模型
    lazy var dataModel: HomeModel = {
        let model = HomeModel.init()
        return model
    }()
    //tableView管理类
    lazy var tableViewManager: HomeTableViewManager = {
        let manager = HomeTableViewManager.init()
        manager.delegate = self
        return manager
    }()
    //子View
    lazy var detailView : HomeView = {
        let view = HomeView.init()
        view.tableView.delegate = self.tableViewManager
        view.tableView.dataSource = self.tableViewManager
        view.headerView.delegate = self
        view.tableView.mj_header = MJRefreshNormalHeader.init(refreshingTarget: self, refreshingAction:  #selector(refreshData))
        return view
    }()
    lazy var changeWalletButton: UIButton = {
        let button = UIButton(type: .custom)
        // 设置字体
        button.setTitle("---" + localLanguage(keyString: "wallet_home_wallet_type_last_title"), for: UIControl.State.normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.regular)
        button.setTitleColor(UIColor.white, for: UIControl.State.normal)
        // 设置图片
        button.setImage(UIImage.init(named: "home_show_detail"), for: UIControl.State.normal)
//        // 调整位置
//        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: -15, bottom: 0, right: 15)
//        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 80, bottom: 0, right: -80)
        button.imagePosition(at: .right, space: 10, imageViewSize: CGSize.init(width: 13, height: 7))
        // 设置frame
//        button.frame = CGRect(x: 0, y: 0, width: 80, height: 37)
        button.addTarget(self, action: #selector(changeWallet), for: .touchUpInside)
        return button
    }()
    lazy var scanButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage.init(named: "home_scan"), for: UIControl.State.normal)
        button.tag = 20
        button.addTarget(self, action: #selector(scanToTransfer), for: .touchUpInside)
        return button
    }()
    lazy var changeWalletButtonView: UIView = {
        var width = 70
        if Localize.currentLanguage() == "en" {
            width = 100
        } else {
            width = 70
        }
        let view = UIView.init(frame: CGRect.init(x: 0, y: 0, width: width, height: 37))
        return view
    }()
    var needRefresh: Bool?
    var needShowBiometricCheck: Bool?
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

                    self.dataModel.tempGetLibraBalance(walletID: wallet.walletID!, address: wallet.walletAddress ?? "")
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
    @objc func scanToTransfer() {
        let vc = ScanViewController()
        vc.actionClosure = { address in
            if address.hasPrefix("bitcoin:") {
                self.showBTCTransferViewController(address: address)
            } else if address.hasPrefix("libra:") {
                self.showLibraTransferViewController(address: address)
            } else if address.hasPrefix("violas:") {
                self.showViolasTransferViewController(address: address)
            } else if address.hasPrefix("violas-") {
                self.showViolasTokenViewController(address: address)
            } else {
                let vc = ScanResultInvalidViewController()
                vc.hidesBottomBarWhenPushed = true
                vc.content = address
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
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
    @objc func refreshData() {
        if self.detailView.headerView.walletModel?.walletType == .Libra {
            self.dataModel.tempGetLibraBalance(walletID: self.detailView.headerView.walletModel?.walletID ?? 0, address: self.detailView.headerView.walletModel?.walletAddress ?? "")
        } else if self.detailView.headerView.walletModel?.walletType == .Violas {
            self.dataModel.getEnableViolasToken(walletID: self.detailView.headerView.walletModel?.walletID ?? 0, address: self.detailView.headerView.walletModel?.walletAddress ?? "")
        } else {
            self.dataModel.getBTCBalance(walletID: self.detailView.headerView.walletModel?.walletID ?? 0, address: self.detailView.headerView.walletModel?.walletAddress ?? "")
        }
    }
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(LCLLanguageChangeNotification), object: nil)
        print("HomeViewController销毁了")
    }
    var myContext = 0
}
extension HomeViewController {
    func showBTCTransferViewController(address: String) {
        let tempAddress = address.replacingOccurrences(of: "bitcoin:", with: "")
        guard BTCManager.isValidBTCAddress(address: tempAddress) else {
            self.view.makeToast(LibraWalletError.WalletScan(reason: .btcAddressInvalid).localizedDescription, position: .center)
            return
        }
        let vc = BTCTransferViewController()
        vc.actionClosure = {
        //            self.dataModel.getLocalUserInfo()
        }
        vc.wallet = self.detailView.headerView.walletModel
        vc.address = tempAddress
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func showLibraTransferViewController(address: String) {
        let tempAddress = address.replacingOccurrences(of: "libra:", with: "")
        guard LibraManager.isValidLibraAddress(address: tempAddress) else {
            self.view.makeToast(LibraWalletError.WalletScan(reason: .libraAddressInvalid).localizedDescription, position: .center)
           return
        }
        let vc = TransferViewController()
        vc.actionClosure = {
//            self.dataModel.getLocalUserInfo()
        }
        vc.wallet = self.detailView.headerView.walletModel
        vc.address = tempAddress
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func showViolasTransferViewController(address: String) {
        let tempAddress = address.replacingOccurrences(of: "violas:", with: "")
        guard ViolasManager.isValidViolasAddress(address: tempAddress) else {
            self.view.makeToast(LibraWalletError.WalletScan(reason: .violasAddressInvalid).localizedDescription, position: .center)
            return
        }
        let vc = ViolasTransferViewController()
        vc.actionClosure = {
        //            self.dataModel.getLocalUserInfo()
        }
        vc.wallet = self.detailView.headerView.walletModel
        vc.sendViolasTokenState = false
        vc.address = tempAddress
        vc.title = (self.detailView.headerView.walletModel?.walletType?.description ?? "") + localLanguage(keyString: "wallet_transfer_navigation_title")
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func showViolasTokenViewController(address: String) {
        let coinAddress = address.split(separator: ":").last?.description
        
        let addressPrifix = address.split(separator: ":").first?.description

        let coinName = addressPrifix?.split(separator: "-")
        guard coinName?.count == 2 else {
            print("token名称为空")
            self.view.makeToast(LibraWalletError.WalletScan(reason: .violasTokenNameEmpty).localizedDescription, position: .center)
            return
        }
        let contract = self.tableViewManager.dataModel?.filter({ item in
            item.name?.lowercased() == coinName?.last?.description
        })
        guard (contract?.count ?? 0) > 0 else {
            // 不支持或未开启
            print("不支持或未开启")
            self.view.makeToast(LibraWalletError.WalletScan(reason: .violasTokenContractInvalid).localizedDescription, position: .center)
            return
        }
        guard ViolasManager.isValidViolasAddress(address: coinAddress ?? "") else {
            self.view.makeToast(LibraWalletError.WalletScan(reason: .violasAddressInvalid).localizedDescription, position: .center)
            return
        }
        let vc = ViolasTransferViewController()
        vc.actionClosure = {
        //            self.dataModel.getLocalUserInfo()
        }
        vc.wallet = self.detailView.headerView.walletModel
        vc.sendViolasTokenState = true
        vc.vtokenModel = contract?.first
        vc.address = coinAddress
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
extension HomeViewController {
    func initKVO() {
        dataModel.addObserver(self, forKeyPath: "dataDic", options: NSKeyValueObservingOptions.new, context: &myContext)
        self.detailView.makeToastActivity(.center)
        self.dataModel.getLocalUserInfo()
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
            } else if error.localizedDescription == LibraWalletError.WalletRequest(reason: .walletNotExist).localizedDescription {
                // 钱包不存在
                print(error.localizedDescription)
//                let vc = WalletCreateViewController()
//                let navi = UINavigationController.init(rootViewController: vc)
//                self.present(navi, animated: true, completion: nil)
            } else if error.localizedDescription == LibraWalletError.WalletRequest(reason: .walletVersionTooOld).localizedDescription {
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
            self.detailView.hideToastActivity()
            self.detailView.tableView.mj_header.endRefreshing()
            return
        }
        let type = jsonData.value(forKey: "type") as! String
        
        if type == "LoadCurrentUseWallet" {
            // 加载本地默认钱包
            if let tempData = jsonData.value(forKey: "data") as? LibraWalletManager {
                self.detailView.model = tempData
                self.detailView.tableView.reloadData()
                if tempData.walletType == .Libra {
                    self.changeWalletButton.setTitle("Libra " + localLanguage(keyString: "wallet_home_wallet_type_last_title"), for: UIControl.State.normal)
                    let defaultModel = ViolasTokenModel.init(name: "Libra",
                                                             description: "",
                                                             address: tempData.walletAddress ?? "",
                                                             icon: "",
                                                             enable: true,
                                                             balance: tempData.walletBalance ?? 0,
                                                             registerState: true)
                    self.tableViewManager.dataModel = [defaultModel]
                } else if tempData.walletType == .Violas {
                    self.changeWalletButton.setTitle("Violas " + localLanguage(keyString: "wallet_home_wallet_type_last_title"), for: UIControl.State.normal)
                    let defaultModel = ViolasTokenModel.init(name: "Violas",
                                                             description: "",
                                                             address: tempData.walletAddress ?? "",
                                                             icon: "",
                                                             enable: true,
                                                             balance: tempData.walletBalance ?? 0,
                                                             registerState: true)
                    self.tableViewManager.dataModel = [defaultModel]
                } else {
                    self.changeWalletButton.setTitle("BTC " + localLanguage(keyString: "wallet_home_wallet_type_last_title"), for: UIControl.State.normal)
                    let defaultModel = ViolasTokenModel.init(name: "BTC",
                                                             description: "",
                                                             address: tempData.walletAddress ?? "",
                                                             icon: "",
                                                             enable: true,
                                                             balance: (tempData.walletBalance ?? 0) / 100,
                                                             registerState: true)
                    self.tableViewManager.dataModel = [defaultModel]
                }
                self.detailView.tableView.reloadData()
                self.changeWalletButton.imagePosition(at: .right, space: 10, imageViewSize: CGSize.init(width: 13, height: 7))
            }
        } else if type == "UpdateBTCBalance" {
            if let tempData = jsonData.value(forKey: "data") as? BalanceBTCModel {
                self.detailView.headerView.btcModel = tempData
                let defaultModel = ViolasTokenModel.init(name: "BTC",
                                                         description: "",
                                                         address: tempData.address ?? "",
                                                         icon: "",
                                                         enable: true,
                                                         balance: (tempData.balance ?? 0) / 100,
                                                         registerState: true)
                self.tableViewManager.dataModel = [defaultModel]
                self.detailView.tableView.reloadData()
            } else {
                let defaultModel = ViolasTokenModel.init(name: "BTC",
                                                         description: "",
                                                         address: self.detailView.model?.walletAddress ?? "",
                                                         icon: "",
                                                         enable: true,
                                                         balance: 0,
                                                         registerState: true)
                self.tableViewManager.dataModel = [defaultModel]
                self.detailView.tableView.reloadData()
            }
        } else if type == "UpdateLibraBalance" {
            if let tempData = jsonData.value(forKey: "data") as? BalanceLibraModel {
                self.detailView.headerView.libraModel = tempData
                let defaultModel = ViolasTokenModel.init(name: "lib",
                                                         description: "",
                                                         address: tempData.address ?? "",
                                                         icon: "",
                                                         enable: true,
                                                         balance: (tempData.balance ?? 0) * 1000000,
                                                         registerState: true)
                self.tableViewManager.dataModel = [defaultModel]
                self.detailView.tableView.reloadData()
            }
        } else if type == "UpdateViolasBalance" {
            if let tempData = jsonData.value(forKey: "data") as? BalanceLibraModel {
                self.detailView.headerView.violasModel = tempData

                if let modules = tempData.modules, let dataModel = self.tableViewManager.dataModel, modules.isEmpty == false, dataModel.isEmpty == false {
                    var tempModules = modules
                    tempModules.append(BalanceViolasModulesModel.init(balance: tempData.balance ?? 0, address: tempData.address ?? ""))
                    
                    self.tableViewManager.dataModel = self.dataModel.dealBalanceWithContract(modules: tempModules, violasTokens: dataModel)
                }
                self.detailView.tableView.reloadData()
            }
        } else if type == "LoadEnableViolasTokenList" {
            if let tempData = jsonData.value(forKey: "data") as? [ViolasTokenModel] {
                let defaultModel = ViolasTokenModel.init(name: "vtoken",
                                                         description: "",
                                                         address: self.detailView.headerView.walletModel?.walletAddress ?? "",
                                                         icon: "",
                                                         enable: true,
                                                         balance: self.detailView.headerView.walletModel?.walletBalance ?? 0,
                                                         registerState: true)
                self.tableViewManager.dataModel = tempData
                self.tableViewManager.dataModel?.insert(defaultModel, at: 0)
                self.detailView.tableView.reloadData()
            }
        }
        self.detailView.hideToastActivity()
        self.detailView.tableView.mj_header.endRefreshing()
    }
}
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
            self.refreshData()
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
           vc.title = (self.detailView.headerView.walletModel?.walletType?.description ?? "") + localLanguage(keyString: "wallet_transfer_navigation_title")

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
//        guard self.detailView.headerView.walletModel?.walletType != .Violas else {
//            self.detailView.makeToast("正在规划中，请稍后", position: .center)
//            return
//        }
        let vc = TokenMappingViewController()
        vc.hidesBottomBarWhenPushed = true
        vc.wallet = self.detailView.headerView.walletModel
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension HomeViewController: HomeTableViewManagerDelegate {
    func tableViewDidSelectRowAtIndexPath(indexPath: IndexPath, model: ViolasTokenModel) {
        guard indexPath.row != 0 else {
            return
        }
        let vc = VTokenMainViewController()
        vc.hidesBottomBarWhenPushed = true
        vc.wallet = self.detailView.headerView.walletModel
        vc.vtokenModel = model
        vc.title = model.name ?? ""
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
