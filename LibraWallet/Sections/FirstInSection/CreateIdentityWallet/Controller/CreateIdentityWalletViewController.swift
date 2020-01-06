//
//  CreateIdentityWalletViewController.swift
//  LibraWallet
//
//  Created by palliums on 2019/10/18.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit
import Toast_Swift
class CreateIdentityWalletViewController: BaseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationWhiteMode()
        self.title = localLanguage(keyString: "wallet_first_in_create_identity_wallet_navigationbar_title")
        // 设置背景色
        self.view.addSubview(detailView)
        self.initKVO()
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        detailView.snp.makeConstraints { (make) in
            make.top.left.right.bottom.equalTo(self.view)
        }
    }
    private lazy var detailView : CreateIdentityWalletView = {
        let view = CreateIdentityWalletView.init()
        view.delegate = self
        return view
    }()
    private lazy var dataModel: CreateIdentityWalletModel = {
        let model = CreateIdentityWalletModel.init()
        return model
    }()
    var myContext = 0
    deinit {
        print("CreateIdentityWalletViewController销毁了")
    }
}
extension CreateIdentityWalletViewController: CreateIdentityWalletViewDelegate {
    func comfirmCreateWallet(walletName: String, password: String) {
        self.detailView.toastView?.show()
        dataModel.createWallet(walletName: walletName, password: password)
    }
}
extension CreateIdentityWalletViewController {
    func initKVO() {
        dataModel.addObserver(self, forKeyPath: "dataDic", options: NSKeyValueObservingOptions.new, context: &myContext)
    }
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?)  {
        
        guard context == &myContext else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }
        guard (change?[NSKeyValueChangeKey.newKey]) != nil else {
            return
        }
        guard let jsonData = (object! as AnyObject).value(forKey: "dataDic") as? NSDictionary else {
            return
        }
        if let error = jsonData.value(forKey: "error") as? LibraWalletError {
            self.detailView.toastView?.hide()
            self.view.makeToast(error.localizedDescription,
                                position: .center)
            return
        }
        let type = jsonData.value(forKey: "type") as! String
        self.detailView.toastView?.hide()
        if type == "CreateWallet" {
            if let tempData = jsonData.value(forKey: "data") as? CreateWalletModel {
                self.view.makeToast(localLanguage(keyString: "wallet_create_wallet_success_title"), duration: 0.5, position: .center, title: nil, image: nil, style: ToastManager.shared.style, completion: { (bool) in
                    let vc = BackupWarningViewController()
                    vc.FirstInApp = true
                    vc.tempWallet = tempData
                    self.navigationController?.pushViewController(vc, animated: true)
                })
            }
        }
    }
}
