//
//  ViolasTransferViewController.swift
//  LibraWallet
//
//  Created by palliums on 2019/11/14.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit

class ViolasTransferViewController: BaseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // 初始化本地配置
        self.setBaseControlllerConfig()
        
//        self.title = (self.wallet?.walletType?.description ?? "") + localLanguage(keyString: "wallet_transfer_navigation_title")
        self.view.addSubview(detailView)
        self.detailView.wallet = self.wallet
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
    private lazy var detailView : ViolasTransferView = {
        let view = ViolasTransferView.init()
        view.delegate = self
        return view
    }()
    lazy var dataModel: ViolasTransferModel = {
        let model = ViolasTransferModel.init()
        return model
    }()
    typealias successClosure = () -> Void
    var actionClosure: successClosure?
    var myContext = 0
    var wallet: LibraWalletManager?
    var sendViolasTokenState: Bool?
    var contract: String?
    var address: String? {
        didSet {
           self.detailView.addressTextField.text = address
        }
    }
}
extension ViolasTransferViewController {
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
            } else if error.localizedDescription == LibraWalletError.WalletRequest(reason: .walletNotExist).localizedDescription {
                // 钱包不存在
                print(error.localizedDescription)
                let vc = WalletCreateViewController()
                let navi = UINavigationController.init(rootViewController: vc)
                self.present(navi, animated: true, completion: nil)
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
                // 数据返回状态异常
            }
            self.detailView.toastView?.hide()
            self.view.makeToast(error.localizedDescription, position: .center)
            return
        }
        let type = jsonData.value(forKey: "type") as! String
        if type == "SendViolasTransaction" {
            self.detailView.toastView?.hide()
            self.view.makeToast(localLanguage(keyString: "wallet_transfer_success_alert"), position: .center)
            if let action = self.actionClosure {
                action()
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
}
extension ViolasTransferViewController: ViolasTransferViewDelegate {
    func scanAddressQRcode() {
        let vc = ScanViewController()
        vc.actionClosure = { address in
            if address.hasPrefix("violas:") {
                let tempAddress = address.replacingOccurrences(of: "violas:", with: "")
                guard ViolasManager().isValidViolasAddress(address: tempAddress) else {
                    self.view.makeToast("不是有效的Violas地址", position: .center)
                    return
                }
                self.detailView.addressTextField.text = tempAddress
            } else {
                self.view.makeToast("不是有效的Violas地址", position: .center)
            }
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func chooseAddress() {
        let vc = AddressManagerViewController()
        vc.actionClosure = { address in
            self.detailView.addressTextField.text = address
        }
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func confirmTransfer(amount: Double, address: String, fee: Double) {
        let alertContr = UIAlertController(title: localLanguage(keyString: "wallet_type_in_password_title"), message: localLanguage(keyString: "wallet_type_in_password_content"), preferredStyle: .alert)
        alertContr.addTextField {
            (textField: UITextField!) -> Void in
            textField.placeholder = localLanguage(keyString: "wallet_type_in_password_textfield_placeholder")
            textField.tintColor = DefaultGreenColor
            textField.isSecureTextEntry = true
        }
        alertContr.addAction(UIAlertAction(title: localLanguage(keyString: "wallet_type_in_password_confirm_button_title"), style: .default) { [weak self]
            clickHandler in
            let password = alertContr.textFields!.first! as UITextField
            NSLog("password:\(password.text!)")
            do {
                let state = try LibraWalletManager.shared.isValidPaymentPassword(walletRootAddress: (self?.wallet?.walletRootAddress)!, password: password.text!)
                guard state == true else {
                    self?.view.makeToast("密码不正确", position: .center)
                    return
                }
                self?.detailView.toastView?.show()
                let menmonic = try LibraWalletManager.shared.getMnemonicFromKeychain(walletRootAddress: (self?.wallet?.walletRootAddress)!)
                
                if self?.sendViolasTokenState == false {
                    self?.dataModel.sendViolasTransaction(sendAddress: (self?.wallet?.walletAddress)!, receiveAddress: address, amount: amount, fee: fee, mnemonic: menmonic)
                } else {
                    self?.dataModel.sendViolasTokenTransaction(sendAddress: (self?.wallet?.walletAddress)!, receiveAddress: address, amount: amount, fee: fee, mnemonic: menmonic, contact: self?.contract ?? "")
                }
            } catch {
                self?.detailView.toastView?.hide()
            }
        })
        alertContr.addAction(UIAlertAction(title: localLanguage(keyString: "wallet_type_in_password_cancel_button_title"), style: .cancel){
            clickHandler in
            NSLog("点击了取消")
            })
        self.present(alertContr, animated: true, completion: nil)
    }
    
}
