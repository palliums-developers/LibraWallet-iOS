//
//  DepositViewController.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/8/26.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit

class DepositViewController: BaseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = localLanguage(keyString: "wallet_bank_deposit_navigationbar_title")
        self.view.backgroundColor = UIColor.init(hex: "F7F7F9")
        // 加载子View
        self.view.addSubview(detailView)
        self.viewModel.initKVO()
        self.detailView.toastView?.show(tag: 99)
        self.viewModel.dataModel.getBankListModel(address: WalletManager.shared.violasAddress!, bankTokens: self.models ?? [BankDepositMarketDataModel]())
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        detailView.snp.makeConstraints { (make) in
            if #available(iOS 11.0, *) {
                make.top.equalTo(self.view.safeAreaLayoutGuide)
            } else {
                make.top.equalTo(self.view)
            }
            make.left.right.bottom.equalTo(self.view)
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
        print("DepositViewController销毁了")
    }
    /// 子View
    lazy var detailView : DepositView = {
        let view = DepositView.init()
        return view
    }()
    /// viewModel
    lazy var viewModel: DepositViewModel = {
        let viewModel = DepositViewModel.init()
        viewModel.view = self.detailView
        return viewModel
    }()
    var selectIndexPath: IndexPath? {
        didSet {
            viewModel.selectIndexPath = selectIndexPath
        }
    }
    var models: [BankDepositMarketDataModel]?
}
