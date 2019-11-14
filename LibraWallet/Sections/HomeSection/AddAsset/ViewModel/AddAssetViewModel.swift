//
//  AddAssetViewModel.swift
//  LibraWallet
//
//  Created by palliums on 2019/11/1.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit

class AddAssetViewModel: NSObject {
    var myContext = 0
    func initKVO(walletID: Int64) {
        dataModel.addObserver(self, forKeyPath: "dataDic", options: NSKeyValueObservingOptions.new, context: &myContext)
        self.detailView.makeToastActivity(.center)
        self.dataModel.getViolasTokenList(walletID: walletID)
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
        
        if type == "LoadLocalViolasToken" {
            if let tempData = jsonData.value(forKey: "data") as? [ViolasTokenModel] {
                self.tableViewManager.dataModel = tempData
                self.detailView.tableView.reloadData()
            }
        } else if type == "UpdateViolasTokenList" {
            if let tempData = jsonData.value(forKey: "data") as? [ViolasTokenModel] {
                self.tableViewManager.dataModel = tempData
                self.detailView.tableView.reloadData()
            }
        }
        self.detailView.hideToastActivity()
    }
    //网络请求、数据模型
    lazy var dataModel: AddAssetModel = {
        let model = AddAssetModel.init()
        return model
    }()
    //tableView管理类
    lazy var tableViewManager: AddAssetTableViewManager = {
        let manager = AddAssetTableViewManager.init()
        manager.delegate = self
        return manager
    }()
    //子View
    lazy var detailView : AddAssetView = {
        let view = AddAssetView.init()
        view.tableView.delegate = self.tableViewManager
        view.tableView.dataSource = self.tableViewManager
        return view
    }()
}
extension AddAssetViewModel: AddAssetTableViewManagerDelegate {
    func switchButtonChange(model: ViolasTokenModel, state: Bool) {
        if state == true {
            let result = DataBaseManager.DBManager.insertViolasToken(walletID: (tableViewManager.headerData?.walletID)!, model: model)
            print("插入:\(result)")
        } else {
            let result = DataBaseManager.DBManager.deleteViolasToken(walletID: (tableViewManager.headerData?.walletID)!,
            address: model.address!)
            print("删除:\(result)")

        }
    }
}
