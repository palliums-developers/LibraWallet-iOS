//
//  WalletTransactionsViewModel.swift
//  LibraWallet
//
//  Created by palliums on 2019/10/29.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit
import MJRefresh
class WalletTransactionsViewModel: NSObject {
    var myContext = 0
    func initKVO() {
        dataModel.addObserver(self, forKeyPath: "dataDic", options: NSKeyValueObservingOptions.new, context: &myContext)
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
        if let error = jsonData.value(forKey: "error") as? LibraWalletError {
            if error.localizedDescription == LibraWalletError.WalletRequest(reason: .networkInvalid).localizedDescription {
                // 网络无法访问
                print(error.localizedDescription)
            } else if error.localizedDescription == LibraWalletError.WalletRequest(reason: .walletNotExist).localizedDescription {
                // 钱包不存在
                print(error.localizedDescription)
//                let vc = WalletCreateViewController()
//                let navi = UINavigationController.init(rootViewController: vc)
//                self.present(navi, animated: true, completion: nil)
            } else if error.localizedDescription == LibraWalletError.WalletRequest(reason: .walletVersionTooOld).localizedDescription {
                // 版本太久
                print(error.localizedDescription)
            } else if error.localizedDescription == LibraWalletError.WalletRequest(reason: .parseJsonError).localizedDescription {
                // 解析失败
                print(error.localizedDescription)
            } else if error.localizedDescription == LibraWalletError.WalletRequest(reason: .dataEmpty).localizedDescription {
                print(error.localizedDescription)
                // 数据为空
            }
            self.detailView.hideToastActivity()
            return
        }
        let type = jsonData.value(forKey: "type") as! String
        if type == "BTCTransactionHistoryOrigin" {
            guard let tempData = jsonData.value(forKey: "data") as? [BTCTransaction] else {
                return
            }
            self.tableViewManager.btcTransactions = tempData
            self.detailView.tableView.reloadData()
        } else if type == "BTCTransactionHistoryMore" {
            guard let tempData = jsonData.value(forKey: "data") as? [BTCTransaction] else {
                return
            }
            if let oldData = self.tableViewManager.btcTransactions, oldData.isEmpty == false {
                let tempArray = NSMutableArray.init(array: oldData)
                var insertIndexPath = [IndexPath]()

                for index in 0..<tempData.count {
                    let indexPath = IndexPath.init(row: 0, section: oldData.count + index)
                    insertIndexPath.append(indexPath)
                    
                }
                tempArray.addObjects(from: tempData)
                self.tableViewManager.btcTransactions = tempArray as? [BTCTransaction]
                self.detailView.tableView.beginUpdates()
                for index in 0..<tempData.count {
                    self.detailView.tableView.insertSections(IndexSet.init(integer: oldData.count + index), with: UITableView.RowAnimation.bottom)
                }
                self.detailView.tableView.endUpdates()
            } else {
                self.tableViewManager.btcTransactions = tempData
                self.detailView.tableView.reloadData()
            }
            self.detailView.tableView.mj_footer.endRefreshing()
        } else if type == "ViolasTransactionHistoryOrigin" {
            guard let tempData = jsonData.value(forKey: "data") as? [ViolasDataModel] else {
                return
            }
            self.tableViewManager.violasTransactions = tempData
            self.detailView.tableView.reloadData()
        } else if type == "ViolasTransactionHistoryMore" {
                   
        } else if type == "LibraTransactionHistoryOrigin" {
            guard let tempData = jsonData.value(forKey: "data") as? [LibraDataModel] else {
               return
            }
            self.tableViewManager.libraTransactions = tempData
            self.detailView.tableView.reloadData()
        } else if type == "LibraTransactionHistoryMore" {
                   
        }
        self.detailView.hideToastActivity()
        self.detailView.tableView.mj_header.endRefreshing()
//        self.endLoading()
    }
    var dataOffset: Int = 1
    //网络请求、数据模型
    lazy var dataModel: WalletTransactionsModel = {
        let model = WalletTransactionsModel.init()
        return model
    }()
    //tableView管理类
    lazy var tableViewManager: WalletTransactionsTableViewManager = {
        let manager = WalletTransactionsTableViewManager.init()
//        manager.delegate = self
        return manager
    }()
    //子View
    lazy var detailView : WalletTransactionsView = {
        let view = WalletTransactionsView.init()
        view.tableView.delegate = self.tableViewManager
        view.tableView.dataSource = self.tableViewManager
        view.tableView.mj_header = MJRefreshNormalHeader.init(refreshingTarget: self, refreshingAction:  #selector(refreshReceive))
        view.tableView.mj_footer = MJRefreshBackNormalFooter.init(refreshingTarget: self, refreshingAction:  #selector(getMoreReceive))
        return view
    }()
    @objc func refreshReceive() {
        dataOffset = 1
        detailView.tableView.mj_footer.resetNoMoreData()
        detailView.tableView.mj_header.beginRefreshing()
        switch self.tableViewManager.transactionType {
        case .Libra:
            dataModel.getLibraTransactionHistory(address: (wallet?.walletAddress)!, page: 1, pageSize: 10, requestStatus: 0)
            break
        case .Violas:
            dataModel.getViolasTransactionHistory(address: (wallet?.walletAddress)!, page: 1, pageSize: 10, requestStatus: 0)
            break
        case .BTC:
            dataModel.getBTCTransactionHistory(address: (wallet?.walletAddress)!, page: 1, pageSize: 10, requestStatus: 0)
        default:
            break
        }
    }
    @objc func getMoreReceive() {
        dataOffset += 1
        detailView.tableView.mj_footer.beginRefreshing()
        switch self.tableViewManager.transactionType {
        case .Libra:
            dataModel.getLibraTransactionHistory(address: (wallet?.walletAddress)!, page: 1, pageSize: 10, requestStatus: 0)
            break
        case .Violas:
            dataModel.getViolasTransactionHistory(address: (wallet?.walletAddress)!, page: 1, pageSize: 10, requestStatus: 0)
            break
        case .BTC:
            dataModel.getBTCTransactionHistory(address: (wallet?.walletAddress)!, page: dataOffset, pageSize: 10, requestStatus: 1)
        default:
            break
        }
    }
    var wallet: LibraWalletManager?
}
