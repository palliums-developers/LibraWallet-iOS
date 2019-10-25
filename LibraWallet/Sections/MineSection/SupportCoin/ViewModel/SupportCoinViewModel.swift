//
//  SupportCoinViewModel.swift
//  LibraWallet
//
//  Created by palliums on 2019/10/24.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit

class SupportCoinViewModel: NSObject {
    var myContext = 0
    func loadLocalData() {
        
        self.tableViewManager.dataModel = dataModel.getSupportCoinData()
        self.detailView.tableView.reloadData()
    }
    
    var dataOffset: Int = 0
    //网络请求、数据模型
    lazy var dataModel: SupportCoinModel = {
        let model = SupportCoinModel.init()
        return model
    }()
    //tableView管理类
    lazy var tableViewManager: SupportCoinTableViewManager = {
        let manager = SupportCoinTableViewManager.init()
//        manager.delegate = self
        return manager
    }()
    //子View
    lazy var detailView : SupportCoinView = {
        let view = SupportCoinView.init()
        view.tableView.delegate = self.tableViewManager
        view.tableView.dataSource = self.tableViewManager
        return view
    }()
}
