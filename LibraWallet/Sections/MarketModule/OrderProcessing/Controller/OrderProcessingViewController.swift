//
//  OrderProcessingViewController.swift
//  LibraWallet
//
//  Created by palliums on 2019/12/10.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit

class OrderProcessingViewController: BaseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // 设置标题
        self.title = localLanguage(keyString: "wallet_wallet_add_navigation_title")
        // 加载子View
        self.view.addSubview(self.detailView)
        // 加载数据
        self.loadLocalData()
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.detailView.snp.makeConstraints { (make) in
            if #available(iOS 11.0, *) {
                make.top.bottom.equalTo(self.view.safeAreaLayoutGuide)
            } else {
                make.top.bottom.equalTo(self.view)
            }
            make.left.right.equalTo(self.view)
        }
    }
    deinit {
        print("SupportCoinViewController销毁了")
    }
    func loadLocalData() {
//        self.tableViewManager.dataModel = dataModel.getSupportCoinData()
//        self.detailView.tableView.reloadData()
    }
    //网络请求、数据模型
    lazy var dataModel: OrderProcessingModel = {
        let model = OrderProcessingModel.init()
        return model
    }()
    //tableView管理类
    lazy var tableViewManager: OrderProcessingTableViewManager = {
        let manager = OrderProcessingTableViewManager.init()
        manager.delegate = self
        return manager
    }()
    //子View
    lazy var detailView : OrderProcessingView = {
        let view = OrderProcessingView.init()
        view.tableView.delegate = self.tableViewManager
        view.tableView.dataSource = self.tableViewManager
        return view
    }()
}
extension OrderProcessingViewController: OrderProcessingTableViewManagerDelegate {
    func tableViewDidSelectRowAtIndexPath(indexPath: IndexPath, address: String) {
        let vc = OrderDetailViewController()
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
}
