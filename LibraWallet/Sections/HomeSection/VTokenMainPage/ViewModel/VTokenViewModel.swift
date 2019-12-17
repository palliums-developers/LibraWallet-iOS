//
//  VTokenViewModel.swift
//  LibraWallet
//
//  Created by palliums on 2019/11/19.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit
import MJRefresh
class VTokenViewModel: NSObject {
    var myContext = 0
    func initKVO() {
        dataModel.addObserver(self, forKeyPath: "dataDic", options: NSKeyValueObservingOptions.new, context: &myContext)
        self.refreshReceive()
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
            } else if error.localizedDescription == LibraWalletError.WalletRequest(reason: .dataCodeInvalid).localizedDescription {
                print(error.localizedDescription)
                // 数据返回状态异常
            }
            self.detailView.hideToastActivity()
            return
        }
        let type = jsonData.value(forKey: "type") as! String
        if type == "ViolasTransactionHistoryOrigin" {
            guard let tempData = jsonData.value(forKey: "data") as? [ViolasDataModel] else {
                return
            }
            self.tableViewManager.violasTransactions = tempData
            self.detailView.tableView.reloadData()
        } else if type == "ViolasTransactionHistoryMore" {
                   
        }
        self.detailView.hideToastActivity()
        self.detailView.tableView.mj_header.endRefreshing()
//        self.endLoading()
    }
    var dataOffset: Int = 1
    //网络请求、数据模型
    lazy var dataModel: VTokenMainModel = {
        let model = VTokenMainModel.init()
        return model
    }()
    //tableView管理类
    lazy var tableViewManager: VTokenTableViewManager = {
        let manager = VTokenTableViewManager.init()
//        manager.delegate = self
        return manager
    }()
    //子View
    lazy var detailView : VTokenMainView = {
        let view = VTokenMainView.init()
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
        dataModel.getViolasTransactionHistory(address: (wallet?.walletAddress)!, page: 1, pageSize: 10, requestStatus: 0)
    }
    @objc func getMoreReceive() {
        dataOffset += 1
        detailView.tableView.mj_footer.beginRefreshing()
        dataModel.getViolasTransactionHistory(address: (wallet?.walletAddress)!, page: dataOffset, pageSize: 10, requestStatus: 1)
    }
    var wallet: LibraWalletManager?
}
