//
//  LoanOrderDetailViewController.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/8/24.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit
import JXSegmentedView

class LoanOrderDetailViewController: BaseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = localLanguage(keyString: "wallet_bank_loan_detail_navigationbar_title")
        // 设置背景色
        self.view.backgroundColor = UIColor.white
        self.view.addSubview(detailView)
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        detailView.snp.makeConstraints { (make) in
            make.top.left.right.equalTo(self.view)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide)
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.barStyle = .default
    }
    deinit {
        print("LoanDetailViewController销毁了")
    }
    /// 网络请求、数据模型
    lazy var dataModel: LoanOrderDetailModel = {
        let model = LoanOrderDetailModel.init()
        return model
    }()
    lazy var detailView: LoanOrderDetailView = {
        let view = LoanOrderDetailView.init()
        view.delegate = self
        view.segmentView.delegate = self
        view.controllers = [loanListController, depositListController, clearingListController]
        return view
    }()
    lazy var loanListController: LoanDetailLoanListViewController = {
        let con = LoanDetailLoanListViewController()
        con.itemID = self.itemID ?? ""
        con.initKVO()
        con.updateAction = { (model) in
            self.detailView.headerView.model = model
        }
        return con
    }()
    lazy var depositListController: LoanDetailDepositListViewController = {
        let con = LoanDetailDepositListViewController()
        con.itemID = self.itemID ?? ""
        con.initKVO()
        con.updateAction = { (model) in
            self.detailView.headerView.model = model
        }
        return con
    }()
    lazy var clearingListController: LoanDetailClearingListViewController = {
        let con = LoanDetailClearingListViewController()
        con.itemID = self.itemID ?? ""
        con.initKVO()
        con.updateAction = { (model) in
            self.detailView.headerView.model = model
        }
        return con
    }()
    /// 数据监听KVO
    private var observer: NSKeyValueObservation?
    var itemID: String?
}
extension LoanOrderDetailViewController: LoanOrderDetailViewDelegate {
    func confirmRepayment() {
        let vc = RepaymentViewController()
        vc.itemID = self.itemID
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
extension LoanOrderDetailViewController: JXSegmentedViewDelegate {
    func segmentedView(_ segmentedView: JXSegmentedView, didSelectedItemAt index: Int) {
        print(index)
    }
    func segmentedView(_ segmentedView: JXSegmentedView, didClickSelectedItemAt index: Int) {
        //传递didClickSelectedItemAt事件给listContainerView，必须调用！！！
        self.detailView.listContainerView.didClickSelectedItem(at: index)
    }
    func segmentedView(_ segmentedView: JXSegmentedView, scrollingFrom leftIndex: Int, to rightIndex: Int, percent: CGFloat) {
        //传递scrolling事件给listContainerView，必须调用！！！
        self.detailView.listContainerView.scrolling(from: leftIndex, to: rightIndex, percent: percent, selectedIndex: segmentedView.selectedIndex)
    }
}
