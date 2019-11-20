//
//  SettingViewController.swift
//  LibraWallet
//
//  Created by palliums on 2019/10/23.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit

class SettingViewController: BaseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // 初始化本地配置
        self.setBaseControlllerConfig()
        // 设置标题
        self.title = localLanguage(keyString: "wallet_setting_navigation_title")
        // 加载子View
        self.view.addSubview(self.viewModel.detailView)
        // 加载数据
        self.viewModel.getLocalData()
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
        print("SettingViewController销毁了")
    }
    lazy var viewModel: SettingViewModel = {
        let viewModel = SettingViewModel.init()
        viewModel.tableViewManager.delegate = self
        return viewModel
    }()
}
extension SettingViewController: SettingTableViewManagerDelegate {
    func tableViewDidSelectRowAtIndexPath(indexPath: IndexPath) {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                let vc = LanguageViewController()
                self.navigationController?.pushViewController(vc, animated: true)
            } else {
                let vc = ServiceLegalViewController()
                self.navigationController?.pushViewController(vc, animated: true)
            }
        } else if indexPath.section == 1 {
            let vc = AboutUsViewController()
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            let vc = HelpCenterViewController()
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
