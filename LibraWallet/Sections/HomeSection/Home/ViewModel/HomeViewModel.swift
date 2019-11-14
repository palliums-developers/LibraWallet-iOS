//
//  HomeViewModel.swift
//  LibraWallet
//
//  Created by palliums on 2019/10/30.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit

class HomeViewModel: NSObject {
    //MARK: - KVO
    var myContext = 0
    func initKVO() {
        dataModel.addObserver(self, forKeyPath: "dataDic", options: NSKeyValueObservingOptions.new, context: &myContext)
        self.detailView.makeToastActivity(.center)
        self.dataModel.getLocalUserInfo()
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
        
        if type == "LoadCurrentUseWallet" {
            // 加载本地数据
            if let tempData = jsonData.value(forKey: "data") as? LibraWalletManager {
                self.detailView.model = tempData
                self.detailView.tableView.reloadData()
            }
        } else if type == "UpdateBTCBalance" {
            if let tempData = jsonData.value(forKey: "data") as? BalanceBTCModel {
                self.detailView.headerView.updateBTCBalanceModel = tempData
                self.detailView.tableView.reloadData()
            }
        } else if type == "UpdateLibraBalance" {
            if let tempData = jsonData.value(forKey: "data") as? BalanceLibraModel {
                self.detailView.headerView.updateBalanceModel = tempData
                self.detailView.tableView.reloadData()
            }
        } else if type == "UpdateViolasBalance" {
            if let tempData = jsonData.value(forKey: "data") as? BalanceLibraModel {
                self.detailView.headerView.updateBalanceModel = tempData
                self.detailView.tableView.reloadData()
            }
        } else if type == "LoadEnableViolasTokenList" {
            if let tempData = jsonData.value(forKey: "data") as? [ViolasTokenModel] {
                self.tableViewManager.dataModel = tempData
                self.detailView.tableView.reloadData()
            }
        }
        self.detailView.hideToastActivity()
    }
    var dataOffset: Int = 0
    //网络请求、数据模型
    lazy var dataModel: HomeModel = {
        let model = HomeModel.init()
        return model
    }()
    //tableView管理类
    lazy var tableViewManager: HomeTableViewManager = {
        let manager = HomeTableViewManager.init()
//        manager.delegate = self
        return manager
    }()
    //子View
    lazy var detailView : HomeView = {
        let view = HomeView.init()
        view.tableView.delegate = self.tableViewManager
        view.tableView.dataSource = self.tableViewManager
        return view
    }()
}
