//
//  CreateWalletViewController.swift
//  LibraWallet
//
//  Created by palliums on 2019/10/18.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit
import Toast_Swift
class CreateWalletViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // 初始化本地配置
        self.setBaseControlllerConfig()
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
    private lazy var detailView : CreateWalletView = {
        let view = CreateWalletView.init()
        view.delegate = self
        return view
    }()
    private lazy var dataModel: CreateWalletModel = {
        let model = CreateWalletModel.init()
        return model
    }()
    var myContext = 0

}
extension CreateWalletViewController: CreateWalletViewDelegate {
    func comfirmCreateWallet(walletName: String, password: String) {
        self.detailView.toastView?.show()
        dataModel.createWallet(walletName: walletName, password: password)
    }
}
extension CreateWalletViewController {
    //MARK: - KVO
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
            if let tempData = jsonData.value(forKey: "data") as? [String] {
                self.view.makeToast("创建成功", duration: 0.5, position: .center, title: nil, image: nil, style: ToastManager.shared.style, completion: { (bool) in
                    let vc = BackupWarningViewController()
                    vc.FirstInApp = true
                    vc.mnemonicArray = tempData
                    self.navigationController?.pushViewController(vc, animated: true)
                })
            }
        }
    }
}
