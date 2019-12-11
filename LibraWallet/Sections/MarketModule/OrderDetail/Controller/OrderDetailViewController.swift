//
//  OrderDetailViewController.swift
//  LibraWallet
//
//  Created by palliums on 2019/12/10.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit

class OrderDetailViewController: BaseViewController {
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
        print("OrderDetailViewController销毁了")
    }
    func loadLocalData() {
//        self.tableViewManager.dataModel = dataModel.getSupportCoinData()
//        self.detailView.tableView.reloadData()
    }
    //网络请求、数据模型
    lazy var dataModel: OrderDetailModel = {
        let model = OrderDetailModel.init()
        return model
    }()
    //tableView管理类
    lazy var tableViewManager: OrderDetailTableViewManager = {
        let manager = OrderDetailTableViewManager.init()
        manager.delegate = self
        return manager
    }()
    //子View
    lazy var detailView : OrderDetailView = {
        let view = OrderDetailView.init()
        view.tableView.delegate = self.tableViewManager
        view.tableView.dataSource = self.tableViewManager
        return view
    }()
}
extension OrderDetailViewController: OrderDetailTableViewManagerDelegate {
    func tableViewDidSelectRowAtIndexPath(indexPath: IndexPath, address: String) {
//        let alert = UIAlertController.init(title: localLanguage(keyString: "wallet_add_wallet_alert_choose_import_or_create_title"), message: nil, preferredStyle: UIAlertController.Style.actionSheet)
//        let importAction = UIAlertAction.init(title: localLanguage(keyString: "wallet_add_wallet_alert_import_action_title"), style: UIAlertAction.Style.default) { (UIAlertAction) in
//
//            let vc = ImportWalletViewController()
//            vc.type = name
//            self.navigationController?.pushViewController(vc, animated: true)
//        }
//        let createAction = UIAlertAction.init(title: localLanguage(keyString: "wallet_add_wallet_alert_create_action_title"), style: UIAlertAction.Style.default) { (UIAlertAction) in
//            let vc = AddWalletViewController()
//            vc.type = name
//            self.navigationController?.pushViewController(vc, animated: true)
//        }
//        let cancelAction = UIAlertAction.init(title: localLanguage(keyString: "wallet_add_wallet_alert_cancel_action_title"), style: UIAlertAction.Style.cancel) { (UIAlertAction) in
//
//        }
//        alert.addAction(importAction)
//        alert.addAction(createAction)
//        alert.addAction(cancelAction)
//        self.present(alert, animated: true, completion: nil)
        
    }
}
