//
//  AddressManagerViewModel.swift
//  LibraWallet
//
//  Created by palliums on 2019/10/22.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit
import MJRefresh
class AddressManagerViewModel: NSObject {
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
        if type == "TransferAddressOrigin" {
            if let tempData = jsonData.value(forKey: "data") as? [AddressModel] {
                self.tableViewManager.dataModel = tempData
                self.detailView.tableView.reloadData()
            }
        }
        self.detailView.hideToastActivity()
        self.detailView.tableView.mj_header.endRefreshing()
//        self.endLoading()
    }
    var dataOffset: Int = 0
    //网络请求、数据模型
    lazy var dataModel: AddressManagerModel = {
        let model = AddressManagerModel.init()
        return model
    }()
    //tableView管理类
    lazy var tableViewManager: AddressManagerTableViewManager = {
        let manager = AddressManagerTableViewManager.init()
//        manager.delegate = self
        return manager
    }()
    //子View
    lazy var detailView : AddressManagerView = {
        let view = AddressManagerView.init()
        view.tableView.delegate = self.tableViewManager
        view.tableView.dataSource = self.tableViewManager
        view.tableView.mj_header = MJRefreshNormalHeader.init(refreshingTarget: self, refreshingAction:  #selector(refreshReceive))
        view.tableView.mj_footer = MJRefreshBackNormalFooter.init(refreshingTarget: self, refreshingAction:  #selector(getMoreReceive))
        return view
    }()
    @objc func refreshReceive() {
        dataOffset = 0
        detailView.tableView.mj_footer.resetNoMoreData()
        detailView.tableView.mj_header.beginRefreshing()
//        self.dataModel.getWithdrawAddressHistory(uid: WalletData.wallet.walletUID!, offset: 0, requestStatus: 0)
        self.dataModel.getWithdrawAddressHistory(type: "", requestStatus: 0)
    }
    @objc func getMoreReceive() {
        dataOffset += 10
//        detailView.tableView.mj_footer.beginRefreshing()
//        self.dataModel.getWithdrawAddressHistory(uid: WalletData.wallet.walletUID!, offset: dataOffset, requestStatus: 1)
    }
}
