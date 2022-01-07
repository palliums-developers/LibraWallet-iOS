//
//  NotificationCenterViewController.swift
//  ViolasWallet
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
        addNavigationRightBar()
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
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if refreshSegmentIndex != 999 {
            self.detailView.segmentView.reloadItem(at: refreshSegmentIndex)
            self.refreshSegmentIndex = 999
        }
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if let action = self.successReadClosure {
            if let model = self.unreadMessageDataModel {
                action(model)
            }
        }
    }
    deinit {
        print("NotificationCenterViewController销毁了")
    }
    /// 网络请求、数据模型
    lazy var dataModel: NotificationCenterModel = {
        let model = NotificationCenterModel.init()
        return model
    }()
    /// DetailView
    lazy var detailView: NotificationCenterView = {
        let view = NotificationCenterView.init(controllers: [walletMessageController, systemMessageController], dotStates: self.dotStates ?? [false, false])
        view.segmentView.delegate = self
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
    /// 二维码扫描按钮
    lazy var messageButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage.init(named: "total_read"), for: UIControl.State.normal)
        button.addTarget(self, action: #selector(checkNotificationCenter), for: .touchUpInside)
        return button
    }()
    @objc func checkNotificationCenter() {
        self.detailView.makeToastActivity(.center)
        self.dataModel.setTotalRead(address: Wallet.shared.violasAddress ?? "", token: getRequestToken()) { [weak self] (result) in
            self?.detailView.hideToastActivity()
            switch result {
            case .success(_):
                print("")
                self?.detailView.makeToast(localLanguage(keyString: "wallet_notification_clean_unread_success"), position: .center)
                self?.detailView.segmentView.reloadData()
            case let .failure(error):
                print(error.localizedDescription)
                self?.handleError(requestType: "", error: error)
            }
        }
    }
    var unreadMessageDataModel: unreadMessagesCountDataModel? {
        didSet {
            var dotStates = [Bool]()
            if let walletMessagesCount = unreadMessageDataModel?.message, walletMessagesCount > 0 {
                dotStates.append(true)
            } else {
                dotStates.append(false)
            }
            if let systemMessagesCount = unreadMessageDataModel?.notice, systemMessagesCount > 0 {
                dotStates.append(true)
            } else {
                dotStates.append(false)
            }
            self.dotStates = dotStates
        }
    }
    private var dotStates: [Bool]?
    private var refreshSegmentIndex: Int = 999
    var successReadClosure: ((unreadMessagesCountDataModel)->Void)?
}
extension NotificationCenterViewController {
    func handleError(requestType: String, error: LibraWalletError) {
        switch error {
        case .WalletRequest(reason: .networkInvalid):
            // 网络无法访问
            print(error.localizedDescription)
        case .WalletRequest(reason: .walletVersionExpired):
            // 版本太久
            print(error.localizedDescription)
        case .WalletRequest(reason: .parseJsonError):
            // 解析失败
            print(error.localizedDescription)
        case .WalletRequest(reason: .dataCodeInvalid):
            // 数据状态异常
            print(error.localizedDescription)
        default:
            // 其他错误
            print(error.localizedDescription)
        }
        self.view?.makeToast(error.localizedDescription, position: .center)
    }
}
extension NotificationCenterViewController {
    func addNavigationRightBar() {
        // 重要方法，用来调整自定义返回view距离左边的距离
        let rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        rightBarButtonItem.width = 15
        
        let notiView = UIBarButtonItem(customView: messageButton)
//         返回按钮设置成功
        self.navigationItem.rightBarButtonItems = [rightBarButtonItem, notiView]
//        self.navigationItem.rightBarButtonItems = [rightBarButtonItem, scanView]
    }

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
        vc.successLoadClosure = { [weak self] in
            if model.readed == 0 {
                self?.walletMessageController.tableViewManager.dataModels?.remove(at: indexPath.row)
                var tempModel = model
                tempModel.readed = 1
                self?.walletMessageController.tableViewManager.dataModels?.insert(tempModel, at: indexPath.row)
                self?.walletMessageController.detailView.tableView.beginUpdates()
                self?.walletMessageController.detailView.tableView.reloadRows(at: [indexPath], with: .none)
                self?.walletMessageController.detailView.tableView.endUpdates()
            }
            self?.clearDotState()
        }
        vc.tokenAddress = Wallet.shared.violasAddress
        vc.violasVersion = model.id
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
extension NotificationCenterViewController: SystemMessagesTableViewManagerDelegate {
    func tableViewDidSelectRowAtIndexPath(indexPath: IndexPath, model: SystemMessagesDataModel) {
        let vc = MessageWebDetailViewController.init()
        vc.messageID = model.id
        vc.successLoadClosure = { [weak self] in
            if model.readed == 0 {
                self?.systemMessageController.tableViewManager.dataModels?.remove(at: indexPath.row)
                var tempModel = model
                tempModel.readed = 1
                self?.systemMessageController.tableViewManager.dataModels?.insert(tempModel, at: indexPath.row)
                self?.systemMessageController.detailView.tableView.beginUpdates()
                self?.systemMessageController.detailView.tableView.reloadRows(at: [indexPath], with: .none)
                self?.systemMessageController.detailView.tableView.endUpdates()
            }
            self?.clearDotState()
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
extension NotificationCenterViewController {
    func clearDotState() {
        if self.detailView.segmentView.selectedIndex == 0 {
            let lastUnread = self.walletMessageController.tableViewManager.dataModels?.filter({
                $0.readed == 0
            })
            self.unreadMessageDataModel?.message = lastUnread?.count
            if lastUnread?.isEmpty == true {
                self.detailView.dotStates?.removeFirst()
                self.detailView.dotStates?.insert(false, at: 0)
                self.detailView.segmentedDataSource.dotStates = self.detailView.dotStates!
                self.refreshSegmentIndex = 0
            }
        } else {
            let lastUnread = self.systemMessageController.tableViewManager.dataModels?.filter({
                $0.readed == 0
            })
            self.unreadMessageDataModel?.notice = lastUnread?.count
            if lastUnread?.isEmpty == true {
                self.detailView.dotStates?.removeLast()
                self.detailView.dotStates?.append(false)
                self.detailView.segmentedDataSource.dotStates = self.detailView.dotStates!
                self.refreshSegmentIndex = 1
            }
        }
    }
}
