//
//  WalletManagerViewController.swift
//  LibraWallet
//
//  Created by palliums on 2019/10/24.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit

class WalletManagerViewController: BaseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        if managerWallet == true {
            self.addRightNavigationBar()
        }
        // 初始化本地配置
        self.setBaseControlllerConfig()
        // 设置标题
        self.title = localLanguage(keyString: "wallet_wallet_manager_navigation_title")
        // 加载子View
        self.view.addSubview(self.viewModel.detailView)
        // 加载数据
        self.viewModel.initKVO()
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
    lazy var viewModel: WalletManagerViewModel = {
        let viewModel = WalletManagerViewModel.init()
        viewModel.tableViewManager.delegate = self
        return viewModel
    }()
    func addRightNavigationBar() {
        // 自定义导航栏的UIBarButtonItem类型的按钮
        let addView = UIBarButtonItem(customView: addButton)
        // 重要方法，用来调整自定义返回view距离左边的距离
        let barButtonItem = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        // 返回按钮设置成功
        self.navigationItem.rightBarButtonItems = [addView, barButtonItem]
    }
    lazy var addButton: UIButton = {
        let button = UIButton(type: .custom)
        // 给按钮设置返回箭头图片
        button.setImage(UIImage.init(named: "add"), for: UIControl.State.normal)
        // 设置frame
        button.frame = CGRect(x: 200, y: 13, width: 22, height: 44)
        button.addTarget(self, action: #selector(addMethod), for: .touchUpInside)
        return button
    }()
    @objc func addMethod() {
        let vc = SupportCoinViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    var managerWallet: Bool?
    var needRefresh: Bool? {
        didSet {
            self.viewModel.dataModel.loadLocalWallet()
        }
    }
}
extension WalletManagerViewController: WalletManagerTableViewManagerDelegate {
    func tableViewDidSelectRowAtIndexPath(indexPath: IndexPath, model: LibraWalletManager) {
        if managerWallet == true {
            let vc = WalletDetailViewController()
            vc.walletModel = model
            vc.canDelete = indexPath.section == 0 ? false:true
            vc.actionClosure = { (action, model) in
//                let tempModel = self.viewModel.tableViewManager.dataModel?.last?.filter({ item in
//                    item.walletRootAddress != model?.walletRootAddress
//                })
//                self.viewModel.tableViewManager.dataModel?.removeLast()
//                self.viewModel.tableViewManager.dataModel?.append(tempModel)
//                self
                self.viewModel.dataModel.loadLocalWallet()
            }
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            let vc = WalletTransactionsViewController()
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
