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
        // 添加语言变换通知
        NotificationCenter.default.addObserver(self, selector: #selector(setText), name: NSNotification.Name(LCLLanguageChangeNotification), object: nil)
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
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(LCLLanguageChangeNotification), object: nil)
        print("BankViewController销毁了")
    }
    /// DetailView
    lazy var detailView: BankView = {
        let view = BankView.init()
        view.segmentView.delegate = self
        view.controllers = [depositController, withdrawController]
        return view
    }()
    /// 存款市场Controller
    lazy var depositController: DepositMarketViewController = {
        let con = DepositMarketViewController()
        con.initKVO()
        con.tableViewManager.delegate = self
        return con
    }()
    /// 贷款市场Controller
    lazy var withdrawController: WithdrawMarketViewController = {
        let con = WithdrawMarketViewController()
        con.initKVO()
        return con
    }()
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
     /// 交易记录按钮
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
//        let vc = RepaymentViewController.init()
//        vc.hidesBottomBarWhenPushed = true
//        self.navigationController?.pushViewController(vc, animated: true)
        let vc = DepositViewController.init()
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
extension BankViewController: DepositMarketTableViewManagerDelegate {
    func tableViewDidSelectRowAtIndexPath(indexPath: IndexPath, models: [BankDepositMarketDataModel]) {
        let vc = DepositViewController.init()
        vc.selectIndexPath = indexPath
        vc.models = models
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
//extension BankViewController: WithdrawMarketTableViewManagerDelegate {
//    func tableViewDidSelectRowAtIndexPath(indexPath: IndexPath) {
//        let vc = LoanViewController.init()
//        vc.hidesBottomBarWhenPushed = true
//        self.navigationController?.pushViewController(vc, animated: true)
//    }
//}
