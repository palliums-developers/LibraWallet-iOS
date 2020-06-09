//
//  TransactionDetailViewController.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/6/5.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit

class TransactionDetailViewController: BaseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // 加载子View
        self.view.addSubview(self.detailView)
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
         super.viewWillAppear(animated)
         self.navigationController?.navigationBar.barStyle = .default
     }
     override func viewWillLayoutSubviews() {
         super.viewWillLayoutSubviews()
         self.detailView.snp.makeConstraints { (make) in
             if #available(iOS 11.0, *) {
                 make.bottom.equalTo(self.view.safeAreaLayoutGuide)
             } else {
                 make.bottom.equalTo(self.view)
             }
            make.top.left.right.equalTo(self.view)
         }
     }
     deinit {
         print("TransactionDetailViewController销毁了")
     }
    // 网络请求、数据模型
    lazy var dataModel: TransactionDetailModel = {
        let model = TransactionDetailModel.init()
        return model
    }()
    // tableView管理类
    lazy var tableViewManager: TransactionDetailTableViewManager = {
        let manager = TransactionDetailTableViewManager.init()
//        manager.delegate = self
        return manager
    }()
    // 子View
    lazy var detailView : TransactionDetailView = {
        let view = TransactionDetailView.init()
        return view
    }()
}
