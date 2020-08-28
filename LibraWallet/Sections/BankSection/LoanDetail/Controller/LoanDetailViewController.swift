//
//  LoanDetailViewController.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/8/24.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit
import JXSegmentedView

class LoanDetailViewController: BaseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // 设置背景色
        self.view.backgroundColor = UIColor.white
        self.view.addSubview(detailView)
        //        self.view.addSubview(segmentView)
        //        self.view.addSubview(listContainerView)
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        //        headerView.snp.makeConstraints { (make) in
        //            if #available(iOS 11.0, *) {
        //                make.top.equalTo(self.view.safeAreaLayoutGuide)
        //            } else {
        //                make.top.equalTo(self.view)
        //            }
        //            make.left.right.equalTo(self.view)
        //            make.height.equalTo(162)
        //        }
        //        segmentView.snp.makeConstraints { (make) in
        //            make.top.equalTo(headerView.snp.bottom)
        //            make.left.equalTo(self.view)
        //            make.size.equalTo(CGSize.init(width: 180, height: 42))
        //        }
        //        listContainerView.snp.makeConstraints { (make) in
        //            make.bottom.equalTo(self.view.safeAreaLayoutGuide)
        //            make.left.right.equalTo(self.view)
        //            make.top.equalTo(segmentView.snp.bottom)
        //        }
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
    lazy var dataModel: WalletMainModel = {
        let model = WalletMainModel.init()
        return model
    }()
    lazy var detailView: LoanDetailView = {
        let view = LoanDetailView.init()
        view.segmentView.delegate = self
        view.controllers = [loanListController, depositListController, clearingListController]
        return view
    }()
    //懒加载
    //    private lazy var segmentView : JXSegmentedView = {
    //        let view = JXSegmentedView.init()
    //        view.backgroundColor = UIColor.white
    //        view.delegate = self
    //        view.dataSource = self.segmentedDataSource
    //        //        view.indicators = self.indicator
    //        view.contentScrollView = self.listContainerView.scrollView
    //        return view
    //    }()
    //    private lazy var segmentedDataSource : JXSegmentedTitleDataSource = {
    //        let data = JXSegmentedTitleDataSource.init()
    //        //配置数据源相关配置属性
    //        data.titles = [localLanguage(keyString: "存款市场"),
    //                       localLanguage(keyString: "借款市场")]
    //        data.isTitleColorGradientEnabled = true
    //        data.titleNormalColor = UIColor.init(hex: "C2C2C2")
    //        data.titleNormalFont = UIFont.systemFont(ofSize: 12, weight: UIFont.Weight.regular)
    //        data.titleSelectedColor = UIColor.init(hex: "7038FD")
    //        data.titleSelectedFont = UIFont.systemFont(ofSize: 12, weight: UIFont.Weight.semibold)
    //
    //        //reloadData(selectedIndex:)方法一定要调用，方法内部会刷新数据源数组
    //        data.reloadData(selectedIndex: 0)
    //        return data
    //    }()
    //    private lazy var listContainerView: JXSegmentedListContainerView = {
    //        let listView = JXSegmentedListContainerView.init(dataSource: self)
    //        return listView
    //    }()
    lazy var loanListController: LoanDetailLoanListViewController = {
        let con = LoanDetailLoanListViewController()
        //        con.wallet = self.wallet
        //        con.requestType = ""
        con.initKVO()
        return con
    }()
    lazy var depositListController: LoanDetailDepositListViewController = {
        let con = LoanDetailDepositListViewController()
        //        con.wallet = self.wallet
        //        con.requestType = ""
        con.initKVO()
        return con
    }()
    lazy var clearingListController: LoanDetailClearingListViewController = {
        let con = LoanDetailClearingListViewController()
        //        con.wallet = self.wallet
        //        con.requestType = "0"
        con.initKVO()
        return con
    }()
    /// 数据监听KVO
    private var observer: NSKeyValueObservation?
    var wallet: Token? {
        didSet {
            // 页面标题
            if wallet?.tokenType == .BTC {
                self.title = "BTC"
            } else {
                self.title = wallet?.tokenName
            }
            //            self.headerView.model = wallet
        }
    }
}
extension LoanDetailViewController: JXSegmentedViewDelegate {
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
