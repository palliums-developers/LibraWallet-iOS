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
//        self.initKVO()
        // 添加语言变换通知
        NotificationCenter.default.addObserver(self, selector: #selector(setText), name: NSNotification.Name(LCLLanguageChangeNotification), object: nil)
    }
    func addNavigationBar() {
        // 自定义导航栏的UIBarButtonItem类型的按钮
//        mineView.addSubview(mineButton)
//        let backView = UIBarButtonItem(customView: mineView)
//        
//        // 重要方法，用来调整自定义返回view距离左边的距离
//        let barButtonItem = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
//        barButtonItem.width = -5
//        // 返回按钮设置成功
//        self.navigationItem.leftBarButtonItems = [barButtonItem, backView]
//        
        // 自定义导航栏的UIBarButtonItem类型的按钮
        
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
    lazy var mineButton: UIButton = {
        let button = UIButton(type: .custom)
        // 给按钮设置返回箭头图片
//        let url = URL(string: WalletData.wallet.walletAvatarURL ?? "")
//        button.kf.setImage(with: url, for: UIControl.State.normal, placeholder: UIImage.init(named: "default_avatar"))
        button.setImage(UIImage.init(named: "default_avatar"), for: UIControl.State.normal)
        // 设置frame
        button.frame = CGRect(x: 0, y: 0, width: 37, height: 37)
        button.addTarget(self, action: #selector(back), for: .touchUpInside)
        return button
    }()
    lazy var mineView: UIView = {
        let view = UIView.init(frame: CGRect.init(x: 0, y: 0, width: 37, height: 37))
        view.layer.cornerRadius = 18.5
        view.layer.masksToBounds = true
        return view
    }()
    lazy var scanButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage.init(named: "home_scan"), for: UIControl.State.normal)
        button.tag = 20
        button.addTarget(self, action: #selector(scanToTransfer), for: .touchUpInside)
        return button
    }()
    lazy var rechargeButtonView: UIView = {
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
    @objc func back() {
//        let vc = MineViewController()
//        self.navigationController?.pushViewController(vc, animated: true)
    }
    @objc func scanToTransfer() {
        let vc = ScanViewController()
        vc.actionClosure = { address in
            
        }
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
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
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}
