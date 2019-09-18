//
//  MainViewController.swift
//  LibraWallet
//
//  Created by palliums on 2019/9/11.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit
import Localize_Swift
class MainViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // 设置背景色
        self.view.backgroundColor = UIColor.init(hex: "F9F9FB")
        // 加载子View
        self.view.addSubview(detailView)
        // 添加导航栏按钮
        self.addNavigationBar()
        // 初始化KVO
        self.initKVO()
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
        rechargeButtonView.addSubview(rechargeButton)
        let recharView = UIBarButtonItem(customView: rechargeButtonView)
        // 重要方法，用来调整自定义返回view距离左边的距离
        let rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        rightBarButtonItem.width = 5
        // 返回按钮设置成功
        self.navigationItem.rightBarButtonItems = [rightBarButtonItem, recharView]
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        if needRefresh == true {
//            dataModel.getLocalUserInfo()
        }
        self.navigationController?.navigationBar.barStyle = .default
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        detailView.snp.makeConstraints { (make) in
            if #available(iOS 11.0, *) {
                make.top.bottom.equalTo(self.view.safeAreaLayoutGuide)
            } else {
                make.top.bottom.equalTo(self.view)
            }
            make.left.right.equalTo(self.view)
        }
    }
    //子View
    private lazy var detailView : MainView = {
        let view = MainView.init()
        view.delegate = self
        return view
    }()
    lazy var dataModel: MainModel = {
        let model = MainModel.init()
        return model
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
    lazy var rechargeButton: UIButton = {
        let button = UIButton(type: .custom)
        if Localize.currentLanguage() == "en" {
            button.frame = CGRect(x: 0, y: 0, width: 100, height: 37)
        } else {
            button.frame = CGRect(x: 0, y: 0, width: 70, height: 37)
        }
        // 给按钮设置返回箭头图片
        button.setTitle("交易历史", for: UIControl.State.normal)
        button.setTitleColor(UIColor.black, for: UIControl.State.normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: UIFont.Weight.regular)
        button.setTitleColor(UIColor.init(hex: "707071"), for: UIControl.State.normal)
//        button.setImage(UIImage.init(named: "home_deposit_icon"), for: UIControl.State.normal)
//        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: -4)
//        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -4, bottom: 0, right: 4)
        button.tag = 20
        button.addTarget(self, action: #selector(recharge), for: .touchUpInside)
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
    @objc func recharge() {
        let vc = TransactionHistoryViewController()
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    @objc func setText(){
        rechargeButton.setTitle(localLanguage(keyString: "wallet_balance_recharge_title"), for: UIControl.State.normal)
        UIView.animate(withDuration: 0.3) { [weak self] in
            var width = 70
            if Localize.currentLanguage() == "en" {
                width = 100
            } else {
                width = 70
            }
            self?.rechargeButton.frame = CGRect.init(x: 0, y: 0, width: width, height: 37)
            self?.rechargeButtonView.frame = CGRect.init(x: 0, y: 0, width: width, height: 37)
        }
    }
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(LCLLanguageChangeNotification), object: nil)
        print("HomeViewController销毁了")
    }
    var myContext = 0
}
extension MainViewController {
    //MARK: - KVO
    func initKVO() {
        dataModel.addObserver(self, forKeyPath: "dataDic", options: NSKeyValueObservingOptions.new, context: &myContext)
        self.view.makeToastActivity(.center)
        
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
            if error.localizedDescription == LibraWalletError.WalletRequestError(reason: .networkInvalid).localizedDescription {
                // 网络无法访问
                print(error.localizedDescription)
            } else if error.localizedDescription == LibraWalletError.WalletRequestError(reason: .walletNotExist).localizedDescription {
                // 钱包不存在
                print(error.localizedDescription)
                let vc = WalletCreateViewController()
                let navi = UINavigationController.init(rootViewController: vc)
                self.present(navi, animated: true, completion: nil)
            } else if error.localizedDescription == LibraWalletError.WalletRequestError(reason: .walletVersionTooOld).localizedDescription {
                // 版本太久
                print(error.localizedDescription)
            } else if error.localizedDescription == LibraWalletError.WalletRequestError(reason: .parseJsonError).localizedDescription {
                // 解析失败
                print(error.localizedDescription)
            } else if error.localizedDescription == LibraWalletError.WalletRequestError(reason: .dataEmpty).localizedDescription {
                print(error.localizedDescription)
                // 数据为空
            }
            self.view.hideToastActivity()
            return
        }
        let type = jsonData.value(forKey: "type") as! String
        
        if type == "LoadLocalWallet" {
            // 加载本地数据
//            self.detailView.model = WalletData.wallet
        } else if type == "UpdateLocalWallet" {
            // 刷新本地数据
            self.detailView.model = LibraWalletManager.wallet
            self.view.hideToastActivity()
            self.view.makeToast("刷新成功", position: .center)

        } else {
            // 获取测试Coin
//            self.detailView.model = WalletData.wallet
            self.view.hideToastActivity()
            self.view.makeToast("获取测试币成功", position: .center)
            self.dataModel.getLocalUserInfo()
        }
        self.view.hideToastActivity()
    }
}
extension MainViewController: MainViewDelegate {
    func getTestCoin() {
        self.view.makeToastActivity(.center)
        self.dataModel.getTestCoin(address: LibraWalletManager.wallet.walletAddress!, amount: 1000000000)
    }
    
    func refreshBalance() {
        guard let address = LibraWalletManager.wallet.walletAddress else { return }
        self.view.makeToastActivity(.center)
        self.dataModel.updateLocalInfo(walletAddress: address)
    }
    func walletSend() {
        let vc = TransferViewController()
        vc.actionClosure = {
            self.dataModel.getLocalUserInfo()
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func walletReceive() {
        let vc = WalletReceiveViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}
