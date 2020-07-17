//
//  AssetsPoolTransactionsViewController.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/7/14.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit
import MJRefresh
class AssetsPoolTransactionsViewController: BaseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        // 加载子View
        self.view.addSubview(detailView)
        // 初始化KVO
        self.initKVO()
        // 请求数据
        self.detailView.tableView.mj_header?.beginRefreshing()
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
    /// 网络请求、数据模型
    lazy var dataModel: AssetsPoolTransactionsModel = {
        let model = AssetsPoolTransactionsModel.init()
        return model
    }()
    /// tableView管理类
    lazy var tableViewManager: AssetsPoolTransactionsTableViewManager = {
        let manager = AssetsPoolTransactionsTableViewManager.init()
        manager.delegate = self
        return manager
    }()
    /// 子View
    lazy var detailView : AssetsPoolTransactionsView = {
        let view = AssetsPoolTransactionsView.init()
        view.tableView.delegate = self.tableViewManager
        view.tableView.dataSource = self.tableViewManager
        view.tableView.mj_header = MJRefreshNormalHeader.init(refreshingTarget: self, refreshingAction:  #selector(refreshData))
        view.tableView.mj_footer = MJRefreshBackNormalFooter.init(refreshingTarget: self, refreshingAction:  #selector(getMoreData))
        return view
    }()
    /// 数据监听KVO
    var observer: NSKeyValueObservation?
    var dataOffset: Int = 0
    @objc func refreshData() {
        dataOffset = 0
        detailView.tableView.mj_footer?.resetNoMoreData()
        self.dataModel.getAssetsPoolTransactions(address: "fa279f2615270daed6061313a48360f7", page: dataOffset, pageSize: 10, requestStatus: 0)
    }
    @objc func getMoreData() {
        dataOffset += 10
        self.dataModel.getAssetsPoolTransactions(address: "fa279f2615270daed6061313a48360f7", page: dataOffset, pageSize: 10, requestStatus: 1)
    }
}
extension AssetsPoolTransactionsViewController: AssetsPoolTransactionsTableViewManagerDelegate {
    func tableViewDidSelectRowAtIndexPath(indexPath: IndexPath, model: AssetsPoolTransactionsDataModel) {
        let vc = AssetsPoolTransactionDetailViewController()
        vc.model = model
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
extension AssetsPoolTransactionsViewController {
    func initKVO() {
        self.observer = dataModel.observe(\.dataDic, options: [.new], changeHandler: { [weak self](model, change) in
            guard let dataDic = change.newValue, dataDic.count != 0 else {
                self?.detailView.hideToastActivity()
                return
            }
            if let error = dataDic.value(forKey: "error") as? LibraWalletError {
                // 隐藏请求指示
                self?.detailView.hideToastActivity()
                if self?.detailView.tableView.mj_footer?.isRefreshing == true {
                    self?.detailView.tableView.mj_footer?.endRefreshingWithNoMoreData()
                }
                if self?.detailView.tableView.mj_header?.isRefreshing == true {
                    self?.detailView.tableView.mj_header?.endRefreshing()
                }
                if error.localizedDescription == LibraWalletError.WalletRequest(reason: .networkInvalid).localizedDescription {
                    // 网络无法访问
                    print(error.localizedDescription)
                    self?.detailView.makeToast(error.localizedDescription,
                                               position: .center)
                } else if error.localizedDescription == LibraWalletError.WalletRequest(reason: .walletVersionExpired).localizedDescription {
                    // 版本太久
                    print(error.localizedDescription)
                    self?.detailView.makeToast(error.localizedDescription,
                                               position: .center)
                } else if error.localizedDescription == LibraWalletError.WalletRequest(reason: .parseJsonError).localizedDescription {
                    // 解析失败
                    print(error.localizedDescription)
                    self?.detailView.makeToast(error.localizedDescription,
                                               position: .center)
                } else if error.localizedDescription == LibraWalletError.WalletRequest(reason: .dataCodeInvalid).localizedDescription {
                    print(error.localizedDescription)
                    // 数据状态异常
                    self?.detailView.makeToast(error.localizedDescription,
                                               position: .center)
                } else if error.localizedDescription == LibraWalletError.WalletRequest(reason: .dataEmpty).localizedDescription {
                    print(error.localizedDescription)
                    // 下拉刷新请求数据为空
                    self?.tableViewManager.dataModels?.removeAll()
                    self?.detailView.tableView.reloadData()
                    self?.detailView.makeToast(error.localizedDescription,
                                               position: .center)
                } else if error.localizedDescription == LibraWalletError.WalletRequest(reason: .noMoreData).localizedDescription {
                    // 上拉请求更多数据为空
                    print(error.localizedDescription)
                    self?.detailView.tableView.mj_footer?.endRefreshingWithNoMoreData()
                } else {
                    self?.detailView.makeToast(error.localizedDescription,
                                               position: .center)
                }
                return
            }
            let type = dataDic.value(forKey: "type") as! String
            if type == "AssetsPoolTransactionsOrigin" {
                guard let tempData = dataDic.value(forKey: "data") as? [AssetsPoolTransactionsDataModel] else {
                    return
                }
                self?.tableViewManager.dataModels = tempData
                self?.detailView.tableView.reloadData()
            } else if type == "AssetsPoolTransactionsMore" {
                guard let tempData = dataDic.value(forKey: "data") as? [AssetsPoolTransactionsDataModel] else {
                    return
                }
                if let oldData = self?.tableViewManager.dataModels, oldData.isEmpty == false {
                    let tempArray = NSMutableArray.init(array: oldData)
                    var insertIndexPath = [IndexPath]()
                    for index in 0..<tempData.count {
                        let indexPath = IndexPath.init(row: oldData.count + index, section: 0)
                        insertIndexPath.append(indexPath)
                    }
                    tempArray.addObjects(from: tempData)
                    self?.tableViewManager.dataModels = tempArray as? [AssetsPoolTransactionsDataModel]
                    self?.detailView.tableView.beginUpdates()
                    self?.detailView.tableView.insertRows(at: insertIndexPath, with: UITableView.RowAnimation.bottom)
                    self?.detailView.tableView.endUpdates()
                } else {
                    self?.tableViewManager.dataModels = tempData
                    self?.detailView.tableView.reloadData()
                }
                self?.detailView.tableView.mj_footer?.endRefreshing()
            }
            self?.detailView.hideToastActivity()
            self?.detailView.tableView.mj_header?.endRefreshing()
        })
    }
}
