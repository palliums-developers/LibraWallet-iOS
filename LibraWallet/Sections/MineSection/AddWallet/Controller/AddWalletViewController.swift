//
//  AddWalletViewController.swift
//  LibraWallet
//
//  Created by palliums on 2019/10/25.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit

class AddWalletViewController: BaseViewController {
   override func viewDidLoad() {
        super.viewDidLoad()
        // 初始化本地配置
        self.setBaseControlllerConfig()
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
    //子View
    private lazy var detailView : AddWalletView = {
        let view = AddWalletView.init()
        view.type = self.type
        return view
    }()
    deinit {
        print("AddWalletViewController销毁了")
    }
    var type: String?
}
