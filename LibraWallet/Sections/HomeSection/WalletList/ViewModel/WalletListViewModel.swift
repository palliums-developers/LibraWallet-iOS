//
//  WalletListViewModel.swift
//  LibraWallet
//
//  Created by palliums on 2019/11/1.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit

class WalletListViewModel: NSObject {
    var myContext = 0
    func initKVO() {
        dataModel.addObserver(self, forKeyPath: "dataDic", options: NSKeyValueObservingOptions.new, context: &myContext)
        self.collectionViewManager.dataArray = self.dataModel.getSupportCoinList()
        self.detailView.collectionView.reloadData()
        dataModel.loadLocalWallet()
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
            } else if error.localizedDescription == LibraWalletError.WalletRequest(reason: .walletTokenExpired).localizedDescription {
                // 钱包不存在
                print(error.localizedDescription)
//                let vc = WalletCreateViewController()
//                let navi = UINavigationController.init(rootViewController: vc)
//                self.present(navi, animated: true, completion: nil)
            } else if error.localizedDescription == LibraWalletError.WalletRequest(reason: .walletVersionExpired).localizedDescription {
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
        if type == "LoadLocalWallets" {
            if let tempData = jsonData.value(forKey: "data") as? [[Token]] {
//                self.tableViewManager.originModel = tempData
//                self.tableViewManager.dataModel = tempData

                self.detailView.tableView.reloadData()
            }
        }
        self.detailView.hideToastActivity()
    }
    //网络请求、数据模型
    lazy var dataModel: WalletListModel = {
        let model = WalletListModel.init()
        return model
    }()
    //tableView管理类
    lazy var tableViewManager: WalletListTableViewManager = {
        let manager = WalletListTableViewManager.init()
        return manager
    }()
    lazy var collectionViewManager: WalletListCollectionViewManager = {
        let manager = WalletListCollectionViewManager.init()
        manager.delegate = self
        return manager
    }()
    //子View
    lazy var detailView : WalletListView = {
        let view = WalletListView.init()
        view.tableView.delegate = self.tableViewManager
        view.tableView.dataSource = self.tableViewManager
        view.collectionView.delegate = self.collectionViewManager
        view.collectionView.dataSource = self.collectionViewManager
        return view
    }()
    var oldCollectionSelectIndexPath: IndexPath?
}
extension WalletListViewModel: WalletListCollectionViewCellDelegate {
    func collectionViewDidSelectRowAtIndexPath(collectionView: UICollectionView, indexPath: IndexPath) {
//        print(indexPath.row)
//        if indexPath.row == 0 {
//            tableViewManager.dataModel = tableViewManager.originModel
//            detailView.tableView.reloadData()
//        } else if indexPath.row == 1 {
//            let tempArray = tableViewManager.originModel.map { (groupArray) in
//                groupArray.map { (items) in
//                    items.filter { (item) in
//                        item.tokenType == .Violas
//                    }
//                }
//            }
//            tableViewManager.dataModel = tempArray
//            detailView.tableView.reloadData()
//        } else if indexPath.row == 2 {
//            let tempArray = tableViewManager.originModel.map { (groupArray) in
//               groupArray.map { (items) in
//                   items.filter { (item) in
//                    item.tokenType == .BTC
//                   }
//               }
//            }
//            tableViewManager.dataModel = tempArray
//            detailView.tableView.reloadData()
//        } else if indexPath.row == 3 {
//            let tempArray = tableViewManager.originModel.map { groupArray in
//                groupArray.map { items in
//                    items.filter { item in
//                        item.tokenType == .Libra
//                    }
//                }
//            }
//            tableViewManager.dataModel = tempArray
//            detailView.tableView.reloadData()
//        }
    }
}
