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
        return viewModel
    }()
    lazy var changeWalletButton: UIButton = {
        let button = UIButton(type: .custom)
        // 设置字体
        button.setTitle(localLanguage(keyString: "Violas 钱包"), for: UIControl.State.normal)
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
                self.viewModel.detailView.headerView.model = wallet
                // 需要更新
                #warning("需要添加获取地址最后交易、余额")
                if wallet.walletType == 0 {
                    self.changeWalletButton.setTitle(localLanguage(keyString: "Libra 钱包"), for: UIControl.State.normal)
                } else if wallet.walletType == 1 {
                    self.changeWalletButton.setTitle(localLanguage(keyString: "Violas 钱包"), for: UIControl.State.normal)
                } else {
                    self.changeWalletButton.setTitle(localLanguage(keyString: "BTC 钱包"), for: UIControl.State.normal)
                }
            }
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @objc func scanToTransfer() {
//        let vc = ScanViewController()
//        vc.actionClosure = { address in
//
//        }
//        vc.hidesBottomBarWhenPushed = true
//        self.navigationController?.pushViewController(vc, animated: true)
        
//        let vc = BackupMnemonicController()
//        vc.hidesBottomBarWhenPushed = true
//        self.navigationController?.pushViewController(vc, animated: true)
        
//        let vc = BackupWarningViewController()
//        vc.hidesBottomBarWhenPushed = true
//        self.navigationController?.pushViewController(vc, animated: true)
//        let alert = WelcomeAlert()
//        alert.show()
        
        
//        let vc = WalletCreateViewController()
//        vc.hidesBottomBarWhenPushed = true
//        self.navigationController?.pushViewController(vc, animated: true)
        let alert = BackupWarningAlert.init {
            let vc = BackupWarningViewController()
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
        alert.show()
        
    }
    @objc func setText(){
    }
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(LCLLanguageChangeNotification), object: nil)
        print("HomeViewController销毁了")
    }
}

extension HomeViewController: HomeHeaderViewDelegate {
    func checkWalletDetail() {
//        let vc = WalletDetailViewController()
////        vc.walletModel = model
//        vc.canDelete = false
//        vc.hidesBottomBarWhenPushed = true
//        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func checkWalletTransactionList() {
        let vc = WalletTransactionsViewController()
        vc.hidesBottomBarWhenPushed = true
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func addCoinToWallet() {
        
        let vc = AddAssetViewController()
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func walletSend() {
        let vc = TransferViewController()
        vc.actionClosure = {
//            self.dataModel.getLocalUserInfo()
        }
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func walletReceive() {
        let vc = WalletReceiveViewController()
        vc.wallet = self.viewModel.detailView.headerView.model
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}
