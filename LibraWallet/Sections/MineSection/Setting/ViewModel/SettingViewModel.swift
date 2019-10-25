//
//  SettingViewModel.swift
//  LibraWallet
//
//  Created by palliums on 2019/10/23.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit

class SettingViewModel: NSObject {
    func getLocalData() {
        self.tableViewManager.dataModel = self.dataModel.getSettingLocalData()
        self.detailView.tableView.reloadData()
    }
    //网络请求、数据模型
    lazy var dataModel: SettingModel = {
        let model = SettingModel.init()
        return model
    }()
    //tableView管理类
    lazy var tableViewManager: SettingTableViewManager = {
        let manager = SettingTableViewManager.init()
//        manager.delegate = self
        return manager
    }()
    //子View
    lazy var detailView : SettingView = {
        let view = SettingView.init()
        view.tableView.delegate = self.tableViewManager
        view.tableView.dataSource = self.tableViewManager
        return view
    }()
}
