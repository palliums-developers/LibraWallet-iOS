//
//  BackupWarningViewController.swift
//  LibraWallet
//
//  Created by palliums on 2019/11/4.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit

class BackupWarningViewController: BaseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = localLanguage(keyString: "wallet_backup_mnemonic_warning_navigationbar_title")
        if FirstInApp == true {
            self.addRightNavigationBar()
        }
        // 加载子View
        self.view.addSubview(detailView)
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
    deinit {
        print("BackupWarningViewController销毁了")
    }
    override func back() {
        if FirstInApp == true {
            let tabbar = BaseTabBarViewController.init()
            UIApplication.shared.keyWindow?.rootViewController = tabbar
            UIApplication.shared.keyWindow?.makeKeyAndVisible()
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    //子View
    private lazy var detailView : BackupWarningView = {
        let view = BackupWarningView.init()
        view.delegate = self
        return view
    }()
    var FirstInApp: Bool?
    func addRightNavigationBar() {
        let scanView = UIBarButtonItem(customView: backupLater)
        // 重要方法，用来调整自定义返回view距离左边的距离
        let rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        rightBarButtonItem.width = 15
        // 返回按钮设置成功
        self.navigationItem.rightBarButtonItems = [rightBarButtonItem, scanView]
    }
    lazy var backupLater: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle(localLanguage(keyString: "wallet_backup_mnemonic_warning_navigation_right_bar_title"), for: UIControl.State.normal)
        button.setTitleColor(UIColor.init(hex: "3B3847"), for: UIControl.State.normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 16), weight: UIFont.Weight.regular)
        button.tag = 20
        button.addTarget(self, action: #selector(buttonClick), for: .touchUpInside)
        return button
    }()
    @objc func buttonClick() {
        let tabbar = BaseTabBarViewController.init()
        UIApplication.shared.keyWindow?.rootViewController = tabbar
        UIApplication.shared.keyWindow?.makeKeyAndVisible()
    }
    var tempWallet: [String]?
}
extension BackupWarningViewController: BackupWarningViewDelegate {
    func checkBackupMnemonic() {
        let vc = BackupMnemonicController()
        vc.FirstInApp = self.FirstInApp
        vc.tempWallet = self.tempWallet
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
