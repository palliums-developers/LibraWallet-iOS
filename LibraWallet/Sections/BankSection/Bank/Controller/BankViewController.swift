//
//  BankViewController.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/8/19.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit
import Localize_Swift
import MJRefresh
import JXSegmentedView

class BankViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // 设置背景色
        self.view.backgroundColor = UIColor.white
        // 添加导航栏按钮
        self.addNavigationBar()
        self.view.addSubview(detailView)
//        self.view.addSubview(segmentView)
//        self.view.addSubview(listContainerView)
        // 添加语言变换通知
        NotificationCenter.default.addObserver(self, selector: #selector(setText), name: NSNotification.Name(LCLLanguageChangeNotification), object: nil)
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
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(LCLLanguageChangeNotification), object: nil)
        print("BankViewController销毁了")
    }
    /// 网络请求、数据模型
    lazy var dataModel: WalletMainModel = {
        let model = WalletMainModel.init()
        return model
    }()
    lazy var detailView: BankView = {
        let view = BankView.init()
        view.segmentView.delegate = self
        view.controllers = [depositController, withdrawController]
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
    lazy var depositController: DepositMarketViewController = {
        let con = DepositMarketViewController()
//        con.wallet = self.wallet
//        con.requestType = ""
        con.initKVO()
        return con
    }()
    lazy var withdrawController: WithdrawMarketViewController = {
        let con = WithdrawMarketViewController()
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
    /// 全部资产价值按钮
     lazy var totalAssetsButton: UIButton = {
         let button = UIButton(type: .custom)
         button.setTitle(localLanguage(keyString: "wallet_bank_total_deposit_title"), for: UIControl.State.normal)
         button.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.regular)
         button.setTitleColor(UIColor.white, for: UIControl.State.normal)
         button.setImage(UIImage.init(named: "eyes_open_white"), for: UIControl.State.normal)
         // 调整位置
         button.imagePosition(at: .right, space: 4, imageViewSize: CGSize.init(width: 14, height: 8))
//         button.addTarget(self, action: #selector(changeWallet), for: .touchUpInside)
         return button
     }()
     /// 二维码扫描按钮
     lazy var transactionsButton: UIButton = {
         let button = UIButton(type: .custom)
         button.setImage(UIImage.init(named: "wallet_detail_indicator"), for: UIControl.State.normal)
         button.addTarget(self, action: #selector(checkOrder), for: .touchUpInside)
         return button
     }()
}
extension BankViewController: JXSegmentedViewDelegate {
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
//MARK: - 语言切换方法
extension BankViewController {
    /// 语言切换
    @objc func setText() {
        totalAssetsButton.setTitle(localLanguage(keyString: "wallet_bank_total_deposit_title"), for: UIControl.State.normal)
        totalAssetsButton.imagePosition(at: .right, space: 4, imageViewSize: CGSize.init(width: 14, height: 8))
    }
}
//MARK: - 导航栏添加按钮
extension BankViewController {
    func addNavigationBar() {
        // 自定义导航栏的UIBarButtonItem类型的按钮
        let backView = UIBarButtonItem(customView: totalAssetsButton)
        // 重要方法，用来调整自定义返回view距离左边的距离
        let barButtonItem = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        barButtonItem.width = 15
        // 返回按钮设置成功
        self.navigationItem.leftBarButtonItems = [barButtonItem, backView]
        
        let scanView = UIBarButtonItem(customView: transactionsButton)
        // 重要方法，用来调整自定义返回view距离左边的距离
        let rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        rightBarButtonItem.width = 15
        // 返回按钮设置成功
        self.navigationItem.rightBarButtonItems = [rightBarButtonItem, scanView]
    }
    @objc func checkOrder() {
//        let vc = DepositOrdersViewController.init()
//        vc.hidesBottomBarWhenPushed = true
//        self.navigationController?.pushViewController(vc, animated: true)
//        let vc = LoanOrdersViewController.init()
//        vc.hidesBottomBarWhenPushed = true
//        self.navigationController?.pushViewController(vc, animated: true)
        let vc = RepaymentViewController.init()
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
}
