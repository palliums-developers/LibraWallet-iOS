//
//  MarketMineViewController.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/7/9.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit

class MarketMineViewController: BaseViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 加载子View
        self.view.addSubview(detailView)
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        detailView.snp.makeConstraints { (make) in
            make.top.bottom.left.right.equalTo(self.view.safeAreaLayoutGuide)
        }
    }
    /// 网络请求、数据模型
    lazy var dataModel: MarketModel = {
        let model = MarketModel.init()
        return model
    }()
    /// tableView管理类
    lazy var tableViewManager: MarketMineTableViewManager = {
        let manager = MarketMineTableViewManager.init()
//        manager.delegate = self
        return manager
    }()
    /// 子View
    private lazy var detailView : MarketMineView = {
        let view = MarketMineView.init()
        view.tableView.delegate = self.tableViewManager
        view.tableView.dataSource = self.tableViewManager
        return view
    }()
}
