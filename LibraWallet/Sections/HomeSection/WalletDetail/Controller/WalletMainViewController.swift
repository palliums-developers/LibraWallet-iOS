//
//  WalletDetailViewController.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/6/4.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit
import MJRefresh
import JXSegmentedView
class WalletMainViewController: BaseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(headerView)
        self.view.addSubview(segmentView)
        self.view.addSubview(listContainerView)
        self.view.addSubview(footerView)
//        self.initKVO()
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        headerView.snp.makeConstraints { (make) in
            if #available(iOS 11.0, *) {
                make.top.equalTo(self.view.safeAreaLayoutGuide)
            } else {
                make.top.equalTo(self.view)
            }
            make.left.right.equalTo(self.view)
            make.height.equalTo(162)
        }
        segmentView.snp.makeConstraints { (make) in
            make.top.equalTo(headerView.snp.bottom)
            make.left.equalTo(self.view)
            make.size.equalTo(CGSize.init(width: 160, height: 42))
        }
        listContainerView.snp.makeConstraints { (make) in
            make.bottom.equalTo(footerView.snp.top)
            make.left.right.equalTo(self.view)
            make.top.equalTo(segmentView.snp.bottom)
        }
        footerView.snp.makeConstraints { (make) in
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(self.view.safeAreaLayoutGuide)
            } else {
                make.bottom.equalTo(self.view)
            }
            make.left.right.equalTo(self.view)
            make.height.equalTo(5+35+7)
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.barStyle = .default
    }
    /// 网络请求、数据模型
    lazy var dataModel: WalletMainModel = {
        let model = WalletMainModel.init()
        return model
    }()
    lazy var headerView: WalletMainViewHeaderView = {
        let view = WalletMainViewHeaderView.init()
        return view
    }()
    lazy var footerView: WalletMainViewFooterView = {
        let view = WalletMainViewFooterView.init()
        view.delegate = self
        return view
    }()
    //懒加载
    private lazy var segmentView : JXSegmentedView = {
        let view = JXSegmentedView.init()
        view.backgroundColor = UIColor.white
        view.delegate = self
        view.dataSource = self.segmentedDataSource
//        view.indicators = self.indicator
        view.contentScrollView = self.listContainerView.scrollView
        return view
    }()
    private lazy var segmentedDataSource : JXSegmentedTitleDataSource = {
        let data = JXSegmentedTitleDataSource.init()
        //配置数据源相关配置属性
        data.titles = [localLanguage(keyString: "全部"),
                      localLanguage(keyString: "转入"),
                      localLanguage(keyString: "转出")]
        data.isTitleColorGradientEnabled = true
        data.titleNormalColor = UIColor.init(hex: "C2C2C2")
        data.titleNormalFont = UIFont.systemFont(ofSize: 12, weight: UIFont.Weight.regular)
        data.titleSelectedColor = UIColor.init(hex: "7038FD")
        data.titleSelectedFont = UIFont.systemFont(ofSize: 12, weight: UIFont.Weight.semibold)

        //reloadData(selectedIndex:)方法一定要调用，方法内部会刷新数据源数组
        data.reloadData(selectedIndex: 0)
        return data
    }()
    private lazy var listContainerView: JXSegmentedListContainerView = {
        let listView = JXSegmentedListContainerView.init(dataSource: self)
        return listView
    }()
    lazy var totalTransactions: WalletTransactionsViewController = {
        let con = WalletTransactionsViewController()
        con.wallet = self.wallet
        con.initKVO()
        return con
    }()
    lazy var transferTransactions: WalletTransactionsViewController = {
        let con = WalletTransactionsViewController()
        con.wallet = self.wallet
        con.initKVO()
        return con
    }()
    lazy var receiveTransactions: WalletTransactionsViewController = {
        let con = WalletTransactionsViewController()
        con.wallet = self.wallet
        con.initKVO()
        return con
    }()
    /// 数据监听KVO
    private var observer: NSKeyValueObservation?
    var wallet: LibraWalletManager? {
        didSet {
            // 页面标题
            self.title = wallet?.walletType?.description
            self.headerView.wallet = wallet
        }
    }
    var vtokenModel: ViolasTokenModel? {
        didSet {
//            self.detailView.headerView.assetLabel.text = getDecimalNumberAmount(amount: NSDecimalNumber.init(value: (vtokenModel?.balance ?? 0)),
//                                                                                          scale: 4,
//                                                                                          unit: 1000000)
//            self.detailView.headerView.assetUnitLabel.text = vtokenModel?.name
        }
    }
}
extension WalletMainViewController: WalletMainViewFooterViewDelegate {
    func walletTransfer() {
        let vc = ViolasTransferViewController()
        vc.actionClosure = {
        //            self.dataModel.getLocalUserInfo()
        }
        vc.wallet = self.wallet
        vc.sendViolasTokenState = true
        vc.vtokenModel = self.vtokenModel
        vc.title = (vtokenModel?.name ?? "") + localLanguage(keyString: "wallet_transfer_navigation_title")
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func walletReceive() {
        let vc = WalletReceiveViewController()
        // 一定要tokenname在前,否则显示有问题
        vc.tokenName = self.vtokenModel?.name
        vc.wallet = self.wallet
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func walletExchange() {
        
    }
}
extension WalletMainViewController: JXSegmentedListContainerViewDataSource {
    func numberOfLists(in listContainerView: JXSegmentedListContainerView) -> Int {
        return self.segmentedDataSource.titles.count
    }
    func listContainerView(_ listContainerView: JXSegmentedListContainerView, initListAt index: Int) -> JXSegmentedListContainerViewListDelegate {
        if index == 0 {
            return totalTransactions
        } else if index == 1 {
            return transferTransactions
        } else {
            return receiveTransactions
        }
    }
}
extension WalletMainViewController: JXSegmentedViewDelegate {
    func segmentedView(_ segmentedView: JXSegmentedView, didSelectedItemAt index: Int) {
        print(index)
    }
    func segmentedView(_ segmentedView: JXSegmentedView, didClickSelectedItemAt index: Int) {
        //传递didClickSelectedItemAt事件给listContainerView，必须调用！！！
        listContainerView.didClickSelectedItem(at: index)
    }
    func segmentedView(_ segmentedView: JXSegmentedView, scrollingFrom leftIndex: Int, to rightIndex: Int, percent: CGFloat) {
        //传递scrolling事件给listContainerView，必须调用！！！
        listContainerView.scrolling(from: leftIndex, to: rightIndex, percent: percent, selectedIndex: segmentedView.selectedIndex)
    }
}
