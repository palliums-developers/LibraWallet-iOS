//
//  AddAddressViewController.swift
//  HKWallet
//
//  Created by palliums on 2019/7/25.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit

class AddAddressViewController: BaseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // 初始化本地配置
        self.setBaseControlllerConfig()
        // 设置标题
        self.title = localLanguage(keyString: "wallet_address_add_navigation_title")
        // 加载子View
        self.view.addSubview(detailView)
        // 初始化KVO
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
    //网络请求、数据模型
    lazy var dataModel: AddAddressModel = {
        let model = AddAddressModel.init()
        return model
    }()
    //子View
    private lazy var detailView : AddAddressView = {
        let view = AddAddressView.init()
        view.delegate = self
        return view
    }()
    typealias nextActionClosure = (ControllerAction, AddressModel) -> Void
    var actionClosure: nextActionClosure?
    deinit {
        print("AddAddressViewController销毁了")
    }
    var myContext = 0
}
extension AddAddressViewController {
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
            if error.localizedDescription == LibraWalletError.WalletRequest(reason: .networkInvalid).localizedDescription {
                // 网络无法访问
                print(error.localizedDescription)
            } else if error.localizedDescription == LibraWalletError.WalletRequest(reason: .walletVersionTooOld).localizedDescription {
                // 版本太久
                print(error.localizedDescription)
            } else if error.localizedDescription == LibraWalletError.WalletRequest(reason: .parseJsonError).localizedDescription {
                // 解析失败
                print(error.localizedDescription)
            } else if error.localizedDescription == LibraWalletError.WalletRequest(reason: .dataEmpty).localizedDescription {
                print(error.localizedDescription)
                // 数据为空
            } else if error.localizedDescription == LibraWalletError.WalletRequest(reason: .dataCodeInvalid).localizedDescription {
                print(error.localizedDescription)
                // 数据状态异常
            }
            self.detailView.hideToastActivity()
            return
        }
        let type = jsonData.value(forKey: "type") as! String
        if type == "AddAddress" {
            if let tempData = jsonData.value(forKey: "data") as? AddressModel {
                if let action = self.actionClosure {
                    action(.add, tempData)
                }
                self.navigationController?.popViewController(animated: true)
            }
        }
        self.view.hideToastActivity()
    }
}
extension AddAddressViewController: AddAddressViewDelegate {
    func confirmAddAddress(address: String, remarks: String, type: String) {
        self.view.makeToastActivity(.center)
        self.dataModel.addWithdrawAddress(address: address, remarks: remarks, type: type)
    }
    func showTypeSelecter() {
        let alert = UIAlertController.init(title: localLanguage(keyString: "wallet_address_add_type_title"), message: localLanguage(keyString: "wallet_address_add_type_action_alert_content"), preferredStyle: .actionSheet)
        let violasAction = UIAlertAction.init(title: "Violas", style: .default) { (UIAlertAction) in
            self.detailView.typeButton.setTitle("Violas", for: UIControl.State.normal)
        }
        let libraAction = UIAlertAction.init(title: "Libra", style: .default) { (UIAlertAction) in
            self.detailView.typeButton.setTitle("Libra", for: UIControl.State.normal)
        }
        let btcAction = UIAlertAction.init(title: "BTC", style: .default) { (UIAlertAction) in
            self.detailView.typeButton.setTitle("BTC", for: UIControl.State.normal)
        }
        let cancelAction = UIAlertAction.init(title: localLanguage(keyString: "wallet_address_add_type_action_alert_cancel_button_title"), style: .cancel) { (UIAlertAction) in
        }
        alert.addAction(violasAction)
        alert.addAction(libraAction)
        alert.addAction(btcAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func scanAddress() {
        let vc = ScanViewController()
        vc.actionClosure = { address in
           self.detailView.addressTextField.text = address
       }
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
