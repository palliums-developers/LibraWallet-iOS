//
//  RepaymentViewController.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/8/25.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit
import Toast_Swift

class RepaymentViewController: BaseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = localLanguage(keyString: "wallet_bank_repayment_navigationbar_title")
        self.view.backgroundColor = UIColor.init(hex: "F7F7F9")
        // 加载子View
        self.view.addSubview(detailView)
        self.requestData()
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        detailView.snp.makeConstraints { (make) in
            make.top.left.right.equalTo(self.view.safeAreaLayoutGuide)
            make.bottom.equalTo(self.view)
        }
    }
    deinit {
        print("RepaymentViewController销毁了")
    }
    func requestData() {
        self.viewModel.loadOrderDetail(itemID: self.itemID!, address: Wallet.shared.violasAddress!)
    }
    /// 子View
    lazy var detailView : RepaymentView = {
        let view = RepaymentView.init()
        view.delegate = self
        view.tableView.delegate = self.viewModel.tableViewManager
        view.tableView.dataSource = self.viewModel.tableViewManager
        return view
    }()
    /// viewModel
    lazy var viewModel: RepaymentViewModel = {
        let viewModel = RepaymentViewModel.init()
        viewModel.delegate = self
        return viewModel
    }()
    var itemID: String?
    var updateAction: ((ControllerAction)->())?
}
extension RepaymentViewController: RepaymentViewModelDelegate {
    func reloadDetailView() {
        self.viewModel.tableViewManager.model = self.viewModel.repaymentInfoModel
        self.viewModel.tableViewManager.dataModels = self.viewModel.repaymentListmodel
        self.detailView.tableView.reloadData()
    }
    func showToast(tag: Int) {
        self.detailView.toastView.show(tag: tag)
    }
    func hideToast(tag: Int) {
        self.detailView.toastView.hide(tag: tag)
    }
    func requestError(errorMessage: String) {
        self.detailView.makeToast(errorMessage, position: .center)
    }
    func successRepayment() {
        self.detailView.makeToast(localLanguage(keyString: "wallet_bank_repayment_submit_successful"), duration: toastDuration, position: .center, title: nil, image: nil, style: ToastManager.shared.style, completion: { [weak self] (bool) in
            if let action = self?.updateAction {
                action(.update)
            }
            self?.navigationController?.popViewController(animated: true)
        })
    }
}
extension RepaymentViewController: RepaymentViewDelegate {
    func confirmRepayment() {
        self.viewModel.confirmRepayment()
    }    
}
