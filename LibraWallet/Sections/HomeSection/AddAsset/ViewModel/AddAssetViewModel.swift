//
//  AddAssetViewModel.swift
//  LibraWallet
//
//  Created by palliums on 2019/11/1.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit
protocol AddAssetViewModelDelegate: NSObjectProtocol {
    func switchButtonChange(model: ViolasTokenModel, state: Bool, indexPath: IndexPath)
}
class AddAssetViewModel: NSObject {
    weak var delegate: AddAssetViewModelDelegate?
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
                print(error.localizedDescription)
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
            self.detailView.toastView?.hide()
            if let action = self.actionClosure {
                action(false)
            }
            self.detailView.makeToast("开启失败", position: .center)
            return
        }
        let type = jsonData.value(forKey: "type") as! String
        
        if type == "LoadLocalViolasToken" {
//            if let tempData = jsonData.value(forKey: "data") as? [ViolasTokenModel] {
//                self.tableViewManager.dataModel = tempData
//                self.detailView.tableView.reloadData()
//                self.detailView.hideToastActivity()
//            }
        } else if type == "UpdateViolasTokenList" {
            if let tempData = jsonData.value(forKey: "data") as? [ViolasTokenModel] {
                self.tableViewManager.dataModel = tempData
                self.detailView.tableView.reloadData()
                self.detailView.hideToastActivity()
            }
        } else if type == "SendViolasTransaction" {
            self.detailView.toastView?.hide()
            if let action = self.actionClosure {
                action(true)
            }
            self.detailView.makeToast(localLanguage(keyString: "wallet_add_asset_alert_success_title"),
                                position: .center)
            
        }
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
    typealias successClosure = (Bool) -> Void
    var actionClosure: successClosure?
}
extension AddAssetViewModel: AddAssetTableViewManagerDelegate {
    func switchButtonChange(model: ViolasTokenModel, state: Bool, indexPath: IndexPath) {
        guard state == true else {
            _ = DataBaseManager.DBManager.deleteViolasToken(walletID: (self.tableViewManager.headerData?.walletID)!, address: model.address!)
            return
        }
        self.delegate?.switchButtonChange(model: model, state: state, indexPath: indexPath)
        self.actionClosure = { result in
            if result == true {
                let cell = self.detailView.tableView.cellForRow(at: indexPath) as! AddAssetViewTableViewCell
                cell.switchButton.setOn(result, animated: true)
                _ = DataBaseManager.DBManager.insertViolasToken(walletID: (self.tableViewManager.headerData?.walletID)!, model: model)
            } else {
                let cell = self.detailView.tableView.cellForRow(at: indexPath) as! AddAssetViewTableViewCell
                cell.switchButton.setOn(result, animated: true)
                _ = DataBaseManager.DBManager.deleteViolasToken(walletID: (self.tableViewManager.headerData?.walletID)!, address: model.address!)
            }
        }
    }
}
