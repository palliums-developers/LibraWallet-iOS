//
//  LoanViewController.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/8/26.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit

class LoanViewController: BaseViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = localLanguage(keyString: "wallet_bank_loan_navigationbar_title")
        self.view.backgroundColor = UIColor.init(hex: "F7F7F9")
        // 加载子View
        self.view.addSubview(detailView)
        // 初始化数据监听
        self.viewModel.initKVO()
        // 加载数据
        self.detailView.toastView?.show(tag: 99)
        self.viewModel.dataModel.getLoanItemDetailModel(itemID: self.itemID ?? "",
                                                        address: WalletManager.shared.violasAddress!)
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        detailView.snp.makeConstraints { (make) in
            make.top.left.right.equalTo(self.view.safeAreaLayoutGuide)
            make.bottom.equalTo(self.view)
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
        print("LoanViewController销毁了")
    }
    /// 子View
    lazy var detailView : LoanView = {
        let view = LoanView.init()
        return view
    }()
    /// viewModel
    lazy var viewModel: LoanViewModel = {
        let viewModel = LoanViewModel.init()
        viewModel.view = self.detailView
        viewModel.delegate = self
        return viewModel
    }()
    ///
    var itemID: String?
    /// 全部数据
    var models: [BankDepositMarketDataModel]? {
        didSet {
//            viewModel.models = models
        }
    }
}
extension LoanViewController: LoanViewModelDelegate {
    func successDeposit() {
        self.navigationController?.popViewController(animated: true)
    }    
}
