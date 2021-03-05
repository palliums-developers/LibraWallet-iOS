//
//  LoanOrdersViewController.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/8/24.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit
import StatefulViewController
import MJRefresh

class LoanOrdersViewController: BaseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.init(hex: "F7F7F9")
        self.view.addSubview(self.detailView)
        // 添加导航栏按钮
        self.addNavigationRightBar()
        // 初始化本地配置
        self.setNavigationWithoutShadowImage()
        // 设置标题
        self.title = localLanguage(keyString: "wallet_bank_loan_orders_navigationbar_title")
        // 设置空数据页面
        self.setEmptyView()
        // 设置默认页面（无数据、无网络）
        self.setPlaceholderView()

        self.requestData()
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        detailView.snp.makeConstraints { (make) in
            if #available(iOS 11.0, *) {
                make.top.bottom.equalTo(self.view.safeAreaLayoutGuide)
            } else {
                make.top.bottom.equalTo(self.view)
            }
            make.left.right.equalTo(self.view)
        }
    }
    //MARK: - 默认页面
    func setPlaceholderView() {
        if let empty = emptyView as? EmptyDataPlaceholderView {
            empty.emptyImageName = "data_empty"
            empty.tipString = localLanguage(keyString: "wallet_bank_loan_orders_empty_title")
        }
    }
    //MARK: - 网络请求
    func requestData() {
        if (lastState == .Loading) {return}
        startLoading ()
        self.detailView.makeToastActivity(.center)
        
        transactionRequest(refresh: true)
    }
    override func hasContent() -> Bool {
        if let models = self.tableViewManager.dataModels, models.isEmpty == false {
            return true
        } else {
            return false
        }
    }
    deinit {
        print("LoanOrdersViewController销毁了")
    }
    // 网络请求、数据模型
    lazy var dataModel: LoanOrdersModel = {
        let model = LoanOrdersModel.init()
        return model
    }()
    // tableView管理类
    lazy var tableViewManager: LoanOrdersTableViewManager = {
        let manager = LoanOrdersTableViewManager.init()
        manager.delegate = self
        return manager
    }()
    // 子View
    lazy var detailView : LoanOrdersView = {
        let view = LoanOrdersView.init()
        view.tableView.delegate = self.tableViewManager
        view.tableView.dataSource = self.tableViewManager
        view.tableView.mj_header = MJRefreshNormalHeader.init(refreshingTarget: self, refreshingAction:  #selector(refreshData))
        view.tableView.mj_footer = MJRefreshBackNormalFooter.init(refreshingTarget: self, refreshingAction:  #selector(getMoreData))
        return view
    }()
    var dataOffset: Int = 0
    @objc func refreshData() {
        dataOffset = 0
        detailView.tableView.mj_footer?.resetNoMoreData()
        transactionRequest(refresh: true)
    }
    @objc func getMoreData() {
        dataOffset += 10
        transactionRequest(refresh: false)
    }
    var firstIn: Bool = true
    /// 二维码扫描按钮
    lazy var depositOrderListButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage.init(named: "deposit_order_list"), for: UIControl.State.normal)
        button.addTarget(self, action: #selector(checkOrder), for: .touchUpInside)
        return button
    }()
    func transactionRequest(refresh: Bool) {
        self.dataModel.getLoanTransactions(address: Wallet.shared.violasAddress!, page: self.dataOffset, limit: 10, refresh: refresh) { [weak self] (result) in
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
extension LoanOrdersViewController {
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
//MARK: - 导航栏添加按钮
extension LoanOrdersViewController {
    func addNavigationRightBar() {
        let scanView = UIBarButtonItem(customView: depositOrderListButton)
        // 重要方法，用来调整自定义返回view距离左边的距离
        let rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        rightBarButtonItem.width = 15
        // 返回按钮设置成功
        self.navigationItem.rightBarButtonItems = [rightBarButtonItem, scanView]
    }
    @objc func checkOrder() {
        let vc = LoanListViewController.init()
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
extension LoanOrdersViewController: LoanOrdersTableViewManagerDelegate {
    func tableViewDidSelectRowAtIndexPath(indexPath: IndexPath, model: LoanOrdersMainDataModel) {
        let vc = LoanOrderDetailViewController()
        vc.itemID = model.id
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
