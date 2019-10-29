//
//  WalletChangeNameViewController.swift
//  LibraWallet
//
//  Created by palliums on 2019/10/28.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit
import Toast_Swift
class WalletChangeNameViewController: BaseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // 初始化本地配置
        self.setBaseControlllerConfig()
        
//        self.title = localLanguage(keyString: "wallet_wallet_manager_change_wallet_name_navigationbar_title")
        self.view.addSubview(detailView)
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
    var account: LibraWalletManager? {
        didSet {
            self.detailView.walletNameTextField.text = account?.walletName
        }
    }
//    typealias nextActionClosure = (ViewControllerAction, HomeData) -> Void
//    var actionClosure: nextActionClosure?
    //懒加载子View
    private lazy var detailView : WalletChangeNameView = {
        let view = WalletChangeNameView.init()
        view.delegate = self
        return view
    }()
    deinit {
        print("WalletChangeNameViewController销毁了")
    }
}
extension WalletChangeNameViewController: WalletChangeNameViewDelegate {
    func changeNameButtonClickMethod(button: UIButton, name: String) {
        if button.tag == 10 {
            //名称相同
//            guard name != account?.walletName! else {
//                self.view.makeToast(localLanguage(keyString: "wallet_manager_change_wallet_name_same_error"), position: .center)
//                return
//            }
//            var tempAccount = account
//            tempAccount?.walletName = name
//            let status = DataBaseManager.BDManager.changeWalletName(homeData: tempAccount!)
//            guard status == true else {
//                self.view.makeToast(localLanguage(keyString: "wallet_manager_change_wallet_name_failed_title"), position: .center)
//                return
//            }
//            self.view.makeToast(localLanguage(keyString: "wallet_manager_change_wallet_name_success_title"), duration: ToastManager.shared.duration, position: .center, title: nil, image: nil, style: ToastManager.shared.style, completion: { [weak self](bool) in
//                if let action = self?.actionClosure {
//                    action(.update, tempAccount!)
//                }
//                self?.navigationController?.popViewController(animated: true)
//            })
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
}
