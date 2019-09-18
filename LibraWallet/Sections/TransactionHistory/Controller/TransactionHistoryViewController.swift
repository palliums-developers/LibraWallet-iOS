//
//  TransactionHistoryViewController.swift
//  LibraWallet
//
//  Created by palliums on 2019/9/17.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit
import MJRefresh
class TransactionHistoryViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // 初始化本地配置
//        self.setBaseControlllerConfig()
        // 设置标题
        self.title = "交易历史"//localLanguage(keyString: "wallet_balance_detail_navigationbar_title")
        // 加载子View
        self.view.addSubview(detailView)
        // 初始化KVO
        self.initKVO()
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        detailView.snp.makeConstraints { (make) in
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(self.view.safeAreaLayoutGuide)
            } else {
                make.bottom.equalTo(self.view)
            }
            make.top.left.right.equalTo(self.view)
        }
    }
    
    //网络请求、数据模型
    lazy var dataModel: TransactionHistoryModel = {
        let model = TransactionHistoryModel.init()
        return model
    }()
    //tableView管理类
    lazy var tableViewManager: TransactionHistoryViewTableViewManager = {
        let manager = TransactionHistoryViewTableViewManager.init()
        manager.delegate = self
        return manager
    }()
    //子View
    private lazy var detailView : TransactionHistoryView = {
        let view = TransactionHistoryView.init()
        view.tableView.delegate = self.tableViewManager
        view.tableView.dataSource = self.tableViewManager
        view.tableView.mj_header = MJRefreshNormalHeader.init(refreshingTarget: self, refreshingAction:  #selector(refreshReceive))
        view.tableView.mj_footer = MJRefreshBackNormalFooter.init(refreshingTarget: self, refreshingAction:  #selector(getMoreReceive))
        return view
    }()
    @objc func refreshReceive() {
        dataOffset = 0
        self.detailView.tableView.mj_footer.resetNoMoreData()
        self.detailView.tableView.mj_header.beginRefreshing()
        self.dataModel.getTransactionHistory(address: LibraWalletManager.wallet.walletAddress!, offset: 0, requestStatus: 0)
    }
    @objc func getMoreReceive() {
        dataOffset += 10
        self.detailView.tableView.mj_footer.beginRefreshing()
        self.dataModel.getTransactionHistory(address: LibraWalletManager.wallet.walletAddress!, offset: dataOffset, requestStatus: 1)
    }
    var dataOffset: Int = 0
    deinit {
        print("BalanceHistoryViewController销毁了")
    }
    var myContext = 0
}
extension TransactionHistoryViewController {
    //MARK: - KVO
    func initKVO() {
        dataModel.addObserver(self, forKeyPath: "dataDic", options: NSKeyValueObservingOptions.new, context: &myContext)
        self.view.makeToastActivity(.center)
        self.dataModel.getTransactionHistory(address: LibraWalletManager.wallet.walletAddress!, offset: 0, requestStatus: 0)
    }
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?)  {
        guard context == &myContext else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }
        guard (change?[NSKeyValueChangeKey.newKey]) != nil else {
            return
        }
        guard let jsonData = (object! as AnyObject).value(forKey: "dataDic") as? NSDictionary else {
            return
        }
        let type = jsonData.value(forKey: "type") as! String
        if let error = jsonData.value(forKey: "error") as? LibraWalletError {
            if error.localizedDescription == LibraWalletError.WalletRequestError(reason: .networkInvalid).localizedDescription {
                // 网络无法访问
                print(error.localizedDescription)
            } else if error.localizedDescription == LibraWalletError.WalletRequestError(reason: .walletNotExist).localizedDescription {
                // 钱包不存在
                print(error.localizedDescription)
                let vc = WalletCreateViewController()
                let navi = UINavigationController.init(rootViewController: vc)
                self.present(navi, animated: true, completion: nil)
            } else if error.localizedDescription == LibraWalletError.WalletRequestError(reason: .walletVersionTooOld).localizedDescription {
                // 版本太久
                print(error.localizedDescription)
            } else if error.localizedDescription == LibraWalletError.WalletRequestError(reason: .parseJsonError).localizedDescription {
                // 解析失败
                print(error.localizedDescription)
            } else if error.localizedDescription == LibraWalletError.WalletRequestError(reason: .dataEmpty).localizedDescription {
                print(error.localizedDescription)
                // 没有更多数据
                if type == "BalanceMore" {
                    self.detailView.tableView.mj_footer.endRefreshingWithNoMoreData()
                }
            }
            self.view.hideToastActivity()
            self.detailView.tableView.mj_header.endRefreshing()
//            showAlert(view: self.view, content: error.localizedDescription)
//            self.endLoading()
            return
        }
        if type == "TransactionHistoryOrigin" {
            if let tempData = jsonData.value(forKey: "data") as? [Transaction] {
                self.tableViewManager.dataModel = tempData
                self.detailView.tableView.reloadData()
            }
        } else if type == "TransactionHistoryMore" {
//            if let tempData = jsonData.value(forKey: "data") as? [BalanceHistoryOrder] {
//                if let oldData = self.tableViewManager.dataModel, oldData.isEmpty == false {
//                    let tempArray = NSMutableArray.init(array: oldData)
//                    let insertIndexPath = NSMutableArray()
//                    for index in 0..<tempData.count {
//                        let indexPath = IndexPath.init(row: oldData.count + index, section: 0)
//                        insertIndexPath.add(indexPath)
//                    }
//                    tempArray.addObjects(from: tempData)
//                    self.tableViewManager.dataModel = tempArray as? [BalanceHistoryOrder]
//                    self.detailView.tableView.beginUpdates()
//                    self.detailView.tableView.insertRows(at: insertIndexPath as! [IndexPath], with: UITableView.RowAnimation.bottom)
//                    self.detailView.tableView.endUpdates()
//                } else {
//                    self.tableViewManager.dataModel = tempData
//                    self.detailView.tableView.reloadData()
//                }
//            }
        }
        self.view.hideToastActivity()
        self.detailView.tableView.mj_header.endRefreshing()
        self.detailView.tableView.mj_footer.endRefreshing()
//        self.endLoading()
    }
}
extension TransactionHistoryViewController: TransactionHistoryViewTableViewManagerDelegate {
    func tableViewDidSelectRowAtIndexPath(indexPath: IndexPath, url: String) {
        let vc = TransactionDetailWebViewController()
        vc.requestURL = url
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
}
