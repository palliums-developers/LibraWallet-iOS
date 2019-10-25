//
//  MineViewModel.swift
//  LibraWallet
//
//  Created by palliums on 2019/10/23.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit

class MineViewModel: NSObject {
    func getLocalData() {
        self.tableViewManager.dataModel = self.dataModel.getLocalData()
        self.detailView.tableView.reloadData()
    }
    //网络请求、数据模型
    lazy var dataModel: MineModel = {
        let model = MineModel.init()
        return model
    }()
    //tableView管理类
    lazy var tableViewManager: MineTableViewManager = {
        let manager = MineTableViewManager.init()
//        manager.delegate = self
        return manager
    }()
    //子View
    lazy var detailView : MineView = {
        let view = MineView.init()
        view.tableView.delegate = self.tableViewManager
        view.tableView.dataSource = self.tableViewManager
        return view
    }()
}

