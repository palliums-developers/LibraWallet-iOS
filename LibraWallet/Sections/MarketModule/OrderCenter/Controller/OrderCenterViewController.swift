//
//  OrderCenterViewController.swift
//  LibraWallet
//
//  Created by palliums on 2019/12/13.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit
import JXSegmentedView
class OrderCenterViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // 设置标题
        self.title = localLanguage(keyString: "wallet_order_center_navigationbar_title")
        // 加载子View
        self.view.addSubview(segmentView)
        self.view.addSubview(segmentSpaceLabel)
        self.view.addSubview(listContainerView)
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        segmentView.snp.makeConstraints { (make) in
            if #available(iOS 11.0, *) {
                make.top.equalTo(self.view.safeAreaLayoutGuide)
            } else {
                make.top.equalTo(self.view)
            }
            make.left.right.equalTo(self.view)
            make.height.equalTo(43)
        }
        segmentSpaceLabel.snp.makeConstraints { (make) in
            make.bottom.equalTo(self.segmentView.snp.bottom)
            make.left.equalTo(self.view).offset(14)
            make.right.equalTo(self.view).offset(-14)
            make.height.equalTo(1)
        }
        listContainerView.snp.makeConstraints { (make) in
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(self.view.safeAreaLayoutGuide)
            } else {
                make.bottom.equalTo(self.view)
            }
            make.left.right.equalTo(self.view)
            make.top.equalTo(segmentView.snp.bottom)
        }
    }
    deinit {
        print("OrderCenterViewController销毁了")
    }
    //懒加载
    private lazy var segmentView : JXSegmentedView = {
        let view = JXSegmentedView.init()
        view.backgroundColor = UIColor.white
        view.delegate = self
        view.dataSource = self.segmentedDataSource
        view.indicators = self.indicator
        view.contentScrollView = self.listContainerView.scrollView
        return view
    }()
    private lazy var segmentedDataSource : JXSegmentedTitleDataSource = {
        let data = JXSegmentedTitleDataSource.init()
        //配置数据源相关配置属性
        data.titles = [localLanguage(keyString: "wallet_market_processing_order_title"),
                       localLanguage(keyString: "wallet_market_done_order_title")]
        data.isTitleColorGradientEnabled = true
        data.titleNormalColor = UIColor.init(hex: "D9D9D9")
        data.titleNormalFont = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.medium)
        data.titleSelectedColor = UIColor.init(hex: "28282B")
        data.titleSelectedFont = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.medium)

        //reloadData(selectedIndex:)方法一定要调用，方法内部会刷新数据源数组
        data.reloadData(selectedIndex: 0)
        return data
    }()
    private lazy var indicator: [JXSegmentedIndicatorLineView] = {
        let view = JXSegmentedIndicatorLineView.init()
        view.indicatorColor = UIColor.init(hex: "28282B")
        view.indicatorHeight = 2
        return [view]
    }()
    private lazy var listContainerView: JXSegmentedListContainerView = {
        let listView = JXSegmentedListContainerView.init(dataSource: self)
        return listView
    }()
    lazy var segmentSpaceLabel: UILabel = {
        let label = UILabel.init()
        label.backgroundColor = DefaultSpaceColor
        return label
    }()
    lazy var processingOrder: OrderProcessingViewController = {
        let con = OrderProcessingViewController()
        con.wallet = self.wallet
        con.initKVO()
//        con.delegate = self
        return con
    }()
    lazy var doneOrder: OrderDoneViewController = {
        let con = OrderDoneViewController()
        con.wallet = self.wallet
        con.initKVO()
        return con
    }()
    var wallet: Token?
}
extension OrderCenterViewController: JXSegmentedListContainerViewDataSource {
    func numberOfLists(in listContainerView: JXSegmentedListContainerView) -> Int {
        return self.segmentedDataSource.titles.count
    }
    func listContainerView(_ listContainerView: JXSegmentedListContainerView, initListAt index: Int) -> JXSegmentedListContainerViewListDelegate {
        if index == 0 {
            return processingOrder
        } else {
            return doneOrder
        }
    }
}
extension OrderCenterViewController: JXSegmentedViewDelegate {
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
