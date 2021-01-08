//
//  LoanMarketViewController.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/8/19.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit
import MJRefresh
import JXSegmentedView
protocol LoanMarketViewControllerDelegate: NSObjectProtocol {
    func refreshAccount()
}
class LoanMarketViewController: BaseViewController {
    weak var delegate: LoanMarketViewControllerDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()
        // 设置空数据页面
        self.setEmptyView()
        // 设置默认页面（无数据、无网络）
        self.setPlaceholderView()
    }
    //    override func viewWillLayoutSubviews() {
    //        super.viewWillLayoutSubviews()
    //        detailView.snp.makeConstraints { (make) in
    //            if #available(iOS 11.0, *) {
    //                make.top.bottom.equalTo(self.view.safeAreaLayoutGuide)
    //            } else {
    //                make.top.bottom.equalTo(self.view)
    //            }
    //            make.left.right.equalTo(self.view)
    //        }
    //    }
    deinit {
        print("LoanMarketViewController销毁了")
    }
    // 默认页面
    func setPlaceholderView() {
        if let empty = emptyView as? EmptyDataPlaceholderView {
            empty.emptyImageName = "transaction_list_empty_default"
            empty.tipString = localLanguage(keyString: "wallet_transactions_empty_default_title")
        }
    }
    // 网络请求
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
    
    /// 网络请求、数据模型
    lazy var dataModel: LoanMarketModel = {
        let model = LoanMarketModel.init()
        return model
    }()
    /// tableView管理类
    lazy var tableViewManager: LoanMarketTableViewManager = {
        let manager = LoanMarketTableViewManager.init()
        return manager
    }()
    /// 子View
    lazy var detailView : LoanMarketView = {
        let view = LoanMarketView.init()
        view.tableView.delegate = self.tableViewManager
        view.tableView.dataSource = self.tableViewManager
        view.tableView.mj_header = MJRefreshNormalHeader.init(refreshingTarget: self, refreshingAction:  #selector(refreshData))
//        view.tableView.mj_footer = MJRefreshBackNormalFooter.init(refreshingTarget: self, refreshingAction:  #selector(getMoreData))
        return view
    }()
    /// 数据监听KVO
    var observer: NSKeyValueObservation?
    /// 页数
    var dataOffset: Int = 0
    /// 防止多次点击
    var firstIn: Bool = true
}
// MARK: - 网络请求
extension LoanMarketViewController {
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
        let requestState = refresh == true ? 0:1
        if refresh == true {
            self.delegate?.refreshAccount()
        }
        self.dataModel.getLoanMarket(requestStatus: requestState)
    }
}
// MARK: - 网络请求数据处理
extension LoanMarketViewController {
    func initKVO() {
        self.observer = dataModel.observe(\.dataDic, options: [.new], changeHandler: { [weak self](model, change) in
            guard let dataDic = change.newValue, dataDic.count != 0 else {
                self?.detailView.hideToastActivity()
                self?.endLoading()
                return
            }
            if let error = dataDic.value(forKey: "error") as? LibraWalletError {
                // 隐藏请求指示
                if self?.detailView.tableView.mj_header?.isRefreshing == true {
                    self?.detailView.tableView.mj_header?.endRefreshing()
                }
                if error.localizedDescription == LibraWalletError.WalletRequest(reason: .networkInvalid).localizedDescription {
                    // 网络无法访问
                    print(error.localizedDescription)
                    if self?.detailView.tableView.mj_footer?.isRefreshing == true {
                        self?.detailView.tableView.mj_footer?.endRefreshing()
                    }
                    self?.detailView.makeToast(error.localizedDescription, position: .center)
                } else if error.localizedDescription == LibraWalletError.WalletRequest(reason: .walletVersionExpired).localizedDescription {
                    // 版本太久
                    print(error.localizedDescription)
                    if self?.detailView.tableView.mj_footer?.isRefreshing == true {
                        self?.detailView.tableView.mj_footer?.endRefreshing()
                    }
                    self?.detailView.makeToast(error.localizedDescription, position: .center)
                } else if error.localizedDescription == LibraWalletError.WalletRequest(reason: .parseJsonError).localizedDescription {
                    // 解析失败
                    print(error.localizedDescription)
                    if self?.detailView.tableView.mj_footer?.isRefreshing == true {
                        self?.detailView.tableView.mj_footer?.endRefreshing()
                    }
                    self?.detailView.makeToast(error.localizedDescription, position: .center)
                } else if error.localizedDescription == LibraWalletError.WalletRequest(reason: .dataCodeInvalid).localizedDescription {
                    // 数据状态异常
                    print(error.localizedDescription)
                    if self?.detailView.tableView.mj_footer?.isRefreshing == true {
                        self?.detailView.tableView.mj_footer?.endRefreshing()
                    }
                    self?.detailView.makeToast(error.localizedDescription, position: .center)
                } else if error.localizedDescription == LibraWalletError.WalletRequest(reason: .dataEmpty).localizedDescription {
                    // 下拉刷新请求数据为空
                    print(error.localizedDescription)
                    //                    self?.endLoading()
                } else if error.localizedDescription == LibraWalletError.WalletRequest(reason: .noMoreData).localizedDescription {
                    // 上拉请求更多数据为空
                    print(error.localizedDescription)
                    if self?.detailView.tableView.mj_footer?.isRefreshing == true {
                        self?.detailView.tableView.mj_footer?.endRefreshingWithNoMoreData()
                    }
                } else {
                    // 其他错误
                    print(error.localizedDescription)
                    if self?.detailView.tableView.mj_footer?.isRefreshing == true {
                        self?.detailView.tableView.mj_footer?.endRefreshing()
                    }
                    self?.detailView.makeToast(error.localizedDescription, position: .center)
                }
                return
            }
            let type = dataDic.value(forKey: "type") as! String
            if type == "GetBankLoanMarketOrigin" {
                guard let tempData = dataDic.value(forKey: "data") as? [BankDepositMarketDataModel] else {
                    return
                }
                self?.tableViewManager.dataModels = tempData
                self?.detailView.tableView.reloadData()
                self?.detailView.tableView.mj_header?.endRefreshing()
            } else if type == "GetBankLoanMarketMore" {
                guard let tempData = dataDic.value(forKey: "data") as? [BankDepositMarketDataModel] else {
                    return
                }
                if let oldData = self?.tableViewManager.dataModels, oldData.isEmpty == false {
                    var insertIndexPath = [IndexPath]()
                    for index in 0..<tempData.count {
                        let indexPath = IndexPath.init(row: oldData.count + index, section: 0)
                        insertIndexPath.append(indexPath)
                    }
                    self?.tableViewManager.dataModels = (oldData + tempData)
                    self?.detailView.tableView.beginUpdates()
                    self?.detailView.tableView.insertRows(at: insertIndexPath, with: UITableView.RowAnimation.bottom)
                    self?.detailView.tableView.endUpdates()
                } else {
                    self?.tableViewManager.dataModels = tempData
                    self?.detailView.tableView.reloadData()
                }
                self?.detailView.tableView.mj_footer?.endRefreshing()
            }
            self?.endLoading()
        })
    }
}
extension LoanMarketViewController: JXSegmentedListContainerViewListDelegate {
    func listView() -> UIView {
        return self.detailView
    }
    // 可选实现，列表显示的时候调用
    func listDidAppear() {
        //防止重复加载数据
        guard firstIn == true else {
            return
        }
        if (lastState == .Loading) {return}
        startLoading ()
        //                self.detailView.makeToastActivity(.center)
        self.detailView.tableView.mj_header?.beginRefreshing()
        firstIn = false
    }
    // 可选实现，列表消失的时候调用
    func listDidDisappear() {
        
    }
}
