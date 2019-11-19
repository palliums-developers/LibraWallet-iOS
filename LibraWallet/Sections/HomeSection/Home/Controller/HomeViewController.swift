//
//  HomeViewController.swift
//  LibraWallet
//
//  Created by palliums on 2019/9/11.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit
import Localize_Swift
class HomeViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // 设置背景色
        self.view.backgroundColor = UIColor.init(hex: "F9F9FB")
        // 加载子View
        self.view.addSubview(viewModel.detailView)
        // 添加导航栏按钮
        self.addNavigationBar()
        // 初始化KVO
        self.viewModel.initKVO()
        // 添加语言变换通知
        NotificationCenter.default.addObserver(self, selector: #selector(setText), name: NSNotification.Name(LCLLanguageChangeNotification), object: nil)
    }
    func addNavigationBar() {
        // 自定义导航栏的UIBarButtonItem类型的按钮
//        changeWalletButtonView.addSubview(changeWalletButton)
        let backView = UIBarButtonItem(customView: changeWalletButton)
        
        // 重要方法，用来调整自定义返回view距离左边的距离
        let barButtonItem = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        barButtonItem.width = -10
        // 返回按钮设置成功
        self.navigationItem.leftBarButtonItems = [barButtonItem, backView]
        
        let scanView = UIBarButtonItem(customView: scanButton)
        // 重要方法，用来调整自定义返回view距离左边的距离
        let rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        rightBarButtonItem.width = 15
        // 返回按钮设置成功
        self.navigationItem.rightBarButtonItems = [rightBarButtonItem, scanView]
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        if needRefresh == true {
//            dataModel.getLocalUserInfo()
        }
        self.navigationController?.navigationBar.barStyle = .black
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.barStyle = .default
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        viewModel.detailView.snp.makeConstraints { (make) in
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(self.view.safeAreaLayoutGuide)
            } else {
                make.bottom.equalTo(self.view)
            }
            make.top.left.right.equalTo(self.view)
        }
    }
    lazy var viewModel: HomeViewModel = {
        let viewModel = HomeViewModel.init()
        viewModel.detailView.headerView.delegate = self
        viewModel.tableViewManager.delegate = self
        return viewModel
    }()
    lazy var changeWalletButton: UIButton = {
        let button = UIButton(type: .custom)
        // 设置字体
        button.setTitle(localLanguage(keyString: "wallet_home_wallet_type_last_title"), for: UIControl.State.normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.regular)
        button.setTitleColor(UIColor.white, for: UIControl.State.normal)
        // 设置图片
        button.setImage(UIImage.init(named: "home_show_detail"), for: UIControl.State.normal)
        // 调整位置
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: -15, bottom: 0, right: 15)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 80, bottom: 0, right: -80)
        // 设置frame
        button.frame = CGRect(x: 0, y: 0, width: 37, height: 37)
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
                if self.viewModel.detailView.headerView.walletModel?.walletRootAddress != wallet.walletRootAddress {
                    self.viewModel.detailView.headerView.walletModel = wallet
                }
                // 需要更新
                self.viewModel.detailView.makeToastActivity(.center)
                if wallet.walletType == .Libra {
                    self.changeWalletButton.setTitle("Libra " + localLanguage(keyString: "wallet_home_wallet_type_last_title"), for: UIControl.State.normal)
                    self.viewModel.dataModel.tempGetLibraBalance(walletID: wallet.walletID!, address: wallet.walletAddress ?? "")
                    self.viewModel.tableViewManager.dataModel?.removeAll()
                    self.viewModel.detailView.tableView.reloadData()
                    self.viewModel.detailView.headerView.hideAddTokenButtonState = true
                } else if wallet.walletType == .Violas {
                    self.changeWalletButton.setTitle("Violas " + localLanguage(keyString: "wallet_home_wallet_type_last_title"), for: UIControl.State.normal)
                    self.viewModel.dataModel.getEnableViolasToken(walletID: wallet.walletID ?? 0, address: wallet.walletAddress ?? "")
                    self.viewModel.detailView.headerView.hideAddTokenButtonState = false
                } else {
                    self.changeWalletButton.setTitle("BTC " + localLanguage(keyString: "wallet_home_wallet_type_last_title"), for: UIControl.State.normal)
                    self.viewModel.dataModel.getBTCBalance(walletID: wallet.walletID ?? 0, address: wallet.walletAddress ?? "")
                    self.viewModel.tableViewManager.dataModel?.removeAll()
                    self.viewModel.detailView.tableView.reloadData()
                    self.viewModel.detailView.headerView.hideAddTokenButtonState = true
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
    @objc func setText(){
    }
    func showBTCTransferViewController(address: String) {
        let tempAddress = address.replacingOccurrences(of: "bitcoin:", with: "")
        guard BTCManager().isValidBTCAddress(address: tempAddress) else {
            self.view.makeToast("不是有效的Bitcoin地址", position: .center)
            return
        }
        let vc = BTCTransferViewController()
        vc.actionClosure = {
        //            self.dataModel.getLocalUserInfo()
        }
        vc.wallet = self.viewModel.detailView.headerView.walletModel
        vc.address = tempAddress
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func showLibraTransferViewController(address: String) {
        let tempAddress = address.replacingOccurrences(of: "libra:", with: "")
        guard LibraManager().isValidLibraAddress(address: tempAddress) else {
           self.view.makeToast("不是有效的Libra地址", position: .center)
           return
        }
        let vc = TransferViewController()
        vc.actionClosure = {
//            self.dataModel.getLocalUserInfo()
        }
        vc.wallet = self.viewModel.detailView.headerView.walletModel
        vc.address = tempAddress
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func showViolasTransferViewController(address: String) {
        let tempAddress = address.replacingOccurrences(of: "violas:", with: "")
        guard ViolasManager().isValidViolasAddress(address: tempAddress) else {
            self.view.makeToast("不是有效的Violas地址", position: .center)
            return
        }
        let vc = ViolasTransferViewController()
        vc.actionClosure = {
        //            self.dataModel.getLocalUserInfo()
        }
        vc.wallet = self.viewModel.detailView.headerView.walletModel
        vc.sendViolasTokenState = false
        vc.address = tempAddress
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func showViolasTokenViewController(address: String) {
        let coinAddress = address.split(separator: ":").last?.description
        
        let addressPrifix = address.split(separator: ":").first?.description

        let coinName = addressPrifix?.split(separator: "-")
        guard coinName?.count == 2 else {
            print("token名称为空")
            self.view.makeToast("Token名称为空", position: .center)
            return
        }
        let contract = self.viewModel.tableViewManager.dataModel?.filter({ item in
            item.name?.lowercased() == coinName?.last?.description
        })
        guard (contract?.count ?? 0) > 0 else {
            // 不支持或未开启
            print("不支持或未开启")
            self.view.makeToast("未开启或不支持", position: .center)
            return
        }
        let vc = ViolasTransferViewController()
        vc.actionClosure = {
        //            self.dataModel.getLocalUserInfo()
        }
        vc.wallet = self.viewModel.detailView.headerView.walletModel
        vc.sendViolasTokenState = true
        vc.contract = contract?.first?.address
        vc.address = coinAddress
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(LCLLanguageChangeNotification), object: nil)
        print("HomeViewController销毁了")
    }
}
extension HomeViewController: HomeHeaderViewDelegate {
    func checkWalletDetail() {
        let vc = WalletDetailViewController()
        vc.walletModel = self.viewModel.detailView.headerView.walletModel
        vc.canDelete = false
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func checkWalletTransactionList() {
        let vc = WalletTransactionsViewController()
        vc.wallet = self.viewModel.detailView.headerView.walletModel
        vc.hidesBottomBarWhenPushed = true
        vc.transactionType = self.viewModel.detailView.headerView.walletModel?.walletType
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func addCoinToWallet() {
        let vc = AddAssetViewController()
        vc.hidesBottomBarWhenPushed = true
        vc.model = self.viewModel.detailView.headerView.walletModel
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func walletSend() {
        // 更新本地数据
        switch self.viewModel.detailView.headerView.walletModel?.walletType {
        case .Libra:
            let vc = TransferViewController()
            vc.actionClosure = {
    //            self.dataModel.getLocalUserInfo()
            }
            vc.wallet = self.viewModel.detailView.headerView.walletModel
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
            break
        case .Violas:
           let vc = ViolasTransferViewController()
           vc.actionClosure = {
    //            self.dataModel.getLocalUserInfo()
           }
           vc.wallet = self.viewModel.detailView.headerView.walletModel
           vc.sendViolasTokenState = false
           vc.hidesBottomBarWhenPushed = true
           self.navigationController?.pushViewController(vc, animated: true)
            break
        case .BTC:
           let vc = BTCTransferViewController()
           vc.actionClosure = {
    //            self.dataModel.getLocalUserInfo()
           }
           vc.wallet = self.viewModel.detailView.headerView.walletModel
           vc.hidesBottomBarWhenPushed = true
           self.navigationController?.pushViewController(vc, animated: true)
            break
        default:
            break
        }
    }
    func walletReceive() {
        let vc = WalletReceiveViewController()
        vc.wallet = self.viewModel.detailView.headerView.walletModel
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
extension HomeViewController: HomeTableViewManagerDelegate {
    func tableViewDidSelectRowAtIndexPath(indexPath: IndexPath, model: ViolasTokenModel) {
        let vc = VTokenMainViewController()
        vc.hidesBottomBarWhenPushed = true
        vc.wallet = self.viewModel.detailView.headerView.walletModel
        vc.vtokenModel = model
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
