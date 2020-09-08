//
//  RepaymentViewController.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/8/25.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit

class RepaymentViewController: BaseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.init(hex: "F7F7F9")
        // 加载子View
        self.view.addSubview(detailView)
        self.viewModel.initKVO()
        self.detailView.toastView?.show(tag: 99)
        self.viewModel.dataModel.getLoanItemDetailModel(itemID: self.itemID ?? "",
                                                        address: WalletManager.shared.violasAddress!)
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
        print("RepaymentViewController销毁了")
    }
    /// 子View
    lazy var detailView : RepaymentView = {
        let view = RepaymentView.init()
        return view
    }()
    /// viewModel
    lazy var viewModel: RepaymentViewModel = {
        let viewModel = RepaymentViewModel.init()
        viewModel.view = self.detailView
        return viewModel
    }()
    var itemID: String?
    /*
     //        WalletManager.unlockWallet(successful: { [weak self] (mnemonic) in
     //            self?.detailView.toastView?.show(tag: 99)
     //            self?.dataModel.sendRepaymentTransaction(sendAddress: WalletManager.shared.violasAddress!,
     //                                                     amount: self?.detailView.headerView.model?.balance ?? 0,
     //                                                     fee: 10,
     //                                                     mnemonic: mnemonic,
     //                                                     module: self?.detailView.headerView.model?.token_module ?? "",
     //                                                     feeModule: self?.detailView.headerView.model?.token_module ?? "")
     //        }) { (errorContent) in
     //            self.view?.makeToast(errorContent, position: .center)
     //        }
     */
}
