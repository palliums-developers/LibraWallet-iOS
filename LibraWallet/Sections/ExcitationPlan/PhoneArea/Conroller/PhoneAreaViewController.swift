//
//  PhoneAreaViewController.swift
//  HKWallet
//
//  Created by palliums on 2019/8/16.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit
import Localize_Swift
class PhoneAreaViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        // 设置标题
        self.title = localLanguage(keyString: "wallet_phone_area_navigation_title")
        // 添加返回按钮
        self.addNavigationBar()
        // 加载子View
        self.view.addSubview(detailView)
        // 加载本地默认数据
        self.tableViewManager.dataModel = self.dataModel.getLocalAreaData()
        self.detailView.tableView.reloadData()
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
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
    }
    deinit {
        print("PhoneAreaViewController销毁了")
    }
    func setNavigationBarTitleColorWhite() {
        self.navigationController?.navigationBar.titleTextAttributes=[NSAttributedString.Key.foregroundColor:UIColor.white,
                                                                      NSAttributedString.Key.font:UIFont.systemFont(ofSize: 20, weight: UIFont.Weight.medium)]
    }
    //子View
    private lazy var detailView : PhoneAreaView = {
        let view = PhoneAreaView.init()
        view.tableView.delegate = self.tableViewManager
        view.tableView.dataSource = self.tableViewManager
        return view
    }()
    lazy var dataModel: PhoneAreaModel = {
        let model = PhoneAreaModel.init()
        return model
    }()
    //tableView管理类
    lazy var tableViewManager: PhoneAreaTableViewManager = {
        let manager = PhoneAreaTableViewManager.init()
        manager.delegate = self
        manager.hideAreaCode = self.hideAreaCode
        return manager
    }()
    typealias nextActionClosure = (ControllerAction, PhoneAreaDataModel) -> Void
    var actionClosure: nextActionClosure?

    func addNavigationBar() {
        // 自定义导航栏的UIBarButtonItem类型的按钮
        let backView = UIBarButtonItem(customView: backButton)
        // 重要方法，用来调整自定义返回view距离左边的距离
        let barButtonItem = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        barButtonItem.width = -5
        // 返回按钮设置成功
        self.navigationItem.leftBarButtonItems = [barButtonItem, backView]
    }
    lazy var backButton: UIButton = {
        let backButton = UIButton(type: .custom)
        // 给按钮设置返回箭头图片
        backButton.setImage(UIImage.init(named: "navigation_back"), for: UIControl.State.normal)
        // 设置frame
        backButton.frame = CGRect(x: 200, y: 13, width: 22, height: 44)
        backButton.addTarget(self, action: #selector(back), for: .touchUpInside)
        return backButton
    }()
    @objc func back() {
        self.dismiss(animated: true, completion: nil)
    }
    var hideAreaCode: Bool?
}
extension PhoneAreaViewController: AreaTableViewManagerDelegate {
    func tableViewDidSelectRowAtIndexPath(indexPath: IndexPath, model: PhoneAreaDataModel) {
        self.dismiss(animated: true) {
            if let action = self.actionClosure {
                if self.hideAreaCode == true {
                    action(.update, model)
                } else {
                    action(.update, model)
                }
            }
        }
    }
}
