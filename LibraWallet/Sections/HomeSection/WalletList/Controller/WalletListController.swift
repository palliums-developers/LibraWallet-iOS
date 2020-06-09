//
//  WalletListController.swift
//  LibraWallet
//
//  Created by palliums on 2019/11/1.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit

class WalletListController: BaseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        // 页面标题
        self.title = localLanguage(keyString: "wallet_wallet_list_navigation_title")
        // 加载子View
        self.view.addSubview(self.viewModel.detailView)
        // 加载数据
        self.viewModel.initKVO()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.barStyle = .default
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.barStyle = .black
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
        print("WalletListController销毁了")
    }
    typealias nextActionClosure = (ControllerAction, LibraWalletManager) -> Void
    var actionClosure: nextActionClosure?
    lazy var viewModel: WalletListViewModel = {
        let viewModel = WalletListViewModel.init()
        viewModel.tableViewManager.delegate = self
        return viewModel
    }()
}
extension WalletListController: WalletListTableViewManagerDelegate {
    func tableViewDidSelectRowAtIndexPath(indexPath: IndexPath, model: LibraWalletManager) {
        print(indexPath.row)
        
//        // 去除旧的选中
//        let oldIndex = viewModel.tableViewManager.dataModelLocation!
//        var oldModel = viewModel.tableViewManager.dataModel![oldIndex.section][oldIndex.row]
//        oldModel.changeWalletCurrentUse(state: false)
//        let oldChangeResult = DataBaseManager.DBManager.updateWalletCurrentUseState(walletID: oldModel.walletID!, state: false)
//        guard oldChangeResult == true else {
//            return
//        }
//        // 添加新的选中
//        let result = DataBaseManager.DBManager.updateWalletCurrentUseState(walletID: model.walletID!, state: true)
//        guard result == true else {
//            return
//        }
//        viewModel.tableViewManager.dataModelLocation = indexPath
//
//        if let action = self.actionClosure {
//            LibraWalletManager.shared.changeDefaultWallet(wallet: model)
//            action(.update, model)
//        }
//        self.navigationController?.popViewController(animated: true)
    }
}
