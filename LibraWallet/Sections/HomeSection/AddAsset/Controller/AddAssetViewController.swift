//
//  AddAssetViewController.swift
//  LibraWallet
//
//  Created by palliums on 2019/11/1.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit

class AddAssetViewController: BaseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        // 初始化本地配置
        self.setBaseControlllerConfig()
        // 加载子View
        self.view.addSubview(self.viewModel.detailView)
        // 加载数据
        self.viewModel.initKVO(walletID: (model?.walletID)!)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.barStyle = .default
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.barStyle = .black
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.viewModel.detailView.snp.makeConstraints { (make) in
            if #available(iOS 11.0, *) {
                make.top.bottom.equalTo(self.view.safeAreaLayoutGuide)
            } else {
                make.top.bottom.equalTo(self.view)
            }
            make.left.right.equalTo(self.view)
        }
    }
    deinit {
        print("AddAssetViewController销毁了")
    }
    lazy var viewModel: AddAssetViewModel = {
        let viewModel = AddAssetViewModel.init()
//        viewModel.tableViewManager.delegate = self
        viewModel.tableViewManager.headerData = self.model
        return viewModel
    }()
    var model: LibraWalletManager?
}
