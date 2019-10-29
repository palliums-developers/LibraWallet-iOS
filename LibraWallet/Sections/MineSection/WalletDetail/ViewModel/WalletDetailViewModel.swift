//
//  WalletDetailViewModel.swift
//  LibraWallet
//
//  Created by palliums on 2019/10/28.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit

class WalletDetailViewModel: NSObject {
    func loadLocalData(model: LibraWalletManager) {
        self.tableViewManager.dataModel = dataModel.loadLocalConfig(model: model)
        self.detailView.tableView.reloadData()
    }
    //网络请求、数据模型
    lazy var dataModel: WalletDetailModel = {
        let model = WalletDetailModel.init()
        return model
    }()
    //tableView管理类
    lazy var tableViewManager: WalletDetailTableViewManager = {
        let manager = WalletDetailTableViewManager.init()
//        manager.delegate = self
        return manager
    }()
    //子View
    lazy var detailView : WalletDetailView = {
        let view = WalletDetailView.init(canDelete: self.canDelete!)
        view.tableView.delegate = self.tableViewManager
        view.tableView.dataSource = self.tableViewManager
        return view
    }()
    var canDelete: Bool?
}
