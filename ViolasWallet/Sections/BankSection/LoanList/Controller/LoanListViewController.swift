//
//  LoanListViewController.swift
//  ViolasWallet
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
        // 授权管理
        viewModel.view = self.detailView
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        detailView.snp.makeConstraints { (make) in
            make.top.bottom.left.right.equalTo(self.view.safeAreaLayoutGuide)
        }
    }
    deinit {
        print("LoanListViewController销毁了")
    }
    /// 子View
    private lazy var detailView : LoanListView = {
        let view = LoanListView.init()
        return view
    }()
    /// viewModel
    private lazy var viewModel: LoanListViewModel = {
        let viewModel = LoanListViewModel.init()
        return viewModel
    }()
}
