//
//  AboutUsViewController.swift
//  HKWallet
//
//  Created by palliums on 2019/7/25.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit

class AboutUsViewController: BaseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setNavigationWithoutShadowImage()
        
        self.view.addSubview(detailView)
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        detailView.snp.makeConstraints { (make) in
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(self.view.safeAreaLayoutGuide)
            } else {
                make.bottom.equalTo(self.view)
            }
            make.top.left.right.equalTo(self.view)
        }
    }
    //tableView管理类
    lazy var tableViewManager: AboutUsTableViewManager = {
        let manager = AboutUsTableViewManager.init()
        return manager
    }()
    //子View
    private lazy var detailView : AboutUsView = {
        let view = AboutUsView.init()
        view.tableView.delegate = self.tableViewManager
        view.tableView.dataSource = self.tableViewManager
        return view
    }()
    deinit {
        print("AboutUsViewController销毁了")
    }
}
