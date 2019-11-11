//
//  CheckBackupViewController.swift
//  LibraWallet
//
//  Created by palliums on 2019/11/5.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit
import Toast_Swift
class CheckBackupViewController: BaseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // 初始化本地配置
        self.setBaseControlllerConfig()
        // 加载子View
        self.view.addSubview(self.viewModel.detailView)
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        viewModel.detailView.snp.makeConstraints { (make) in
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
    lazy var viewModel: CheckBackupViewModel = {
        let viewModel = CheckBackupViewModel.init()
        viewModel.detailView.delegate = self
        return viewModel
    }()
    var mnemonicArray: [String]? {
        didSet {
            self.viewModel.dataArray = mnemonicArray
        }
    }
    var FirstInApp: Bool?
}
extension CheckBackupViewController: CheckBackupViewDelegate {
    func confirmBackup() {
        do {
            try self.viewModel.checkIsAllValid()
            if FirstInApp == true {
                self.view.makeToast("备份成功", duration: 0.5, position: .center, title: nil, image: nil, style: ToastManager.shared.style, completion: { (bool) in
                    let tabbar = BaseTabBarViewController.init()
                    UIApplication.shared.keyWindow?.rootViewController = tabbar
                    UIApplication.shared.keyWindow?.makeKeyAndVisible()
                })
            } else {
                
            }
            
        } catch {
            self.view.makeToast(error.localizedDescription,
                                position: .center)
        }
    }
}
