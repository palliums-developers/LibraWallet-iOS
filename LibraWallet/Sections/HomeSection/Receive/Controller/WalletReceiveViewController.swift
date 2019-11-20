//
//  WalletReceiveViewController.swift
//  LibraWallet
//
//  Created by palliums on 2019/9/6.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit

class WalletReceiveViewController: BaseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // 初始化本地配置
        self.setBaseControlllerConfig()
        // 页面标题
        self.title = localLanguage(keyString: "wallet_receive_navigation_title")

        
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
    var wallet: LibraWalletManager? {
        didSet {
            self.detailView.wallet = wallet
        }
    }
    var tokenName: String? {
        didSet {
            self.detailView.violasTokenName = self.tokenName
        }
    }
    private lazy var detailView : WalletReceiveView = {
        let view = WalletReceiveView.init()
        return view
    }()
    deinit {
        print("WalletReceiveViewController销毁了")
    }
}
