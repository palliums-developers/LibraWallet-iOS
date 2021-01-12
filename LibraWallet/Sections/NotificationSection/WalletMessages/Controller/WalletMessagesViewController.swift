//
//  WalletMessagesViewController.swift
//  LibraWallet
//
//  Created by wangyingdong on 2021/1/11.
//  Copyright © 2021 palliums. All rights reserved.
//

import UIKit
import MJRefresh
import JXSegmentedView

class WalletMessagesViewController: BaseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(self.detailView)
        // 设置空数据页面
        self.setEmptyView()
        // 设置默认页面（无数据、无网络）
        self.setPlaceholderView()
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        detailView.snp.makeConstraints { (make) in
            make.top.left.right.bottom.equalTo(self.view.safeAreaLayoutGuide)
        }
    }
    deinit {
        print("WalletMessagesViewController销毁了")
    }
    // 网络请求
    func requestData() {
        if (lastState == .Loading) {return}
        startLoading ()
        self.detailView.makeToastActivity(.center)
        
        transactionRequest(refresh: true)
    }
    // 默认页面
    func setPlaceholderView() {
        if let empty = emptyView as? EmptyDataPlaceholderView {
            empty.emptyImageName = "notification_empty"
            empty.tipString = localLanguage(keyString: "wallet_notification_empty_default_title")
//            empty.edge = UIEdgeInsets.init(top: 29, left: 0, bottom: 0, right: 0)
        }
    }
    override func hasContent() -> Bool {
        if let models = self.tableViewManager.dataModels, models.isEmpty == false {
            return true
        } else {
            return false
        }
    }
    /// 网络请求、数据模型
    lazy var dataModel: WalletMessagesModel = {
        let model = WalletMessagesModel.init()
        return model
    }()
    /// tableView管理类
    lazy var tableViewManager: WalletMessagesTableViewManager = {
        let manager = WalletMessagesTableViewManager.init()
        return manager
    }()
    /// 子View
    lazy var detailView : WalletMessagesView = {
        let view = WalletMessagesView.init()
        view.tableView.delegate = self.tableViewManager
        view.tableView.dataSource = self.tableViewManager
        view.tableView.mj_header = MJRefreshNormalHeader.init(refreshingTarget: self, refreshingAction:  #selector(refreshData))
        view.tableView.mj_footer = MJRefreshBackNormalFooter.init(refreshingTarget: self, refreshingAction:  #selector(getMoreData))
        return view
    }()
    /// 页数
    var dataOffset: Int = 0
    /// 防止多次点击
    var firstIn: Bool = true
}
// MARK: - 网络请求
extension WalletMessagesViewController {
    @objc func refreshData() {
        dataOffset = 0
        detailView.tableView.mj_footer?.resetNoMoreData()
        transactionRequest(refresh: true)
    }
    @objc func getMoreData() {
        dataOffset += 10
        transactionRequest(refresh: false)
    }
    func transactionRequest(refresh: Bool) {
        self.dataModel.getWalletMessages(address: "", limit: dataOffset, count: 10, refresh: refresh) { [weak self] (result) in
            switch result {
            case let .success(models):
                if refresh == true {
                    guard models.isEmpty == false else {
                        self?.detailView.hideToastActivity()
                        self?.tableViewManager.dataModels?.removeAll()
                        self?.detailView.tableView.reloadData()
                        self?.detailView.tableView.mj_header?.endRefreshing()
                        self?.endLoading()
                        return
                    }
                    self?.detailView.hideToastActivity()
                    // 下拉刷新
                    self?.tableViewManager.dataModels = models
                    self?.detailView.tableView.reloadData()
                    self?.detailView.tableView.mj_header?.endRefreshing()
                } else {
                    // 上拉刷新
                    guard models.isEmpty == false else {
                        self?.detailView.tableView.mj_footer?.endRefreshingWithNoMoreData()
                        return
                    }
                    guard let oldData = self?.tableViewManager.dataModels, oldData.isEmpty == false else {
                        self?.tableViewManager.dataModels = models
                        self?.detailView.tableView.reloadData()
                        return
                    }
                    var insertIndexPath = [IndexPath]()
                    for index in 0..<models.count {
                        let indexPath = IndexPath.init(row: oldData.count + index, section: 0)
                        insertIndexPath.append(indexPath)
                    }
                    self?.tableViewManager.dataModels = oldData + models
                    self?.detailView.tableView.beginUpdates()
                    self?.detailView.tableView.insertRows(at: insertIndexPath, with: UITableView.RowAnimation.bottom)
                    self?.detailView.tableView.endUpdates()
                    self?.detailView.tableView.mj_footer?.endRefreshing()
                }
            case let .failure(error):
                self?.detailView.hideToastActivity()
                if refresh == true {
                    if self?.detailView.tableView.mj_header?.isRefreshing == true {
                        self?.detailView.tableView.mj_header?.endRefreshing()
                    }
                } else {
                    if self?.detailView.tableView.mj_footer?.isRefreshing == true {
                        self?.detailView.tableView.mj_footer?.endRefreshing()
                    }
                }
                self?.handleError(requestType: "", error: error)
            }
            self?.endLoading()
        }
    }
}
// MARK: - 网络请求数据处理
extension WalletMessagesViewController {
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
extension WalletMessagesViewController: JXSegmentedListContainerViewListDelegate {
    func listView() -> UIView {
        return self.view
    }
    // 可选实现，列表显示的时候调用
    func listDidAppear() {
        //防止重复加载数据
        guard firstIn == true else {
            return
        }
        self.requestData()
        firstIn = false
    }
    // 可选实现，列表消失的时候调用
    func listDidDisappear() {
        
    }
}
