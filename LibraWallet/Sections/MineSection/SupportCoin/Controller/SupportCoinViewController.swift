//
//  SupportCoinViewController.swift
//  LibraWallet
//
//  Created by palliums on 2019/10/24.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit

class SupportCoinViewController: BaseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // 初始化本地配置
        self.setBaseControlllerConfig()
        // 设置标题
        self.title = localLanguage(keyString: "wallet_home_right_bar_title")
        // 加载子View
        self.view.addSubview(self.viewModel.detailView)
        // 加载数据
        self.viewModel.loadLocalData()
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.viewModel.detailView.snp.makeConstraints { (make) in
            if #available(iOS 11.0, *) {
                make.top.bottom.equalTo(self.view.safeAreaLayoutGuide)
            } else {
                make.top.bottom.equalTo(self.view)
            }
            make.left.right.equalTo(self.view)
        }
    }
    deinit {
        print("WalletManagerViewController销毁了")
    }
    lazy var viewModel: SupportCoinViewModel = {
        let viewModel = SupportCoinViewModel.init()
        viewModel.tableViewManager.delegate = self
        return viewModel
    }()
}
extension SupportCoinViewController: SupportCoinTableViewManagerDelegate {
    func tableViewDidSelectRowAtIndexPath(indexPath: IndexPath, name: String) {
        let alert = UIAlertController.init(title: "", message: "选择", preferredStyle: UIAlertController.Style.actionSheet)
        let importAction = UIAlertAction.init(title: "导入", style: UIAlertAction.Style.default) { (UIAlertAction) in

            let vc = ImportWalletViewController()
            vc.type = name
            self.navigationController?.pushViewController(vc, animated: true)
        }
        let createAction = UIAlertAction.init(title: "创建", style: UIAlertAction.Style.default) { (UIAlertAction) in
            let vc = AddWalletViewController()
            vc.type = name
            self.navigationController?.pushViewController(vc, animated: true)
        }
        let cancelAction = UIAlertAction.init(title: "取消", style: UIAlertAction.Style.cancel) { (UIAlertAction) in

        }
        alert.addAction(importAction)
        alert.addAction(createAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
        
    }
}
