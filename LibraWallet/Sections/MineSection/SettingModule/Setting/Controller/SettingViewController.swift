//
//  SettingViewController.swift
//  LibraWallet
//
//  Created by palliums on 2019/10/23.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit
import Localize_Swift
class SettingViewController: BaseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // 初始化本地配置
//        self.setBaseControlllerConfig()
        // 设置标题
        self.title = localLanguage(keyString: "wallet_setting_navigation_title")
        // 加载子View
        self.view.addSubview(self.detailView)
        // 加载数据
        self.getLocalData()
        // 添加语言变换通知
        NotificationCenter.default.addObserver(self, selector: #selector(setText), name: NSNotification.Name(LCLLanguageChangeNotification), object: nil)
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        detailView.snp.makeConstraints { (make) in
            if #available(iOS 11.0, *) {
                make.top.bottom.equalTo(self.view.safeAreaLayoutGuide)
            } else {
                make.top.bottom.equalTo(self.view)
            }
            make.left.right.equalTo(self.view)
        }
    }
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(LCLLanguageChangeNotification), object: nil)
        print("SettingViewController销毁了")
    }
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
        manager.delegate = self
        return manager
    }()
    //子View
    lazy var detailView : SettingView = {
        let view = SettingView.init()
        view.tableView.delegate = self.tableViewManager
        view.tableView.dataSource = self.tableViewManager
        return view
    }()
    @objc func setText() {
        // 设置标题
        self.title = localLanguage(keyString: "wallet_setting_navigation_title")
        // 加载数据
        self.getLocalData()
    }
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
