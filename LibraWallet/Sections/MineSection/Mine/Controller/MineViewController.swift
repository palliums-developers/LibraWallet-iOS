//
//  MineViewController.swift
//  LibraWallet
//
//  Created by palliums on 2019/10/23.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit

class MineViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        // 初始化本地配置
//        self.setBaseControlllerConfig()
        // 加载子View
        self.view.addSubview(self.viewModel.detailView)
        // 加载数据
        self.viewModel.getLocalData()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.barStyle = .black
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.barStyle = .default
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.viewModel.detailView.snp.makeConstraints { (make) in
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(self.view.safeAreaLayoutGuide)
            } else {
                make.bottom.equalTo(self.view)
            }
            make.top.left.right.equalTo(self.view)
        }
    }
    deinit {
        print("MineViewController销毁了")
    }
    lazy var viewModel: MineViewModel = {
        let viewModel = MineViewModel.init()
        viewModel.tableViewManager.delegate = self
        return viewModel
    }()
}
extension MineViewController: MineTableViewManagerDelegate {
    func tableViewDidSelectRowAtIndexPath(indexPath: IndexPath) {
        if indexPath.row == 2 {
            let vc = AddressManagerViewController()
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        } else if indexPath.row == 3 {
            let vc = SettingViewController()
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        } else if indexPath.row == 0 {
            let vc = WalletManagerViewController()
            vc.hidesBottomBarWhenPushed = true
            vc.managerWallet = true
            self.navigationController?.pushViewController(vc, animated: true)
        } else if indexPath.row == 1 {
            let vc = WalletManagerViewController()
            vc.hidesBottomBarWhenPushed = true
            vc.managerWallet = false
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
