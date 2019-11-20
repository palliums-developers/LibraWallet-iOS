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
    typealias nextActionClosure = (ControllerAction, AddressManagerModelAddress) -> Void
    var actionClosure: nextActionClosure?
    deinit {
        print("AddAddressViewController销毁了")
    }
    var myContext = 0
}
extension AddAddressViewController {
    //MARK: - KVO
    func initKVO() {
//        dataModel.addObserver(self, forKeyPath: "dataDic", options: NSKeyValueObservingOptions.new, context: &myContext)
    }
//    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?)  {
//        guard context == &myContext else {
//            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
//            return
//        }
//        guard (change?[NSKeyValueChangeKey.newKey]) != nil else {
//            return
//        }
//        guard let jsonData = (object! as AnyObject).value(forKey: "dataDic") as? NSDictionary else {
//            return
//        }
//        if let error = jsonData.value(forKey: "error") as? HKWalletError {
//            if error.localizedDescription == HKWalletError.WalletRequestError(reason: .networkInvalid).localizedDescription {
//                // 网络无法访问
//                print(error.localizedDescription)
//            } else if error.localizedDescription == HKWalletError.WalletRequestError(reason: .accessTokenInvalid).localizedDescription {
//                // 授权许可过期
//                print(error.localizedDescription)
//            } else if error.localizedDescription == HKWalletError.WalletRequestError(reason: .walletVersionTooOld).localizedDescription {
//                // 版本太久
//                print(error.localizedDescription)
//            } else if error.localizedDescription == HKWalletError.WalletRequestError(reason: .parseJsonError).localizedDescription {
//                // 解析失败
//                print(error.localizedDescription)
//            } else if error.localizedDescription == HKWalletError.WalletRequestError(reason: .dataEmpty).localizedDescription {
//                print(error.localizedDescription)
//                // 数据为空
//            }
//            self.view.hideToastActivity()
//            showAlert(view: self.view, content: error.localizedDescription)
//            return
//        }
//        let type = jsonData.value(forKey: "type") as! String
//        if type == "AddAddress" {
//            if let action = self.actionClosure {
//                let model = AddressManagerModelAddress.init(address: self.detailView.addressTextField.text!, remark: self.detailView.remarksTextField.text ?? "")
//                action(.add, model)
//            }
//            self.navigationController?.popViewController(animated: true)
//        }
//        self.view.hideToastActivity()
//    }
}
extension AddAddressViewController: AddAddressViewDelegate {
    func confirmAddAddress(address: String, remarks: String, type: String) {
        self.dataModel.addWithdrawAddress(address: address, remarks: remarks, type: type)
    }
    
    func showTypeSelecter() {
        let alert = UIAlertController.init(title: "类型", message: "请选择地址类型", preferredStyle: .actionSheet)
        let violasAction = UIAlertAction.init(title: "Violas", style: .default) { (UIAlertAction) in
            self.detailView.typeButton.setTitle("Violas", for: UIControl.State.normal)
        }
        let libraAction = UIAlertAction.init(title: "Libra", style: .default) { (UIAlertAction) in
            self.detailView.typeButton.setTitle("Libra", for: UIControl.State.normal)

        }
        let btcAction = UIAlertAction.init(title: "BTC", style: .default) { (UIAlertAction) in
            self.detailView.typeButton.setTitle("BTC", for: UIControl.State.normal)

        }
        let cancelAction = UIAlertAction.init(title: "取消", style: .cancel) { (UIAlertAction) in
            
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
    
    func confirmAddress() {
        guard let address = self.detailView.addressTextField.text else {
//            self.view.makeToast(HKWalletError.WalletWithdrawError(reason: .addressInvalid).localizedDescription,
//                                position: .center)
            return
        }

        guard address.isEmpty == false else {
//            self.view.makeToast(HKWalletError.WalletWithdrawError(reason: .addressEmpty).localizedDescription,
//                                position: .center)
            return
        }
//        guard isValidBTCAddres(address: address) == true else {
////            self.view.makeToast(HKWalletError.WalletWithdrawError(reason: .addressInvalid).localizedDescription,
////                                position: .center)
//            let alert = UIAlertController.init(title: localLanguage(keyString: "wallet_withdraw_address_alert_title"), message: HKWalletError.WalletWithdrawAddressError(reason: .addressLimitError).localizedDescription, preferredStyle: UIAlertController.Style.alert)
//            let action = UIAlertAction.init(title: localLanguage(keyString: "wallet_withdraw_address_alert_confirm_button_title"), style: UIAlertAction.Style.default) { (UIAlertAction) in
//            }
//            alert.addAction(action)
//            self.present(alert, animated: true, completion: nil)
//            return
//        }
//        self.view.makeToastActivity(.center)
//        self.dataModel.addWithdrawAddress(uid: WalletData.wallet.walletUID!, address: address, remarks: self.detailView.remarksTextField.text ?? "")
        self.dataModel.addWithdrawAddress(address: address, remarks: "test", type: "Libra")
    }
}
