//
//  ProfitMainViewController.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/12/2.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit
import JXSegmentedView

class ProfitMainViewController: BaseViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = localLanguage(keyString: "wallet_profit_list_navigation_title")
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
        print("ProfitMainViewController销毁了")
    }
    /// 网络请求、数据模型
    lazy var dataModel: LoanOrderDetailModel = {
        let model = LoanOrderDetailModel.init()
        return model
    }()
    lazy var detailView: ProfitMainView = {
        let view = ProfitMainView.init()
        view.delegate = self
        view.segmentView.delegate = self
        view.controllers = [invitationListController, poolListController, bankListController]
        return view
    }()
    lazy var invitationListController: ProfitInvitationViewController = {
        let con = ProfitInvitationViewController()
        con.itemID = self.itemID ?? ""
        con.initKVO()
//        con.updateAction = { [weak self] (model) in
//            self?.detailView.headerView.model = model
//        }
        return con
    }()
    lazy var poolListController: ProfitPoolViewController = {
        let con = ProfitPoolViewController()
        con.itemID = self.itemID ?? ""
        con.initKVO()
//        con.updateAction = { [weak self] (model) in
//            self?.detailView.headerView.model = model
//        }
        return con
    }()
    lazy var bankListController: ProfitBankViewController = {
        let con = ProfitBankViewController()
        con.itemID = self.itemID ?? ""
        con.initKVO()
//        con.updateAction = { [weak self] (model) in
//            self?.detailView.headerView.model = model
//        }
        return con
    }()
    /// 数据监听KVO
    private var observer: NSKeyValueObservation?
    var itemID: String?
}
extension ProfitMainViewController: ProfitMainViewDelegate {
    func confirmRepayment() {
        let vc = RepaymentViewController()
        vc.itemID = self.itemID
        vc.updateAction = { action in
            if self.detailView.segmentView.selectedIndex == 0 {
                self.invitationListController.detailView.tableView.mj_header?.beginRefreshing()
            } else if self.detailView.segmentView.selectedIndex == 0 {
                self.poolListController.detailView.tableView.mj_header?.beginRefreshing()
            } else {
                self.bankListController.detailView.tableView.mj_header?.beginRefreshing()
            }
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
extension ProfitMainViewController: JXSegmentedViewDelegate {
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
