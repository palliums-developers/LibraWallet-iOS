//
//  CreateWalletViewController.swift
//  LibraWallet
//
//  Created by palliums on 2019/10/18.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit

class CreateWalletViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
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
