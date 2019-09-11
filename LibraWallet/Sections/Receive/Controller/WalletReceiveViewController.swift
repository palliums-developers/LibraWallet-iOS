//
//  WalletReceiveViewController.swift
//  LibraWallet
//
//  Created by palliums on 2019/9/6.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit

class WalletReceiveViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // 加载子View
        self.view.addSubview(detailView)
        self.detailView.model = self.wallet
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
    var wallet: LibraWallet? 
    private lazy var detailView : WalletReceiveView = {
        let view = WalletReceiveView.init()
        return view
    }()
    deinit {
        print("WalletReceiveViewController销毁了")
    }
}
