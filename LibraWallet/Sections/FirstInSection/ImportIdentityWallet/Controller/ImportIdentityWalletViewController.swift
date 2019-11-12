//
//  ImportIdentityWalletViewController.swift
//  PalliumsWallet
//
//  Created by palliums on 2019/5/30.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit
import Toast_Swift
class ImportIdentityWalletViewController: BaseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.title = localLanguage(keyString: "wallet_wallet_manager_import_new_wallet_navigationbar_title")
        self.view.addSubview(detailView)
        self.initKVO()
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
    var mnemonicArray: [String]?
    //懒加载子View
    private lazy var detailView : ImportIdentityWalletView = {
        let view = ImportIdentityWalletView.init()
        view.delegate = self
        return view
    }()
    private lazy var dataModel: ImportIdentityWalletModel = {
        let model = ImportIdentityWalletModel.init()
        return model
    }()
    var myContext = 0
    deinit {
        print("ImportIdentityWalletViewController销毁了")
    }
}
extension ImportIdentityWalletViewController: ImportIdentityWalletViewDelegate {
    func confirmImportWallet(walletName: String, password: String, mnemonic: [String]) {
        self.detailView.toastView.show()
        dataModel.importWallet(walletName: walletName, password: password, mnemonic: mnemonic)
    }
}
extension ImportIdentityWalletViewController {
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
            self.detailView.toastView.hide()
            self.view.makeToast(error.localizedDescription,
                                position: .center)
            return
        }
        let type = jsonData.value(forKey: "type") as! String
        self.detailView.toastView.hide()
        if type == "ImportWallet" {
            self.view.makeToast("导入成功", duration: 0.5, position: .center, title: nil, image: nil, style: ToastManager.shared.style, completion: { (bool) in
                let tabbar = BaseTabBarViewController.init()
                UIApplication.shared.keyWindow?.rootViewController = tabbar
                UIApplication.shared.keyWindow?.makeKeyAndVisible()
            })
        }
    }
}
