//
//  LanguageViewController.swift
//  HKWallet
//
//  Created by palliums on 2019/8/5.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit
import Localize_Swift
class LanguageViewController: BaseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // 初始化本地配置
        self.setNavigationWithoutShadowImage()
        self.view.backgroundColor = UIColor.init(hex: "F8F8F8")
        // 设置标题
        self.title = localLanguage(keyString: "wallet_setting_language_navigationbar_title")
        // 加载子View
        self.view.addSubview(detailView)
        // 添加语言变换通知
        NotificationCenter.default.addObserver(self, selector: #selector(setText), name: NSNotification.Name(LCLLanguageChangeNotification), object: nil)
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
    lazy var tableViewManager: LanguageTabViewManager = {
        let manager = LanguageTabViewManager.init()
        manager.delegate = self
        manager.selectRow = self.getSeletRow()
        return manager
    }()
    //子View
    private lazy var detailView : LanguageView = {
        let view = LanguageView.init()
        view.tableView.delegate = self.tableViewManager
        view.tableView.dataSource = self.tableViewManager
        return view
    }()
    func getSeletRow() -> Int {
        let str = Localize.currentLanguage()
        if str == "zh-Hans" {
            return 0
        } else {
            return 1
        }
    }
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(LCLLanguageChangeNotification), object: nil)
        print("LanguageViewController销毁了")
    }
    @objc func setText(){
        self.title = localLanguage(keyString: "wallet_setting_language_navigationbar_title")
    }
}
extension LanguageViewController: LanguageTabViewManagerDelegate {
    func tableViewDidSelectRowAtIndexPath(indexPath: IndexPath) {
        self.tableViewManager.selectRow = indexPath.row
        if indexPath.section == 0 {
            Localize.setCurrentLanguage("zh-Hans")
        } else if indexPath.section == 1 {
            Localize.setCurrentLanguage("en")
        }
        self.view.makeToast(localLanguage(keyString: "wallet_language_change_success"), position: .center)
    }
}
