//
//  LoanDetailLoanListViewController.swift
//  ViolasWallet
//
//  Created by wangyingdong on 2020/8/24.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit
import MJRefresh
import JXSegmentedView

class LoanDetailLoanListViewController: BaseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // 初始化本地配置
        self.setNavigationWithoutShadowImage()
        // 设置标题
        self.title = localLanguage(keyString: "wallet_transactions_navigation_title")
        //设置空数据页面
        self.setEmptyView()
        //设置默认页面（无数据、无网络）
        self.setPlaceholderView()
    }
    //MARK: - 默认页面
    func setPlaceholderView() {
        if let empty = emptyView as? EmptyDataPlaceholderView {
            empty.emptyImageName = "transaction_list_empty_default"
            empty.tipString = localLanguage(keyString: "wallet_transactions_empty_default_title")
        }
    }
    //MARK: - 网络请求
    func requestData() {
        if (lastState == .Loading) {return}
        startLoading ()
        //        self.detailView.makeToastActivity(.center)
        
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
        print("LoanDetailLoanListViewController销毁了")
    }
    /// 网络请求、数据模型
    lazy var dataModel: LoanDetailLoanListModel = {
        let model = LoanDetailLoanListModel.init()
        return model
    }()
    /// tableView管理类
    lazy var tableViewManager: LoanDetailLoanListTableViewManager = {
        let manager = LoanDetailLoanListTableViewManager.init()
        //        manager.delegate = self
        return manager
    }()
    /// 子View
    lazy var detailView : LoanDetailLoanListView = {
        let view = LoanDetailLoanListView.init()
        view.tableView.delegate = self.tableViewManager
        view.tableView.dataSource = self.tableViewManager
        view.tableView.mj_header = MJRefreshNormalHeader.init(refreshingTarget: self, refreshingAction:  #selector(refreshData))
        view.tableView.mj_footer = MJRefreshBackNormalFooter.init(refreshingTarget: self, refreshingAction:  #selector(getMoreData))
        return view
    }()
    ///
    var observer: NSKeyValueObservation?
    /// 页数
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
    var itemID: String?
    var updateAction: ((LoanOrderDetailMainDataModel)->())?
    func transactionRequest(refresh: Bool) {
        let requestState = refresh == true ? 0:1
        self.dataModel.getLoanOrderDetailLoanList(address: Wallet.shared.violasAddress ?? "",
                                                  orderID: itemID ?? "",
                                                  page: dataOffset,
                                                  limit: 10,
                                                  requestStatus: requestState)
    }
}
extension LoanDetailLoanListViewController {
    func initKVO() {
        self.observer = dataModel.observe(\.dataDic, options: [.new], changeHandler: { [weak self](model, change) in
            guard let dataDic = change.newValue, dataDic.count != 0 else {
                self?.detailView.hideToastActivity()
                self?.endLoading()
                return
            }
            let type = dataDic.value(forKey: "type") as! String
            if let error = dataDic.value(forKey: "error") as? LibraWalletError {
                self?.handleError(requestType: type, error: error)
                return
            }
            if type == "GetBankLoanOrderDetailLoanListOrigin" {
                guard let tempData = dataDic.value(forKey: "data") as? LoanOrderDetailMainDataModel else {
                    return
                }
                self?.tableViewManager.dataModels = tempData.list
                if let action = self?.updateAction {
                    action(tempData)
                }
                self?.detailView.tableView.reloadData()
            } else if type == "GetBankLoanOrderDetailLoanListMore" {
                guard let tempData = dataDic.value(forKey: "data") as? LoanOrderDetailMainDataModel else {
                    return
                }
                if let oldData = self?.tableViewManager.dataModels, oldData.isEmpty == false {
                    let tempArray = NSMutableArray.init(array: oldData)
                    var insertIndexPath = [IndexPath]()
                    for index in 0..<tempData.list!.count {
                        let indexPath = IndexPath.init(row: oldData.count + index, section: 0)
                        insertIndexPath.append(indexPath)
                    }
                    tempArray.addObjects(from: tempData.list!)
                    self?.tableViewManager.dataModels = tempArray as? [LoanOrderDetailMainDataListModel]
                    self?.detailView.tableView.beginUpdates()
                    self?.detailView.tableView.insertRows(at: insertIndexPath, with: UITableView.RowAnimation.bottom)
                    self?.detailView.tableView.endUpdates()
                } else {
                    self?.tableViewManager.dataModels = tempData.list
                    self?.detailView.tableView.reloadData()
                }
                self?.detailView.tableView.mj_footer?.endRefreshing()
            }
            self?.detailView.tableView.mj_footer?.endRefreshing()
            self?.detailView.hideToastActivity()
            self?.detailView.tableView.mj_header?.endRefreshing()
            self?.endLoading()
        })
    }
    func handleError(requestType: String, error: LibraWalletError) {
        // 隐藏请求指示
        self.detailView.hideToastActivity()
        // 隐藏下拉刷新状态
        if self.detailView.tableView.mj_header?.isRefreshing == true {
            self.detailView.tableView.mj_header?.endRefreshing()
        }
        if error.localizedDescription == LibraWalletError.WalletRequest(reason: .networkInvalid).localizedDescription {
            // 网络无法访问
            print(error.localizedDescription)
            if self.detailView.tableView.mj_footer?.isRefreshing == true {
                self.detailView.tableView.mj_footer?.endRefreshing()
            }
            self.detailView.makeToast(error.localizedDescription, position: .center)
        } else if error.localizedDescription == LibraWalletError.WalletRequest(reason: .walletVersionExpired).localizedDescription {
            // 版本太久
            print(error.localizedDescription)
            if self.detailView.tableView.mj_footer?.isRefreshing == true {
                self.detailView.tableView.mj_footer?.endRefreshing()
            }
            self.detailView.makeToast(error.localizedDescription, position: .center)
        } else if error.localizedDescription == LibraWalletError.WalletRequest(reason: .parseJsonError).localizedDescription {
            // 解析失败
            print(error.localizedDescription)
            if self.detailView.tableView.mj_footer?.isRefreshing == true {
                self.detailView.tableView.mj_footer?.endRefreshing()
            }
            self.detailView.makeToast(error.localizedDescription, position: .center)
        } else if error.localizedDescription == LibraWalletError.WalletRequest(reason: .dataCodeInvalid).localizedDescription {
            print(error.localizedDescription)
            // 数据状态异常
            if self.detailView.tableView.mj_footer?.isRefreshing == true {
                self.detailView.tableView.mj_footer?.endRefreshing()
            }
            self.detailView.makeToast(error.localizedDescription, position: .center)
        } else if error.localizedDescription == LibraWalletError.WalletRequest(reason: .dataEmpty).localizedDescription {
            print(error.localizedDescription)
            // 下拉刷新请求数据为空
            self.tableViewManager.dataModels?.removeAll()
            self.detailView.tableView.reloadData()
            self.detailView.makeToast(error.localizedDescription, position: .center)
        } else if error.localizedDescription == LibraWalletError.WalletRequest(reason: .noMoreData).localizedDescription {
            // 上拉请求更多数据为空
            print(error.localizedDescription)
            if self.detailView.tableView.mj_footer?.isRefreshing == true {
                self.detailView.tableView.mj_footer?.endRefreshingWithNoMoreData()
            }
        } else {
            if self.detailView.tableView.mj_footer?.isRefreshing == true {
                self.detailView.tableView.mj_footer?.endRefreshing()
            }
            self.detailView.makeToast(error.localizedDescription, position: .center)
        }
        self.endLoading()
    }
}
extension LoanDetailLoanListViewController: JXSegmentedListContainerViewListDelegate {
    func listView() -> UIView {
        return self.detailView
    }
    /// 可选实现，列表显示的时候调用
    func listDidAppear() {
        //防止重复加载数据
        guard firstIn == true else {
            return
        }
        if (lastState == .Loading) {return}
        startLoading ()
        //        self.detailView.makeToastActivity(.center)
//        transactionRequest(refresh: true)
        self.detailView.tableView.mj_header?.beginRefreshing()
        firstIn = false
    }
    /// 可选实现，列表消失的时候调用
    func listDidDisappear() {
        
    }
}
