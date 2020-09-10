//
//  LoanListViewController.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/8/24.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit

class LoanListViewController: BaseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = localLanguage(keyString: "wallet_bank_loan_orders_list_navigationbar_title")
        self.view.backgroundColor = UIColor.white
        // 加载子View
        self.view.addSubview(detailView)
        self.viewModel.initKVO()
        self.detailView.tableView.mj_header?.beginRefreshing()
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
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.barStyle = .default
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.navigationController?.navigationBar.barStyle = .default
    }
    deinit {
        print("DepositListViewController销毁了")
    }
    /// 子View
    lazy var detailView : LoanListView = {
        let view = LoanListView.init()
        return view
    }()
    /// viewModel
    lazy var viewModel: LoanListViewModel = {
        let viewModel = LoanListViewModel.init()
        viewModel.view = self.detailView
        viewModel.supprotTokens = self.supprotTokens
        return viewModel
    }()

    var supprotTokens: [BankDepositMarketDataModel]?
}
