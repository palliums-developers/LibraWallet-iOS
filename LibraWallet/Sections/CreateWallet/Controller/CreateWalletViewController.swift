//
//  CreateWalletViewController.swift
//  LibraWallet
//
//  Created by palliums on 2019/10/18.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit

class CreateWalletViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // 初始化本地配置
        self.setBaseControlllerConfig()
        // 设置背景色
        self.view.addSubview(detailView)
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        detailView.snp.makeConstraints { (make) in
            make.top.left.right.bottom.equalTo(self.view)
        }
    }
    private lazy var detailView : CreateWalletView = {
        let view = CreateWalletView.init()
        view.delegate = self
        return view
    }()
    private lazy var dataModel: CreateWalletModel = {
        let model = CreateWalletModel.init()
        return model
    }()
}
extension CreateWalletViewController: CreateWalletViewDelegate {
    func comfirmCreateWallet(walletName: String, password: String) {
        dataModel.createWallet(walletName: walletName, password: password)
    }
}
