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
    override func back() {
        guard self.detailView.walletNameTextField.text != self.account?.walletName else {
            self.navigationController?.popViewController(animated: true)
            return
        }
        let alert = UIAlertController.init(title: "提示", message: "已修改钱包名称,是否立即保存", preferredStyle: .alert)
        let confirmAction = UIAlertAction.init(title: "保存", style: UIAlertAction.Style.default) { (UIAlertAction) in
            self.changeWalletName()
        }
        let cancelAction = UIAlertAction.init(title: "取消", style: UIAlertAction.Style.destructive) { (UIAlertAction) in
            self.navigationController?.popViewController(animated: true)
        }
        alert.addAction(cancelAction)
        alert.addAction(confirmAction)
        self.present(alert, animated: true, completion: nil)
        print("rest")
    }
    var account: LibraWalletManager? {
        didSet {
            self.detailView.walletNameTextField.text = account?.walletName
        }
    }
    typealias nextActionClosure = (ControllerAction, LibraWalletManager) -> Void
    var actionClosure: nextActionClosure?
    //懒加载子View
    private lazy var detailView : WalletChangeNameView = {
        let view = WalletChangeNameView.init()
        view.delegate = self
        return view
    }()
    deinit {
        print("WalletChangeNameViewController销毁了")
    }
    func changeWalletName() {
        // 拆包检测
        guard let walletName = detailView.walletNameTextField.text else {
            self.view.makeToast(localLanguage(keyString: "wallet_manager_change_wallet_name_invalid_title"),
                                position: .center)
            return
        }
        //没输入
        guard walletName.isEmpty == false else {
            self.view.makeToast(localLanguage(keyString: "wallet_manager_change_wallet_name_without_insert_error"),
                                position: .center)
            return
        }
        //名称相同
        guard walletName != account?.walletName else {
            self.view.makeToast(localLanguage(keyString: "wallet_manager_change_wallet_name_same_error"), position: .center)
            return
        }
        var tempAccount = account
        tempAccount?.changeWalletName(name: walletName)
        let status = DataBaseManager.DBManager.updateWalletName(walletID: (account?.walletID)!, name: walletName)
        guard status == true else {
            self.view.makeToast(localLanguage(keyString: "wallet_manager_change_wallet_name_failed_title"), position: .center)
            return
        }
        self.view.makeToast(localLanguage(keyString: "wallet_manager_change_wallet_name_success_title"), duration: ToastManager.shared.duration, position: .center, title: nil, image: nil, style: ToastManager.shared.style, completion: { [weak self](bool) in
            if let action = self?.actionClosure {
                action(.update, tempAccount!)
            }
            self?.navigationController?.popViewController(animated: true)
        })
    }
}
extension WalletChangeNameViewController: WalletChangeNameViewDelegate {
    func changeNameButtonClickMethod(button: UIButton) {
        if button.tag == 10 {
            self.changeWalletName()
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
}
