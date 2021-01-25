//
//  NotificationCenterViewController.swift
//  LibraWallet
//
//  Created by wangyingdong on 2021/1/11.
//  Copyright © 2021 palliums. All rights reserved.
//

import UIKit
import MJRefresh
import JXSegmentedView

class NotificationCenterViewController: BaseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = localLanguage(keyString: "wallet_notification_navigation_title")
        // 设置背景色
        self.view.backgroundColor = UIColor.white
        self.view.addSubview(detailView)
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        detailView.snp.makeConstraints { (make) in
            make.top.left.right.bottom.equalTo(self.view.safeAreaLayoutGuide)
        }
    }
    deinit {
        print("NotificationCenterViewController销毁了")
    }
    /// 网络请求、数据模型
    lazy var dataModel: BankModel = {
        let model = BankModel.init()
        return model
    }()
    /// DetailView
    lazy var detailView: NotificationCenterView = {
        let view = NotificationCenterView.init()
        view.segmentView.delegate = self
        view.controllers = [walletMessageController, systemMessageController]
        return view
    }()
    /// 钱包消息页面
    lazy var walletMessageController: WalletMessagesViewController = {
        let con = WalletMessagesViewController()
        con.tableViewManager.delegate = self
        return con
    }()
    /// 系统消息页面
    lazy var systemMessageController: SystemMessagesViewController = {
        let con = SystemMessagesViewController()
        con.tableViewManager.delegate = self
        return con
    }()
    /// 数据监听KVO
    var observer: NSKeyValueObservation?
    var startRefresh: Bool = false
}
extension NotificationCenterViewController: JXSegmentedViewDelegate {
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
extension NotificationCenterViewController: WalletMessagesTableViewManagerDelegate {
    func tableViewDidSelectRowAtIndexPath(indexPath: IndexPath, model: WalletMessagesDataModel) {
        let vc = TransactionDetailViewController()
        //            vc.requestURL = address
        vc.successLoadClosure = {
            if model.readed == 0 {
                self.walletMessageController.tableViewManager.dataModels?.remove(at: indexPath.row)
                var tempModel = model
                tempModel.readed = 1
                self.walletMessageController.tableViewManager.dataModels?.insert(tempModel, at: indexPath.row)
                self.walletMessageController.detailView.tableView.beginUpdates()
                self.walletMessageController.detailView.tableView.reloadRows(at: [indexPath], with: .none)
                self.walletMessageController.detailView.tableView.endUpdates()
            }
        }
        vc.tokenAddress = WalletManager.shared.violasAddress
        vc.violasVersion = model.version
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
extension NotificationCenterViewController: SystemMessagesTableViewManagerDelegate {
    func tableViewDidSelectRowAtIndexPath(indexPath: IndexPath, model: SystemMessagesDataModel) {
        let vc = MessageWebDetailViewController.init()
        vc.successLoadClosure = {
            if model.is_read == false {
                self.systemMessageController.tableViewManager.dataModels?.remove(at: indexPath.row)
                var tempModel = model
                tempModel.is_read = true
                self.systemMessageController.tableViewManager.dataModels?.insert(tempModel, at: indexPath.row)
                self.systemMessageController.detailView.tableView.beginUpdates()
                self.systemMessageController.detailView.tableView.reloadRows(at: [indexPath], with: .none)
                self.systemMessageController.detailView.tableView.endUpdates()
            }
        }
        vc.url = model.content
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
