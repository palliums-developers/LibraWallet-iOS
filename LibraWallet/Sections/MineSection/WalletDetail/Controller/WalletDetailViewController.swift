//
//  WalletDetailViewController.swift
//  LibraWallet
//
//  Created by palliums on 2019/10/28.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit

class WalletDetailViewController: BaseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // 初始化本地配置
        self.setBaseControlllerConfig()
        // 设置标题
        self.title = localLanguage(keyString: "wallet_home_right_bar_title")
        // 加载子View
        self.view.addSubview(self.viewModel.detailView)
        // 加载数据
        self.viewModel.loadLocalData(model: self.walletModel!)
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
        print("WalletDetailViewController销毁了")
    }
    lazy var viewModel: WalletDetailViewModel = {
        let viewModel = WalletDetailViewModel.init()
        viewModel.tableViewManager.delegate = self
        viewModel.canDelete = self.canDelete
        return viewModel
    }()
    var walletModel: LibraWalletManager?
    var canDelete: Bool?
}
extension WalletDetailViewController: WalletDetailTableViewManagerDelegate {
    func tableViewDidSelectRowAtIndexPath(indexPath: IndexPath) {
        if indexPath.row == 0 {
            let vc = WalletChangeNameViewController()
            vc.account = walletModel
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
