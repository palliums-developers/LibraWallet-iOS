//
//  TransactionsViewController.swift
//  LibraWallet
//
//  Created by palliums on 2019/9/17.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit
import MJRefresh
class TransactionsViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // 初始化本地配置
//        self.setBaseControlllerConfig()
        // 设置标题
        self.title = "交易历史"//localLanguage(keyString: "wallet_balance_detail_navigationbar_title")
        // 加载子View
        self.view.addSubview(self.viewModel.detailView)
        // 初始化KVO
        self.viewModel.initKVO()
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.viewModel.detailView.snp.makeConstraints { (make) in
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(self.view.safeAreaLayoutGuide)
            } else {
                make.bottom.equalTo(self.view)
            }
            make.top.left.right.equalTo(self.view)
        }
    }
    deinit {
        print("TransactionsViewController销毁了")
    }
    lazy var viewModel: TransactionsViewModel = {
        let viewModel = TransactionsViewModel.init()
        viewModel.tableViewManager.delegate = self
        return viewModel
    }()
}
extension TransactionsViewController: TransactionsViewTableViewManagerDelegate {
    func tableViewDidSelectRowAtIndexPath(indexPath: IndexPath, url: String) {
        let vc = TransactionDetailWebViewController()
        vc.requestURL = url
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
