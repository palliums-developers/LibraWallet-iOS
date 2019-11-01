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
        // 初始化本地配置
        self.setBaseControlllerConfig()
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
        if let action = self.actionClosure {
            action(.update, model)
        }
        // 去除旧的选中
        let oldIndex = viewModel.tableViewManager.dataModelLocation!
//        let tempArray = viewModel.tableViewManager.originModel.map { (groupArray) in
//            groupArray.map { (items) in
//                items.map { (item) in
//
//                }
//            }
//        }
//        for groupArray in viewModel.tableViewManager.originModel! {
//            for var item in groupArray {
//                var state: Bool = false
//                if item.walletCurrentUse == true {
//                    state = false
//                }
//                if item.walletID == model.walletID {
//                    state = true
//                }
//                item.changeWalletCurrentUse(state: state)
////                LibraWalletManager.init(walletID: item.walletID,
////                                        walletBalance: item.walletBalance,
////                                        walletAddress: item.walletAddress,
////                                        walletRootAddress: item.walletRootAddress,
////                                        walletCreateTime: item.walletCreateTime,
////                                        walletName: item.walletName,
////                                        walletCurrentUse: state,
////                                        walletBiometricLock: item.walletBiometricLock,
////                                        walletIdentity: item.walletIdentity,
////                                        walletType: item.walletType)
//            }
//        }

        viewModel.tableViewManager.dataModel![oldIndex.section][oldIndex.row].changeWalletCurrentUse(state: false)
        viewModel.tableViewManager.dataModel![indexPath.section][indexPath.row].changeWalletCurrentUse(state: true)

        viewModel.tableViewManager.originModel![oldIndex.section][oldIndex.row].changeWalletCurrentUse(state: false)
        
        viewModel.tableViewManager.dataModel![indexPath.section][indexPath.row].changeWalletCurrentUse(state: true)
        
        // 添加新的选中
//        let result = DataBaseManager.DBManager.updateWalletCurrentUseState(walletID: model.walletID!, state: true)
//        if result == true {
            viewModel.tableViewManager.dataModelLocation = indexPath
//        }
        self.viewModel.detailView.tableView.beginUpdates()
        self.viewModel.detailView.tableView.reloadRows(at: [oldIndex, indexPath], with: .none)
        self.viewModel.detailView.tableView.endUpdates()
//        self.navigationController?.popViewController(animated: true)
    }
}
