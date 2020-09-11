//
//  DepositListViewController.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/8/21.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit
import MJRefresh

class DepositListViewController: BaseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // 设置标题
        self.title = localLanguage(keyString: "wallet_bank_deposit_orders_list_navigationbar_title")
        // 加载子View
        self.view.addSubview(detailView)
        self.viewModel.initKVO()
        
        self.detailView.makeToastActivity(.center)
        self.viewModel.requestData()
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
        print("DepositListViewController销毁了")
    }
    /// 子View
    lazy var detailView : DepositListView = {
        let view = DepositListView.init()
//        view.delegate = self.viewModel
//        view.tableView.delegate = self.viewModel.tableViewManager
//        view.tableView.dataSource = self.viewModel.tableViewManager
//        view.tableView.mj_header = MJRefreshNormalHeader.init(refreshingTarget: self.viewModel, refreshingAction:  #selector(self.viewModel.refreshData))
//        view.tableView.mj_footer = MJRefreshBackNormalFooter.init(refreshingTarget: self.viewModel, refreshingAction:  #selector(self.viewModel.getMoreData))
        return view
    }()
    /// viewModel
    lazy var viewModel: DepositListViewModel = {
        let viewModel = DepositListViewModel.init(handleView: self.detailView)
        viewModel.supprotTokens = self.supprotTokens
        return viewModel
    }()
    var supprotTokens: [BankDepositMarketDataModel]?
}
